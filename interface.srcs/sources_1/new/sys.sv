`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2024 06:06:33 PM
// Design Name: 
// Module Name: sys
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

typedef enum {
    SR_Nop,
    SR_HB
} SysRegs;

module sys(
    input wire clk,
    
    AXIStream.master output_data_interf,
    AXIStream.slave input_cmd_interf    
);

logic [23:0] addr;
logic wr_stb;

logic [31:0] hb_counter = '0;
logic [15:0] hb_interval = '0;
wire hb_cnt_hit = hb_counter[31 -: 16] == hb_interval;
wire hb_reg_wr = wr_stb && addr[23 -: 4] == SR_HB;

bram_reciever #(3) inp_cmd (.clk, .interf(input_cmd_interf), .ram_addr(addr), .ram_data(), .ram_wr_en(), .addr_wr_stb(wr_stb), .ctrl_ready_to_process(1'b1));

hdr_sender #(DST_SYSTEM) hb_sender(.clk, .interf(output_data_interf), .header( CmdPkt'{dest: DST_SYSTEM, payload:SR_HB}), .stb(hb_cnt_hit && hb_interval != '0));

always_ff @(posedge clk) if (hb_reg_wr) hb_interval <= addr[15:0];
    
always_ff @(posedge clk)
    if (hb_reg_wr || hb_interval == '0 || hb_cnt_hit) hb_counter <= '0; 
    else hb_counter <= hb_counter + 1'b1;

endmodule
