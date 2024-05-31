vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/fifo_generator_v13_2_9
vlib questa_lib/msim/axis_interconnect_v1_1_22
vlib questa_lib/msim/xil_defaultlib

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap fifo_generator_v13_2_9 questa_lib/msim/fifo_generator_v13_2_9
vmap axis_interconnect_v1_1_22 questa_lib/msim/axis_interconnect_v1_1_22
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xilinx_vip  -incr -mfcu  -sv -L axi4stream_vip_v1_1_16 -L xilinx_vip "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr -mfcu  -sv -L axi4stream_vip_v1_1_16 -L xilinx_vip "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_2_9  -incr -mfcu  "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_9  -93  \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_9  -incr -mfcu  "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axis_interconnect_v1_1_22  -incr -mfcu  "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../ipstatic/hdl/axis_interconnect_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../interface.gen/sources_1/ip/axis_interconnect_input/sim/axis_interconnect_input.v" \

vlog -work xil_defaultlib \
"glbl.v"

