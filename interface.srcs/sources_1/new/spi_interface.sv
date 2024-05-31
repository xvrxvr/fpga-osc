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
    wire [7:0] TDEST;
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

logic spi_data_miso, spi_stat_miso;
logic spi_data_int, spi_stat_int;

assign spi_miso = spi_frame ? spi_stat_miso : spi_data_miso;
assign spi_int = spi_frame ? spi_stat_int : spi_data_int;

/// Cross domain signals ///
// Sources for hold register
logic [31:0] spi_out_data_word;// Word preloaded from input FIFO

// Signal to 'clk' domain about new data request
logic spi_out_data_req;                 // Pulse to 1 if new data can be supplied (CDC and rasing edge logic required)
logic spi_data_sent_toggle;
//////////////

spi_out spi_out_inst(.spi_clk, .spi_miso(spi_data_miso), .spi_cs(spi_cs | spi_frame),
    .data_to_send(spi_out_data_word),
    .next_data_request(spi_out_data_req),
    .data_sent_toggle(spi_data_sent_toggle)    
);

// Resync spi_out_data_req and spi_frame to 'clk' domain
logic spi_out_data_req_clk;
logic data_cs;
logic out_reg_filled;
logic data_sent;

cdc_sync input_resync_cs_cdc(.clk, .in(spi_cs), .out(data_cs));

cdc_sync #("TOGGLE") cdc_out_data_reg(.clk, .in(spi_out_data_req), .out(spi_out_data_req_clk));
cdc_sync #("TOGGLE") cdc_spi_data_sent_reg(.clk, .in(spi_data_sent_toggle), .out(data_sent));

logic spi_frame_resync;
cdc_sync spi_frame_sync(.clk, .in(spi_frame), .out(spi_frame_resync));

`NEDGE(spi_frame_start, spi_frame_resync);
`PEDGE(spi_frame_end, spi_frame_resync);

logic req_counters;
logic grant_counters;

body_out body_out_imp(
    .clk, .fpga2host_fifo_filled, .host2fpga_fifo_empty, 
    .spi_out_data_word, .out_reg_filled, .data_sent,
    .req_data(spi_out_data_req_clk | spi_frame_start), 
    .frame_end(spi_frame_end),
    .req_counters,
    .grant_counters,
    .interf_out(interf_fpga2host),
    .errors(err_scale)
);

assign spi_data_int = out_reg_filled | (fpga2host_fifo_filled != 0);
//////////////////////////////////////////////////////////////////////////////////////////
// 8 bit FIFO control

spi_fifo_ctrl sfc(
    .clk, .spi_clk, .spi_mosi, .spi_miso(spi_stat_miso), .spi_int(spi_stat_int), .spi_cs, .spi_frame,
//    .spi_cs_resync(data_cs), .spi_frame_resync(spi_frame_resync),
    .fpga2host_fifo_filled, .host2fpga_fifo_empty,
    .req_counters, .grant_counters,
    .clr_errors,
    .err_scale, .out_reg_filled);

//////////////////////////////////////////////////////////////////////////////////////////
// Input path - Host -> FPGA
logic [31:0] input_data;
logic data_stb_toggle;
logic data_stb_resync;
logic input_overflow_stb;

cdc_sync #("TOGGLE") data_stb_resync_cdc(.clk, .in(data_stb_toggle), .out(data_stb_resync));

spi_input spi_input_imp(.spi_clk, .spi_mosi, .spi_cs, .spi_frame, .data(input_data), .data_stb_toggle);

body_input body_input_imp(.clk,
    .data(input_data), 
    .data_cs,
    .data_frame(spi_frame_resync),
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
    output wire next_data_request,
    output wire data_sent_toggle 
);

const logic [4:0] NewDataBit = 26;

