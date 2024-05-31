// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
// Date        : Fri May 31 19:47:34 2024
// Host        : Desktop-XVRi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               w:/home/roman/sito/FPGA-HAT/fw/interface/interface.gen/sources_1/ip/axis_interconnect_output/axis_interconnect_output_stub.v
// Design      : axis_interconnect_output
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7s6ftgb196-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axis_interconnect_v1_1_22_axis_interconnect_16x16_top,Vivado 2023.2.2" *)
module axis_interconnect_output(ACLK, ARESETN, S00_AXIS_ACLK, S01_AXIS_ACLK, 
  S02_AXIS_ACLK, S03_AXIS_ACLK, S04_AXIS_ACLK, S00_AXIS_ARESETN, S01_AXIS_ARESETN, 
  S02_AXIS_ARESETN, S03_AXIS_ARESETN, S04_AXIS_ARESETN, S00_AXIS_TVALID, S01_AXIS_TVALID, 
  S02_AXIS_TVALID, S03_AXIS_TVALID, S04_AXIS_TVALID, S00_AXIS_TREADY, S01_AXIS_TREADY, 
  S02_AXIS_TREADY, S03_AXIS_TREADY, S04_AXIS_TREADY, S00_AXIS_TDATA, S01_AXIS_TDATA, 
  S02_AXIS_TDATA, S03_AXIS_TDATA, S04_AXIS_TDATA, S00_AXIS_TLAST, S01_AXIS_TLAST, 
  S02_AXIS_TLAST, S03_AXIS_TLAST, S04_AXIS_TLAST, S00_AXIS_TDEST, S01_AXIS_TDEST, 
  S02_AXIS_TDEST, S03_AXIS_TDEST, S04_AXIS_TDEST, S00_AXIS_TUSER, S01_AXIS_TUSER, 
  S02_AXIS_TUSER, S03_AXIS_TUSER, S04_AXIS_TUSER, M00_AXIS_ACLK, M00_AXIS_ARESETN, 
  M00_AXIS_TVALID, M00_AXIS_TREADY, M00_AXIS_TDATA, M00_AXIS_TLAST, M00_AXIS_TDEST, 
  M00_AXIS_TUSER, S00_ARB_REQ_SUPPRESS, S01_ARB_REQ_SUPPRESS, S02_ARB_REQ_SUPPRESS, 
  S03_ARB_REQ_SUPPRESS, S04_ARB_REQ_SUPPRESS, S00_DECODE_ERR, S01_DECODE_ERR, 
  S02_DECODE_ERR, S03_DECODE_ERR, S04_DECODE_ERR, M00_FIFO_DATA_COUNT)
