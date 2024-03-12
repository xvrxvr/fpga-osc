`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2024 06:11:26 PM
// Design Name: 
// Module Name: spi_interface
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

interface AXIStream;
    wire TVALID;
    wire TREADY;
    wire [31:0] TDATA;
    wire TLAST;
    wire [5:0] TDEST;
    wire [3:0] TUSER;
    modport master(
        output TVALID,
        input TREADY,
        output TDATA,
        output TLAST,
        output TDEST,
        output TUSER
    );
    modport slave (
        input TVALID,
        output TREADY,
        input TDATA,
        input TLAST,
        // This signals unused
        input TDEST,
        input TUSER
    );
endinterface

module spi_interface(
    input wire clk,
    
    input wire spi_clk,
    input wire spi_mosi,
    output wire spi_miso,
    input wire spi_cs,
    input wire spi_frame,
    output wire spi_int,
    
    AXIStream.master interf_host2fpga,
    AXIStream.slave interf_fpga2host,
    
    input wire [9:0] fpga2host_fifo_filled, // 0-512
    input wire [9:0] host2fpga_fifo_empty, // 0-512
    
    input wire err_outfifo_overflow_pulse
);

// Error processing
logic clr_errors;
ErrorScale err_scale = '0;

///////////////////////////////////////////
// SPI frontend - Output path (FPGA -> HOST)
//  Data to send - one of
//      1. Input FIFO word (available if FIFO not empty)
//      2. Status word (available if 'spi_frame' signal toggle
//      3. Status word (if no other data available)
//  All sources formed in main clk domain and filled into 'hold' register on front edge spi_cs signel (implemented as asynchoronous preload)
//  Next 'data to send' formed in main clk domain by request from other domain (CDC required):
//      1. spi_frane toggle
//      2. SPI shift register shift out 24 bit (24 is abitrary choosen constant, can be anything in range 16-30) 

/// Cross domain signals ///
// Sources for hold register
logic [31:0] spi_out_data_word;// Word preloaded from input FIFO

// Signal to 'clk' domain about new data request
logic spi_out_data_req;                 // Pulse to 1 if new data can be supplied (CDC and rasing edge logic required)
//////////////

spi_out spi_out_inst(.spi_clk, .spi_miso, .spi_cs,
    .data_to_send(spi_out_data_word),
    .next_data_request(spi_out_data_req)    
);

// Resync spi_out_data_req and spi_frame to 'clk' domain
logic spi_out_data_req_clk;
logic spi_frame_clk;

cdc_sync #("PULSE") cdc_out_data_reg(.clk, .in(spi_out_data_req), .out(spi_out_data_req_clk));
cdc_sync #("TOGGLE") cdc_frame(.clk, .in(spi_frame), .out(spi_frame_clk));

body_out body_out_imp(.clk, .fpga2host_fifo_filled, .host2fpga_fifo_empty, .spi_out_data_word, .spi_out_data_req_clk, .spi_frame_clk, .spi_int,
    .interf_out(interf_fpga2host),
    .errors(err_scale)
);

//////////////////////////////////////////////////////////////////////////////////////////
// Input path - Host -> FPGA
logic [31:0] input_data;
logic input_data_stb;
logic input_overflow_stb;

cdc_sync #("PULSE") input_data_stb_cdc(.clk, .in(~spi_cs), .out(input_data_stb));

spi_input spi_input_imp(.spi_clk, .spi_mosi, .spi_cs, .data(input_data));

body_input body_input_imp(.clk, .clr_errors, 
    .data(input_data), 
    .data_stb(input_data_stb), 
    .interf(interf_host2fpga), 
    .overflow_error(input_overflow_stb)     
);

// Error processing
always_ff @(posedge clk)
    if (clr_errors) err_scale  <= '0; 
    else err_scale <= err_scale | {err_outfifo_overflow_pulse,input_overflow_stb};  

endmodule


// Output SPI part (FPGA->Host)

module spi_out(
    input wire spi_clk,
    output wire spi_miso,
    input wire spi_cs,

    input wire [31:0] data_to_send,
    output wire next_data_request 
);

localparam NewDataBit = 24;

// Hold/shift SPI register
logic [30:0] spi_out_shift_reg = '0; // Register used to shift out SPI data. On first SPI clock original data cpoied to it, on follow clock its contents is shifted
logic [31:0] spi_out_hold_reg = '0; // This register got SPI data to send on start of SPI transaction (by front edge of SPI CS signal)
logic bit0 = '1; // Set to 1 during sending first bit of SPI. Used to commutate SPI out between high bits of spi_out_hold_reg (for first bit) and spi_out_shift_reg (for others)  

// Bit counter
logic [4:0] spi_out_bit_counter;

logic next_data_request_ff = 0;

assign next_data_request = next_data_request_ff;

always @(posedge spi_cs) spi_out_hold_reg <= data_to_send;

always @(negedge spi_clk or negedge spi_cs)
    if (!spi_cs) bit0 <= '1;
    else bit0 <= '1;

assign spi_miso = bit0 ? spi_out_hold_reg[31] : spi_out_shift_reg[30];

always @(negedge spi_clk or negedge spi_cs) begin
    if (!spi_cs) begin // We in reset
        spi_out_bit_counter <= '0;
    end else begin
        spi_out_bit_counter <= spi_out_bit_counter + 1;
    end
end
 
always @(negedge spi_clk) begin
    spi_out_shift_reg <= bit0 ? spi_out_hold_reg[30:0] : spi_out_shift_reg << 1;
end

always @(negedge spi_clk or negedge spi_cs) begin
    if (!spi_cs) next_data_request_ff <= '0; else
    if (spi_out_bit_counter == NewDataBit) next_data_request_ff <= '1; 
end

endmodule

// Main part of output path (FPGA->Host)
module body_out(
    input wire clk,
    
    AXIStream.slave interf_out,
    
    input wire [9:0] fpga2host_fifo_filled, // 0-512
    input wire [9:0] host2fpga_fifo_empty, // 0-512

    output wire [31:0] spi_out_data_word,
    input wire spi_out_data_req_clk,
    input wire spi_frame_clk,
    
    input ErrorScale errors,
    
    output wire spi_int
);
`UNUSED({interf_out.TUSER, interf_out.TDEST});