// Hold/shift SPI register
logic [30:0] spi_out_shift_reg = '0; // Register used to shift out SPI data. On first SPI clock original data cpoied to it, on follow clock its contents is shifted
logic [31:0] spi_out_hold_reg = '0; // This register got SPI data to send on start of SPI transaction (by front edge of SPI CS signal)
logic bit0 = '1; // Set to 1 during sending first bit of SPI. Used to commutate SPI out between high bits of spi_out_hold_reg (for first bit) and spi_out_shift_reg (for others)  

// Bit counter
logic [4:0] spi_out_bit_counter;

logic next_data_request_ff = 0;
logic data_sent_toggle_ff = 0;

assign next_data_request = next_data_request_ff;
assign data_sent_toggle = data_sent_toggle_ff;

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
    if (bit0) data_sent_toggle_ff <= ~data_sent_toggle_ff; 
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
    input wire data_sent,
    input wire frame_end,
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

SPIData st1 = '0, st2 = '0; // 2nd word os ESC of Data to send to SPI
SPIData out_data_word = '0; // Data preloaded from FIFO
logic out_data_word_first_word = '0; // Header word placed in 'out_data_word'
logic out_data_word_last_word = '0; // Last word of packet placed in 'out_data_word' 
logic last_word_is_last = '0; // Set to 1 if last word sent to SPI was last word in packet
logic can_drop_data = '0; // Set to 1 if current st1 value can be safely dropped (when it is ESC_Wait or ESC_pkt)

assign spi_out_data_word = st1.data;
assign out_reg_filled = st2.data_active | out_data_word.data_active | req_counters;

assign interf_out.TREADY = !out_data_word.data_active;

always_ff @(posedge clk) begin
    if (!out_data_word.data_active & interf_out.TVALID) begin 
        out_data_word.data <= interf_out.TDATA; 
        out_data_word_first_word <= interf_out.TUSER[0];
        out_data_word_last_word <= interf_out.TLAST;
        out_data_word.data_active <= 1'b1; 
    end else if (req_data && !st1.data_active && !st2.data_active && !req_counters) begin
        out_data_word.data_active <= 1'b0;
    end
end

assign grant_counters = req_counters & !st2.data_active & req_data;

