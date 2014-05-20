vlib work
vmap work work

# source
vcom -93 ../../../counter/src/vhdl/counter_comp.vhd
vcom -93 ../../../counter/src/vhdl/counter.vhd
vcom -93 ../../../ticks_generator/src/vhdl/ticks_generator_pack.vhd
vcom -93 ../../../ticks_generator/src/vhdl/ticks_generator.vhd
vcom -93 ../../src/vhdl/ev76c560_eth_if.vhd 

# test bench
vcom -93 ../../tb/tb_ev76c560_eth_if.vhd 
