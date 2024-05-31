// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
// Date        : Fri May 31 19:47:15 2024
// Host        : Desktop-XVRi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               w:/home/roman/sito/FPGA-HAT/fw/interface/interface.gen/sources_1/ip/axis_interconnect_input/axis_interconnect_input_stub.v
// Design      : axis_interconnect_input
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7s6ftgb196-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axis_interconnect_v1_1_22_axis_interconnect_16x16_top,Vivado 2023.2.2" *)
module axis_interconnect_input(ACLK, ARESETN, S00_AXIS_ACLK, S00_AXIS_ARESETN, 
  S00_AXIS_TVALID, S00_AXIS_TREADY, S00_AXIS_TDATA, S00_AXIS_TLAST, S00_AXIS_TDEST, 
  S00_AXIS_TUSER, M00_AXIS_ACLK, M01_AXIS_ACLK, M02_AXIS_ACLK, M03_AXIS_ACLK, M04_AXIS_ACLK, 
  M00_AXIS_ARESETN, M01_AXIS_ARESETN, M02_AXIS_ARESETN, M03_AXIS_ARESETN, M04_AXIS_ARESETN, 
  M00_AXIS_TVALID, M01_AXIS_TVALID, M02_AXIS_TVALID, M03_AXIS_TVALID, M04_AXIS_TVALID, 
  M00_AXIS_TREADY, M01_AXIS_TREADY, M02_AXIS_TREADY, M03_AXIS_TREADY, M04_AXIS_TREADY, 
  M00_AXIS_TDATA, M01_AXIS_TDATA, M02_AXIS_TDATA, M03_AXIS_TDATA, M04_AXIS_TDATA, 
  M00_AXIS_TLAST, M01_AXIS_TLAST, M02_AXIS_TLAST, M03_AXIS_TLAST, M04_AXIS_TLAST, 
  M00_AXIS_TDEST, M01_AXIS_TDEST, M02_AXIS_TDEST, M03_AXIS_TDEST, M04_AXIS_TDEST, 
  M00_AXIS_TUSER, M01_AXIS_TUSER, M02_AXIS_TUSER, M03_AXIS_TUSER, M04_AXIS_TUSER, 
  S00_DECODE_ERR, S00_FIFO_DATA_COUNT, M01_SPARSE_TKEEP_REMOVED, 
  M02_SPARSE_TKEEP_REMOVED, M03_SPARSE_TKEEP_REMOVED, M04_SPARSE_TKEEP_REMOVED)
/* synthesis syn_black_box black_box_pad_pin="ARESETN,S00_AXIS_ACLK,S00_AXIS_ARESETN,S00_AXIS_TVALID,S00_AXIS_TREADY,S00_AXIS_TDATA[31:0],S00_AXIS_TLAST,S00_AXIS_TDEST[7:0],S00_AXIS_TUSER[3:0],M00_AXIS_ACLK,M01_AXIS_ACLK,M02_AXIS_ACLK,M03_AXIS_ACLK,M04_AXIS_ACLK,M00_AXIS_ARESETN,M01_AXIS_ARESETN,M02_AXIS_ARESETN,M03_AXIS_ARESETN,M04_AXIS_ARESETN,M00_AXIS_TVALID,M01_AXIS_TVALID,M02_AXIS_TVALID,M03_AXIS_TVALID,M04_AXIS_TVALID,M00_AXIS_TREADY,M01_AXIS_TREADY,M02_AXIS_TREADY,M03_AXIS_TREADY,M04_AXIS_TREADY,M00_AXIS_TDATA[31:0],M01_AXIS_TDATA[31:0],M02_AXIS_TDATA[31:0],M03_AXIS_TDATA[31:0],M04_AXIS_TDATA[31:0],M00_AXIS_TLAST,M01_AXIS_TLAST,M02_AXIS_TLAST,M03_AXIS_TLAST,M04_AXIS_TLAST,M00_AXIS_TDEST[7:0],M01_AXIS_TDEST[7:0],M02_AXIS_TDEST[7:0],M03_AXIS_TDEST[7:0],M04_AXIS_TDEST[7:0],M00_AXIS_TUSER[3:0],M01_AXIS_TUSER[3:0],M02_AXIS_TUSER[3:0],M03_AXIS_TUSER[3:0],M04_AXIS_TUSER[3:0],S00_DECODE_ERR,S00_FIFO_DATA_COUNT[31:0],M01_SPARSE_TKEEP_REMOVED,M02_SPARSE_TKEEP_REMOVED,M03_SPARSE_TKEEP_REMOVED,M04_SPARSE_TKEEP_REMOVED" */
/* synthesis syn_force_seq_prim="ACLK" */;
  input ACLK /* synthesis syn_isclock = 1 */;
  input ARESETN;
  input S00_AXIS_ACLK;
  input S00_AXIS_ARESETN;
  input S00_AXIS_TVALID;
  output S00_AXIS_TREADY;
  input [31:0]S00_AXIS_TDATA;
  input S00_AXIS_TLAST;
  input [7:0]S00_AXIS_TDEST;
  input [3:0]S00_AXIS_TUSER;
  input M00_AXIS_ACLK;
  input M01_AXIS_ACLK;
  input M02_AXIS_ACLK;
  input M03_AXIS_ACLK;
  input M04_AXIS_ACLK;
  input M00_AXIS_ARESETN;
  input M01_AXIS_ARESETN;
  input M02_AXIS_ARESETN;
  input M03_AXIS_ARESETN;
  input M04_AXIS_ARESETN;
  output M00_AXIS_TVALID;
  output M01_AXIS_TVALID;
  output M02_AXIS_TVALID;
  output M03_AXIS_TVALID;
  output M04_AXIS_TVALID;
  input M00_AXIS_TREADY;
  input M01_AXIS_TREADY;
  input M02_AXIS_TREADY;
  input M03_AXIS_TREADY;
  input M04_AXIS_TREADY;
  output [31:0]M00_AXIS_TDATA;
  output [31:0]M01_AXIS_TDATA;
  output [31:0]M02_AXIS_TDATA;
  output [31:0]M03_AXIS_TDATA;
  output [31:0]M04_AXIS_TDATA;
  output M00_AXIS_TLAST;
  output M01_AXIS_TLAST;
  output M02_AXIS_TLAST;
  output M03_AXIS_TLAST;
  output M04_AXIS_TLAST;
  output [7:0]M00_AXIS_TDEST;
  output [7:0]M01_AXIS_TDEST;
  output [7:0]M02_AXIS_TDEST;
  output [7:0]M03_AXIS_TDEST;
  output [7:0]M04_AXIS_TDEST;
  output [3:0]M00_AXIS_TUSER;
  output [3:0]M01_AXIS_TUSER;
  output [3:0]M02_AXIS_TUSER;
  output [3:0]M03_AXIS_TUSER;
  output [3:0]M04_AXIS_TUSER;
  output S00_DECODE_ERR;
  output [31:0]S00_FIFO_DATA_COUNT;
  output M01_SPARSE_TKEEP_REMOVED;
  output M02_SPARSE_TKEEP_REMOVED;
  output M03_SPARSE_TKEEP_REMOVED;
  output M04_SPARSE_TKEEP_REMOVED;
endmodule
