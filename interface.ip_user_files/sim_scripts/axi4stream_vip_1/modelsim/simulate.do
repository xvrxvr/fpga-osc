onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -L xilinx_vip -L xpm -L axis_infrastructure_v1_1_1 -L xil_defaultlib -L axi4stream_vip_v1_1_16 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.axi4stream_vip_1 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {axi4stream_vip_1.udo}

run 1000ns

quit -force
