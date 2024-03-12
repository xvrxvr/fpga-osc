`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2024 05:00:21 PM
// Design Name: 
// Module Name: generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

interface LoopMgr #(parameter RAM_ADDR_SIZE=0) (
    input wire clk,
    input wire enable,
    
    // Runtime data
    input wire [RAM_ADDR_SIZE-1:0] address, // Current address of main BRAM to match to
    input wire reset,
    input wire [1:0] cfg_address, // Config data address
    input wire [31:0] cfg_data // Config data to write
); 

  wire address_match;  // signal that 'address' equal to this module address
  wire loop_cnt_done;  // signal that loop count decremented to zero
  wire [RAM_ADDR_SIZE-1:0] target_address; // Where to continue (if address_match && loop_cnt_done is 1)  
    
  // Runtime control
  wire reload_loop_counter;     // Reload loop conter with config value
  wire decrement_loop_counter; // Decrement loop counter
    
  // Write data
  wire cfg_wr_stb;  // Config data write strobe
  
  modport mgr(
    input clk, enable, address, reload_loop_counter, decrement_loop_counter, cfg_address, cfg_data, cfg_wr_stb, reset,
    output address_match, loop_cnt_done, target_address
  );
endinterface

typedef struct packed {
    logic reset;    // Perform reset of Loop managers and Generator
    logic autorun;  // Run Generator right on system start, do not wait for Trigger 
} GeneratorConfig;

typedef enum logic[3:0] {
    GS_Config,
    GS_LoopMgr1,
    GS_LoopMgr2,
    GS_LoopMgr3,
    GS_LoopMgr4,
    GS_RAM
} GeneratorSections;

typedef enum {
    LMC_Config,
    LMC_EndOfLoopAddress,
    LMC_StartOfLoopAddress,
    LMC_LoopCounter
} LoopMgrCfg;

module generator #(parameter RAM_ADDR_SIZE=10, DATA_SIZE=32) (
    input wire clk,
    
    output wire [DATA_SIZE-1:0] data,
    
    AXIStream.slave input_cmd_interf,
    
    // Start-stop logic
    input wire trigger_start,
    input wire run
);

typedef struct packed {
    logic [31:0] delay;
    logic [DATA_SIZE-1:0] data;
} Data;

logic running = '0; // Generator in running state
logic [31:0] ts_delay = '0; // Now many ticks next stage will be delayed
logic suspend = '0; // Suspend Gen sequencer. used to ramp-up inital state before running Gen (it starts, got for 2 ticks when BRAM pipline filles and suspended until Run time hit) 
logic [1:0] mem_wr_filled = '0; // Scale of filled BRAM pipeline
GeneratorConfig generator_config ='0; // Config (Write register $0)

// Config write interface
RegRAMPayload cfg_address;
logic [31:0] cfg_data;
logic cfg_wr_stb;

wire [3:0] cfg_section = cfg_address.section;

///// Main memory

// Write interface
logic mem_wr_en;
logic [RAM_ADDR_SIZE-1:0] mem_wr_addr;
Data mem_wr_data;

// Read interface
logic mem_rd_en;
logic [RAM_ADDR_SIZE-1:0] mem_rd_addr;
Data mem_rd_data2;

//// BRAM /////////////////////////////////////////////////////////

bram #(Data, RAM_ADDR_SIZE) ram(
    .clk,
    .read_addr(mem_rd_addr),
    .write_addr(mem_wr_addr),
    .write_data(mem_wr_data),
    .read_data(mem_rd_data2),
    .read_en(mem_rd_en),
    .write_en(mem_wr_en)
);
///////////////////////////////////////////////////////////////////
assign data = mem_rd_data2.data;

// Loop managers
LoopMgr #(RAM_ADDR_SIZE) loop_mgr_interf [3:0] (.clk, .enable(running && !suspend), .address(mem_rd_addr), .reset(!running || generator_config.reset), .cfg_address(cfg_address.address[1:0]), .cfg_data);

// Loop decoder. ROM with data:
//  Address: {'addr_match[3:0]', 'loop_end[3:0]}
//  Data: DecoderAction
typedef struct packed {
    logic [3:0] reload_loop_counter;
    logic [3:0] decrement_loop_counter;
    logic do_jump;
    logic [1:0] jump_index; 
} DecoderAction;
typedef DecoderAction DecoderActionArray [255:0];
DecoderActionArray loop_decoder = evaluate_loop_decoder();

wire [7:0] ld_index = {
        loop_mgr_interf[3].address_match,
        loop_mgr_interf[2].address_match,
        loop_mgr_interf[1].address_match,
        loop_mgr_interf[0].address_match,
        loop_mgr_interf[3].loop_cnt_done,
        loop_mgr_interf[2].loop_cnt_done,
        loop_mgr_interf[1].loop_cnt_done,
        loop_mgr_interf[0].loop_cnt_done
};

DecoderAction action;
assign action = loop_decoder[ld_index];

for(genvar i=0; i<4; ++i) begin
    loop_mgr #(RAM_ADDR_SIZE) lm(loop_mgr_interf[i]);
    assign loop_mgr_interf[i].cfg_wr_stb = cfg_section == (GS_LoopMgr1+i) && cfg_wr_stb;
    assign loop_mgr_interf[i].reload_loop_counter = action.reload_loop_counter[i];
    assign loop_mgr_interf[i].decrement_loop_counter = action.decrement_loop_counter[i];
end

// BRAM address counter
assign mem_rd_en = !suspend && running && ts_delay == 0;
always_ff @(posedge clk)
    if (mem_rd_en) begin // Count
        if (action.do_jump) begin
            case(action.jump_index)
                0: mem_rd_addr <= loop_mgr_interf[0].target_address;
                1: mem_rd_addr <= loop_mgr_interf[1].target_address;
                2: mem_rd_addr <= loop_mgr_interf[2].target_address;
                3: mem_rd_addr <= loop_mgr_interf[3].target_address;
            endcase
        end else begin
            mem_rd_addr <= mem_rd_addr + 1;
        end 
    end

// Fill ts_delay counter
always_ff @(posedge clk)
    if (generator_config.reset) ts_delay <= '0; else 
    if (mem_wr_filled[1] && mem_rd_en) begin // We got new word from BRAM
        ts_delay <= mem_rd_data2.delay;        
    end

// Miscalenious logic
always_ff @(posedge clk)
    if (generator_config.reset || !run) running <= '0; else
    if (generator_config.autorun || trigger_start) running <= '1;

always_ff @(posedge clk)
    if (generator_config.reset || !running) mem_wr_filled <= '0; else
    if (mem_rd_en) mem_wr_filled <= (mem_wr_filled << 1) | 1'b1; 

always_ff @(posedge clk)
    if (generator_config.reset || !run || running) suspend <= '0; else
    if (mem_wr_filled[1]) suspend <= '1;

always_ff @(posedge clk)
    if (cfg_wr_stb && cfg_section == GS_Config) generator_config <= cfg_data; 

/// Config processing
bram_reciever #(RAM_ADDR_SIZE) inp_cmd(
    .clk, 
    .interf(input_cmd_interf), 
    .ctrl_ready_to_process(1'b1),
    
    .ram_addr(cfg_address),
    .ram_data(cfg_data),
    .ram_wr_en(cfg_wr_stb),
    .addr_wr_stb()
);   
// BRAM writes
logic [DATA_SIZE-1:0] data_buffer = '0;

always_ff @(posedge clk)
    if (cfg_wr_stb && cfg_section == GS_RAM && ~cfg_address[0]) data_buffer <= cfg_data;    

assign mem_wr_en = cfg_wr_stb && cfg_section == GS_RAM && cfg_address[0];
assign mem_wr_addr = cfg_address >> 1;
assign mem_wr_data.delay = cfg_data;
assign mem_wr_data.data = data_buffer;

///////////////// Aux functions /////////////////////////////
function automatic DecoderActionArray evaluate_loop_decoder;
    DecoderActionArray result = '{default:'0};
    for(integer addr_match=0; addr_match < 16; ++addr_match)
        for(integer loop_done=0; loop_done < 16; ++loop_done) begin
            DecoderAction data = '{default: 0};
            for(integer i=0; i<3; ++i) begin
                if (addr_match[i]) begin // We got match - do jump or pass through
                    if (loop_done[i]) begin // Reload loop counter and continue
                        data.reload_loop_counter = '1;                        
                    end else begin // Decrement loop counter and go to loop start
                        data.decrement_loop_counter = '1;
                        data.do_jump = '1;
                        data.jump_index = i;
                        break;
                    end
                end
            end
            result[{addr_match[3:0], loop_done[3:0]}] = data;
        end
    return result;
endfunction

endmodule

module loop_mgr #(parameter RAM_ADDR_SIZE=10) (LoopMgr.mgr interf);
// Config
logic [31:0] cfg_loop_counter = '0;
logic cfg_unconditional = '1;
logic cfg_enable = '1;
logic [RAM_ADDR_SIZE-1:0] cfg_target = '0;
logic [RAM_ADDR_SIZE-1:0] cfg_address = '0;

// Runtime
logic [31:0] loop_counter = '0;

assign interf.address_match = cfg_enable && interf.address == cfg_address;
assign interf.loop_cnt_done = cfg_enable && loop_counter == 0 && !cfg_unconditional;
assign interf.target_address = cfg_target;

// loop_counter handling
always_ff @(posedge interf.clk)
    if (interf.reset) loop_counter <= cfg_loop_counter; else
    if (interf.enable && cfg_enable && !cfg_unconditional) begin
        if (interf.reload_loop_counter) loop_counter <= cfg_loop_counter; else
        if (interf.decrement_loop_counter) loop_counter <= loop_counter - 1;
    end else if (interf.cfg_wr_stb && interf.cfg_address == 2) begin
        loop_counter <= interf.cfg_data;
    end 

// config handling
always_ff @(posedge interf.clk)
    if (interf.cfg_wr_stb)
        case(interf.cfg_address)
            LMC_Config: {cfg_unconditional, cfg_enable} <= interf.cfg_data;
            LMC_EndOfLoopAddress: cfg_target <= interf.cfg_data;
            LMC_StartOfLoopAddress: cfg_address <= interf.cfg_data;
            LMC_LoopCounter: cfg_loop_counter <= interf.cfg_data;
        endcase

endmodule
