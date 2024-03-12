`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2024 05:17:50 PM
// Design Name: 
// Module Name: la_front
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
`default_nettype none

import SPIInterf::*;

`include "utils.vh"
/*
LA AXI Write packet:
<header:8 bit> <section:4 bit> <data:20 bit>

Sections:
0 - Read BRAM request (low word). Data is start address. Size tor read contains in Wrreg #2. Read started after end of this packet.
1 - Read BRAM request (high word). Data is start address. Size tor read contains in Wrreg #2. Read started after end of this packet.
2 - Write trigger RAM. Data is starting address, data to write follow (see Trigger module definition)
3 - Set BRAM read request size. Data is BRAM size 
*/

typedef enum {
    SEC_READ_RAM_LOW,
    SEC_READ_RAM_HIGH,
    SEC_TRIGGER,
    SEC_WR_RAM_SIZE
} LA_ProtSection;

// SIZE is a size of address bus of LA memory (memory size is 1<<SIZE)
module la_body #(parameter RAM_ADDR_SIZE=10, DATA_SIZE=32) (
    input wire clk,
    
    input wire [DATA_SIZE-1:0] data,
    input wire [3:0] ext_trigger,
    
    AXIStream.master output_data_interf,
    AXIStream.slave input_cmd_interf,
    
    // Interface to SeqCtrl
    input wire [31:0] ts,
    
    // BRAM adress part (used for latching start/end point and for limit/end-delay processing)
    RAMCounter.src ram_counter,
    
    // Start-stop logic
    output wire trigger_start,
    output wire trigger_end,
    input wire run
    
);
typedef struct packed {
    logic [31:0] ts;
    logic [DATA_SIZE-1:0] data;
} LA_Data;
LA_Data la_data;
logic out_stb;
logic [RAM_ADDR_SIZE-1:0] ram_addr = '0;
assign ram_counter.ram_addr = ram_addr;
logic busy;

RegRAMPayload ram_rd_addr;
LA_Data ram_rd_data;
logic ram_rd_en;
wire ram_wr_en = run & out_stb;

logic [31:0] trigger_data;
logic trigger_wr_stb;

bram #(LA_Data, RAM_ADDR_SIZE) ram(
    .clk,
    .read_addr(ram_rd_addr.address[RAM_ADDR_SIZE-1:0]),
    .write_addr(ram_addr),
    .write_data(la_data),
    .read_data(ram_rd_data),
    .read_en(ram_rd_en),
    .write_en(ram_wr_en)
);

logic [23:0] header_low_part_and_address;
logic ram_send_start;

logic [23:0] ram_size_register; // Image of 'BRAM send size' register

la_front #(DATA_SIZE) la_front_imp(.clk, .data, .out_bus(la_data), .out_stb, .ts); 

assign ram_counter.ram_inc_enable = ram_wr_en;

always_ff @(posedge clk) if (ram_wr_en) ram_addr <= ram_addr + 1;

logic ram_half_to_read; // Select low/high part of BRAM Word to read
     
// BRAM and Registers read (send) port
bram_sender #(DST_LA, RAM_ADDR_SIZE) read_port (
    .clk, 
    .interf(output_data_interf),
    
    // BRAM interface (2 clock delay BRAM read assumed)
    .ram_data(ram_half_to_read ? ram_rd_data.ts : ram_rd_data.data), // data read from BRAM 
    .ram_rd_en(ram_rd_en), // Read strobe
    .ram_addr(ram_rd_addr), // Address to read.

// Control
    .ctrl_start_address(header_low_part_and_address[19:0]), // BRAM start address to send contents
    .ctr_size(ram_size_register), // Size of BRAM data chunk to send
    .ctrl_start(ram_send_start),  // Pulse to 1 to start BRAM data sending process. Ignored if module currently busy
    .header({DST_LA, header_low_part_and_address }), // Header to send in first word, before BRAM contents
    .busy,   // Set to 1 while module busy sending BRAM contents.

// OOB data send - not used
    .oob_header('0),   // Header to send
    .oob_data('0), // Data word to send
    .oob_send('0) // Pulse to 1 to start transaction. Ignored if module currently busy
);        

la_ctrl #(RAM_ADDR_SIZE) la_ctrl_imp(
    .clk,
    .input_cmd_interf,
    .ram_size_register, // Image of 'BRAM send size' register
      
    .trigger_data,    // data to write to trigger RAM (adress in header_low_part_and_address low bits)
    .trigger_wr_stb,         // Strobe to write

    .header_low_part_and_address, // Address and low part of all headers (high posrt is {2.b00, Dest tag}
    .ram_send_start,    // Signal to start BRAM sending. Address is in header_low_part_and_address, size in WR_BRAM_READ_SIZE register
    .ram_half_to_read,  // Selector high/low part of BRAM word (64 bit) to send
    
    // Sync
    .busy  //Busy from BRAM Sender interface 
);

la_trigger (.clk,
    .ram_data(trigger_data),
    .ram_addr(header_low_part_and_address[8:0]),
    .ram_wr_en(trigger_wr_stb),
    
    .in_data(la_data.data),
    .in_data_stb(out_stb),
    
    .ext_trigger,
    .start(trigger_start),
    .stop(trigger_end),
    
    .reset(!run) 
);    

endmodule

module la_ctrl #(parameter RAM_ADDR_SIZE=10) (
    input wire clk,
    
    AXIStream.slave input_cmd_interf,
    
    output wire [23:0] ram_size_register, // Image of 'BRAM send size' register
      
    // Trigger RAM filler
    output wire [31:0] trigger_data,    // data to write to trigger RAM (adress in header_low_part_and_address low bits)
    output wire trigger_wr_stb,         // Strobe to write

    // Connection to bram_sender module     
    output wire [23:0] header_low_part_and_address, // Address and low part of all headers (high posrt is {2.b00, Dest tag}
    output wire ram_send_start,    // Signal to start BRAM sending. Address is in header_low_part_and_address, size in WR_BRAM_READ_SIZE register
    output wire ram_half_to_read,  // Selector high/low part of BRAM word (64 bit) to send
    
    // Sync
    input wire busy  //Busy from BRAM Sender interface 
);

RegRAMPayload ram_addr;   // Address to write
logic [31:0] ram_data;    // Data to write
logic [23:0] ram_size_reg = '0; 
logic ram_wr_en;         // Write strobe
logic addr_wr_stb;        // Set with 'bram_addr' setup
assign ram_size_register = ram_size_reg;

bram_reciever #(RAM_ADDR_SIZE) inp_cmd(.clk, .interf(input_cmd_interf), .ctrl_ready_to_process(~busy), .*);   

wire [3:0] section = ram_addr.section;
`DLY(addr_dly, addr_wr_stb);

