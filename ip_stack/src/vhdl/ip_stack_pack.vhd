library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
library work;
use work.ethernet_package.all;

package ip_stack_pack is

  -- Static constants 

  -- Local types
 
  -- Local components 
  component tse_config is
    port(
      clk_i : in std_logic;
      rst_i : in std_logic;
      
      tse_cfg_i : in tse_cfg_i_t;
      tse_cfg_o : out tse_cfg_o_t
      );
  end component tse_config;

  
  component udp_status is
  port(
    -- Global Signals
    clk_i                    : in  std_logic;
    rst_i                    : in  std_logic;
    -- TX Stream
    tx_stream_o              : out tx_stream_o_t;
    tx_stream_i              : in  tx_stream_i_t;
    -- Input Signals
    signal_i                 : in  udp_status_signal_i_t; 
	 
	 avalon_status_register0_i : in std_logic_vector(31 downto 0);
	 avalon_status_register1_i : in std_logic_vector(31 downto 0);
	 avalon_status_register2_i : in std_logic_vector(31 downto 0);
	 avalon_status_register3_i : in std_logic_vector(31 downto 0);
	 avalon_status_register4_i : in std_logic_vector(31 downto 0);
	 avalon_status_register5_i : in std_logic_vector(31 downto 0);
	 avalon_status_register6_i : in std_logic_vector(31 downto 0);
	 avalon_status_register7_i : in std_logic_vector(31 downto 0);
	 avalon_local_port_i     : in std_logic_vector(15 downto 0);                    -- local_port_o
	 avalon_remote_port_i    : in std_logic_vector(15 downto 0);                    -- remote_port_o
	 avalon_local_IP_i       : in std_logic_vector(31 downto 0);                    -- local_IP_o
	 avalon_remote_IP_i      : in std_logic_vector(31 downto 0);                    -- remote_IP_o
	 avalon_local_MAC_LSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_LSB_o
	 avalon_local_MAC_MSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_MSB_o
	 avalon_remote_MAC_LSB_i : in std_logic_vector(31 downto 0);                    -- remote_MAC_LSB_o
	 avalon_checksum_i       : in std_logic_vector(15 downto 0);                    -- checksum_o
	 avalon_remote_MAC_MSB_i : in std_logic_vector(31 downto 0);                    -- remote_MAC_MSB_o
			
    -- Output Signals
    signal_o                 : out udp_status_signal_o_t
	 
    );
end component udp_status;

  component udp_video is
    port(
      -- Global Signals
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      -- TX Stream
      tx_stream_o : out tx_stream_o_t;
      tx_stream_i : in  tx_stream_i_t;
      -- Configuration 
      configuration_packet_i : in  configuration_packet_t;
      -- Input Signals
      signal_i               : in  udp_video_stream_out_signal_i_t;
      -- Output Signals
      signal_o               : out udp_video_stream_out_signal_o_t;
      --
      pixel_ready_i         : in  std_logic;
      pixel_read_o          : out std_logic;
      pixel_i               : in  std_logic_vector(31 downto 0);
	
		fifo_empty_i : in std_logic;
	   rd_fifo_o : out std_logic;
		
		avalon_local_port_i     : in std_logic_vector(15 downto 0);                    -- local_port_o
	   avalon_remote_port_i    : in std_logic_vector(15 downto 0);                    -- remote_port_o
	   avalon_local_IP_i       : in std_logic_vector(31 downto 0);                    -- local_IP_o
	   avalon_remote_IP_i      : in std_logic_vector(31 downto 0);                    -- remote_IP_o
	   avalon_local_MAC_LSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_LSB_o
	   avalon_local_MAC_MSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_MSB_o
	   avalon_remote_MAC_LSB_i : in std_logic_vector(31 downto 0);                    -- remote_MAC_LSB_o
	   avalon_checksum_i       : in std_logic_vector(15 downto 0);                    -- checksum_o
	   avalon_remote_MAC_MSB_i : in std_logic_vector(31 downto 0);                     -- remote_MAC_MSB_o
		avalon_length_i			: in std_logic_vector(15 downto 0)
      );
  end component udp_video;

end ip_stack_pack;