onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib axis_interconnect_output_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {axis_interconnect_output.udo}

run 1000ns

quit -force
