// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
// Date        : Sat Jun  8 21:07:10 2024
// Host        : Desktop-XVRi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               w:/home/roman/sito/FPGA-HAT/fw/interface/interface.gen/sources_1/ip/axi4stream_vip_1/axi4stream_vip_1_stub.v
// Design      : axi4stream_vip_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7s6ftgb196-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axi4stream_vip_v1_1_16_top,Vivado 2023.2.2" *)
module axi4stream_vip_1(aclk, s_axis_tvalid, s_axis_tready, 
  s_axis_tdata, s_axis_tlast, s_axis_tdest, s_axis_tuser)
/* synthesis syn_black_box black_box_pad_pin="aclk,s_axis_tvalid[0:0],s_axis_tready[0:0],s_axis_tdata[31:0],s_axis_tlast[0:0],s_axis_tdest[7:0],s_axis_tuser[3:0]" */;
  input aclk;
  input [0:0]s_axis_tvalid;
  output [0:0]s_axis_tready;
  input [31:0]s_axis_tdata;
  input [0:0]s_axis_tlast;
  input [7:0]s_axis_tdest;
  input [3:0]s_axis_tuser;
endmodule
