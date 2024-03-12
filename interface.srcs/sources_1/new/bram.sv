`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2024 07:15:08 PM
// Design Name: 
// Module Name: bram
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


module bram #(parameter type Type = logic [31:0], parameter RAM_ADDR_SIZE=1) (
    input wire clk,
    
    input wire [RAM_ADDR_SIZE-1:0] read_addr,
    input wire [RAM_ADDR_SIZE-1:0] write_addr,
    input wire Type write_data,
    output wire Type read_data,
    input wire read_en,
    input wire write_en
);

Type ram_read_data;
Type ram_read_data_buf = '0;

assign read_data = ram_read_data_buf;
    
localparam RAM_SIZE = 1 << RAM_ADDR_SIZE;

(* ram_style="block" *) logic [$bits(Type)-1:0] ram[0:RAM_SIZE-1];

always_ff @(posedge clk) begin
    if (write_en) ram[write_addr] <= write_data;
    if (read_en) ram_read_data <= ram[read_addr];
end

always_ff @(posedge clk) if (read_en) ram_read_data_buf <= ram_read_data; 
    
endmodule
