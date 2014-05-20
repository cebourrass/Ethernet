source system.tcl
vsim -novopt -t 1ps work.tb_mac_top
source auto_wave.tcl
run 100 us