always_ff @(posedge clk) if (ram_wr_en && section == SEC_WR_RAM_SIZE) ram_size_reg <= ram_data[23:0];  

assign header_low_part_and_address = ram_addr;
assign ram_half_to_read = section == SEC_READ_RAM_HIGH;

assign trigger_data = ram_data;
assign trigger_wr_stb = ram_wr_en && section == SEC_TRIGGER;   

assign ram_send_start = addr_dly && section inside {SEC_READ_RAM_LOW, SEC_READ_RAM_HIGH};
    
endmodule
   
module la_front #(parameter SIZE=32) (
    input wire clk,
    input wire [SIZE-1:0] data,
    output wire [(31+SIZE):0] out_bus,
    output wire out_stb,
    input wire [31:0] ts
);

logic [SIZE-1:0] inputs;    // CDC synchronized version of 'data' 
logic [31:0] prev_inputs = '0; // Last registered version of 'inputs'
logic [31+SIZE:0] out_data = '0; // Output data
wire write_data = (inputs != prev_inputs) || ts == 32'hFFFFFFFF; // Strobe when writes a data  
`DLY(out_stb_ff, write_data); // Output strobe

assign out_bus = out_data;
assign out_stb = out_stb_ff;
 
cdc_multi_sync #(SIZE) cdc_input(.clk, .in(data), .out(inputs));

always_ff @(posedge clk) prev_inputs <= inputs;

always_ff @(posedge clk)
    if (write_data) out_data <= {ts, inputs};
    
endmodule
