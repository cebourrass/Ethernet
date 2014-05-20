source system.tcl


vsim -novopt  -t 1ps tb_com_eth_if
source auto_wave.do
run 10 us