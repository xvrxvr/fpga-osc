// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
// Date        : Wed Feb 28 12:46:25 2024
// Host        : DESKTOP-JRU94P5 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               w:/home/roman/FPGA-HAT/fw/interface/interface.gen/sources_1/ip/dsp_macro_mul_add/dsp_macro_mul_add_stub.v
// Design      : dsp_macro_mul_add
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7s6ftgb196-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dsp_macro_v1_0_5,Vivado 2023.2.2" *)
module dsp_macro_mul_add(CLK, CE, SCLR, SEL, A, B, P)
/* synthesis syn_black_box black_box_pad_pin="CE,SCLR,SEL[0:0],A[10:0],B[15:0],P[47:0]" */
/* synthesis syn_force_seq_prim="CLK" */;
  input CLK /* synthesis syn_isclock = 1 */;
  input CE;
  input SCLR;
  input [0:0]SEL;
  input [10:0]A;
  input [15:0]B;
  output [47:0]P;
endmodule
