vlib work
vmap work work

vlib altera_mf
vmap altera_mf work
vlib altera_mf_components
vmap altera_mf_components altera_mf_components
# vcom C:/altera/12.1sp1/quartus/eda/sim_lib/altera_mf_components.vhd
# vlog -work work C:/altera/12.1sp1/quartus/eda/sim_lib/altera_mf.v

## vlog ../../src/verilog/header.v
## vlog ../../src/verilog/timescale.v

vlog ../../src/verilog/TECH/duram.v
vlog ../../src/verilog/reg_int.v
vlog ../../src/verilog/eth_miim.v
vlog ../../src/verilog/phy_int.v
vlog ../../src/verilog/rmon.v
vlog ../../src/verilog/RMON/rmon_addr_gen.v
vlog ../../src/verilog/RMON/rmon_ctrl.v
vlog ../../src/verilog/RMON/rmon_dpram.v  -timescale "1ns / 1ns"
vlog ../../src/verilog/clk_ctrl.v
vlog ../../src/verilog/TECH/clk_div_2.v
vlog ../../src/verilog/TECH/clk_switch.v
vlog ../../src/verilog/miim/eth_clockgen.v
vlog ../../src/verilog/miim/eth_shiftreg.v
vlog ../../src/verilog/miim/eth_outputcontrol.v

vlog ../../src/verilog/MAC_tx/mac_tx.v 
vlog ../../src/verilog/MAC_tx/mac_tx_ctrl.v
vlog ../../src/verilog/MAC_tx/mac_tx_ff.v  +define+MAC_TX_FF_DEPTH=9 +define+MAC_RX_FF_DEPTH=9 
vlog ../../src/verilog/MAC_rx/mac_rx.v 
vlog ../../src/verilog/MAC_rx/mac_rx_ctrl.v
vlog ../../src/verilog/MAC_rx/mac_rx_ff.v +define+MAC_RX_FF_DEPTH=9
vlog ../../src/verilog/MAC_rx/crc_chk.v
vlog ../../src/verilog/MAC_tx/crc_gen.v
vlog ../../src/verilog/MAC_tx/random_gen.v
vlog ../../src/verilog/MAC_tx/flow_ctrl.v
vlog ../../src/verilog/mac_top.v -timescale "1ns / 1ns"

## RGMII_IF ------------------------------------------------------------------
vcom -93 ../../../rgmii_if_test/altera/ddio/ddio_out.vhd
vcom -93 ../../../rgmii_if_test/altera/ddio/ddio_in.vhd
vcom -93 ../../../rgmii_if_test/altera/pll/pll.vhd
vcom -93 ../../../rgmii_if_test/src/vhdl/rgmii_if_pack.vhd
vcom -93 ../../../rgmii_if_test/src/vhdl/rgmii_if.vhd

vcom ../../tb/tb_mac_top.vhd