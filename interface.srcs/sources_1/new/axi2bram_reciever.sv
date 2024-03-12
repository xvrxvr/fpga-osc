`timescale 1ns / 1ps
`default_nettype none

`include "utils.vh"

// AXIStream (slave) -> BRAM module (writer). Input interface
// Recieve BRAM (or any other data) from AXIStream slave interface

module bram_reciever #(parameter RAM_ADDR_SIZE=10) (

input wire clk,

// AXIStream
AXIStream.slave interf,

// BRAM/Registers (write interface)
output wire SPIInterf::RegRAMPayload ram_addr,   // Address to write
output wire [31:0] ram_data,    // Data to write
output wire ram_wr_en,         // Write strobe
output wire addr_wr_stb,        // Set with 'ram_addr' setup

// Control
input wire ctrl_ready_to_process   // Set to 0 to suspend data processing from 'interf'
); 
`UNUSED({interf.TUSER[3:1], interf.TDEST});

logic [RAM_ADDR_SIZE-1:0] ram_address = '0; // Variable part of BRAM address
logic [23-RAM_ADDR_SIZE:0] fixed_addr = '0; // Fixed part of Address (high bits)
logic [31:0] ram_out_data = '0;
logic wr_en = '0; // Output write strobe
logic addr_wr = '0;

logic can_suspend = '1; // Set to 1 when 'ctrl_ready_to_process' can suspend transactions

wire tready = !can_suspend || ctrl_ready_to_process;
wire transf = tready && interf.TVALID;
assign interf.TREADY = tready;
assign ram_data = ram_out_data;
assign ram_addr = SPIInterf::RegRAMPayload'({fixed_addr, ram_address});
assign ram_wr_en = wr_en; 
assign addr_wr_stb = addr_wr; 

always_ff @(posedge clk) if (transf) can_suspend <= interf.TLAST;  

// Address latch
always_ff @(posedge clk)
    if (transf && interf.TUSER[0]) fixed_addr <= interf.TDATA[23:RAM_ADDR_SIZE]; 

// Address/counter
always_ff @(posedge clk)
    if (transf && interf.TUSER[0]) ram_address <= interf.TDATA[RAM_ADDR_SIZE-1:0]; else
    if (wr_en) ram_address <= ram_address + 1'b1;
    
// Data latch
always_ff @(posedge clk)
    if (transf && !interf.TUSER[0]) ram_out_data <= interf.TDATA;

// wr en
always_ff @(posedge clk) wr_en <= transf && !interf.TUSER[0];
always_ff @(posedge clk) addr_wr <= transf && interf.TUSER[0];

endmodule
