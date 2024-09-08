`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 03:12:50 PM
// Design Name: 
// Module Name: seq_ctrl
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
import SPIInterf::*;

/*
Sequensor Control Write packet:
<header:8 bit> <section:4 bit> <data:20 bit>

Sections:
0 - Commands. Data is bitset:
    0 - Enable Seq
1 - Write register(s). Data - write register address, data to write follow
2 - Read register. Data is register address. Read process started after end of this packet.


Read registers:
0. Seq status (bitset)
    0. Seq is running
    1. Seq recording started by trigger
    2. Seq stop is pending
    3. Seq stopped by max Seq run span
1. Seq start ts tick
2. Seq end ts tick
3. Seq start BRAM address
4. Seq end BRAM address
... Repeat 3 & 4 for all available BRAMs

Write registers:
0. Max Seq run span in ticks
1. Seq end postpone in ticks
2. Max Seq run span in ts ticks
3. Seq end postpone in BRAM addresses
... repeat 2 & 3 for all available BRAM
*/

typedef enum {
    SEQ_CMD,
    SEQ_WR_REGS,
    SEQ_RD_REGS
} Seq_ProtSection;

typedef enum {
    RR_STATUS,
    RR_START_TS,
    RR_END_TS,
    RR_START_RAM,  // Duplicated for all BRAMs
    RR_END_RAM,    // Duplicated for all BRAMs
    
    RR_TOTAL
} Seq_ProtRdRegs;    

typedef enum {
    WR_MAX_SPAN_TS,
    WR_DELAY_TS,
    WR_MAX_SPAN_RAM,   // Duplicated for all BRAMs
    WR_DELAY_RAM,      // Duplicated for all BRAMs
    
    WR_TOTAL
} Seq_ProtWrRegs;

typedef struct packed {
    logic enable_seq;
} Seq_ProtCmd;

typedef struct packed {
    logic stopped_by_span_max;
    logic stop_pending;
    logic rec_started;
    logic run;    
} Seq_ProtStatus;    

interface RAMCounter #(parameter RAM_ADDR_SIZE=0);
    logic [RAM_ADDR_SIZE-1:0] ram_addr;
    logic ram_inc_enable;
    
    modport dst(input ram_addr, ram_inc_enable);
    modport src(output ram_addr, ram_inc_enable);
endinterface

module seq_ctrl #(parameter RAM_ADDR_SIZE=1, RAM_TOTAL=1) (
    input wire clk,
    
    AXIStream.master output_data_interf,
    AXIStream.slave input_data_interf,
    
    // Timestamp part. Timestamp implemented inside module and exported outside
    output wire [31:0] ts,
    input wire ts_inc_enable,
    
    // BRAM adress part (used for latching start/end point and for limit/end-delay processing)
    RAMCounter.dst rams[RAM_TOTAL-1:0],
    
    // Start-stop logic
    input wire trigger_start,
    input wire trigger_end,
    output wire run
);

logic [31:0] ts_counter = '0;

logic [31:0] read_regs[RR_TOTAL+RAM_TOTAL*2-3:0];
logic [31:0] write_regs[WR_TOTAL+RAM_TOTAL*2-3:0];

for(genvar i=0; i<RAM_TOTAL; ++i) begin
    `UNUSED(write_regs[WR_MAX_SPAN_RAM+i*2][31:RAM_ADDR_SIZE+1]);
    `UNUSED(write_regs[WR_DELAY_RAM+i*2][31:RAM_ADDR_SIZE+1]);
end

Seq_ProtCmd cmd_on;
Seq_ProtCmd cmd_off;
Seq_ProtStatus status = '0;
 
logic [31:0] lim_ts = '0;
logic [RAM_ADDR_SIZE:0] lim_ram [RAM_TOTAL-1:0] = '{default:0};   // We use ADDR_SIZE (not ADDR_SIZE-1) to enable hold value 1<<ADDR_SIZE (full BRAM) in this counter
logic [31:0] dly_ts = '0;
logic [RAM_ADDR_SIZE:0] dly_ram [RAM_TOTAL-1:0] = '{default:0};

assign read_regs[RR_STATUS] = 32'b0 | status;
assign run = status.run; 
assign ts = ts_counter;

s_ctrl #(RAM_TOTAL) scltr_imp(.clk, .output_data_interf, .input_cmd_interf(input_data_interf), .read_regs, .write_regs, .cmd_on, .cmd_off);

always_ff @(posedge clk)
    if (!status.run) ts_counter <= '0; else
    if (ts_inc_enable) ts_counter <= ts_counter + 1;

function automatic logic is_array_zero(logic [RAM_ADDR_SIZE:0] array [RAM_TOTAL-1:0]);
    for(int i=0; i< RAM_TOTAL; ++i)
        if (array[i] == 0) return 1;
    return 0;
endfunction

wire lim_ts_is_zero = lim_ts == '0;
wire lim_ram_is_zero = is_array_zero(lim_ram);
wire dly_ts_is_zero = dly_ts == '0;
wire dly_ram_is_zero = is_array_zero(dly_ram);

wire stop_seq_by_lim = status.rec_started && (lim_ts_is_zero || lim_ram_is_zero == '0);
wire dly_is_zero = dly_ts_is_zero || dly_ram_is_zero;
wire stop_by_dly = status.stop_pending && dly_is_zero; 
wire imm_stop = status.rec_started && trigger_end && dly_is_zero; 

wire do_start = cmd_on.enable_seq && !status.run;
wire do_trigger_start = status.run && trigger_start; 

always_ff @(posedge clk)
    if (do_start) status.run = 1; else
    if (cmd_off.enable_seq && status.run || stop_seq_by_lim || stop_by_dly || imm_stop) status.run = 0;

always @(posedge clk)
    if (do_start) status.stopped_by_span_max = 0; else
    if (stop_seq_by_lim) status.stopped_by_span_max = 1;

always @(posedge clk)
    if (do_start) status.stop_pending = 0; else
    if (status.rec_started && trigger_end && !dly_is_zero) status.stop_pending = 1; 

always @(posedge clk)
    if (do_start) status.rec_started = 0; else
    if (do_trigger_start) status.rec_started = 1;

always @(posedge clk)
    if (status.stop_pending || !status.run) lim_ts <= write_regs[WR_MAX_SPAN_TS]; else
    if (ts_inc_enable) lim_ts <= lim_ts - 1;
    
for(genvar i=0; i<RAM_TOTAL; ++i) begin
    always @(posedge clk)
        if (status.stop_pending || !status.run) lim_ram[i] <= write_regs[WR_MAX_SPAN_RAM+i*2][RAM_ADDR_SIZE:0]; else
        if (rams[i].ram_inc_enable) lim_ram[i] <= lim_ram[i] - 1;
end        

always @(posedge clk)
    if (!status.stop_pending) dly_ts <= write_regs[WR_DELAY_TS]; else
    if (ts_inc_enable) dly_ts <= dly_ts - 1;

for(genvar i=0; i<RAM_TOTAL; ++i) begin
    always @(posedge clk)
        if (!status.stop_pending) dly_ram[i] <= write_regs[WR_DELAY_RAM+i*2][RAM_ADDR_SIZE:0]; else
        if (rams[i].ram_inc_enable) dly_ram[i] <= dly_ram[i] - 1;
end        
    
always @(posedge clk)
    if (do_trigger_start) read_regs[RR_START_TS] <= ts_counter;
    

for(genvar i=0; i<RAM_TOTAL;++i)   
    always @(posedge clk)
        if (do_trigger_start) read_regs[RR_START_RAM+i*2] <= 0 | rams[i].ram_addr;   
        

always @(posedge clk)
    if (stop_seq_by_lim || status.rec_started && trigger_end) begin
        read_regs[RR_END_TS] <= ts_counter;
    end 

for(genvar i=0; i<RAM_TOTAL;++i)   
    always @(posedge clk)
        if (stop_seq_by_lim || status.rec_started && trigger_end) begin
            read_regs[RR_END_RAM+i*2] <= 0 | rams[i].ram_addr;   
        end 

endmodule

module s_ctrl #(parameter RAM_TOTAL=1) (
    input wire clk,
    
    AXIStream.master output_data_interf,
    AXIStream.slave input_cmd_interf,
    
    // Registers read/write
    input wire [31:0] read_regs[RR_TOTAL+RAM_TOTAL*2-3:0],  // Read only registers. Implemented outside of module, seeding through post 
    output wire [31:0] write_regs[WR_TOTAL+RAM_TOTAL*2-3:0],    // Write only registers. Implemented inside module, sourcing through post
    
    output wire Seq_ProtCmd cmd_on, // Command (pulse)   
    output wire Seq_ProtCmd cmd_off // Command (pulse)   
);

localparam RRT = RR_TOTAL+RAM_TOTAL*2-2;
localparam WRT = WR_TOTAL+RAM_TOTAL*2-2;

logic [23:0] ram_addr;   // Address to write
logic [31:0] ram_data;    // Data to write
logic ram_wr_en;         // Write strobe

bram_reciever #(1) inp_cmd(.clk, .interf(input_cmd_interf), .ctrl_ready_to_process('1), .addr_wr_stb(), .*);   

wire [3:0] section = ram_addr[23 -: 4];
logic [31:0] write_regs_img[WRT-1:0] = '{default: '0};
assign write_regs = write_regs_img;

wire cmd_stb = ram_wr_en && section == SEQ_CMD; 
assign cmd_on = cmd_stb ? ram_data : '0;
assign cmd_off = cmd_stb ? ~ram_data : '0;

always_ff @(posedge clk)
    if (ram_wr_en && section == SEQ_WR_REGS) write_regs_img[ram_addr[$clog2(WRT):0]] <= ram_data;

bram_sender #(DST_SEQ, 1) out_data( 
    .clk, .interf(output_data_interf),
    
    // BRAM interface - not used
    .ram_data('0), .ram_rd_en(), .ram_addr(), .ctrl_start_address('0), .ctr_size('0), .ctrl_start('0), .header('0), .busy(),
    
    // Data sender part
    .oob_header({DST_SEQ, ram_addr}),   // Header to send
    .oob_data(read_regs[ram_addr[$clog2(RRT):0]]), // Data word to send
    .oob_send(ram_wr_en && section == SEQ_RD_REGS)
);
         
endmodule

