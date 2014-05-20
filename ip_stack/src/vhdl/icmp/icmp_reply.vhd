library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;

entity icmp_reply is
  port(
    -- Global Signals
    clk_i                    : in  std_logic;
    rst_i                    : in  std_logic;
    -- TX Stream
    tx_stream_o              : out tx_stream_o_t;
    tx_stream_i              : in  tx_stream_i_t;
    -- Input Feedback
    ethernet_packet_header_i : in  ethernet_packet_header_t;
    ipv4_packet_header_i     : in  ipv4_packet_header_t;
    icmp_packet_header_i     : in  icmp_packet_header_t;
    -- Input Signals
    icmp_reply_signal_i      : in  icmp_reply_signal_i_t;   
	 avalon_local_MAC_LSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_LSB_o
	 avalon_local_MAC_MSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_MSB_o
	 
    -- Output Signals
    icmp_reply_signal_o      : out icmp_reply_signal_o_t
    );
end icmp_reply;

architecture icmp_reply_arc of icmp_reply is

  type icmp_rep_state_t is(
    ICMPREP1,
    ICMPREP2,
    ICMPREP3,
    ICMPREP4,
    ICMPREP5,
    ICMPREP6,
    ICMPREP7,
    ICMPREP8,
    ICMPREP9,
    ICMPREP10,
    ICMPREP11,
    ICMPREP12,
    ICMPREP13,
    ICMPREP14,
    ICMPREP15,
    ICMPREP16,
    ICMPREP17,
    ICMPREP18,
    ICMPREP19,
    ICMPREP20
  );

  signal icmp_rep_state_r : icmp_rep_state_t;
  signal  n1 : integer;
  signal  n2 : integer;
  signal  n3 : integer;
  signal  n4 : integer;
  signal  s1 : integer;
  signal  s2 : integer;
  signal  c1 : std_logic_vector(16 downto 0);
  signal  cs : std_logic_vector(15 downto 0);
