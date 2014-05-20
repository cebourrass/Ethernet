vlib work
vmap work work

# vlib altera_mf
# vmap altera_mf work
##
# vcom -work work C:/altera/12.1sp1/quartus/eda/sim_lib/altera_mf_components.vhd
# vlog -work work C:/altera/12.1sp1/quartus/eda/sim_lib/altera_mf.v
##
# vcom -93 ../../../rgmii_ddio/ddio_out.vhd
# vcom -93 ../../../rgmii_ddio/ddio_in.vhd
# vcom -93 ../../../com_pll/pll.vhd
## Rgmii interface
vcom -93 ../../../rgmii_if/src/vhdl/rgmii_if_pack.vhd
vcom -93 ../../../rgmii_if/src/vhdl/rgmii_if.vhd
## Etm mac
vcom -93 ../../../etm_mac/src/vhdl/etm_mac_pack.vhd
# vlog ../../../etm_mac/src/verilog/header.v
# vlog ../../../etm_mac/src/verilog/timescale.v
# vlog ../../../etm_mac/src/verilog/duram.v
# vlog ../../../etm_mac/src/verilog/afifo.v
# vlog ../../../etm_mac/src/verilog/reg_int.v
# vlog ../../../etm_mac/src/verilog/eth_miim.v
# vlog ../../../etm_mac/src/verilog/phy_int.v
# vlog ../../../etm_mac/src/verilog/rmon.v
# vlog ../../../etm_mac/src/verilog/rmon_addr_gen.v
# vlog ../../../etm_mac/src/verilog/rmon_ctrl.v
# vlog ../../../etm_mac/src/verilog/rmon_dpram.v  -timescale "1ns / 1ns"
# vlog ../../../etm_mac/src/verilog/clk_ctrl.v
# vlog ../../../etm_mac/src/verilog/clk_div_2.v
# vlog ../../../etm_mac/src/verilog/clk_switch.v
# vlog ../../../etm_mac/src/verilog/eth_clockgen.v
# vlog ../../../etm_mac/src/verilog/eth_shiftreg.v
# vlog ../../../etm_mac/src/verilog/eth_outputcontrol.v
# vlog ../../../etm_mac/src/verilog/mac_tx.v 
# vlog ../../../etm_mac/src/verilog/mac_tx_ctrl.v
# vlog ../../../etm_mac/src/verilog/mac_tx_ff.v  +define+MAC_TX_FF_DEPTH=9 +define+MAC_RX_FF_DEPTH=9 
# vlog ../../../etm_mac/src/verilog/mac_rx.v 
# vlog ../../../etm_mac/src/verilog/mac_rx_ctrl.v
# vlog ../../../etm_mac/src/verilog/mac_rx_ff.v +define+MAC_RX_FF_DEPTH=9
# vlog ../../../etm_mac/src/verilog/crc_chk.v
# vlog ../../../etm_mac/src/verilog/crc_gen.v
# vlog ../../../etm_mac/src/verilog/random_gen.v
# vlog ../../../etm_mac/src/verilog/flow_ctrl.v

vlog ../../../etm_mac/src/verilog/mac_top.v -timescale "1ns / 1ns"


vcom -93 ../../src/com_eth_if_pack.vhd
vcom -93 ../../src/com_eth_if.vhd
vcom -93 ../../design/fpga_top_level.vhd

vcom -93 ../../tb/tb_com_eth_if.vhd
