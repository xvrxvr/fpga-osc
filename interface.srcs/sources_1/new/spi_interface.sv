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

spi_out spi_out_inst(.spi_clk, .spi_miso, .spi_cs(spi_cs | spi_frame),
    .data_to_send(spi_out_data_word),
    .next_data_request(spi_out_data_req)    
);

// Resync spi_out_data_req and spi_frame to 'clk' domain
logic spi_out_data_req_clk;
logic data_frame;
logic out_reg_filled;

cdc_sync input_resync_frame_cdc(.clk, .in(spi_frame), .out(data_frame));

cdc_sync #("TOGGLE") cdc_out_data_reg(.clk, .in(spi_out_data_req), .out(spi_out_data_req_clk));
`NEDGE(spi_frame_clk, spi_frame);

body_out body_out_imp(
    .clk, .fpga2host_fifo_filled, .host2fpga_fifo_empty, 
    .spi_out_data_word, .out_reg_filled,
    .req_data(spi_out_data_req_clk | spi_frame_clk), 
    .req_counters(),
    .grant_counters(),
    .interf_out(interf_fpga2host),
    .errors(err_scale)
);

assign spi_int = out_reg_filled | (fpga2host_fifo_filled != 0);
//////////////////////////////////////////////////////////////////////////////////////////
// Input path - Host -> FPGA
logic [31:0] input_data;
logic data_cs;
logic data_stb_toggle;
logic data_stb_resync;
logic input_overflow_stb;

cdc_sync input_resync_cs_cdc(.clk, .in(spi_cs), .out(data_cs));
cdc_sync #("TOGGLE") data_stb_resync_cdc(.clk, .in(data_stb_toggle), .out(data_stb_resync));

spi_input spi_input_imp(.spi_clk, .spi_mosi, .spi_cs, .spi_frame, .data(input_data), .data_stb_toggle);

body_input body_input_imp(.clk,
    .data(input_data), 
    .data_cs,
    .data_frame,
    .data_stb(data_stb_resync),
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
    else bit0 <= '0;

assign spi_miso = bit0 ? spi_out_hold_reg[0] : spi_out_shift_reg[0];

always @(negedge spi_clk or negedge spi_cs) begin
    if (!spi_cs) begin // We in reset
        spi_out_bit_counter <= '0;
    end else begin
        spi_out_bit_counter <= spi_out_bit_counter + 1'b1;
    end
end
 
always @(negedge spi_clk) begin
    spi_out_shift_reg <= bit0 ? spi_out_hold_reg[31:1] : spi_out_shift_reg >> 1;
end

always @(negedge spi_clk) begin
    if (spi_out_bit_counter == NewDataBit) next_data_request_ff <= ~next_data_request_ff; 
end

endmodule

// Main part of output path (FPGA->Host)
module body_out(
    input wire clk,
    
    AXIStream.slave interf_out,
    
    input wire [9:0] fpga2host_fifo_filled, // 0-512
    input wire [9:0] host2fpga_fifo_empty, // 0-512

    output wire [31:0] spi_out_data_word,
    input wire req_data,
    input wire req_counters,
    output wire grant_counters,
    
    input ErrorScale errors,
    
    output wire out_reg_filled
);
`UNUSED({interf_out.TUSER, interf_out.TDEST});

typedef struct packed {
    logic [31:0] data;
    logic data_active;
} SPIData;

logic [31:0] st1_data = '0; // Data to send to SPI
SPIData st2 = '0; // 2nd word os ESC of Data to send to SPI
SPIData out_data_word = '0; // Data preloaded from FIFO
logic out_data_word_first_word = '0; // Header word placed in 'out_data_word'
logic out_data_word_last_word = '0; // Last word of packet placed in 'out_data_word' 
logic last_word_is_last = '0; // Set to 1 if last word sent to SPI was last word in packet

assign spi_out_data_word = st1_data;
assign out_reg_filled = st2.data_active | out_data_word.data_active | req_counters;

assign interf_out.TREADY = !out_data_word.data_active;

always_ff @(posedge clk) begin
    if (!out_data_word.data_active & interf_out.TVALID) begin 
        out_data_word.data <= interf_out.TDATA; 
        out_data_word_first_word <= interf_out.TUSER[0];
        out_data_word_last_word <= interf_out.TLAST;
        out_data_word.data_active <= 1'b1; 
    end else if (req_data && !st2.data_active && !req_counters) out_data_word.data_active <= 1'b0;
end

assign grant_counters = req_counters & !st2.data_active & req_data;

