library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;

entity icmp_packet_filter is
  port(
    -- Global Signals
    clk_i                    : in  std_logic;
    rst_i                    : in  std_logic;
    -- RX Stream
    rx_stream_i              : in  rx_stream_i_t;
    --rx_stream_o : in rx_stream_o_t
    -- Input Feedback
    ethernet_packet_header_i : in  ethernet_packet_header_t;
    ipv4_packet_header_i     : in  ipv4_packet_header_t;
    -- Input Signals
    ipv4_signal_i            : in  ipv4_signal_t;
    -- Extracted Information
    icmp_packet_header_o     : out icmp_packet_header_t;
    -- Output Signals
    icmp_signal_o            : out icmp_signal_t
    );
end icmp_packet_filter;

architecture icmp_packet_filter_arc of icmp_packet_filter is

  type icmp_state_t is (
    ICMP_1,
    ICMP_2,
    ICMP_3,
    ICMP_4,
    ICMP_5,
    ICMP_6,
    ICMP_7,
    ICMP_8,
    ICMP_9,
    ICMP_10
    );

  signal icmp_state_r         : icmp_state_t;
  signal icmp_packet_header_s : icmp_packet_header_t;
  
begin

  icmp_packet_header_o <= icmp_packet_header_s;

  ICMP_SCAN : process(clk_i, rst_i)
  begin
    if (rst_i = '1') then
        icmp_signal_o.sig_reply <= '0';
        icmp_state_r            <= ICMP_1;
    else
      if (clk_i'event and clk_i = '1') then
        if (rx_stream_i.ff_rx_val = '0') then
          icmp_signal_o.sig_reply <= '0';
        else
          case icmp_state_r is
            when icmp_1 =>
              icmp_signal_o.sig_reply <= '0';
              if ipv4_signal_i.sig_icmp = '1' then
                icmp_packet_header_s.icmp_type <= rx_stream_i.ff_rx_data(31 downto 24);
                icmp_packet_header_s.icmp_code <= rx_stream_i.ff_rx_data(23 downto 16);
                icmp_packet_header_s.check_sum <= rx_stream_i.ff_rx_data(15 downto 0);
                icmp_state_r                   <= icmp_2;
              end if;
            when icmp_2 =>
              icmp_packet_header_s.id              <= rx_stream_i.ff_rx_data(31 downto 16);
              icmp_packet_header_s.sequence_number <= rx_stream_i.ff_rx_data(15 downto 0);
              icmp_state_r                         <= icmp_3;
            when icmp_3 =>
              icmp_packet_header_s.data_1 <= rx_stream_i.ff_rx_data;
              icmp_state_r                <= icmp_4;
            when icmp_4 =>
              icmp_packet_header_s.data_2 <= rx_stream_i.ff_rx_data;
              icmp_state_r                <= icmp_5;
            when icmp_5 =>
              icmp_packet_header_s.data_3 <= rx_stream_i.ff_rx_data;
              icmp_state_r                <= icmp_6;
            when icmp_6 =>
              icmp_packet_header_s.data_4 <= rx_stream_i.ff_rx_data;
              icmp_state_r                <= icmp_7;
            when icmp_7 =>
              icmp_packet_header_s.data_5 <= rx_stream_i.ff_rx_data;
              icmp_state_r                <= icmp_8;
            when icmp_8 =>
              icmp_packet_header_s.data_6 <= rx_stream_i.ff_rx_data;
              icmp_state_r                <= icmp_9;
            when icmp_9 =>
              icmp_packet_header_s.data_7 <= rx_stream_i.ff_rx_data;
              icmp_state_r                <= icmp_10; 
            when icmp_10 =>
              icmp_packet_header_s.data_8 <= rx_stream_i.ff_rx_data;
              if (icmp_packet_header_s.icmp_type=ICMP_ECHO_REQUEST_TYPE and icmp_packet_header_s.icmp_code=ICMP_ECHO_REQUEST_CODE) then
                icmp_signal_o.sig_reply <= '1';
              else
                icmp_signal_o.sig_reply <= '0';
              end if;
              icmp_state_r            <= icmp_1;
            when others =>
              icmp_state_r <= icmp_1;
          end case;
        end if;
      end if;
    end if;
  end process;
  
end icmp_packet_filter_arc;
