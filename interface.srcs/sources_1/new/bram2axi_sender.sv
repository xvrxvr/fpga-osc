`timescale 1ns / 1ps
`default_nettype none

import SPIInterf::*;

// AXIStream (master) <- BRAM module (reader). Output interface
// Send contents of BRAM (or direct supplied word) to AXIStream master

module bram_sender #(parameter TDEST=-1, RAM_ADDR_SIZE=10) (

input wire clk,

// AXIStream
AXIStream.master interf,

// BRAM interface (2 clock delay BRAM read assumed)
input wire [31:0] ram_data, // data read from BRAM 
output wire ram_rd_en, // Read strobe
output wire RegRAMPayload ram_addr, // Address to read.

// Control
input wire [31:0] ctrl_start_address, // BRAM start address to send contents
input wire [31:0] ctr_size, // Size of BRAM data chunk to send
input wire ctrl_start,  // Pulse to 1 to start BRAM data sending process.  Ignored if module currently busy
input wire [31:0] header, // Header to send in first word, before BRAM contents
output wire busy,   // Set to 1 while module busy sending BRAM contents.

// OOB data send. Send header + 1 word of data NOT from BRAM
input wire [31:0] oob_header,   // Header to send
input wire [31:0] oob_data, // Data word to send
input wire oob_send // Pulse to 1 to start transaction. Ignored if module currently busy
); 
if (TDEST == -1) $error("Parameter TDEST of bram_sender should be specified");
`UNUSED(ctr_size[31:RAM_ADDR_SIZE]);
`UNUSED(ctrl_start_address[31:RAM_ADDR_SIZE]);

// State of FSM
typedef enum logic [2:0] {
    S_Idle,         // Idle - Nothing happened
    S_RAM_Header,  // BRAM sender started - waiting to send header
    S_RAM_Body,    // BRAM sender active - sending body
    S_OOB_Header,   // OOB sender active - sending Header word
    S_OOB_Data      // OOB sender active - sending Data word
} State;
State fsm_state = S_Idle;

// BRAM sequencer
logic [1:0] ram_data_rdy = '0; // Bitscale of BRAM read data in BRAM read pipeline. High bit - Data available in 'ram_data' port
logic [RAM_ADDR_SIZE-1:0] ram_address = '0; // Variable part of BRAM address
logic [$bits(RegRAMPayload)-RAM_ADDR_SIZE-1:0] fixed_addr = '0; // Fixed part of Address (high bits)
logic [RAM_ADDR_SIZE-1:0] ram_counter = '0; // Words count (how many rest to send)
 
// Input data latches
logic [31:0] latch_header = '0; // Header to send in first word. Both OOB and BRAM
logic [31:0] latch_oob_data = '0; // Data word to send

// Do we ready to send something?
wire rdy_to_send = fsm_state inside {S_RAM_Header, S_OOB_Header, S_OOB_Data} || (fsm_state == S_RAM_Body && ram_data_rdy[1]);

assign interf.TVALID = rdy_to_send;
assign interf.TDEST = TDEST;

assign busy = fsm_state != S_Idle;

// Do ASI transfer performed in this tick? 
wire transf = rdy_to_send && interf.TREADY;

// Mux for data to send
assign interf.TDATA = fsm_state inside {S_RAM_Header, S_OOB_Header} ? latch_header : fsm_state == S_OOB_Data ? latch_oob_data : ram_data;
assign interf.TUSER = fsm_state inside {S_RAM_Header, S_OOB_Header} ? 4'b1 : 4'b0;
assign ram_addr = {fixed_addr, ram_address};

// Load latches
always_ff @(posedge clk) if (ctrl_start) fixed_addr <= ctrl_start_address[$bits(RegRAMPayload)-1:RAM_ADDR_SIZE];        
always_ff @(posedge clk) 
    if (ctrl_start) latch_header <= header; else
    if (oob_send) latch_header <= oob_header;
always_ff @(posedge clk) if (oob_send) latch_oob_data <= oob_data;

////// RAM sequencer

// Request to BRAM to read word
wire rd_request = fsm_state inside {S_RAM_Header, S_RAM_Body} && !ram_data_rdy[1];
assign ram_rd_en = rd_request;

// Word read from BRAM successfully transfered to AXI
wire ram2axi_transf = fsm_state == S_RAM_Body && transf;

// Pipeline
always_ff @(posedge clk)
    if ( !(fsm_state inside {S_RAM_Header, S_RAM_Body}) ) ram_data_rdy <= '0; else begin
        if (rd_request) ram_data_rdy <= (ram_data_rdy << 1) | 1'b1;
        if (ram2axi_transf) ram_data_rdy[0] <= '0; 
    end

// BRAM address and counter
always_ff @(posedge clk)
    if (ctrl_start) begin
        ram_address <= ctrl_start_address[RAM_ADDR_SIZE-1:0];
        ram_counter <= ctr_size;
    end else if (ram2axi_transf) begin
        ram_address <= ram_address + 1'b1;
        ram_counter <= ram_counter - 1'b1;
    end

// TLAST bit
assign interf.TLAST = fsm_state == S_OOB_Data || (fsm_state inside {S_RAM_Body, S_RAM_Header} && ram_counter == '0);    
  
// FSM
always_ff @(posedge clk)
    unique case(fsm_state)
        S_Idle: begin
            if (ctrl_start) fsm_state <= S_RAM_Header; else
            if (oob_send) fsm_state <= S_OOB_Header;
        end
        S_RAM_Header: begin
            if (transf) fsm_state <= ram_counter == '0 ? S_Idle : S_RAM_Body;
        end
        S_RAM_Body: begin
            if (transf && ram_counter == '0) fsm_state <= S_Idle;
        end
        S_OOB_Header: begin
            if (transf) fsm_state <= S_OOB_Data; 
        end
        S_OOB_Data: begin
            if (transf) fsm_state <= S_Idle; 
        end
        default: fsm_state <= S_Idle;
    endcase

endmodule

module hdr_sender #(parameter TDEST=-1)(
    input wire clk,
    AXIStream.master interf,

    input wire [31:0] header,
    input wire stb
);
if (TDEST == -1) $error("TDEST of hdr_sender shoud be specified");
logic [31:0] data2send = '0;
logic rdy2send = '0;

always_ff @(posedge clk) if (stb) data2send <= header;
always_ff @(posedge clk)
    if (stb) rdy2send <= '1; else
    if (rdy2send && interf.TREADY) rdy2send <= '0;

assign interf.TLAST = 1'b1;
assign interf.TVALID = rdy2send;
assign interf.TDEST = TDEST;
assign interf.TDATA = data2send;
assign interf.TUSER = 4'b1;
endmodule

