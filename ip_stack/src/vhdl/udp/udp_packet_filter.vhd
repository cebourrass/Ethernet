library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;

entity udp_packet_filter is
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
	 -- avalon Local Port 
	 avalon_local_port_i     : in std_logic_vector(15 downto 0);                    -- local_port_o
    -- Extracted Information
    udp_packet_header_o      : out udp_packet_header_t;
    configuration_packet_o   : out configuration_packet_t;
    -- Output Signals
    udp_signal_o             : out udp_signal_t
    );
end udp_packet_filter;

architecture udp_packet_filter_arc of udp_packet_filter is

  type udp_state_t is (
    UDP_1,
    UDP_2,
    UDP_3,
    UDP_4,
    UDP_5,
    UDP_6,
    UDP_7,
    UDP_8,
    UDP_9,
    UDP_10
    );

  signal udp_state_r            : udp_state_t;
  signal udp_packet_header_s    : udp_packet_header_t;
  signal configuration_packet_s : configuration_packet_t;
  
begin

  udp_packet_header_o    <= udp_packet_header_s;
  configuration_packet_o <= configuration_packet_s;
  
  UDP_SCAN : process(clk_i, rst_i)
  begin
    if (rst_i = '1') then
		configuration_packet_s.reg_0 <= std_logic_vector(to_unsigned(0, 32));
		configuration_packet_s.reg_1 <= std_logic_vector(to_unsigned(0, 32));
		configuration_packet_s.reg_2 <= std_logic_vector(to_unsigned(0, 32));
		configuration_packet_s.reg_3 <= std_logic_vector(to_unsigned(0, 32));
		configuration_packet_s.reg_4 <= std_logic_vector(to_unsigned(0, 32));
		configuration_packet_s.reg_5 <= std_logic_vector(to_unsigned(0, 32));
		configuration_packet_s.reg_6 <= std_logic_vector(to_unsigned(0, 32));
		configuration_packet_s.reg_7 <= std_logic_vector(to_unsigned(0, 32));
      udp_signal_o.udp_data_valid <= '0';

      udp_state_r <= UDP_1;
      
      
    else
      if (clk_i'event and clk_i = '1') then
        if (rx_stream_i.ff_rx_val = '0') then
          -- Nothing to do
        else
          case udp_state_r is
            when UDP_1 =>
              if ipv4_signal_i.sig_udp = '1' then
                udp_packet_header_s.source_port      <= rx_stream_i.ff_rx_data(31 downto 16);
                udp_packet_header_s.destination_port <= rx_stream_i.ff_rx_data(15 downto 0);
                udp_state_r                          <= UDP_2;
              end if;
            when UDP_2 =>
              udp_packet_header_s.data_length <= rx_stream_i.ff_rx_data(31 downto 16);
              udp_packet_header_s.check_sum   <= rx_stream_i.ff_rx_data(15 downto 0);
              if udp_packet_header_s.destination_port= avalon_local_port_i then
				    udp_signal_o.udp_data_valid <= '0';
                udp_state_r <= UDP_3;
              else
                udp_state_r <= UDP_1;
              end if;
            when UDP_3 =>
            
				-- Start Data Reception 
				-- Register 0 
					configuration_packet_s.reg_0(31 downto 0) <= rx_stream_i.ff_rx_data(31 downto 0);	  
               udp_state_r <= UDP_4;
			
				-- Register 1	
            when UDP_4 =>
				   configuration_packet_s.reg_1(31 downto 0) <= rx_stream_i.ff_rx_data(31 downto 0);
               udp_state_r <= UDP_5;
					
				-- Register 2
            when UDP_5 =>                                            
              configuration_packet_s.reg_2(31 downto 0) <= rx_stream_i.ff_rx_data(31 downto 0);
              udp_state_r <= UDP_6;
				  
				-- Register 3
            when UDP_6 =>
					configuration_packet_s.reg_3(31 downto 0) <= rx_stream_i.ff_rx_data(31 downto 0);
               udp_state_r <= UDP_7;
					
				-- Register 4
            when UDP_7 =>
              configuration_packet_s.reg_4(31 downto 0) <= rx_stream_i.ff_rx_data(31 downto 0);
              udp_state_r <= UDP_8;
	
				-- Register 5
            when UDP_8 =>
              configuration_packet_s.reg_5(31 downto 0) <= rx_stream_i.ff_rx_data(31 downto 0);
              udp_state_r <= UDP_9;

				-- Register 6				  
            when UDP_9 =>
              configuration_packet_s.reg_6(31 downto 0) <= rx_stream_i.ff_rx_data(31 downto 0);
              udp_state_r <= UDP_10;
				
				-- Register 7
            when UDP_10 =>
            configuration_packet_s.reg_7(31 downto 0) <= rx_stream_i.ff_rx_data(31 downto 0);
				udp_signal_o.udp_data_valid <= '1';
				 
            udp_state_r <= UDP_1;
            when others =>
              udp_state_r <= UDP_1;
          end case;
        end if;
      end if;
    end if;
  end process;
  
end udp_packet_filter_arc;