logic [31:0] out_data_word = '0; // Data preloaded from FIFO
logic [29:0] bit_stuff_acc = '0; // High bits from Data
logic [4:0] bit_stuff_count = '0; // How many bits collected in 'bit_stuff_acc'  
logic [31:0] out_status_word = '0; // Status word (from Frame strobe or from empty FIFO)
logic data_fetch_slot = '0; // Set to 1 if Data can be read from FIFO
logic out_status_word_override = '0; // select 'out_status_word' event Data is available 
logic out_data_filled = '0; // 'out_data_word' is filled
logic send_stuff_bits = '0; // Set to 1 to override Data and send BitStuff instead 

logic spi_int_ff = '0;

always @(posedge clk) spi_int_ff <= out_status_word_override || out_data_filled || send_stuff_bits || fpga2host_fifo_filled != '0;  
assign spi_int = spi_int_ff;   

assign spi_out_data_word = out_status_word_override ?  out_status_word :
                           out_data_filled ? out_data_word :
                           send_stuff_bits ? {PT_BitStuff, bit_stuff_acc} : out_status_word;                     

wire tready = !out_data_filled && !send_stuff_bits && data_fetch_slot;
assign interf_out.TREADY = tready;
wire data_available = tready && interf_out.TVALID;

// Handle data_fetch_slot
always_ff @(posedge clk)
    if (spi_out_data_req_clk || spi_frame_clk) data_fetch_slot <= '1; else
    if (data_available) data_fetch_slot <= '0;