// Data request - fill st1
always_ff @(posedge clk) begin
    if (req_data) begin
        if (st2.data_active) begin // 2nd word os ESC sequence always has a precidence
            st1_data <= st2.data;
            st2.data_active <= 1'b0;
        end else if (req_counters) begin // Emit Stat ESC
            st1_data <= {OutESC, ET_Stat};
            st2.data <= StatusPayload'{
                padding: '0,
                errors: errors,
                buf_reg_filled: out_data_word.data_active,
                fpga2host_fifo_filled: fpga2host_fifo_filled,
                host2fpga_fifo_empty: host2fpga_fifo_empty            
            }; st2.data_active <= 1'b1;
        end else if (out_data_word.data_active) begin // Send Data
            if (out_data_word_first_word) begin // Send as Esc Header
                st1_data <= {OutESC, ET_Data};
                st2.data <= out_data_word.data; st2.data_active <= 1'b1;
            end else if (out_data_word.data[31:2] == OutESC) begin // Send as ESC Data sequence
                st1_data <= {OutESC, ET_Data};
                st2.data <= {30'h0, out_data_word.data[1:0]}; st2.data_active <= 1'b1;                
            end else begin // Send as is
                st1_data <= out_data_word.data;
            end
            last_word_is_last <= out_data_word_last_word;
        end else begin // Send 'empty' ESC
            st1_data <= {OutESC, last_word_is_last ? ET_Pkt : ET_Wait};
        end
    end
end

endmodule

///////////////////
// Input path (Host -> FPGA)

// SPI frontend
module spi_input(
    input wire spi_clk,
    input wire spi_mosi,
    input wire spi_cs,
    input wire spi_frame,
    
    output wire [31:0] data,
    output wire data_stb_toggle
);

logic [30:0] in_register = '0;
logic [31:0] hold_register = '0;
logic [4:0] counter = '0;
logic data_stb_ff = '0;

assign data = hold_register;
assign data_stb_toggle = data_stb_ff;

always_ff @(posedge spi_clk) if (!spi_cs) in_register <= {spi_mosi, in_register[30:1]};
always_ff @(posedge spi_clk) if (counter == 31 && !spi_cs) begin hold_register <= {spi_mosi, in_register}; data_stb_ff <= ~data_stb_ff; end
always @(posedge spi_clk or negedge spi_frame) if (!spi_frame) counter <= '0; else counter <= counter + 1'b1; 

endmodule

module body_input(
    input wire clk,
    
    input wire [31:0] data,
    input wire data_stb, // Strobe for input data ready
    input wire data_cs,  // CS from SPI
    input wire data_frame, // FRAME from SPI

    AXIStream.master interf,
    
    output wire overflow_error
);

logic is_cmd = '0; // Set to 1 if currently active command streamed from SPI to FIFO. Set to 0 if first word was 0 (bits 30..0)
logic is_header = '0; // Current word is a Header (put 1 to TUSER)
logic [31:0] data_to_send = '0; // Data from SPI frontend to send to FIFO
logic [5:0] tdest = '0; // TDEST part of header
logic data_rdy_to_send = '0; // data_to_send is holding vaild data (but TLAST cound be not known yet)
wire data_rdy_to_send_eff = data_rdy_to_send && is_cmd; // Do we really want to send this data?
logic tlast_to_send = '0; // TLAST value to send
logic tlast_ready = '0; // data_to_send and tlast_to_send was set up - data can be pushed to FIFO

`NEDGE(frame_start, data_frame);
`PEDGE(frame_end, data_frame);
`NEDGE(cs_start, data_cs);

wire data_pushed_to_fifo = tlast_ready && interf.TREADY; // Data was push to FIFO this cycle

assign overflow_error = data_stb && data_rdy_to_send_eff;

always_ff @(posedge clk) begin
    if (frame_start) is_header <= 1'b1; else
    if (data_pushed_to_fifo) is_header <= 1'b0;
end

always_ff @(posedge clk) begin
    if (data_stb) begin 
        data_to_send <= data; 
        if (is_header) begin is_cmd <= data != 0; tdest <= get_dest(data); end
        data_rdy_to_send <= 1'b1; 
    end
    else if (data_pushed_to_fifo) begin
        data_rdy_to_send <= 1'b0;
    end
end

always_ff @(posedge clk) begin
    if (data_rdy_to_send_eff && !tlast_ready) begin
        if (frame_end) begin tlast_to_send <= 1'b1; tlast_ready <= 1'b1; end else // Frame is done - send accumulated word as LAST
        if (cs_start)  begin tlast_to_send <= 1'b0; tlast_ready <= 1'b1; end      // Next word seen (recieve started). This word not last, and can be send to FIFO
    end
    if (data_pushed_to_fifo) tlast_ready <= 1'b0;
end

assign interf.TVALID = tlast_ready;
assign interf.TDATA = data_to_send;
assign interf.TLAST = tlast_to_send;
assign interf.TDEST = tdest;
assign interf.TUSER = is_header ? '1 : '0;

endmodule
