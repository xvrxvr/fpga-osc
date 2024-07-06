`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2024 01:04:52 PM
// Design Name: 
// Module Name: utils_dly
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


module utils_dly #(parameter N=1, type Type=logic) (
    input wire clk,
    input wire Type in,
    output wire Type out,
    input wire ce,
    output wire Type out_scale [N-1:0] 
);
Type shift_reg[N-1:0] = '{'0};
assign out_scale = shift_reg;
assign out = shift_reg[N-1];

always_ff @(posedge clk)
    if (ce) begin
        for(int i=N-1; i>0; --i) shift_reg[i] <= shift_reg[i-1];
        shift_reg[0] <= in; 
    end
endmodule

module unused(input wire dnu);
wire _unused_ok = &{1'b0, dnu, 1'b0};
endmodule
