library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;

entity ethernet_packet_filter is
  port(
    -- Global Signals
    clk_i                    : in  std_logic;
    rst_i                    : in  std_logic;
    -- RX Stream
    rx_stream_i              : in  rx_stream_i_t;
    --rx_stream_o : in rx_stream_o_t
    -- Extracted Information
    ethernet_packet_header_o : out ethernet_packet_header_t;
    -- Output Signals
    ethernet_signal_o        : out ethernet_signal_t;
	 -- NIOS register MAC address
	 av_eth_config_0_conduit_end_local_MAC_LSB_i  : in std_logic_vector(31 downto 0); 
    av_eth_config_0_conduit_end_local_MAC_MSB_i  : in std_logic_vector(31 downto 0)
    );
end ethernet_packet_filter;

architecture ethernet_packet_filter_arc of ethernet_packet_filter is

  type ethernet_header_state_t is (
    ETH_MAC_DST_0,
    ETH_MAC_DST_1,
    ETH_MAC_SRC_0,
    MAC_SRC_1_PROTOCOL,
    ETH_PAYLOAD
    );

  signal ethernet_header_state_r  : ethernet_header_state_t;
  signal ethernet_packet_header_s : ethernet_packet_header_t;
  
begin

  ethernet_packet_header_o <= ethernet_packet_header_s;

  ETH_HEADER_SCAN : process (clk_i, rst_i)
  begin
    if (rst_i = '1') then
        ethernet_header_state_r                          <= ETH_MAC_DST_0;
        ethernet_packet_header_s.destination_mac_address <= (others => '0');
        ethernet_packet_header_s.source_mac_address      <= (others => '0');
        ethernet_signal_o.sig_arp                        <= '0';
        ethernet_signal_o.sig_ipv4                       <= '0';
    else
      if (clk_i'event and clk_i = '1') then
        if (rx_stream_i.ff_rx_val = '0') then
        else
          case ethernet_header_state_r is
            when ETH_MAC_DST_0 =>
              if (rx_stream_i.ff_rx_sop = '1') then
                ethernet_packet_header_s.destination_mac_address(47 downto 40) <= rx_stream_i.ff_rx_data(15 downto 8);
                ethernet_packet_header_s.destination_mac_address(39 downto 32) <= rx_stream_i.ff_rx_data(7 downto 0);
                ethernet_header_state_r                                        <= ETH_MAC_DST_1;
              else
                ethernet_header_state_r <= ETH_MAC_DST_0;
              end if;
            when ETH_MAC_DST_1 =>
              ethernet_packet_header_s.destination_mac_address(31 downto 24) <= rx_stream_i.ff_rx_data(31 downto 24);
              ethernet_packet_header_s.destination_mac_address(23 downto 16) <= rx_stream_i.ff_rx_data(23 downto 16);
              ethernet_packet_header_s.destination_mac_address(15 downto 8)  <= rx_stream_i.ff_rx_data(15 downto 8);
              ethernet_packet_header_s.destination_mac_address(7 downto 0)   <= rx_stream_i.ff_rx_data(7 downto 0);
              ethernet_header_state_r                                        <= ETH_MAC_SRC_0;
            when ETH_MAC_SRC_0 =>
              ethernet_packet_header_s.source_mac_address(47 downto 40) <= rx_stream_i.ff_rx_data(31 downto 24);
              ethernet_packet_header_s.source_mac_address(39 downto 32) <= rx_stream_i.ff_rx_data(23 downto 16);
              ethernet_packet_header_s.source_mac_address(31 downto 24) <= rx_stream_i.ff_rx_data(15 downto 8);
              ethernet_packet_header_s.source_mac_address(23 downto 16) <= rx_stream_i.ff_rx_data(7 downto 0);
              -- Mac Filtering
              if ((ethernet_packet_header_s.destination_mac_address = BROADCAST_MAC_ADDRESS) or
                  (ethernet_packet_header_s.destination_mac_address = av_eth_config_0_conduit_end_local_MAC_MSB_i(15 downto 0) & av_eth_config_0_conduit_end_local_MAC_LSB_i )) then
                ethernet_header_state_r <= MAC_SRC_1_PROTOCOL;
              else
                ethernet_header_state_r <= ETH_MAC_DST_0;
					 
              end if;
            when MAC_SRC_1_PROTOCOL =>
              ethernet_packet_header_s.source_mac_address(15 downto 8) <= rx_stream_i.ff_rx_data(31 downto 24);
              ethernet_packet_header_s.source_mac_address(7 downto 0)  <= rx_stream_i.ff_rx_data(23 downto 16);
              ethernet_packet_header_s.ethernet_type <= rx_stream_i.ff_rx_data(15 downto 0);
              case rx_stream_i.ff_rx_data(15 downto 0) is
                when ETHERNET_TYPE_ARP =>
                  ethernet_signal_o.sig_arp <= '1';
                when ETHERNET_TYPE_IPV4 =>
                  ethernet_signal_o.sig_ipv4 <= '1';
                when others =>
                  ethernet_signal_o.sig_arp  <= '0';
                  ethernet_signal_o.sig_ipv4 <= '0';
              end case;
              ethernet_header_state_r <= ETH_PAYLOAD;
            when ETH_PAYLOAD =>
              ethernet_signal_o.sig_arp  <= '0';
              ethernet_signal_o.sig_ipv4 <= '0';
              if (rx_stream_i.ff_rx_eop = '1') then
                ethernet_header_state_r <= ETH_MAC_DST_0;
              else
                ethernet_header_state_r <= ETH_PAYLOAD;
              end if;
            when others =>
              ethernet_header_state_r <= ETH_MAC_DST_0;
          end case;
        end if;
      end if;
    end if;
  end process;
  
end ethernet_packet_filter_arc;
