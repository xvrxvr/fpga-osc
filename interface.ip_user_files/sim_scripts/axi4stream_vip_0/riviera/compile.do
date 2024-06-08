transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/axis_infrastructure_v1_1_1
vlib riviera/xil_defaultlib
vlib riviera/axi4stream_vip_v1_1_16

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap axis_infrastructure_v1_1_1 riviera/axis_infrastructure_v1_1_1
vmap xil_defaultlib riviera/xil_defaultlib
vmap axi4stream_vip_v1_1_16 riviera/axi4stream_vip_v1_1_16

vlog -work xilinx_vip  -incr "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axis_infrastructure_v1_1_1 -l xil_defaultlib -l axi4stream_vip_v1_1_16 \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axis_infrastructure_v1_1_1 -l xil_defaultlib -l axi4stream_vip_v1_1_16 \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"Z:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axis_infrastructure_v1_1_1  -incr -v2k5 "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axis_infrastructure_v1_1_1 -l xil_defaultlib -l axi4stream_vip_v1_1_16 \
"../../../ipstatic/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axis_infrastructure_v1_1_1 -l xil_defaultlib -l axi4stream_vip_v1_1_16 \
"../../../../interface.gen/sources_1/ip/axi4stream_vip_0/sim/axi4stream_vip_0_pkg.sv" \

vlog -work axi4stream_vip_v1_1_16  -incr "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axis_infrastructure_v1_1_1 -l xil_defaultlib -l axi4stream_vip_v1_1_16 \
"../../../ipstatic/hdl/axi4stream_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../ipstatic/hdl" "+incdir+Z:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" -l xilinx_vip -l xpm -l axis_infrastructure_v1_1_1 -l xil_defaultlib -l axi4stream_vip_v1_1_16 \
"../../../../interface.gen/sources_1/ip/axi4stream_vip_0/sim/axi4stream_vip_0.sv" \

vlog -work xil_defaultlib \
"glbl.v"

