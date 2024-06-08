vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/axis_infrastructure_v1_1_1
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/axi4stream_vip_v1_1_16

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap xpm modelsim_lib/msim/xpm
vmap axis_infrastructure_v1_1_1 modelsim_lib/msim/axis_infrastructure_v1_1_1
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap axi4stream_vip_v1_1_16 modelsim_lib/msim/axi4stream_vip_v1_1_16

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

vlog -work axis_infrastructure_v1_1_1  -incr -mfcu  "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../ipstatic/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi4stream_vip_v1_1_16 -L xilinx_vip "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../interface.gen/sources_1/ip/axi4stream_vip_0/sim/axi4stream_vip_0_pkg.sv" \

vlog -work axi4stream_vip_v1_1_16  -incr -mfcu  -sv -L axi4stream_vip_v1_1_16 -L xilinx_vip "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../ipstatic/hdl/axi4stream_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi4stream_vip_v1_1_16 -L xilinx_vip "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"../../../../interface.gen/sources_1/ip/axi4stream_vip_0/sim/axi4stream_vip_0.sv" \

vlog -work xil_defaultlib \
"glbl.v"

