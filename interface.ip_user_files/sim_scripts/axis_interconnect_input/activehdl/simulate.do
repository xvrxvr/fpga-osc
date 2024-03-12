transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axis_interconnect_input  -L xpm -L fifo_generator_v13_2_9 -L axis_interconnect_v1_1_22 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axis_interconnect_input xil_defaultlib.glbl

do {axis_interconnect_input.udo}

run 1000ns

endsim

quit -force
