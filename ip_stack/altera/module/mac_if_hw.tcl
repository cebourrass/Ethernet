package require -exact sopc 9.1

set_module_property NAME mac_if
set_module_property DISPLAY_NAME "MAC Interface"
set_module_property AUTHOR LASMEA
set_module_property GROUP Custom
set_module_property TOP_LEVEL_HDL_FILE mac_if.vhd
set_module_property TOP_LEVEL_HDL_MODULE mac_if
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property VERSION 11.1
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL FALSE
set_module_property ELABORATION_CALLBACK elaborate

set_module_property GROUP lasmea

# +-----------------------------------
# | files
# | 

add_file mac_if.vhd {SYNTHESIS SIMULATION}
add_file ethernet_package.vhd {SYNTHESIS SIMULATION}
add_file ethernet_packet_filter.vhd {SYNTHESIS SIMULATION}
add_file arp_packet_filter.vhd {SYNTHESIS SIMULATION}
add_file ipv4_packet_filter.vhd {SYNTHESIS SIMULATION}
add_file udp_packet_filter.vhd {SYNTHESIS SIMULATION}
add_file icmp_packet_filter.vhd {SYNTHESIS SIMULATION}
add_file arp_reply.vhd {SYNTHESIS SIMULATION}
add_file icmp_reply.vhd {SYNTHESIS SIMULATION}
#add_file udp_0x1235_status.vhd {SYNTHESIS SIMULATION}
add_file udp_video.vhd {SYNTHESIS SIMULATION}
add_file counter.vhd {SYNTHESIS SIMULATION}
add_file tse_config.vhd {SYNTHESIS SIMULATION}

# +-----------------------------------
# | parameters
# |

# +-----------------------------------
# | ELABORATION_CALLBACK procedure
# |

proc elaborate {} {

    add_interface clk clock end
    add_interface_port clk clk_i clk Input 1
    add_interface_port clk rst_i reset Input 1
    
    add_interface "ff_rx" "avalon_streaming" "sink" "clk"
    add_interface_port "ff_rx" "ff_rx_ready" "ready" "output" 1
    add_interface_port "ff_rx" "ff_rx_data" "data" "input" 32
    add_interface_port "ff_rx" "ff_rx_mod" "empty" "input" 2
    add_interface_port "ff_rx" "ff_rx_sop" "startofpacket" "input" 1
    add_interface_port "ff_rx" "ff_rx_eop" "endofpacket" "input" 1
    add_interface_port "ff_rx" "ff_rx_err" "error" "input" 6
    add_interface_port "ff_rx" "ff_rx_val" "valid" "input" 1
    
    add_interface "ff_tx" "avalon_streaming" "source" "clk"
    add_interface_port "ff_tx" "ff_tx_ready" "ready" "input" 1
    add_interface_port "ff_tx" "ff_tx_data" "data" "output" 32
    add_interface_port "ff_tx" "ff_tx_mod" "empty" "output" 2
    add_interface_port "ff_tx" "ff_tx_sop" "startofpacket" "output" 1
    add_interface_port "ff_tx" "ff_tx_eop" "endofpacket" "output" 1
    add_interface_port "ff_tx" "ff_tx_err" "error" "output" 1
    add_interface_port "ff_tx" "ff_tx_wren" "valid" "output" 1
    
    add_interface "tse_cfg" "avalon" "master" "clk"
    add_interface_port "tse_cfg" "tse_cfg_address"  "address" "output" 10
    add_interface_port "tse_cfg" "tse_cfg_write"    "write" "output" 1
    add_interface_port "tse_cfg" "tse_cfg_read"     "read" "output" 1
    add_interface_port "tse_cfg" "tse_cfg_writedata" "writedata" "output" 32
    add_interface_port "tse_cfg" "tse_cfg_readdata"   "readdata" "input" 32
    add_interface_port "tse_cfg" "tse_cfg_waitrequest" "waitrequest" "input" 1
    set_interface_property "tse_cfg" "readWaitTime" "0"
    
    add_interface "test" "conduit" "end"
    add_interface_port "test" "test_pin" "test_pin" "output" 8
}
    
