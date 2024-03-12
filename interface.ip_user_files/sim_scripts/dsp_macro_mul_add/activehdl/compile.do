transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/xbip_dsp48_wrapper_v3_0_5
vlib activehdl/xbip_utils_v3_0_12
vlib activehdl/xbip_pipe_v3_0_8
vlib activehdl/dsp_macro_v1_0_5
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xbip_dsp48_wrapper_v3_0_5 activehdl/xbip_dsp48_wrapper_v3_0_5
vmap xbip_utils_v3_0_12 activehdl/xbip_utils_v3_0_12
vmap xbip_pipe_v3_0_8 activehdl/xbip_pipe_v3_0_8
vmap dsp_macro_v1_0_5 activehdl/dsp_macro_v1_0_5
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 -l xpm -l xbip_dsp48_wrapper_v3_0_5 -l xbip_utils_v3_0_12 -l xbip_pipe_v3_0_8 -l dsp_macro_v1_0_5 -l xil_defaultlib \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_5 -93  \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_utils_v3_0_12 -93  \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_8 -93  \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work dsp_macro_v1_0_5 -93  \
"../../../ipstatic/hdl/dsp_macro_v1_0_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../../interface.gen/sources_1/ip/dsp_macro_mul_add/sim/dsp_macro_mul_add.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

