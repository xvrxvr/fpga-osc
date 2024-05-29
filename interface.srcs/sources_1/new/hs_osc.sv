`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2024 05:48:22 PM
// Design Name: 
// Module Name: hs_osc
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

`include "utils.vh"

import SPIInterf::*;

// OSC data stored 3 points in word. High 2 bits (SamplaTag) contains number of samples, stored in word.
// SamplaTag of 0 denotes 3 value from decimator, stored in one word: min/max/avg

typedef enum {
    HSOWR_Control,
    HSOWR_RAM_ReadSize, // Register with size of BRAM area to read by HSOWR_BRAM_Read request 
    HSOWR_RAM_Read, // Read request. Data field is start address
    HSOWR_T1_Setup,
    HSOWR_T2_Setup,
    HSOWR_T3_Setup,
    HSOWR_T4_Setup,
    HSOWR_HW_Setup, // From here and to end - interface to OSC hardware (TBD)
    
    HSOWR_Total
} HiSOscWriteReagister;

typedef struct packed {
    logic [3:0] decimation; // Frequency divider (1 << decimation). ADC will run on 100MHz, dividing performed by averedging samples. Min effective sampling is ~3KHz
    logic shifted_repr;     // ADC use shifted-zero representation (ADC value = V + 10'b10000000000)
    logic signed_repr;      // Set to 1 if ADC value is signed
    logic use_tripple_dec;  // Store 3 value from decimator: min/max/avg (value tag will be 0). If 0 store only avg
} HiSOscControl;

typedef struct packed {
    logic [9:0] min_value;  // Low value of trigger (hysterises)
    logic [9:0] max_value;  // High value of trigger (hysterises)
    logic tr_up;            // Trigger on cross 0 -> hi
    logic tr_down;          // Trigger on cross hi -> 0
} HiSOscTrigger;

typedef enum logic [1:0] {
    HSOST_Tripple,
    HSOST_1Samp,
    HSOST_2Samp,
    HSOST_3Samp   
} HiSOscSampleTag;

typedef struct packed {
    HiSOscSampleTag sample_tag;
    logic [9:0] word2;
    logic [9:0] word1;
    logic [9:0] word0;
} HiSOscWord;

module hs_osc #(parameter RAM_ADDR_SIZE=10)(
    input wire clk,
    
    input wire [9:0] adc_data,
    input wire adc_stb,
    
    output wire [3:0] ext_trigger,
    
    AXIStream.master output_data_interf,
    AXIStream.slave input_cmd_interf,
    
    // Interface to SeqCtrl
    // BRAM adress part (used for latching start/end point and for limit/end-delay processing)
    RAMCounter.src ram_counter,
    
    // Start-stop logic
    input wire run
);
HiSOscControl setup;

// ADC data in 2s complement (or unsigned) format
wire  [9:0] data = {adc_data[9] ^ setup.shifted_repr, adc_data[8:0]};

// BRAM part
RegRAMPayload ram_rd_addr;
logic [RAM_ADDR_SIZE-1:0] ram_wr_addr;
HiSOscWord ram_wr_data;
HiSOscWord ram_rd_data;
logic ram_rd_en;
logic ram_wr_en;

bram #(HiSOscWord, RAM_ADDR_SIZE) ram(
    .clk,
    .read_addr(ram_rd_addr.address[RAM_ADDR_SIZE-1:0]),
    .write_addr(ram_wr_addr),
    .write_data(ram_wr_data),
    .read_data(ram_rd_data),
    .read_en(ram_rd_en),
    .write_en(ram_wr_en)
);

///////////
assign ram_counter.ram_addr = ram_wr_addr;
assign ram_counter.ram_inc_enable = ram_wr_en;
///////////

// Decimator
HiSOscWord decimator_data;
logic decimator_stb;
 
hso_decimator decimator(
    .clk, .reset(!run), 
    .adc_data(data), .adc_stb,
    .out_data(decimator_data), .out_stb(decimator_stb),
    .setup
);
///////////////

// Active Data - raw ADC or Decimator
wire [9:0] active_data = setup.decimation == 0 ? data : decimator_data.word0;
wire active_stb = setup.decimation == 0 ? adc_stb : decimator_stb;
///////////////

