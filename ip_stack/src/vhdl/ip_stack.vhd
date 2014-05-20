--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2012-11-16
--! @brief Tse Mac Interface
--! @details
--!
--! @page p_Tse_Mac_Interface Tse Mac Interface
--! This page describes Tse Mac Interface contents.
--! @section sec_000 Revisions
--! - 2012-04-10 : Created
--! @section sec_001 Block diagram
--! @image html tse_mac_interface-block_diagram.png "Tse_Mac_Interface block diagram"
--! @section sec_002 Concepts
--! Tse Mac Interface implements Ip stack up to Udp protocol.
--! Tse Mac Interface comunicates with Tse Mac Ip for transmiting,
--! receiving packets, and configuring Tse Mac Ip and Marvell Physical Interface.
-------------------------------------------------------------------------------
--! Librairies
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ethernet_package.all;
use work.ip_stack_pack.all;
use work.reset_generator_pack.all;

-------------------------------------------------------------------------------
--! Ip Stack Entity
entity ip_stack_entity is
  port(
    --! Master Clock
    clk_i                  : in  std_logic;
    -- System Reset     
    com_rst_i              : in  com_rst_m2s_t;
    com_rst_o              : out com_rst_s2m_t;
    -- Rx Stream         
    ff_rx_ready            : out std_logic;
    ff_rx_data             : in  std_logic_vector(31 downto 0);
    ff_rx_mod              : in  std_logic_vector(1 downto 0);
    ff_rx_sop              : in  std_logic;
    ff_rx_eop              : in  std_logic;
    ff_rx_err              : in  std_logic_vector(5 downto 0);
    ff_rx_val              : in  std_logic;
    -- Tx Stream         
    ff_tx_ready            : in  std_logic;
    ff_tx_data             : out std_logic_vector(31 downto 0);
    ff_tx_mod              : out std_logic_vector(1 downto 0);
    ff_tx_sop              : out std_logic;
    ff_tx_eop              : out std_logic;
    ff_tx_err              : out std_logic;
    ff_tx_wren             : out std_logic;
    -- Tse Configuration Port
    tse_cfg_address        : out std_logic_vector(9 downto 0);
    tse_cfg_write          : out std_logic;
    tse_cfg_read           : out std_logic;
    tse_cfg_writedata      : out std_logic_vector(31 downto 0);
    tse_cfg_readdata       : in  std_logic_vector(31 downto 0);
    tse_cfg_waitrequest    : in  std_logic;
    -- Configuration By Ethernet Packet
    configuration_packet_o : out configuration_packet_t;
    --
    udp_send_status_i      : in  std_logic;
    -- 
    udp_send_video_line_i  : in  std_logic;
    pixel_ready_i          : in  std_logic;
    pixel_read_o           : out std_logic;
    pixel_i                : in  std_logic_vector(31 downto 0);
	 
	 fifo_empty_i : in std_logic;
	 rd_fifo_o : out std_logic;	 
	 
	 -- Avalon interface
	 avalon_status_register0 : in std_logic_vector(31 downto 0);
	 avalon_status_register1 : in std_logic_vector(31 downto 0);
	 avalon_status_register2 : in std_logic_vector(31 downto 0);
	 avalon_status_register3 : in std_logic_vector(31 downto 0);
	 avalon_status_register4 : in std_logic_vector(31 downto 0);
	 avalon_status_register5 : in std_logic_vector(31 downto 0);
	 avalon_status_register6 : in std_logic_vector(31 downto 0);
	 avalon_status_register7 : in std_logic_vector(31 downto 0);
	 udp_signal_s           : out udp_signal_t;
	 av_eth_config_0_conduit_end_local_port_i     : in std_logic_vector(15 downto 0);
	 av_eth_config_0_conduit_end_remote_port_i    : in std_logic_vector(15 downto 0); 
	 av_eth_config_0_conduit_end_local_IP_i       : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_remote_IP_i      : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_local_MAC_LSB_i  : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_local_MAC_MSB_i  : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_remote_MAC_LSB_i : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_checksum_i       : in std_logic_vector(15 downto 0);
	 av_eth_config_0_conduit_end_remote_MAC_MSB_i : in std_logic_vector(31 downto 0);
	 
	 av_sendpacket_0_conduit_end_checksum_i       : in std_logic_vector(15 downto 0);                    -- checksum_o
	 av_sendpacket_0_conduit_end_local_port_i     : in std_logic_vector(15 downto 0);                    -- local_port_o
	 av_sendpacket_0_conduit_end_remote_port_i    : in std_logic_vector(15 downto 0);                    -- remote_port_o
	 av_sendpacket_0_conduit_end_remote_IP_i      : in std_logic_vector(31 downto 0);                    -- remote_IP_o
	 av_sendpacket_0_conduit_end_remote_MAC_MSB_i : in std_logic_vector(31 downto 0);                    -- remote_MAC_MSB_o
	 av_sendpacket_0_conduit_end_remote_MAC_LSB_i : in std_logic_vector(31 downto 0);                    -- remote_MAC_LSB_o
	 av_sendpacket_0_conduit_end_length_i 			 : in std_logic_vector(15 downto 0)                    -- remote_MAC_LSB_o
	 
	  
    );
