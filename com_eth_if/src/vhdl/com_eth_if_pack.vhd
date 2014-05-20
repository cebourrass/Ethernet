library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.debug_pack.all;
use work.reset_generator_pack.all;
use work.ticks_generator_pack.all;
use work.rgmii_if_pack.all;
use work.ethernet_package.all;

package com_eth_if_pack is

  component com_eth_if
    port (
    -- System clock
    clk_50mhz_i    : in    std_logic;
    clk_100mhz_i   : in    std_logic;
    -- 
    clk_125mhz_i   : in    std_logic;    
    -- System reset
    rst_i          : in    com_rst_m2s_t;
    rst_o          : out   com_rst_s2m_t;
    -- System ticks
    ticks_i        : in    ticks_t;
    -- Rgmii interface               
    rgmii_i        : in    rgmii_i_t;
    rgmii_o        : out   rgmii_o_t;
    -- Rmii interface
    gmii_i         : in    gmii_i_t;
    gmii_o         : out   gmii_o_t;      
    -- Marvell 
    eth_reset_n_o  : out   std_logic;
    eth_mdc_o      : out   std_logic;
    eth_mdio_io    : inout std_logic;
    -- Debug
    debug_o        : out   debug_o_t;
    -- udp
    udp_send_video_line_i	: in std_logic;
    pixel_ready_i		      : in std_logic;
    pixel_read_o          : out std_logic;
    pixel_i               : in std_logic_vector(31 downto 0);
	fifo_empty_i : in std_logic;
	   rd_fifo_o : out std_logic;
		
		  -- Avalon interface
	 avalon_status_register0_i : in std_logic_vector(31 downto 0);
	 avalon_status_register1_i : in std_logic_vector(31 downto 0);
	 avalon_status_register2_i : in std_logic_vector(31 downto 0);
	 avalon_status_register3_i : in std_logic_vector(31 downto 0);
	 avalon_status_register4_i : in std_logic_vector(31 downto 0);
	 avalon_status_register5_i : in std_logic_vector(31 downto 0);
	 avalon_status_register6_i : in std_logic_vector(31 downto 0);
	 avalon_status_register7_i : in std_logic_vector(31 downto 0);
	 udp_send_status_i : in std_logic;
	 udp_signal_o      : out udp_signal_t;
	 configuration_packet_o : out configuration_packet_t;
	 
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
	 av_sendpacket_0_conduit_end_length_i : in std_logic_vector(15 downto 0)
      );
  end component;
  
type packet_t is array (0 to 31) of std_logic_vector (31 downto 0);
  
  constant PACKET_TEST : packet_t :=(
    X"FF_FF_FF_FF",
    X"FF_FF_00_00",
    X"00_00_00_11",
    X"08_06_00_01",
    X"08_00_06_04",
    X"00_01_00_00",
    X"00_00_00_11",
    X"C0_A8_00_02",
    X"00_00_00_00",
    X"00_00_C0_A8",
    X"00_01_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00",
    X"00_00_00_00"
   -- X"55", X"55", X"55", X"55", X"55", X"55", X"55", X"D5", -- Preambule
   -- X"FF", X"FF", X"FF", X"FF", X"FF", X"FF",               -- Mac des
   -- X"00", X"00", X"00", X"00", X"00", X"11",               -- Mac source
   -- X"08", X"06",                                           -- Type Arp
   -- X"00", X"01",                                           -- Eth type
   -- X"08", X"00",                                           -- Protocol type IP 
   -- X"06",                                                  -- HW size
   -- X"04",                                                  -- Protocol size
   -- X"00", X"01",                                           -- OP code request
   -- X"00", X"00", X"00", X"00", X"00", X"11",               -- Mac source
   -- X"C0", X"A8", X"00", X"02",                             -- IP source
   -- X"00", X"00", X"00", X"00", X"00", X"00",               -- Mac dest
   -- X"C0", X"A8", X"00", X"01",                             -- IP dest
   -- X"00", X"00", X"00", X"00",                             -- Padding
   -- X"00", X"00", X"00", X"00",                             
   -- X"00", X"00", X"00", X"00",                             
   -- X"00", X"00", X"00", X"00",                             
   -- X"00", X"00",                                                                      -- 
   -- X"4E", X"11", X"89", X"C4",                             -- CRC Bytes in reverse order (BE)
   -- -- X"FE", X"1C", X"23", X"31",                             -- CRC Bytes in reverse order (BE)
   -- X"00", X"00", X"00", X"00",
   -- X"00", X"00", X"00", X"00",                             
   -- X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   -- X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   -- X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   -- X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   -- X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
   -- X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
  );
   -- 255,255,255,255,255,255,
   -- 000,000,000,000,000,011,
   -- 8,006,000,001,8,000,006,004,000,001,
   -- 000,000,000,000,000,007,
   -- 192,168,000,002,
   -- 000,000,000,000,000,000,
   -- 192,168,000,001  
end package;
