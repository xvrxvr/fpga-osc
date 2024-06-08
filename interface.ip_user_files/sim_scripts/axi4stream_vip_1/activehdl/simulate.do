transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axi4stream_vip_1  -L xilinx_vip -L xpm -L axis_infrastructure_v1_1_1 -L xil_defaultlib -L axi4stream_vip_v1_1_16 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi4stream_vip_1 xil_defaultlib.glbl

do {axi4stream_vip_1.udo}

run 1000ns

endsim

quit -force