end ip_stack_entity;
-------------------------------------------------------------------------------
--! Ip Stack Architecture
architecture syn of ip_stack_entity is
  --! Rx Stream Input
  signal rx_stream_i_s                   : rx_stream_i_t;
  --! Rx Stream Output
  signal rx_stream_o_s                   : rx_stream_o_t;
  --! Tx Stream Input
  signal tx_stream_i_s                   : tx_stream_i_t;
  --! Tx Stream Output
  signal tx_stream_o_s                   : tx_stream_o_t;
  --! Tse Mac Configuration Port Input
  signal tse_cfg_i_s                     : tse_cfg_i_t;
  --! Tse Mac Configuration Port Output
  signal tse_cfg_o_s                     : tse_cfg_o_t;
  --! @todo comment
  signal arp_tx_stream_o_s               : tx_stream_o_t;
  --! @todo comment
  signal icmp_tx_stream_o_s              : tx_stream_o_t;
  --! @todo comment
  signal udp_video_o_s                   : tx_stream_o_t;
  --! @todo comment
  signal udp_status_o_s                  : tx_stream_o_t;
  --! Ethernet Packet Header
  signal eth_packet_header_s             : ethernet_packet_header_t;
  --! ARP Packet Header  
  signal arp_packet_header_s             : arp_packet_header_t;
  --! IPV4 Packet Header
  signal ipv4_packet_header_s            : ipv4_packet_header_t;
  --! UDP Packet Header  
  signal udp_packet_header_s             : udp_packet_header_t;
  --! ICMP Packet Header  
  signal icmp_packet_header_s            : icmp_packet_header_t;
  --! Ethernet Filter Output Signals
  signal ethernet_signal_s               : ethernet_signal_t;
  --! Arp Filter Output Signals
  signal arp_signal_o_s                  : arp_signal_o_t;
  --! Ipv4 Filter Output Signals
  signal ipv4_signal_s                   : ipv4_signal_t;
  --! Udp Filter Output Signals
  -- signal udp_signal_s                    : udp_signal_t;
  --! Icmp Filter Output Signals
  signal icmp_signal_s                   : icmp_signal_t;
  --! Arp Reply Input Signals
  signal arp_reply_signal_i_s            : arp_reply_signal_i_t;
  --! Arp Reply Output Signals  
  signal arp_reply_signal_o_s            : arp_reply_signal_o_t;
  --! Icmp Reply Input Signals
  signal icmp_reply_signal_i_s           : icmp_reply_signal_i_t;
  --! Icmp Reply Output Signals  
  signal icmp_reply_signal_o_s           : icmp_reply_signal_o_t;
  --! Udp status Input Signals  
  signal udp_status_signal_i_s           : udp_status_signal_i_t;
  --! Udp Status Output Signals  
  signal udp_status_signal_o_s           : udp_status_signal_o_t;
  

  --! @todo comment
  signal configuration_packet_s          : configuration_packet_t;
  --! Udp Video Stream Out Input Signals
  signal udp_video_stream_out_signal_i_s : udp_video_stream_out_signal_i_t;
  --! Udp Video Stream Out Output Signals
  signal udp_video_stream_out_signal_o_s : udp_video_stream_out_signal_o_t;
  --! Configuration Instance Output Reset
  signal cfg_rst_s                       : std_logic;
  -- TX Priority Arbiter Inputs
  signal tx_arbiter_i_s                  : tx_arbiter_i_t;
  -- TX Priority Arbiter Outputs  
  signal tx_arbiter_o_s                  : tx_arbiter_o_t;
  signal channel_s                       : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
  signal vector_s                        : tx_mux_vector_i_t;
  
  -- NIOS registers
  signal av_eth_config_0_conduit_end_local_port_s     : std_logic_vector(15 downto 0);
  signal av_eth_config_0_conduit_end_remote_port_s    : std_logic_vector(15 downto 0); 
  signal av_eth_config_0_conduit_end_local_IP_s       : std_logic_vector(31 downto 0); 
  signal av_eth_config_0_conduit_end_remote_IP_s      : std_logic_vector(31 downto 0); 
  signal av_eth_config_0_conduit_end_local_MAC_LSB_s  : std_logic_vector(31 downto 0); 
  signal av_eth_config_0_conduit_end_local_MAC_MSB_s  : std_logic_vector(31 downto 0); 
  signal av_eth_config_0_conduit_end_remote_MAC_LSB_s : std_logic_vector(31 downto 0); 
  signal av_eth_config_0_conduit_end_checksum_s       : std_logic_vector(15 downto 0);
  signal av_eth_config_0_conduit_end_remote_MAC_MSB_s : std_logic_vector(31 downto 0);
	 
	signal pixel_s : std_logic_vector(31 downto 0);
	 
	  component random is
    generic ( width : integer :=  32 ); 
		port (
      clk : in std_logic;
      random_num : out std_logic_vector (width-1 downto 0)   --output vector            
    );
