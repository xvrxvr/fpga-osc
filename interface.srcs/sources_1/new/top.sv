`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2024 04:57:09 PM
// Design Name: 
// Module Name: top
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


module top(
    input wire clk20,

    input wire spi_clk,
    input wire spi_mosi,
    output wire spi_miso,
    input wire spi_cs,
    input wire spi_frame,
    output wire spi_int,

    input wire [31:0] la_data,
    output wire [31:0] gen_data,
    input wire [9:0] adc_data


);
logic clk;

clk_wiz_main (.clk_out1(clk), .clk_in1(clk20));

AXIStream input_axi(), output_axi();
logic [31:0] fpga2host_fifo_filled; // 0-512
logic [31:0] host2fpga_fifo_empty; // 0-512

spi_interface main_spi_inst(
    .clk,
    
    .spi_clk,
    .spi_mosi,
    .spi_miso,
    .spi_cs,
    .spi_frame,
    .spi_int,
    
    .interf_host2fpga(input_axi),
    .interf_fpga2host(output_axi),
    
    .fpga2host_fifo_filled(fpga2host_fifo_filled[9:0]), // 0-512
    .host2fpga_fifo_empty(host2fpga_fifo_empty[9:0]), // 0-512
    
    .err_outfifo_overflow_pulse('0)
);

AXIStream input_la(), output_la();

logic [3:0] ext_trigger;
logic [31:0] ts;

// Start-stop logic
logic trigger_start;
logic trigger_end;
logic run;

RAMCounter #(10) ram_cntr [1:0]();

la_body #(.RAM_ADDR_SIZE(9), .DATA_SIZE(32)) la_body_imp (
    .clk,
    
    .data(la_data),   
    .ext_trigger,
    
    .output_data_interf(output_la),
    .input_cmd_interf(input_la),
    
    // Interface to SeqCtrl
    .ts,
    .ram_counter(ram_cntr[0]),
    .trigger_start,
    .trigger_end,
    .run
);

AXIStream input_seq(), output_seq();

seq_ctrl #(.RAM_ADDR_SIZE(10), .RAM_TOTAL($size(ram_cntr))) seqeunser(
    .clk,
    
    .output_data_interf(output_seq),
    .input_data_interf(input_seq),
    
    // Timestamp part. Timestamp implemented inside module and exported outside
    .ts,
    .ts_inc_enable(1'b1),
    
    // BRAM adress part (used for latching start/end point and for limit/end-delay processing)
    .rams(ram_cntr),
    
    .trigger_start,
    .trigger_end,
    .run
);

AXIStream input_sys(), output_sys();

sys sys_inst(.clk, .output_data_interf(output_sys), .input_cmd_interf(input_sys));

AXIStream input_osc(), output_osc();

hs_osc #(.RAM_ADDR_SIZE(10)) hso_inst(
    .clk, .adc_data, .adc_stb('1), .ext_trigger, .run,
    .output_data_interf(output_osc), .input_cmd_interf(input_osc),
    .ram_counter(ram_cntr[1])
);

AXIStream input_gen(), output_gen();
assign output_gen.TVALID = '0;
assign output_gen.TDATA = '0;
assign output_gen.TUSER = '0;
assign output_gen.TDEST = '0;
assign output_gen.TLAST = '0;
`UNUSED({output_gen.TREADY, fpga2host_fifo_filled[31:10], host2fpga_fifo_empty[31:10]});

generator #(.RAM_ADDR_SIZE(10), .DATA_SIZE(32)) gen_module(
    .clk, .data(gen_data), .input_cmd_interf(input_gen),
    .trigger_start,
    .run
);

`define PAXI(index, inst) \
    .``index``_AXIS_ACLK(clk), \
    .``index``_AXIS_ARESETN(1), \
    .``index``_AXIS_TVALID(inst.TVALID), \
    .``index``_AXIS_TREADY(inst.TREADY), \
    .``index``_AXIS_TDATA(inst.TDATA), \
    .``index``_AXIS_TLAST(inst.TLAST), \
    .``index``_AXIS_TDEST(inst.TDEST), \
    .``index``_AXIS_TUSER(inst.TUSER)

`define MAXI(index, inst) `PAXI(M``index, inst), .M``index``_SPARSE_TKEEP_REMOVED()
`define SAXI(index, inst) `PAXI(S``index, inst), .S``index``_ARB_REQ_SUPPRESS(0), .S``index``_DECODE_ERR()

axis_interconnect_input axi_input (
  .ACLK(clk),
  .ARESETN(1),
  
  `PAXI(S00,input_axi),
  
  `PAXI(M00,input_sys),
  `MAXI(01,input_la),
  `MAXI(02,input_seq),
  `MAXI(03,input_osc),
  `MAXI(04,input_gen),
  
  .S00_DECODE_ERR(),
  .S00_FIFO_DATA_COUNT(host2fpga_fifo_empty)
);

axis_interconnect_output axi_output (
  .ACLK(clk),
  .ARESETN(1),
  
  `PAXI(M00,output_axi),
  
  `SAXI(00,output_sys),
  `SAXI(01,output_la), 
  `SAXI(02,output_seq),
  `SAXI(03,output_osc),
  `SAXI(04,output_gen),
  
  .M00_FIFO_DATA_COUNT(fpga2host_fifo_filled)
);

endmodule
