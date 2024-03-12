transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/fifo_generator_v13_2_9
vlib riviera/axis_interconnect_v1_1_22
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap fifo_generator_v13_2_9 riviera/fifo_generator_v13_2_9
vmap axis_interconnect_v1_1_22 riviera/axis_interconnect_v1_1_22
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../ipstatic/hdl" -l xpm -l fifo_generator_v13_2_9 -l axis_interconnect_v1_1_22 -l xil_defaultlib \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_2_9  -incr -v2k5 "+incdir+../../../ipstatic/hdl" -l xpm -l fifo_generator_v13_2_9 -l axis_interconnect_v1_1_22 -l xil_defaultlib \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_9 -93  -incr \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_9  -incr -v2k5 "+incdir+../../../ipstatic/hdl" -l xpm -l fifo_generator_v13_2_9 -l axis_interconnect_v1_1_22 -l xil_defaultlib \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axis_interconnect_v1_1_22  -incr -v2k5 "+incdir+../../../ipstatic/hdl" -l xpm -l fifo_generator_v13_2_9 -l axis_interconnect_v1_1_22 -l xil_defaultlib \
"../../../ipstatic/hdl/axis_interconnect_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../ipstatic/hdl" -l xpm -l fifo_generator_v13_2_9 -l axis_interconnect_v1_1_22 -l xil_defaultlib \
"../../../../interface.gen/sources_1/ip/axis_interconnect_output/sim/axis_interconnect_output.v" \

vlog -work xil_defaultlib \
"glbl.v"