end component;

-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
  -- Reset System
  com_rst_o.rst_done   <= not tse_cfg_o_s.tse_cfg_rst;
  com_rst_o.rst_status <= COM_RESET;

--------------------------------------------------------------------------------  
  -- Rx Stream Mapping
  rx_stream_i_s.ff_rx_data        <= ff_rx_data;
  rx_stream_i_s.ff_rx_mod         <= ff_rx_mod;
  rx_stream_i_s.ff_rx_sop         <= ff_rx_sop;
  rx_stream_i_s.ff_rx_eop         <= ff_rx_eop;
  rx_stream_i_s.ff_rx_err         <= ff_rx_err;
  rx_stream_i_s.ff_rx_val         <= ff_rx_val;
  ff_rx_ready                     <= rx_stream_o_s.ff_rx_ready;
  -- Tx Stream Mapping
  ff_tx_data                      <= tx_stream_o_s.ff_tx_data;
  ff_tx_mod                       <= tx_stream_o_s.ff_tx_mod;
  ff_tx_sop                       <= tx_stream_o_s.ff_tx_sop;
  ff_tx_eop                       <= tx_stream_o_s.ff_tx_eop;
  ff_tx_err                       <= tx_stream_o_s.ff_tx_err;
  ff_tx_wren                      <= tx_stream_o_s.ff_tx_wren;
  tx_stream_i_s.ff_tx_ready       <= ff_tx_ready;
  -- Tse Configuration Bus Mapping
  tse_cfg_address                 <= tse_cfg_o_s.tse_cfg_address;
  tse_cfg_write                   <= tse_cfg_o_s.tse_cfg_write;
  tse_cfg_read                    <= tse_cfg_o_s.tse_cfg_read;
  tse_cfg_writedata               <= tse_cfg_o_s.tse_cfg_writedata;
  tse_cfg_i_s.tse_cfg_readdata    <= tse_cfg_readdata;
  tse_cfg_i_s.tse_cfg_waitrequest <= tse_cfg_waitrequest;
  -- Reset Signal Generated by Configuration Module
  cfg_rst_s                       <= tse_cfg_o_s.tse_cfg_rst;
  -- Always Ready for Receiving
  rx_stream_o_s.ff_rx_ready       <= '1';
  -- Configuration packet broadcasting
  configuration_packet_o          <= configuration_packet_s;
  
   
   
	 
