library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;

entity ipv4_packet_filter is
  port(
    -- Global Signals
    clk_i                    : in  std_logic;
    rst_i                    : in  std_logic;
    -- RX Stream
    rx_stream_i              : in  rx_stream_i_t;
    --rx_stream_o : in rx_stream_o_t
    -- Input Feedback
    ethernet_packet_header_i : in  ethernet_packet_header_t;
    -- Input Signals
    ethernet_signal_i        : in  ethernet_signal_t;
    -- Extracted Information
    ipv4_packet_header_o     : out ipv4_packet_header_t;
	  avalon_local_IP_i       : in std_logic_vector(31 downto 0);                    -- local_IP_o
    -- Output Signals
    ipv4_signal_o            : out ipv4_signal_t
    );
end ipv4_packet_filter;

architecture ipv4_packet_filter_arc of ipv4_packet_filter is

  type ipv4_state_t is(
    IPV4_1,
    IPV4_2,
    IPV4_3,
    IPV4_4,
    IPV4_5,
    IPV4_6,
    IPV4_7,
    IPV4_8,
    IPV4_9,
    IPV4_10,
    IPV4_11
    );

  signal ipv4_state_r         : ipv4_state_t;
  signal ipv4_packet_header_s : ipv4_packet_header_t;
  
begin

  ipv4_packet_header_o <= ipv4_packet_header_s;

  IPV4_HEADER_SCAN : process(clk_i, rst_i)
  begin
    if (rst_i = '1') then
      ipv4_state_r           <= IPV4_1;
      ipv4_signal_o.sig_udp  <= '0';
      ipv4_signal_o.sig_icmp <= '0';
    else
      if (clk_i'event and clk_i = '1') then
        if (rx_stream_i.ff_rx_val = '0') then
        else
          case ipv4_state_r is
            when IPV4_1 =>
              if ethernet_signal_i.sig_ipv4 = '1' then
                ipv4_packet_header_s.version     <= rx_stream_i.ff_rx_data(31 downto 28);
                ipv4_packet_header_s.ihl         <= rx_stream_i.ff_rx_data(27 downto 24);
                ipv4_packet_header_s.service     <= rx_stream_i.ff_rx_data(23 downto 16);
                ipv4_packet_header_s.data_length <= rx_stream_i.ff_rx_data(15 downto 0); 
                ipv4_state_r <= IPV4_2;
              end if;
              ipv4_signal_o.sig_udp  <= '0';
              ipv4_signal_o.sig_icmp <= '0';
            when IPV4_2 =>
              ipv4_packet_header_s.id                <= rx_stream_i.ff_rx_data(31 downto 16);
              ipv4_packet_header_s.flags             <= rx_stream_i.ff_rx_data(15 downto 13);
              ipv4_packet_header_s.fragment_position <= rx_stream_i.ff_rx_data(12 downto 0);
              ipv4_state_r <= IPV4_3;
            when IPV4_3 =>
              ipv4_packet_header_s.time_to_live <= rx_stream_i.ff_rx_data(31 downto 24);
              ipv4_packet_header_s.protocol     <= rx_stream_i.ff_rx_data(23 downto 16);
              ipv4_packet_header_s.check_sum    <= rx_stream_i.ff_rx_data(15 downto 0);
              ipv4_state_r                      <= IPV4_4;
            when IPV4_4 =>
              ipv4_packet_header_s.source_ip_address <= rx_stream_i.ff_rx_data;
              ipv4_state_r                           <= IPV4_5;
            when IPV4_5 =>
              ipv4_packet_header_s.destination_ip_address <= rx_stream_i.ff_rx_data;
              if (rx_stream_i.ff_rx_data = avalon_local_IP_i) then
                case ipv4_packet_header_s.protocol is
                  when IPV4_PROTOCOL_UDP =>
                    ipv4_signal_o.sig_udp <= '1';
                  when IPV4_PROTOCOL_ICMP =>
                    ipv4_signal_o.sig_icmp <= '1';
                  when others =>
                    ipv4_signal_o.sig_udp  <= '0';
                    ipv4_signal_o.sig_icmp <= '0';
                end case;
              end if;
              ipv4_state_r <= IPV4_1;
            when others =>
              ipv4_state_r <= IPV4_1;
          end case;
        end if;
      end if;
    end if;
  end process;
  
end ipv4_packet_filter_arc;