/* synthesis syn_black_box black_box_pad_pin="ARESETN,S00_AXIS_ACLK,S01_AXIS_ACLK,S02_AXIS_ACLK,S03_AXIS_ACLK,S04_AXIS_ACLK,S00_AXIS_ARESETN,S01_AXIS_ARESETN,S02_AXIS_ARESETN,S03_AXIS_ARESETN,S04_AXIS_ARESETN,S00_AXIS_TVALID,S01_AXIS_TVALID,S02_AXIS_TVALID,S03_AXIS_TVALID,S04_AXIS_TVALID,S00_AXIS_TREADY,S01_AXIS_TREADY,S02_AXIS_TREADY,S03_AXIS_TREADY,S04_AXIS_TREADY,S00_AXIS_TDATA[31:0],S01_AXIS_TDATA[31:0],S02_AXIS_TDATA[31:0],S03_AXIS_TDATA[31:0],S04_AXIS_TDATA[31:0],S00_AXIS_TLAST,S01_AXIS_TLAST,S02_AXIS_TLAST,S03_AXIS_TLAST,S04_AXIS_TLAST,S00_AXIS_TDEST[7:0],S01_AXIS_TDEST[7:0],S02_AXIS_TDEST[7:0],S03_AXIS_TDEST[7:0],S04_AXIS_TDEST[7:0],S00_AXIS_TUSER[3:0],S01_AXIS_TUSER[3:0],S02_AXIS_TUSER[3:0],S03_AXIS_TUSER[3:0],S04_AXIS_TUSER[3:0],M00_AXIS_ARESETN,M00_AXIS_TVALID,M00_AXIS_TREADY,M00_AXIS_TDATA[31:0],M00_AXIS_TLAST,M00_AXIS_TDEST[7:0],M00_AXIS_TUSER[3:0],S00_ARB_REQ_SUPPRESS,S01_ARB_REQ_SUPPRESS,S02_ARB_REQ_SUPPRESS,S03_ARB_REQ_SUPPRESS,S04_ARB_REQ_SUPPRESS,S00_DECODE_ERR,S01_DECODE_ERR,S02_DECODE_ERR,S03_DECODE_ERR,S04_DECODE_ERR,M00_FIFO_DATA_COUNT[31:0]" */
/* synthesis syn_force_seq_prim="ACLK" */
/* synthesis syn_force_seq_prim="M00_AXIS_ACLK" */;
  input ACLK /* synthesis syn_isclock = 1 */;
  input ARESETN;
  input S00_AXIS_ACLK;
  input S01_AXIS_ACLK;
  input S02_AXIS_ACLK;
  input S03_AXIS_ACLK;
  input S04_AXIS_ACLK;
  input S00_AXIS_ARESETN;
  input S01_AXIS_ARESETN;
  input S02_AXIS_ARESETN;
  input S03_AXIS_ARESETN;
  input S04_AXIS_ARESETN;
  input S00_AXIS_TVALID;
  input S01_AXIS_TVALID;
  input S02_AXIS_TVALID;
  input S03_AXIS_TVALID;
  input S04_AXIS_TVALID;
  output S00_AXIS_TREADY;
  output S01_AXIS_TREADY;
  output S02_AXIS_TREADY;
  output S03_AXIS_TREADY;
  output S04_AXIS_TREADY;
  input [31:0]S00_AXIS_TDATA;
  input [31:0]S01_AXIS_TDATA;
  input [31:0]S02_AXIS_TDATA;
  input [31:0]S03_AXIS_TDATA;
  input [31:0]S04_AXIS_TDATA;
  input S00_AXIS_TLAST;
  input S01_AXIS_TLAST;
  input S02_AXIS_TLAST;
  input S03_AXIS_TLAST;
  input S04_AXIS_TLAST;
  input [7:0]S00_AXIS_TDEST;
  input [7:0]S01_AXIS_TDEST;
  input [7:0]S02_AXIS_TDEST;
  input [7:0]S03_AXIS_TDEST;
  input [7:0]S04_AXIS_TDEST;
  input [3:0]S00_AXIS_TUSER;
  input [3:0]S01_AXIS_TUSER;
  input [3:0]S02_AXIS_TUSER;
  input [3:0]S03_AXIS_TUSER;
  input [3:0]S04_AXIS_TUSER;
  input M00_AXIS_ACLK /* synthesis syn_isclock = 1 */;
  input M00_AXIS_ARESETN;
  output M00_AXIS_TVALID;
  input M00_AXIS_TREADY;
  output [31:0]M00_AXIS_TDATA;
  output M00_AXIS_TLAST;
  output [7:0]M00_AXIS_TDEST;
  output [3:0]M00_AXIS_TUSER;
  input S00_ARB_REQ_SUPPRESS;
  input S01_ARB_REQ_SUPPRESS;
  input S02_ARB_REQ_SUPPRESS;
  input S03_ARB_REQ_SUPPRESS;
  input S04_ARB_REQ_SUPPRESS;
  output S00_DECODE_ERR;
  output S01_DECODE_ERR;
  output S02_DECODE_ERR;
  output S03_DECODE_ERR;
  output S04_DECODE_ERR;
  output [31:0]M00_FIFO_DATA_COUNT;
endmodule
