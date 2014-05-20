library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
library work;
use work.ethernet_package.all;
use work.reset_generator_pack.all;

package ip_stack_comp is

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

  component ip_stack is
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
	 
		av_eth_config_0_conduit_end_Checksum_i         : in std_logic_vector(15 downto 0);                    -- Checksum_o
		av_eth_config_0_conduit_end_Send_port_i        : in std_logic_vector(15 downto 0);                    -- Send_port_o
		av_eth_config_0_conduit_end_Receive_port_i     : in std_logic_vector(15 downto 0);                    -- Receive_port_o
		av_eth_config_0_conduit_end_Sender_IP_i        : in std_logic_vector(31 downto 0);                    -- Sender_IP_o
		av_eth_config_0_conduit_end_Receiver_IP_i      : in std_logic_vector(31 downto 0);                    -- Receiver_IP_o
		av_eth_config_0_conduit_end_Sender_MAC_LSB_i   : in std_logic_vector(31 downto 0);                    -- Sender_MAC_LSB_o
		av_eth_config_0_conduit_end_Sender_MAC_MSB_i   : in std_logic_vector(31 downto 0);                    -- Sender_MAC_MSB_o
		av_eth_config_0_conduit_end_Receiver_MAC_LSB_i : in std_logic_vector(31 downto 0);                    -- Receiver_MAC_LSB_o
		av_eth_config_0_conduit_end_Receiver_MAC_MSB_i : in std_logic_vector(31 downto 0);                    -- Receiver_MAC_MSB_o
	 
	   av_sendpacket_0_conduit_end_checksum_i       : in std_logic_vector(15 downto 0);                    -- checksum_o
	   av_sendpacket_0_conduit_end_local_port_i     : in std_logic_vector(15 downto 0);                    -- local_port_o
	   av_sendpacket_0_conduit_end_remote_port_i    : in std_logic_vector(15 downto 0);                    -- remote_port_o
	   av_sendpacket_0_conduit_end_remote_IP_i      : in std_logic_vector(31 downto 0);                    -- remote_IP_o
	   av_sendpacket_0_conduit_end_remote_MAC_MSB_i : in std_logic_vector(31 downto 0);                    -- remote_MAC_MSB_o
	   av_sendpacket_0_conduit_end_remote_MAC_LSB_i : in std_logic_vector(31 downto 0)                     -- remote_MAC_LSB_o
      );
  end component ip_stack;

end ip_stack_comp;