begin

  -- Check Sum Update
  -- Add x800 in one's complement
  n1 <= to_integer ( unsigned ( icmp_packet_header_i.check_sum ) );
  n2 <= 2048;
  s1 <= n1+n2;
  c1 <= std_logic_vector( to_unsigned (s1, 17 ));
  n3 <= to_integer ( unsigned ( c1(16 downto 16) ) );
  n4 <= to_integer ( unsigned ( c1(15 downto 0) ) );
  s2 <= n3+n4;
  cs <= std_logic_vector( to_unsigned (s2, 16 ));
  
  
  ICMP_REPLY_PROC : process(clk_i, rst_i)
  begin
    if (rst_i = '1') then
        icmp_reply_signal_o.done <= '0';
        icmp_rep_state_r        <= ICMPREP1;
        tx_stream_o.ff_tx_sop  <= '0';
        tx_stream_o.ff_tx_eop  <= '0';
        tx_stream_o.ff_tx_mod  <= (others => '0');
        tx_stream_o.ff_tx_err  <= '0'; --(others => '0');
        tx_stream_o.ff_tx_wren <= '0';
    else
      if (clk_i'event and clk_i = '1') then
        if (tx_stream_i.ff_tx_ready = '1') then
          case icmp_rep_state_r is
            when ICMPREP1 =>
              if (icmp_reply_signal_i.send = '1') then
                tx_stream_o.ff_tx_data <= X"0000" & ethernet_packet_header_i.source_mac_address(47 downto 32);
                tx_stream_o.ff_tx_sop  <= '1';
                tx_stream_o.ff_tx_wren <= '1';
                icmp_rep_state_r        <= ICMPREP2;
              end if;
            when ICMPREP2 =>
              tx_stream_o.ff_tx_sop  <= '0';
              tx_stream_o.ff_tx_data <= ethernet_packet_header_i.source_mac_address(31 downto 0);
              icmp_rep_state_r        <= ICMPREP3;
            when ICMPREP3 =>
              --tx_stream_o.ff_tx_data <= LOCAL_MAC_ADDRESS(47 downto 16);
				  tx_stream_o.ff_tx_data <= avalon_local_MAC_MSB_i(15 downto 0) & avalon_local_MAC_LSB_i(31 downto 16);
              icmp_rep_state_r        <= ICMPREP4;
            when ICMPREP4 =>
              tx_stream_o.ff_tx_data(31 downto 16) <= avalon_local_MAC_LSB_i(15 downto 0);
              tx_stream_o.ff_tx_data(15 downto 0)  <= ETHERNET_TYPE_IPV4;
              icmp_rep_state_r                      <= ICMPREP5;
            when ICMPREP5 =>
              tx_stream_o.ff_tx_data(31 downto 28) <= ipv4_packet_header_i.version;
              tx_stream_o.ff_tx_data(27 downto 24) <= ipv4_packet_header_i.ihl;
              tx_stream_o.ff_tx_data(23 downto 16) <= ipv4_packet_header_i.service;
              tx_stream_o.ff_tx_data(15 downto 0)  <= ipv4_packet_header_i.data_length;
              icmp_rep_state_r        <= ICMPREP6;
            when ICMPREP6 =>
              tx_stream_o.ff_tx_data(31 downto 16) <= ipv4_packet_header_i.id;
              tx_stream_o.ff_tx_data(15 downto 13) <= ipv4_packet_header_i.flags;
              tx_stream_o.ff_tx_data(12 downto 0)  <= ipv4_packet_header_i.fragment_position;
              icmp_rep_state_r        <= ICMPREP7;
            when ICMPREP7 =>
              tx_stream_o.ff_tx_data(31 downto 24) <= ipv4_packet_header_i.time_to_live;
              tx_stream_o.ff_tx_data(23 downto 16) <= ipv4_packet_header_i.protocol;
              tx_stream_o.ff_tx_data(15 downto 0)  <= ipv4_packet_header_i.check_sum;
              icmp_rep_state_r        <= ICMPREP8;
            when ICMPREP8 =>
              tx_stream_o.ff_tx_data(31 downto 0) <= ipv4_packet_header_i.destination_ip_address;
              icmp_rep_state_r                      <= ICMPREP9;
            when ICMPREP9 =>
              tx_stream_o.ff_tx_data(31 downto 0) <= ipv4_packet_header_i.source_ip_address;
              icmp_rep_state_r                      <= ICMPREP10;
            when ICMPREP10 =>
              tx_stream_o.ff_tx_data(31 downto 24) <= ICMP_ECHO_REPLY_TYPE;
              tx_stream_o.ff_tx_data(23 downto 16) <= ICMP_ECHO_REPLY_CODE;
              tx_stream_o.ff_tx_data(15 downto 0)  <= cs;
              icmp_rep_state_r                     <= ICMPREP11;
            when ICMPREP11 =>
              tx_stream_o.ff_tx_data(31 downto 16) <= icmp_packet_header_i.id;
              tx_stream_o.ff_tx_data(15 downto 0)  <= icmp_packet_header_i.sequence_number;
              icmp_rep_state_r              <= ICMPREP12;
            when ICMPREP12 =>
              tx_stream_o.ff_tx_data <= icmp_packet_header_i.data_1;
              icmp_rep_state_r              <= ICMPREP13;
            when ICMPREP13 =>
              tx_stream_o.ff_tx_data <= icmp_packet_header_i.data_2;
              icmp_rep_state_r              <= ICMPREP14;
            when ICMPREP14 =>
              tx_stream_o.ff_tx_data <= icmp_packet_header_i.data_3;
              icmp_rep_state_r              <= ICMPREP15;
            when ICMPREP15 =>
              tx_stream_o.ff_tx_data <= icmp_packet_header_i.data_4;
              icmp_rep_state_r              <= ICMPREP16;
            when ICMPREP16 =>
              tx_stream_o.ff_tx_data <= icmp_packet_header_i.data_5;
              icmp_rep_state_r              <= ICMPREP17;
            when ICMPREP17 =>
              tx_stream_o.ff_tx_data <= icmp_packet_header_i.data_6;
              icmp_rep_state_r              <= ICMPREP18;
            when ICMPREP18 =>
              tx_stream_o.ff_tx_data <= icmp_packet_header_i.data_7;
              icmp_rep_state_r              <= ICMPREP19;
            when ICMPREP19 =>
              tx_stream_o.ff_tx_data <= icmp_packet_header_i.data_8; 
              tx_stream_o.ff_tx_eop         <= '1';
              icmp_reply_signal_o.done <= '1';
              icmp_rep_state_r              <= ICMPREP20;
            when ICMPREP20 =>
              tx_stream_o.ff_tx_wren        <= '0';
              tx_stream_o.ff_tx_eop         <= '0';
              icmp_reply_signal_o.done <= '0';
              icmp_rep_state_r              <= ICMPREP1;
            when others =>
              icmp_rep_state_r <= ICMPREP1;
          end case;
        end if;
      end if;
    end if;
  end process;
  
end icmp_reply_arc;