--------------------------------------------------------------------------------  
  --! Mac_etm Configuration Instance
  TSE_CONFIG_INST : tse_config
      port map (
        clk_i     => clk_i,
        rst_i     => com_rst_i.rst,
        tse_cfg_i => tse_cfg_i_s,
        tse_cfg_o => tse_cfg_o_s
        );
--------------------------------------------------------------------------------
  --! Ethernet Packet Filter Instance
  ETHERNET_PACKET_FILTER_INST :
    entity work.ethernet_packet_filter(ethernet_packet_filter_arc)
      port map (
        clk_i                    => clk_i,
        rst_i                    => cfg_rst_s,
        rx_stream_i              => rx_stream_i_s,
        ethernet_packet_header_o => eth_packet_header_s,
        ethernet_signal_o        => ethernet_signal_s,
		  av_eth_config_0_conduit_end_local_MAC_LSB_i  => av_eth_config_0_conduit_end_local_MAC_LSB_i,
		  av_eth_config_0_conduit_end_local_MAC_MSB_i  => av_eth_config_0_conduit_end_local_MAC_MSB_i
        );
--------------------------------------------------------------------------------  
  --! Arp Packet Filter Instance
  ARP_PACKET_FILTER_INST :
    entity work.arp_packet_filter(arp_packet_filter_arc)
      port map (
        clk_i                    => clk_i,
        rst_i                    => cfg_rst_s,
        rx_stream_i              => rx_stream_i_s,
        ethernet_packet_header_i => eth_packet_header_s,
        ethernet_signal_i        => ethernet_signal_s,
        arp_packet_header_o      => arp_packet_header_s,
        arp_signal_o             => arp_signal_o_s,
		  avalon_local_IP_i        => av_eth_config_0_conduit_end_local_IP_i
        );
--------------------------------------------------------------------------------  
  --! Ipv4 Packet Filter Instance
  IPV4_PACKET_FILTER_INST :
    entity work.ipv4_packet_filter(ipv4_packet_filter_arc)
      port map (
        clk_i                    => clk_i,
        rst_i                    => cfg_rst_s,
        rx_stream_i              => rx_stream_i_s,
        ethernet_packet_header_i => eth_packet_header_s,
        ethernet_signal_i        => ethernet_signal_s,
        ipv4_packet_header_o     => ipv4_packet_header_s,
        ipv4_signal_o            => ipv4_signal_s,
		  avalon_local_IP_i         => av_eth_config_0_conduit_end_local_IP_i
        );
--------------------------------------------------------------------------------  
  --: Udp Packet Filter Instance
  UDP_PACKET_FILTER_INST :
    entity work.udp_packet_filter(udp_packet_filter_arc)
      port map (
        clk_i                    => clk_i,
        rst_i                    => cfg_rst_s,
        rx_stream_i              => rx_stream_i_s,
        ethernet_packet_header_i => eth_packet_header_s,
        ipv4_packet_header_i     => ipv4_packet_header_s,
        ipv4_signal_i            => ipv4_signal_s,
        udp_packet_header_o      => udp_packet_header_s,
        configuration_packet_o   => configuration_packet_s,
        udp_signal_o             => udp_signal_s,
		  avalon_local_port_i      => av_eth_config_0_conduit_end_local_port_i
        );
--------------------------------------------------------------------------------  
  --! Icmp Packet Filter Instance
  ICMP_PACKET_FILTER_INST :
    entity work.icmp_packet_filter(icmp_packet_filter_arc)
      port map (
        clk_i                    => clk_i,
        rst_i                    => cfg_rst_s,
        rx_stream_i              => rx_stream_i_s,
        ethernet_packet_header_i => eth_packet_header_s,
        ipv4_packet_header_i     => ipv4_packet_header_s,
        ipv4_signal_i            => ipv4_signal_s,
        icmp_packet_header_o     => icmp_packet_header_s,
        icmp_signal_o            => icmp_signal_s
        );
