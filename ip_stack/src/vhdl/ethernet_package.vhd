--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2012-11-16
--! @brief Ethernet Interface Configuration Package
--! @details
--!
--! @page p_Ethernet_Interface_Configuration_Package Ethernet Interface
--! Configuration Package
--! This page describes Ethernet Interface Configuration Package contents.
--! @section sec_000 Revisions
--! - 2012-04-10 : Created
--!
--! @section sec_002 Concepts
--! This package contains all data types and constants needed to configure 
--! Ethernet Interface.
--! It replaces generic use.
--!
--! Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--! Package Interface
package ethernet_package is
  --------------------------------------------------- Local Static Arp Table ---
  --! PC Mac Address
  constant PC_MAC_ADDRESS : std_logic_vector(47 downto 0) :=
    -- X"0021976E4737"; -- Fixe LENOVO Lo�c - Carte Marvell Yukon 88E8053 PCI-E Gigabit
    -- X"544249873B74"; -- Portable VAIO
	  --X"D4BED93049D9"; -- Cedric Dell
	-- X"001B63A9592A"; -- Luca MAc 
		X"74EA3A851BD7";
		 
  --! PC Ip Address
  constant PC_IP_ADDRESS : std_logic_vector(31 downto 0) :=
    std_logic_vector(to_unsigned(192, 8)) &
    std_logic_vector(to_unsigned(168, 8)) &
    std_logic_vector(to_unsigned(0, 8)) &
    std_logic_vector(to_unsigned(5, 8));
  --! Broadcast Mac Address
  constant BROADCAST_MAC_ADDRESS : std_logic_vector(47 downto 0) :=
    X"FFFFFFFFFFFF";
  --! Local Mac Address
  constant LOCAL_MAC_ADDRESS : std_logic_vector(47 downto 0) :=
    X"74EA3A851BD9";
  --! Local Ip Address
  constant LOCAL_IP_ADDRESS : std_logic_vector(31 downto 0) :=
    std_logic_vector(to_unsigned(192, 8)) &
    std_logic_vector(to_unsigned(168, 8)) &
    std_logic_vector(to_unsigned(0, 8)) &
    std_logic_vector(to_unsigned(4, 8));
  -------------------------------------------------------------- Local Ports ---  
  --! Debug port  
  constant DEBUG_PORT                : std_logic_vector(15 downto 0) := X"0001";
  --! Configuration Port
  constant CONFIGURATION_PORT        : std_logic_vector(15 downto 0) := X"FDE9";
  --! Status Port
  constant STATUS_PORT               : std_logic_vector(15 downto 0) := X"FDE8";
  --! Video Port
  constant VIDEO_PORT                : std_logic_vector(15 downto 0) := X"FDEA";
  -- constant VIDEO_PORT                : std_logic_vector(15 downto 0) := X"FDEB";
  ------------------------------------------------------------------------------
  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  -- Do NOT Modify Below This Comment
  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ------------------------------------------------------------------------------
  --! System Clock Frequency (Mhz)
  constant CLK_FREQUENCY_MHZ         : integer                       := 50;
  ------------------------------------------------ Ethernet Packet Constants ---
  --! Ethernet Packet Arp Signature
  constant ETHERNET_TYPE_ARP         : std_logic_vector(15 downto 0) := X"0806";
  --! Ethernet Packet Ipv4 Signature
  constant ETHERNET_TYPE_IPV4        : std_logic_vector(15 downto 0) := X"0800";
  ---------------------------------------------------- Ipv4 Packet Constants ---
  --! Ipv4 Header Length
  constant IPV4_HEADER_LENGTH        : integer                       := 20;
  --! Ipv4 Packet Version
  constant IPV4_VERSION              : std_logic_vector(3 downto 0)  := X"4";
  --! Ipv4 Packet Header Lenght (unit: 32 bit word)
  constant IPV4_IHL                  : std_logic_vector(3 downto 0)  := X"5";
  --! Ipv4 Packet Service Type
  constant IPV4_SERVICE_TYPE         : std_logic_vector(7 downto 0)  := X"00";
  --! Ipv4 Packet Udp Signature
  constant IPV4_PROTOCOL_UDP         : std_logic_vector(7 downto 0)  := X"11";
  --! Ipv4 Packet Icmp Signature
  constant IPV4_PROTOCOL_ICMP        : std_logic_vector(7 downto 0)  := X"01";
  --! Ipv4 Id
  constant IPV4_ID                   : std_logic_vector(15 downto 0) := X"0000";
  --! IPV4 Flags
  constant IPV4_FLAGS                : std_logic_vector(2 downto 0)  := "000";
  --! IPV4 Fragment Offser
  constant IPV4_FRAGMENT_OFFSET      : std_logic_vector(12 downto 0)
    := "0000000000000";
  --! IPV4 Time To Live
  constant IPV4_TIME_TO_LIVE         : std_logic_vector(7 downto 0)  := X"40";
  ----------------------------------------------------- Arp Packet Constants ---
  --! Arp Packet Network Type
  constant ARP_NETWORK_TYPE_ETHERNET : std_logic_vector(15 downto 0) := X"0001";
  --! Arp Packet Protocol Type
  constant ARP_PROTOCOL_TYPE_IP      : std_logic_vector(15 downto 0) := X"0800";
  --! Arp Packet Hardware Address Size (unit: byte)
  constant ARP_HW_ADDRESS_SIZE       : std_logic_vector(7 downto 0)  := X"06";
  --! Arp Packet Logical Address Size (unit: byte)
  constant ARP_LOGICAL_ADDRESS_SIZE  : std_logic_vector(7 downto 0)  := X"04";
  --! Arp Packet Request Signature
  constant ARP_REQUEST               : std_logic_vector(15 downto 0) := X"0001";
  ---------------------------------------------------- Icmp Packet Constants ---
  --! Icmp Packet Request Type
  constant ICMP_ECHO_REQUEST_TYPE    : std_logic_vector(7 downto 0)  := X"08";
  --! Icmp Packet Request Code
  constant ICMP_ECHO_REQUEST_CODE    : std_logic_vector(7 downto 0)  := X"00";
  --! Icmp Packet Reply Type
  constant ICMP_ECHO_REPLY_TYPE      : std_logic_vector(7 downto 0)  := X"00";
  --! Icmp Packet Reply Code
  constant ICMP_ECHO_REPLY_CODE      : std_logic_vector(7 downto 0)  := X"00";
  ----------------------------------------------------- Udp Packet Constants ---
  --! Udp Header Length
  constant UDP_HEADER_LENGTH         : integer                       := 8;
  ------------------------------------------------ Rx Stream Type Definition ---
  --! Rx Stream Inputs
  type rx_stream_i_t is record
    ff_rx_data : std_logic_vector(31 downto 0);
    ff_rx_mod  : std_logic_vector(1 downto 0);
    ff_rx_sop  : std_logic;
    ff_rx_eop  : std_logic;
    ff_rx_err  : std_logic_vector(5 downto 0);
    ff_rx_val  : std_logic;
  end record;
  --! Rx Stream Outputs
  type rx_stream_o_t is record
    ff_rx_ready : std_logic;
  end record;
  ------------------------------------------------ Tx Stream Type Definition ---
  --! Tx Stream Inputs
  type tx_stream_i_t is record
    ff_tx_ready : std_logic;
  end record;
  --! Tx Stream Outputs
  type tx_stream_o_t is record
    ff_tx_data : std_logic_vector(31 downto 0);
    ff_tx_mod  : std_logic_vector(1 downto 0);
    ff_tx_sop  : std_logic;
    ff_tx_eop  : std_logic;
    ff_tx_err  : std_logic;
    ff_tx_wren : std_logic;
  end record;
  --! Tx Stream Outputs Default Value
  constant TX_STREAM_O_IDLE : tx_stream_o_t :=
    ((others => '0'),
     (others => '0'),
     '0',
     '0',
     '0',
     '0');
  ----------------------------------- Tse Configuration Port Type Definition ---
  --! Tse Config Port Inputs
  type tse_cfg_i_t is record
    tse_cfg_readdata    : std_logic_vector(31 downto 0);
    tse_cfg_waitrequest : std_logic;
  end record;
  --! Tse Config Port outputs
  type tse_cfg_o_t is record
    --! Tse Configuration Done
    tse_cfg_rst       : std_logic;
    tse_cfg_address   : std_logic_vector(9 downto 0);
    tse_cfg_write     : std_logic;
    tse_cfg_read      : std_logic;
    tse_cfg_writedata : std_logic_vector(31 downto 0);
  end record;
  -------------------------------- Ethernet Filter Output Signals Definition ---
  --! Ethernet Filter Output Signals
  type ethernet_signal_t is record
    sig_arp  : std_logic;
    sig_ipv4 : std_logic;
  end record;
  -------------------------------------------- Arp Filter Signals Definition --- 
  --! Arp Filter Output Signals
  type arp_signal_o_t is record
    sig_reply : std_logic;
  end record;
  ------------------------------------------- Ipv4 Filter Signals Definition ---
  --! Ipv4 Filter Output Signals
  type ipv4_signal_t is record
    sig_udp  : std_logic;
    sig_icmp : std_logic;
  end record;
  ------------------------------------- Udp Filter Output Signals Definition ---
  --! Udp Filter Output Signals
  type udp_signal_t is record
    -- sig_test                : std_logic_vector(7 downto 0);
    -- sig_config_video_stream : std_logic;
    -- sig_config_image_sensor : std_logic;
	    udp_data_valid : std_logic;
  end record;
  ------------------------------------ Icmp Filter Output Signals Definition ---
  --! Icmp Filter Output Signals
  type icmp_signal_t is record
    sig_reply : std_logic;
  end record;
  --! Icmp Reply Output Signals
  type icmp_reply_signal_t is record
    sig_reply : std_logic;
  end record;
  --------------------------------------------- Arp Reply Signals Definition ---
  --! Icmp Filter Input Signals
  type arp_reply_signal_i_t is record
    send : std_logic;
  end record;
  --! Icmp Reply Output Signals
  type arp_reply_signal_o_t is record
    done : std_logic;
  end record;
  -------------------------------------------- Icmp Reply Signals Definition ---
  --! Icmp Filter Input Signals
  type icmp_reply_signal_i_t is record
    send : std_logic;
  end record;
  --! Icmp Reply Output Signals
  type icmp_reply_signal_o_t is record
    done : std_logic;
  end record;
  -------------------------------------------- Udp Status Signals Definition ---
  --! Udp Status Input Signals
  type udp_status_signal_i_t is record
    send : std_logic;
  end record;
  --! Udp Status Output Signals
  type udp_status_signal_o_t is record
    done : std_logic;
  end record;  
  ---------------------------------- Udp Video Stream Out Signals Definition ---
  --! Udp Video Stream Out Input Signals
  type udp_video_stream_out_signal_i_t is record
    send : std_logic;
  end record;
  --! Udp Video Stream Out Output Signals
  type udp_video_stream_out_signal_o_t is record
    done : std_logic;
  end record;
  --------------------------------------- Ethernet Packet Header Data Record ---
  --! Ethernet Packet Header
  type ethernet_packet_header_t is record
    destination_mac_address : std_logic_vector(47 downto 0);
    source_mac_address      : std_logic_vector(47 downto 0);
    ethernet_type           : std_logic_vector(15 downto 0);
  end record;
  -------------------------------------------- Arp Packet Header Data Record ---
  --! ARP Packet Header
  type arp_packet_header_t is record
    source_ip_address      : std_logic_vector (31 downto 0);
    destination_ip_address : std_logic_vector (31 downto 0);
  end record;
  ------------------------------------------- Ipv4 Packet Header Data Record ---
  --! IPV4 Packet Header
  type ipv4_packet_header_t is record
    version                : std_logic_vector (3 downto 0);
    ihl                    : std_logic_vector (3 downto 0);
    service                : std_logic_vector (7 downto 0);
    data_length            : std_logic_vector (15 downto 0);
    id                     : std_logic_vector (15 downto 0);
    flags                  : std_logic_vector (2 downto 0);
    fragment_position      : std_logic_vector (12 downto 0);
    time_to_live           : std_logic_vector (7 downto 0);
    protocol               : std_logic_vector (7 downto 0);
    check_sum              : std_logic_vector (15 downto 0);
    source_ip_address      : std_logic_vector (31 downto 0);
    destination_ip_address : std_logic_vector (31 downto 0);
  end record;
  -------------------------------------------- Udp Packet Header Data Record ---
  --! UDP Packet Header
  type udp_packet_header_t is record
    source_port      : std_logic_vector (15 downto 0);
    destination_port : std_logic_vector (15 downto 0);
    data_length      : std_logic_vector (15 downto 0);
    check_sum        : std_logic_vector (15 downto 0);
  end record;
  ------------------------------------------- Icmp Packet Header Data Record ---
  --! ICMP Packet Header (32 Bytes Data Packet)
  type icmp_packet_header_t is record
    icmp_type       : std_logic_vector (7 downto 0);
    icmp_code       : std_logic_vector (7 downto 0);
    check_sum       : std_logic_vector (15 downto 0);
    id              : std_logic_vector (15 downto 0);
    sequence_number : std_logic_vector (15 downto 0);
    data_1          : std_logic_vector (31 downto 0);
    data_2          : std_logic_vector (31 downto 0);
    data_3          : std_logic_vector (31 downto 0);
    data_4          : std_logic_vector (31 downto 0);
    data_5          : std_logic_vector (31 downto 0);
    data_6          : std_logic_vector (31 downto 0);
    data_7          : std_logic_vector (31 downto 0);
    data_8          : std_logic_vector (31 downto 0);
  end record;
  ----------------------------------------- Configuration Packet Data Record ---
  --! Configuration Packet
  type configuration_packet_t is record
    --!  Reg 0
    reg_0 : std_logic_vector (31 downto 0);
    --!  Reg 1
    reg_1 : std_logic_vector (31 downto 0);
    --!  Reg 2
    reg_2 : std_logic_vector (31 downto 0);    
    --!  Reg 3
    reg_3 : std_logic_vector (31 downto 0);
    --!  Reg 4
    reg_4 : std_logic_vector (31 downto 0);    
    --!  Reg 5
    reg_5 : std_logic_vector (31 downto 0);
    --!  Reg 6
    reg_6 : std_logic_vector (31 downto 0);    
    --! Reg 7
    reg_7 : std_logic_vector (31 downto 0);        
 
  end record;
  ----------------------------------------------------- Tx arbiter constants ---
  --! Tx arbiter channel number
  constant TX_ARBITER_CHANNNEL_NUMBER : integer := 4;
  -------------------------------------------- Tx arbiter channel fsm states ---
  --! Tx arbiter channel fsm states
  type tx_arbiter_fsm_channel_state_t is (
    TX_ARBITER_CHANNEL_IDLE,
    TX_ARBITER_CHANNEL_WAIT,
    TX_ARBITER_CHANNEL_ACK,
    TX_ARBITER_CHANNEL_PROCESS
  );
  ----------------------------------------- Tx arbiter channel inputs Record ---
  --! Tx arbiter channel inputs
  type tx_arbiter_i_t is record
    request  : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
    --accepted : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
    release  : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
  end record;
  --------------------------------------- Tx arbiter channel outputs Record  ---
  --! Tx arbiter channel outputs
  type tx_arbiter_o_t is record
    acknowledge : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
    pending     : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
    memorized   : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
  end record;  
------------------------------------------------ Tx mux input vector Record  ---
  --! Tx mux input vector Record
  type tx_mux_vector_i_t is 
    array (TX_ARBITER_CHANNNEL_NUMBER-1 downto 0) of tx_stream_o_t;
  
  type pixel_row_o_t is record
    pixel_read : std_logic;
  end record;
  
  type pixel_row_i_t is record
    pixel_ready : std_logic;
    pixel_value : std_logic_vector (31 downto 0);
  end record;
end ethernet_package;

