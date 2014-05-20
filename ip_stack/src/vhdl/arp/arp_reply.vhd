library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;

entity arp_reply is
  port(
    -- Global Signals
    clk_i                    : in  std_logic;
    rst_i                    : in  std_logic;
    -- TX Stream
    tx_stream_o              : out tx_stream_o_t;
    tx_stream_i              : in  tx_stream_i_t;
    -- Input Feedback
    ethernet_packet_header_i : in  ethernet_packet_header_t;
    arp_packet_header_i      : in  arp_packet_header_t;
    -- Input Signals
    arp_reply_signal_i       : in  arp_reply_signal_i_t; 
    avalon_local_MAC_LSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_LSB_o
	 avalon_local_MAC_MSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_MSB_o
	 
    -- Output Signals
    arp_reply_signal_o       : out arp_reply_signal_o_t
    );
end arp_reply;

architecture arp_reply_arc of arp_reply is

  type arp_rep_state_t is(
    ARPREP1,
    ARPREP2,
    ARPREP3,
    ARPREP4,
    ARPREP5,
    ARPREP6,
    ARPREP7,
    ARPREP8,
    ARPREP9,
    ARPREP10,
    ARPREP11,
    ARPREP12
    );

  signal arp_rep_state_r : arp_rep_state_t;
  
begin
  -- ff_tx_eop  <= ff_tx_eop_s;
  -- ff_tx_wren <= ff_tx_ready and (ff_tx_wren_r or ff_tx_eop_s);
  
  ARP_REPLY_PROC : process(clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if (rst_i = '1') then
        arp_reply_signal_o.done <= '0';
        arp_rep_state_r        <= ARPREP1;
        tx_stream_o.ff_tx_sop  <= '0';
        tx_stream_o.ff_tx_eop  <= '0';
        tx_stream_o.ff_tx_mod  <= (others => '0');
        tx_stream_o.ff_tx_err  <= '0'; --(others => '0');
        tx_stream_o.ff_tx_wren <= '0';
      else
        if (tx_stream_i.ff_tx_ready = '1') then
          case arp_rep_state_r is
            when ARPREP1 =>
              if (arp_reply_signal_i.send = '1') then
                tx_stream_o.ff_tx_data <= X"0000" & ethernet_packet_header_i.source_mac_address(47 downto 32);
                tx_stream_o.ff_tx_sop  <= '1';
                tx_stream_o.ff_tx_wren <= '1';
                arp_rep_state_r        <= ARPREP2;
              end if;
            when ARPREP2 =>
              tx_stream_o.ff_tx_sop  <= '0';
              tx_stream_o.ff_tx_data <= ethernet_packet_header_i.source_mac_address(31 downto 0);
              arp_rep_state_r        <= ARPREP3;
            when ARPREP3 =>
              tx_stream_o.ff_tx_data <= LOCAL_MAC_ADDRESS(47 downto 16);
              arp_rep_state_r        <= ARPREP4;
            when ARPREP4 =>
              tx_stream_o.ff_tx_data(31 downto 16) <= LOCAL_MAC_ADDRESS(15 downto 0);
              tx_stream_o.ff_tx_data(15 downto 0)  <= X"0806";
              arp_rep_state_r                      <= ARPREP5;
            when ARPREP5 =>
              tx_stream_o.ff_tx_data <= X"00010800";
              arp_rep_state_r        <= ARPREP6;
            when ARPREP6 =>
              tx_stream_o.ff_tx_data <= X"06040002";
              arp_rep_state_r        <= ARPREP7;
            when ARPREP7 =>
              --tx_stream_o.ff_tx_data <= LOCAL_MAC_ADDRESS(47 downto 16);
				  tx_stream_o.ff_tx_data <= avalon_local_MAC_MSB_i(15 downto 0) & avalon_local_MAC_LSB_i(31 downto 16);
              arp_rep_state_r        <= ARPREP8;
            when ARPREP8 =>
              --tx_stream_o.ff_tx_data(31 downto 16) <= LOCAL_MAC_ADDRESS(15 downto 0);
				  tx_stream_o.ff_tx_data(31 downto 16) <= avalon_local_MAC_LSB_i(15 downto 0);
              tx_stream_o.ff_tx_data(15 downto 0)  <= arp_packet_header_i.destination_ip_address(31 downto 16);
              arp_rep_state_r                      <= ARPREP9;
            when ARPREP9 =>
              tx_stream_o.ff_tx_data(31 downto 16) <= arp_packet_header_i.destination_ip_address(15 downto 0);
              tx_stream_o.ff_tx_data(15 downto 0)  <= ethernet_packet_header_i.source_mac_address(47 downto 32);
              arp_rep_state_r                      <= ARPREP10;
            when ARPREP10 =>
              tx_stream_o.ff_tx_data <= ethernet_packet_header_i.source_mac_address(31 downto 0);
              arp_rep_state_r        <= ARPREP11;
            when ARPREP11 =>
              tx_stream_o.ff_tx_data       <= arp_packet_header_i.destination_ip_address;
              
              tx_stream_o.ff_tx_eop        <= '1';
              arp_reply_signal_o.done <= '1';
              arp_rep_state_r              <= ARPREP12;
            when ARPREP12 =>
              tx_stream_o.ff_tx_eop        <= '0';
              tx_stream_o.ff_tx_wren       <= '0';
              arp_reply_signal_o.done <= '0';
              arp_rep_state_r              <= ARPREP1;
            when others =>
              arp_rep_state_r <= ARPREP1;
          end case;
        end if;
      end if;
    end if;
  end process;
  
end arp_reply_arc;