// Data accumulator (3 to 1)
HiSOscWord acc_data = '0;
wire scc_data_word3_stb = acc_data.sample_tag == HSOST_3Samp && active_stb;
`DLY(acc_data_stb, scc_data_word3_stb);

always_ff @(posedge clk)
    if (!run) acc_data <= '0; else 
    if (active_stb) begin
        unique case(acc_data.sample_tag)
            HSOST_Tripple, HSOST_3Samp: begin acc_data.word0 <= active_data; acc_data.sample_tag <= HSOST_1Samp; end
            HSOST_1Samp: begin acc_data.word1 <= active_data; acc_data.sample_tag <= HSOST_2Samp; end
            HSOST_2Samp: begin acc_data.word2 <= active_data; acc_data.sample_tag <= HSOST_3Samp; end
        endcase
    end
///////////////////

// BRAM data write mux and counter
wire use_raw_decimator_data = setup.decimation != 0 && setup.use_tripple_dec;
assign ram_wr_data = use_raw_decimator_data ? decimator_data : acc_data;
assign ram_wr_en = use_raw_decimator_data ? decimator_stb : acc_data_stb;

always_ff @(posedge clk)
    if (!run) ram_wr_addr <= '0; else
    if (ram_wr_en) ram_wr_addr <= ram_wr_addr + 1;
//////////////////////
// Config and BRAM access
logic cfg_addr_phase_stb;
logic [23:0] cfg_address;
`DLY(cfg_stb, cfg_addr_phase_stb);
wire [3:0] cfg_register = cfg_address[23 -: 4];
wire [19:0] cfg_data = cfg_address[19:0];

logic ram_sender_busy;
logic [19:0] ram_send_size = '0;

// CMD reciever
bram_reciever #(1) cmd_recvr (
    .clk, .interf(input_cmd_interf),

    // BRAM (write interface)
    .ram_addr(cfg_address),   // Address to write
    .addr_wr_stb(cfg_addr_phase_stb),        // Set with 'bram_addr' setup
    .ram_data(),    // Data to write
    .ram_wr_en(),         // Write strobe

    // Control
    .ctrl_ready_to_process(!ram_sender_busy)   // Set to 0 to suspend data processing from 'interf'
); 

// Some control registers
always_ff @(posedge clk) if (cfg_register == HSOWR_Control && cfg_stb) setup <= cfg_data;
always_ff @(posedge clk) if (cfg_register == HSOWR_RAM_ReadSize && cfg_stb) ram_send_size <= cfg_data;