--------------------------------------------------------------------------------
  --! Arp Reply Packet Generator Instance
  ARP_REPLY_INST :
    entity work.arp_reply(arp_reply_arc)
      port map (
        clk_i                    => clk_i,
        rst_i                    => cfg_rst_s,
        tx_stream_o              => arp_tx_stream_o_s,
        tx_stream_i              => tx_stream_i_s,
        ethernet_packet_header_i => eth_packet_header_s,
        arp_packet_header_i      => arp_packet_header_s,
        arp_reply_signal_i       => arp_reply_signal_i_s,
        arp_reply_signal_o       => arp_reply_signal_o_s,
		  avalon_local_MAC_LSB_i    => av_eth_config_0_conduit_end_local_MAC_LSB_i,
		  avalon_local_MAC_MSB_i    => av_eth_config_0_conduit_end_local_MAC_MSB_i
        );
--------------------------------------------------------------------------------  
  --! Icmp Reply Packet Generator Instance
  ICMP_REPLY_INST :
    entity work.icmp_reply(icmp_reply_arc)
      port map (
        clk_i                    => clk_i,
        rst_i                    => cfg_rst_s,
        tx_stream_o              => icmp_tx_stream_o_s,
        tx_stream_i              => tx_stream_i_s,
        ethernet_packet_header_i => eth_packet_header_s,
        ipv4_packet_header_i     => ipv4_packet_header_s,
        icmp_packet_header_i     => icmp_packet_header_s,
        icmp_reply_signal_i      => icmp_reply_signal_i_s,
        icmp_reply_signal_o      => icmp_reply_signal_o_s,
		  avalon_local_MAC_LSB_i   => av_eth_config_0_conduit_end_local_MAC_LSB_i,
		  avalon_local_MAC_MSB_i   => av_eth_config_0_conduit_end_local_MAC_MSB_i
        );
--------------------------------------------------------------------------------
  --! Udp Status Module
  UDP_STATUS_INST : udp_status
      port map (
        clk_i       =>clk_i,               
        rst_i       =>cfg_rst_s,          
        tx_stream_o =>udp_status_o_s,          
        tx_stream_i =>tx_stream_i_s,          
        signal_i    =>udp_status_signal_i_s,
		  avalon_status_register0_i => avalon_status_register0,
		  avalon_status_register1_i => avalon_status_register1,
		  avalon_status_register2_i => avalon_status_register2,
		  avalon_status_register3_i => avalon_status_register3,
        avalon_status_register4_i => avalon_status_register4,
        avalon_status_register5_i => avalon_status_register5,
		  avalon_status_register6_i => avalon_status_register6,
		  avalon_status_register7_i => avalon_status_register7,
		  avalon_local_port_i       => av_eth_config_0_conduit_end_local_port_i,
		  avalon_remote_port_i      => av_eth_config_0_conduit_end_remote_port_i,
		  avalon_local_IP_i         => av_eth_config_0_conduit_end_local_IP_i,
		  avalon_remote_IP_i        => av_eth_config_0_conduit_end_remote_IP_i,
		  avalon_local_MAC_LSB_i    => av_eth_config_0_conduit_end_local_MAC_LSB_i,
		  avalon_local_MAC_MSB_i    => av_eth_config_0_conduit_end_local_MAC_MSB_i,
		  avalon_remote_MAC_LSB_i   => av_eth_config_0_conduit_end_remote_MAC_LSB_i,
		  avalon_checksum_i         => av_eth_config_0_conduit_end_checksum_i,
		  avalon_remote_MAC_MSB_i   => av_eth_config_0_conduit_end_remote_MAC_MSB_i,
		  signal_o    =>udp_status_signal_o_s
        );