// Data request - fill st1
always_ff @(posedge clk) begin
    if (req_data && !st1.data_active) begin
        can_drop_data <= 1'b0; // Assume valid data
        if (st2.data_active) begin // 2nd word os ESC sequence always has a precidence
            st1.data <= st2.data;
            st2.data_active <= 1'b0;
        end else if (req_counters) begin // Emit Stat ESC
            st1.data <= {OutESC, ET_Stat};
            st2.data <= StatusPayload'{
                padding: '0,
                errors: errors,
                buf_reg_filled: out_data_word.data_active,
                fpga2host_fifo_filled: fpga2host_fifo_filled,
                host2fpga_fifo_empty: host2fpga_fifo_empty            
            }; st2.data_active <= 1'b1;
        end else if (out_data_word.data_active) begin // Send Data
            if (out_data_word_first_word) begin // Send as Esc Header
                st1.data <= {OutESC, ET_Data};
                st2.data <= out_data_word.data; st2.data_active <= 1'b1;
            end else if (out_data_word.data[31:2] == OutESC) begin // Send as ESC Data sequence
                st1.data <= {OutESC, ET_Data};
                st2.data <= {30'h0, out_data_word.data[1:0]}; st2.data_active <= 1'b1;
            end else begin // Send as is
                st1.data <= out_data_word.data;
            end
            last_word_is_last <= out_data_word_last_word;
        end else begin // Send 'empty' ESC
            st1.data <= {OutESC, last_word_is_last ? ET_Pkt : ET_Wait};
            can_drop_data <= 1'b1;                
        end
        st1.data_active <= 1'b1;
    end else if (data_sent || (frame_end && can_drop_data)) begin
        st1.data_active <= 1'b0;
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
logic [7:0] tdest = '0; // TDEST part of header
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
////////////////////////////////////////////////////
class BinGrayCvt #(parameter WIDTH=32);
    static function logic [WIDTH-1:0] bin2gray(input logic [WIDTH-1:0] bin);
        return bin ^ (bin>>1);
    endfunction
    static function logic [WIDTH-1:0] gray2bin(input logic [WIDTH-1:0] gray);
        logic [WIDTH-1:0] result;
        result[WIDTH-1] = gray[WIDTH-1];
        for(int i=WIDTH-2; i>0; --i) result[i] = result[i+1] ^ gray[i];
        return result;
    endfunction
endclass

// 8 bit FIFO Status interface
// Implements:
//  SPI in/out
//  FIFO stat request
//  FIFO words counter (to automatically request FIFO stat update emit)
//  Treshold Sys register
//  Error clear Sys register
module spi_fifo_ctrl(
    input wire clk,

    // SPI physical interface
    input wire spi_clk,
    input wire spi_mosi,
    output wire spi_miso,
    input wire spi_cs,    
    input wire spi_frame, // Frame signal. SPI addressed only when Frame is 1
    output wire spi_int,  // Emit 'has HOST->FPGA input space' signal (active is 1)

    // Resync version of some SPI control
//    input wire spi_cs_resync,
//    input wire spi_frame_resync,

    // FIFO status feeds
    input wire [9:0] fpga2host_fifo_filled,
    input wire [9:0] host2fpga_fifo_empty,

    // Rest of control
    output wire req_counters, // Set to 1 if output channel should emit FIFO Status ESC record
    input wire grant_counters, // Answer for 'req_counter'. 'req_counter' should be held in 1 until this signal will be set to 1
    output wire clr_errors, // Clear all error status bits

    // Status bits for output
    input ErrorScale err_scale,
    inout wire out_reg_filled
);

///// Input SPI part
logic [6:0] spi_reg_threshold;

spi8_in spi_in(.*);

/////
assign spi_int = host2fpga_fifo_empty >= spi_reg_threshold;

///// Output SPI part
logic [4:0] spi_bit_count_out = '0; // Bit counter for SPI out. Includes 3 bits for bit count inside 1 SPI transaction + 2 bit for 4 sequential SPI transaction
logic [23:0] spi_out_shift_reg = '0; // Output shift register for 2-4 bytes. First byte send by MUX
wire [1:0] spi_out_byte = spi_bit_count_out[4:3];
logic spi_out_first_byte; // Value for miso for first output byte

logic [9:0] cpy_fpga2host_fifo_filled;  // Copy of appropriate counters, resynchronized to SPI clock (in Gray code)
logic [9:0] cpy_host2fpga_fifo_empty;

wire latch_stat_cntr = spi_frame && !spi_cs && spi_bit_count_out == '0; // Latch fpga2host_fifo_filled and host2fpga_fifo_empty here

always_ff @(negedge spi_clk or negedge spi_frame) begin
    if (!spi_frame) spi_bit_count_out <= '0; else 
    if (!spi_cs) spi_bit_count_out <= spi_bit_count_out + 1'b1;
end

// MUX for first byte
always_comb 
    case(spi_bit_count_out[2:0])
        3'd0: spi_out_first_byte = err_scale.host2fpga_overflow;
        3'd1: spi_out_first_byte = err_scale.fpga2host_overflow;
        3'd2: spi_out_first_byte = out_reg_filled;
        3'd7: spi_out_first_byte = 1'b1;
        default: spi_out_first_byte = 1'b0;
    endcase

assign spi_miso = spi_out_byte == '0 ? spi_out_first_byte : spi_out_shift_reg[0];

// Latch stat counters on first SPI transaction.
always_ff @(negedge spi_clk) begin
    if (latch_stat_cntr) begin 
        cpy_fpga2host_fifo_filled <= BinGrayCvt #(10)::bin2gray(fpga2host_fifo_filled);
        cpy_host2fpga_fifo_empty <= BinGrayCvt #(10)::bin2gray(host2fpga_fifo_empty);                
    end
end

// Out shift reg implementation
always_ff @(negedge spi_clk) begin
    if (spi_frame && spi_cs) begin
        if (spi_bit_count_out == 5'h6) begin
            automatic logic [9:0] f2h = BinGrayCvt #(10)::gray2bin(cpy_fpga2host_fifo_filled);
            automatic logic [9:0] h2f = BinGrayCvt #(10)::gray2bin(cpy_host2fpga_fifo_empty);
            spi_out_shift_reg <= {2'b0, h2f[9:7], f2h[9:7], 1'b0, f2h[6:0], 1'b0, h2f[6:0]};
        end else if (spi_out_byte != '0) begin
            spi_out_shift_reg <= spi_out_shift_reg >> 1;
        end
    end
end



///// Stat auto request handler
logic latch_stat_cntr_ff = '0;
logic stat_cntr_resync;
logic stat_send_req;
logic req_counters_reg = '0;
assign req_counters = req_counters_reg;

always_ff @(negedge spi_clk) begin
    if (latch_stat_cntr) latch_stat_cntr_ff <= ~latch_stat_cntr_ff;
end

cdc_sync #("TOGGLE") stat_resync(.clk, .in(latch_stat_cntr_ff), .out(stat_cntr_resync));

`PEDGE(expl_stat_latch, grant_counters);

spi_stat_ctrs_reloader spi_scr(
    .clk,
    .latch(stat_cntr_resync | expl_stat_latch),
    .stat_send_req,
    .fpga2host_fifo_filled,
    .host2fpga_fifo_empty
);

always_ff @(posedge clk) begin
    if (stat_send_req) req_counters_reg <= 1'b1; else
    if (grant_counters) req_counters_reg <= 1'b0;
end

endmodule


///// Input SPI part
module spi8_in( 
    input wire clk,

    // SPI physical interface
    input wire spi_clk,
    input wire spi_mosi,
    input wire spi_cs,    
    input wire spi_frame, // Frame signal. SPI addressed only when Frame is 1

    output wire clr_errors,
    output reg [6:0] spi_reg_threshold
);

logic [6:0] spi_reg_data  = '0; // Accumulator for Data word from SPI
logic [6:0] spi_in_shift_reg = '0; // Shift register for SPI
logic [2:0] spi_bit_count = '0; // Bit counter in SPI transaction
logic       spi_cmd_clear = '0; // Toggle bit for 'clear' system register

wire spi_cs_eff = ~spi_cs & spi_frame; // Enable SPI

always_ff @(posedge spi_clk or negedge spi_cs_eff) begin
    if (!spi_cs_eff) spi_bit_count <= '0;
    else spi_bit_count <= spi_bit_count + 1'b1;
end

always_ff @(posedge spi_clk) spi_in_shift_reg <= {spi_mosi, spi_in_shift_reg[6:1]};

always_ff @(posedge spi_clk) begin
    if (spi_bit_count == 3'd7 && spi_mosi == 0) spi_reg_data <= spi_in_shift_reg;
end

always_ff @(posedge spi_clk) begin
    if (spi_bit_count == 3'd7 && spi_mosi == 1) begin
        case(spi_in_shift_reg)
            6'd0: spi_reg_threshold <= spi_reg_data;
            6'd1: spi_cmd_clear <= ~spi_cmd_clear;
        endcase
    end
end

cdc_sync #("TOGGLE") sync_clear(.clk, .in(spi_cmd_clear), .out(clr_errors));
endmodule

// Implement auto sender of SPI FIFO stat
module spi_stat_ctrs_reloader (
    input wire clk,
    input wire latch, // Counters was sent to Host
    input wire [9:0] fpga2host_fifo_filled, // Counters
    input wire [9:0] host2fpga_fifo_empty,
    output wire stat_send_req // Request to send counters update
);

endmodule