// Peek data from FIFO and place it to out_data_word  
always_ff @(posedge clk) 
    if (data_available) begin
        out_data_word <= {1'b1, interf_out.TDATA[30:0]};
        out_data_filled <= '1;
    end else if (!out_status_word_override && spi_out_data_req_clk) begin
        out_data_filled <= '0;
    end

// Would we really send stuff bits in this time?
wire effective_send_stuff_bits = !out_status_word_override && !out_data_filled && send_stuff_bits && spi_out_data_req_clk;

// Fill bitstuff register & update counter
always_ff @(posedge clk) begin 
    if (effective_send_stuff_bits) begin
         bit_stuff_acc <= '0;
         bit_stuff_count <= '0;        
    end 
    if (data_available && !interf_out.TUSER[0] && (interf_out.TDATA[31] || bit_stuff_count != '0)) begin
         bit_stuff_acc <= (bit_stuff_acc << 1) | interf_out.TDATA[31];
         bit_stuff_count <= bit_stuff_count + 1;
    end
end

// Form send_stuff_bits flag
always_ff @(posedge clk)
    if (data_available && interf_out.TLAST && bit_stuff_count != 0) send_stuff_bits <= '1; else // Flush of TLAST (if any)
    if (data_available && bit_stuff_count == 28) send_stuff_bits <= '1; else // Flush of full BitStuff register
    if (effective_send_stuff_bits) send_stuff_bits <= '0; // Clear when sent

// Status (by OOB and Empty FIFO)
always_ff @(posedge clk) begin
    if (out_status_word_override && spi_out_data_req_clk) out_status_word_override <= '0;
    if (spi_frame_clk || !out_status_word_override && spi_out_data_req_clk)
        out_status_word <= CmdPkt'{
            cmd_tag: PT_Cmd, dest: 6'b0, 
            payload: StatusPayload'{
                padding: 5'b0,
                buf_reg_filled: out_data_filled || send_stuff_bits, 
                errors: errors, 
                oob_answer: spi_frame_clk, 
                delimiter: fpga2host_fifo_filled == 0 && !(out_data_filled || send_stuff_bits), 
                fpga2host_fifo_filled: cnt_scale(fpga2host_fifo_filled), 
                hos3fpgat_fifo_empty: cnt_scale(host2fpga_fifo_empty)
            }
        };
    if (spi_frame_clk) out_status_word_override <= '1;
end

function automatic [7:0] cnt_scale(logic [9:0] value);
    if (value >= 512) return 8'h80;
    if (value < 128) return value;
    return 8'h80 | (value >> 2);
endfunction 

endmodule

///////////////////
// Input path (Host -> FPGA)

// SPI frontend
module spi_input(
    input wire spi_clk,
    input wire spi_mosi,
    input wire spi_cs,
    
    output wire [31:0] data
);

logic [30:0] in_register = '0;
logic [31:0] hold_register = '0;
logic [4:0] counter = '0;

assign data = hold_register;

always_ff @(posedge spi_clk) in_register <= (in_register << 1) | spi_mosi;
always_ff @(posedge spi_clk) if (counter == 31) hold_register <= {in_register, spi_mosi};
always @(posedge spi_clk or negedge spi_cs) if (!spi_cs) counter <= '0; else counter <= counter + 1; 

endmodule

module body_input(
    input wire clk,
    
    input wire [31:0] data,
    input wire data_stb,
    AXIStream.master interf,
    
    output wire overflow_error,
    output wire clr_errors    
);

logic [31:0] high_bits = '0;

wire [31:0] effective_data = {high_bits[0] & data[31], data[30:0]};
wire bit_stuff_in = get_tag(data) == PT_BitStuff; 
logic clr_errors_ff = '0;

ff2 ff2_inst(.clk, .interf, .overflow_error, .data(effective_data), .cmd(get_tag(data) == PT_Cmd), .stb(data_stb && !bit_stuff_in));   

always_ff @(posedge clk)
    if (data_stb) begin 
        if (bit_stuff_in) high_bits <= {data[29:0], 1'b1}; else
        if (data[31]) high_bits <= high_bits >> 1;
    end

always_ff @(posedge clk) clr_errors_ff <= data_stb && data == 1;

assign clr_errors =  clr_errors_ff;

endmodule

// ff2 module bufferise 'data' for word and add TLAST flag to buffered word if next word has flag 'cmd'
// Word with active 'cmd' used as TDEST source
// 'cmd' with zero 'data' not pushed to FIFO

// Module can holds up to 2 word of data (last word from previous packet + 'cmd' part of next)
// Module will not implement buffering for 'data' - when 'cmd' word arrived all contents will be flushed to 'interf' before next word arrived 
//             Empty        Word
//   !cmd       hold        send current, hold new
//    cmd       send cmd    send current with TLAST, hold new
//    zero cmd   --         send current with TLAST

// 2 buffers with flags:
//  C - Contents (2 bit enum): E - Empty, W - Word, C - Command
//  T - TLAST
// Buffers forms shift register, on new data contents is shifted
// Flags copied as-is, except TLAST - it asserted on copy from 0 to 1 stage if data pushed is 'cmd'
// Zero command writes 'E' as data to stage 0

// Send process scans shift register stage 1 and send data, if not [E]. Shift register advanced after send

// Pushing anything out of stage 1 if it not empty is an overflow

module ff2(
    input wire clk,
    
    input wire [31:0] data,
    input wire cmd,
    input wire stb,

    AXIStream.master interf,    // Destination to push data to
    
    output wire overflow_error // 'interf' not ready to accept word from 'data' bus
);

typedef enum logic [1:0] {
    Empty = 2'b00,
    Word = 2'b01,
    Command = 2'b10
} Contents ;

typedef struct packed {
    logic [31:0] data;
    logic [5:0] tdest;
    Contents ctx;
} Stage;

Stage st0 = '0;
Stage st1 = '0;

logic clr_st1;  // Flag 'clear st1.ctx' (data was send to 'interf')
logic tlast = '0; // tlast flag for st1

logic overflow_error_ff = '0;
always_ff @(posedge clk) overflow_error_ff = st1.ctx != Empty && stb;
assign overflow_error = overflow_error_ff;

// Shift register (ctx field hanled separately)
always_ff @(posedge clk)
    if (stb) begin
        st1.data <= st0.data;
        st1.tdest <= st0.tdest;
        tlast <= st0.ctx == Word && cmd && stb;
        st0.data <= data;
        st0.ctx <= !stb ? Empty : !cmd ? Word : data == '0 ? Empty : Command;
        if (stb && cmd) st0.tdest <= data[29:24]; 
    end

// Shift register for 'ctx' field
always_ff @(posedge clk) begin
    if (clr_st1) st1.ctx <= Empty;
    if (stb) st1.ctx <= st0.ctx;
end    

// 'interf' sender
wire tvalid = st1.ctx != Empty;

assign interf.TVALID = tvalid;
assign interf.TDATA = st1.data;
assign interf.TLAST = tlast;
assign interf.TDEST = st1.tdest;
assign interf.TUSER = st1.ctx == Command ? '1 : '0;

assign clr_st1 = tvalid && interf.TREADY;
  
endmodule