--------------------------------------------------------------------------------

 RANDOM_INST : random
 port map(
	clk =>clk_i,
	random_num => pixel_s
 );

	 	 
  --! Udp Video Stream Out Module
  UDP_VIDEO_STREAM_OUT_INST : udp_video
      port map (
        clk_i                  => clk_i,
        rst_i                  => cfg_rst_s,
        tx_stream_o            => udp_video_o_s,
        tx_stream_i            => tx_stream_i_s,
        configuration_packet_i => configuration_packet_s,
        signal_i               => udp_video_stream_out_signal_i_s,
        signal_o               => udp_video_stream_out_signal_o_s,
        pixel_ready_i          => pixel_ready_i,
        pixel_read_o           => pixel_read_o,
        pixel_i                => pixel_s,  
		  fifo_empty_i => fifo_empty_i,
		  rd_fifo_o => rd_fifo_o,
		  avalon_local_port_i       => av_sendpacket_0_conduit_end_local_port_i,
		  avalon_remote_port_i      => av_sendpacket_0_conduit_end_remote_port_i,
		  avalon_local_IP_i         => av_eth_config_0_conduit_end_local_IP_i,
		  avalon_remote_IP_i        => av_sendpacket_0_conduit_end_remote_IP_i,
		  avalon_local_MAC_LSB_i    => av_eth_config_0_conduit_end_local_MAC_LSB_i,
		  avalon_local_MAC_MSB_i    => av_eth_config_0_conduit_end_local_MAC_MSB_i,
		  avalon_remote_MAC_LSB_i   => av_sendpacket_0_conduit_end_remote_MAC_LSB_i,
		  avalon_checksum_i         => av_sendpacket_0_conduit_end_checksum_i,
		  avalon_remote_MAC_MSB_i   => av_sendpacket_0_conduit_end_remote_MAC_MSB_i,
		  avalon_length_i => av_sendpacket_0_conduit_end_length_i
        );
--------------------------------------------------------------------------------
  --! Tx arbiter Instance
  TX_ARBITER_INST :
    entity work.tx_arbiter(tx_arbiter_arc)
      port map (
        clk_i        => clk_i,
        rst_i        => cfg_rst_s,
        tx_arbiter_i => tx_arbiter_i_s,
        tx_arbiter_o => tx_arbiter_o_s
        );
  -- Channel 0 mapping : arp reply
  tx_arbiter_i_s.request(0)            <= arp_signal_o_s.sig_reply;
  arp_reply_signal_i_s.send            <= tx_arbiter_o_s.acknowledge(0);
  tx_arbiter_i_s.release(0)            <= arp_reply_signal_o_s.done;
  -- Channel 1 mapping : icmp reply
  tx_arbiter_i_s.request(1)            <= icmp_signal_s.sig_reply;
  icmp_reply_signal_i_s.send           <= tx_arbiter_o_s.acknowledge(1);
  tx_arbiter_i_s.release(1)            <= icmp_reply_signal_o_s.done;
  -- Channel 2 mapping : udp status out
  tx_arbiter_i_s.request(2)            <= udp_send_status_i;
  udp_status_signal_i_s.send           <= tx_arbiter_o_s.acknowledge(2);
  tx_arbiter_i_s.release(2)            <= udp_status_signal_o_s.done;
  
  -- Channel 2 mapping : udp video stream out
  tx_arbiter_i_s.request(3)            <= udp_send_video_line_i;
  udp_video_stream_out_signal_i_s.send <= tx_arbiter_o_s.acknowledge(3);
  tx_arbiter_i_s.release(3)            <= udp_video_stream_out_signal_o_s.done;
--------------------------------------------------------------------------------
  --! Tx Stream Mux
  TX_MUX_INST :
    entity work.tx_mux_entity(tx_mux_arc)
      port map (
        vector_i  => vector_s,
        scalar_o  => tx_stream_o_s,
        channel_i => channel_s
      );
      vector_s <= (udp_video_o_s,
                   udp_status_o_s,
                   icmp_tx_stream_o_s,
                   arp_tx_stream_o_s);
                   
      channel_s <= tx_arbiter_o_s.pending(3) &
                   tx_arbiter_o_s.pending(2) &
                   tx_arbiter_o_s.pending(1) &
                   tx_arbiter_o_s.pending(0);
    -- tx_stream_o_s <=
      -- arp_tx_stream_o_s  when tx_arbiter_o_s.pending(0) = '1' else
      -- icmp_tx_stream_o_s when tx_arbiter_o_s.pending(1) = '1' else
      -- udp_video_o_s      when tx_arbiter_o_s.pending(2) = '1' else
      -- TX_STREAM_O_IDLE;
--------------------------------------------------------------------------------  
end syn;
