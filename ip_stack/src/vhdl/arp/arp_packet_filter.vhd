library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;

entity arp_packet_filter is
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
    arp_packet_header_o      : out arp_packet_header_t;
    -- Output Signals
    arp_signal_o             : out arp_signal_o_t;
	 avalon_local_IP_i        : in std_logic_vector(31 downto 0)                    -- local_IP
    );
end arp_packet_filter;

architecture arp_packet_filter_arc of arp_packet_filter is

  type arp_state_t is(
    ARP1,
    ARP2,
    ARP3,
    ARP4,
    ARP5,
    ARP6,
    ARP7
    );

  signal arp_state_r         : arp_state_t;
  signal arp_packet_header_s : arp_packet_header_t;
  
begin

  arp_packet_header_o <= arp_packet_header_s;
 
  ARP_SCAN : process (clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if (rst_i = '1') then
        arp_state_r            <= ARP1;
        arp_signal_o.sig_reply <= '0';
      else
        if (rx_stream_i.ff_rx_val = '0') then
          arp_signal_o.sig_reply <= '0';
        else
          case arp_state_r is
            when ARP1 =>
              arp_signal_o.sig_reply <= '0';
              if ethernet_signal_i.sig_arp = '1' then
                if (rx_stream_i.ff_rx_data(31 downto 16) = ARP_NETWORK_TYPE_ETHERNET and
                    rx_stream_i.ff_rx_data(15 downto 0) = ARP_PROTOCOL_TYPE_IP)
                then
                  arp_state_r <= ARP2;
                else
                  arp_state_r <= ARP1;
                end if;
              end if;
            when ARP2 =>
              if (rx_stream_i.ff_rx_data(31 downto 24) = ARP_HW_ADDRESS_SIZE and
                  rx_stream_i.ff_rx_data(23 downto 16) = ARP_LOGICAL_ADDRESS_SIZE and
                  rx_stream_i.ff_rx_data(15 downto 0) = ARP_REQUEST) then
                arp_state_r <= ARP3;
              else
                arp_state_r <= ARP1;
              end if;
            when ARP3 =>
              arp_state_r <= ARP4;
            when ARP4 =>
              arp_packet_header_s.source_ip_address(31 downto 16) <= rx_stream_i.ff_rx_data(15 downto 0);
              arp_state_r                                         <= ARP5;
            when ARP5 =>
              arp_packet_header_s.source_ip_address(15 downto 0) <= rx_stream_i.ff_rx_data(31 downto 16);
              arp_state_r                                        <= ARP6;
            when ARP6 =>
              arp_state_r <= ARP7;
            when ARP7 =>
              arp_packet_header_s.destination_ip_address <= rx_stream_i.ff_rx_data;
              -- Check IP requested
              if rx_stream_i.ff_rx_data = avalon_local_IP_i then
                arp_signal_o.sig_reply <= '1';
                arp_state_r            <= ARP1;
              end if;
            when others =>
              arp_state_r <= ARP1;
          end case;
        end if;
      end if;
    end if;
  end process;
  
end arp_packet_filter_arc;