// BRAM sender
bram_sender #(.TDEST(DST_OSC), .RAM_ADDR_SIZE(RAM_ADDR_SIZE)) bram_sender_imp (
    .clk, .interf(output_data_interf),

    // BRAM interface (2 clock delay BRAM read assumed)
    .ram_data(ram_rd_data), // data read from BRAM 
    .ram_rd_en(ram_rd_en), // Read strobe
    .ram_addr(ram_rd_addr), // Address to read.

    // Control
    .ctrl_start_address(cfg_data), // BRAM start address to send contents
    .ctr_size(ram_send_size), // Size of BRAM data chunk to send
    .ctrl_start(cfg_stb && cfg_register == HSOWR_RAM_Read),  // Pulse to 1 to start BRAM data sending process.  Ignored if module currently busy
    .header(CmdPkt'{dest: DST_OSC, payload: cfg_address}),
    .busy(ram_sender_busy),   // Set to 1 while module busy sending BRAM contents.

    // OOB data send. - not used
    .oob_header('0),   // Header to send
    .oob_data('0), // Data word to send
    .oob_send('0) // Pulse to 1 to start transaction. Ignored if module currently busy
); 
//////////////////////
// Triggers
hso_triger t1(
    .clk, .adc_data(active_data), .adc_stb(active_stb), .reset(!run), .cfg_data,
    .triger_out(ext_trigger[0]), .cfg_stb(cfg_stb && cfg_register == HSOWR_T1_Setup)
);

hso_triger t2(
    .clk, .adc_data(active_data), .adc_stb(active_stb), .reset(!run), .cfg_data,
    .triger_out(ext_trigger[1]), .cfg_stb(cfg_stb && cfg_register == HSOWR_T2_Setup)
);

hso_triger t3(
    .clk, .adc_data(active_data), .adc_stb(active_stb), .reset(!run), .cfg_data,
    .triger_out(ext_trigger[2]), .cfg_stb(cfg_stb && cfg_register == HSOWR_T3_Setup)
);

hso_triger t4(
    .clk, .adc_data(active_data), .adc_stb(active_stb), .reset(!run), .cfg_data,
    .triger_out(ext_trigger[3]), .cfg_stb(cfg_stb && cfg_register == HSOWR_T4_Setup)
);


endmodule

module hso_triger(
    input wire clk,

    input wire [9:0] adc_data,
    input wire adc_stb,

    output wire triger_out,
    
    input wire reset,
    
    input wire [31:0] cfg_data,
    input wire cfg_stb
);
HiSOscTrigger setup;
`USED_PART(HiSOscTrigger, cfg_data);

logic cur_state = '0;
logic prev_state = '0;

always_ff @(posedge clk) if (cfg_stb) setup <= cfg_data; 

always_ff @(posedge clk)
    if (reset) cur_state <= '0; else
    if (adc_stb) begin
        if (cur_state && adc_data < setup.min_value) cur_state <= '0; else
        if (!cur_state && adc_data > setup.max_value) cur_state <= '1;
    end

always_ff @(posedge clk) prev_state <= ~reset && cur_state;

assign triger_out = (setup.tr_up && ~prev_state && cur_state) || (setup.tr_down && prev_state && ~cur_state);  

endmodule
        
module hso_decimator(
    input wire clk,
    input wire reset,
    
    input wire [9:0] adc_data,
    input wire adc_stb,

    output HiSOscWord out_data,
    output wire out_stb,
    
    input HiSOscControl setup
);
`UNUSED({setup.shifted_repr, setup.use_tripple_dec});
    
wire [10:0] mul_data = {adc_data[9] & setup.signed_repr, adc_data};
wire [15:0] mul_shift = 16'h8000 >> setup.decimation;

logic [15:0] counter = '0;
wire phase_ff = counter[setup.decimation];
`EDGE(reload, phase_ff);
`DLY4_G(latch_output, reload, adc_stb);
`DLY4_TG(logic [9:0], data_for_mimmax, adc_data, adc_stb);

logic [47:0] full_dsp_out;
wire [9:0] acc_result = full_dsp_out[26 -: 10];
// Only subset of full_dsp_out used
`UNUSED(full_dsp_out);

// DSP module has 4 stage pipeline        
// SEL: 0 - Full add (A*B+P), 1 - short (A*B)                
dsp_macro_mul_add dsp(.CLK(clk), .CE(adc_stb), .SCLR(reset), .SEL({reload}), .A(mul_data), .B(mul_shift), .P(full_dsp_out));
                    
always_ff @(posedge clk)
    if (reset) counter <= '0; else
    if (adc_stb) counter <= counter + 1;

logic [9:0] min, max;

hso_minmax mm_module(.clk, .reset(reset), .data(data_for_mimmax), .data_stb(adc_stb), .latch(latch_output), .min, .max);

always_ff @(posedge clk)
    if (latch_output) begin
        out_data.word0 <= acc_result;
        out_data.word1 <= min;
        out_data.word2 <= max;
    end
assign out_data.sample_tag = HSOST_Tripple;
    
`DLY(latch_output_dly, latch_output);    
assign out_stb = latch_output_dly;

endmodule

module hso_minmax(
    input wire clk,
    input wire reset,
    
    input wire [9:0] data,
    input wire data_stb,
    input wire latch,
    
    output wire [9:0] min,
    output wire [9:0] max 
);

logic [9:0] min_value = '0;
logic [9:0] max_value = '0;

assign min = min_value;
assign max = max_value;

always_ff @(posedge clk)
    if (reset) min_value <= '0; else
    if (data_stb) begin
        if (latch || min_value > data) min_value <= data;
    end

always_ff @(posedge clk)
    if (reset) max_value <= '0; else
    if (data_stb) begin
        if (latch || max_value < data) max_value <= data;
    end
    
endmodule
