library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;
use work.counter_comp.all;

entity udp_status_entity is
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
end udp_status_entity;

architecture udp_status_arc of udp_status_entity is
  
  -- Data Byte Length
  constant UDP_DATA_BYTE_LENGTH : integer := 32;
  -- 32 bit Data Word Length
  constant UDP_DATA_FULL_WORD_LENGTH : integer := UDP_DATA_BYTE_LENGTH/4;
  -- Byte Reminder
  constant UDP_DATA_BYTE_LEFT : integer := UDP_DATA_BYTE_LENGTH-4*UDP_DATA_FULL_WORD_LENGTH;
  
  constant UDP_DATA_WORD_LENGTH : integer := UDP_DATA_FULL_WORD_LENGTH ;
  
  constant IPV4_PACKET_LENGTH : integer := IPV4_HEADER_LENGTH + UDP_HEADER_LENGTH + UDP_DATA_BYTE_LENGTH;
  
  
  -- Constant Ipv4 Header Data
  constant IPV4_ID : std_logic_vector(15 downto 0) := X"0000";
  constant IPV4_FLAGS : std_logic_vector(2 downto 0) := "000";
  constant IPV4_FRAGMENT_OFFSET : std_logic_vector(12 downto 0) := "0000000000000";
  constant IPV4_TIME_TO_LIVE : std_logic_vector(7 downto 0) := X"40";
  
  
  -- Precomputed Ipv4 Header Checsum
  
  -- Sum of 16 Bit Header Data
  constant IPV4_HEADER_PRECOMPUTED_SUM : integer :=
    to_integer(unsigned(IPV4_VERSION & IPV4_IHL & IPV4_SERVICE_TYPE))+
    IPV4_PACKET_LENGTH+
    to_integer(unsigned(IPV4_ID))+
    to_integer(unsigned(IPV4_FLAGS & IPV4_FRAGMENT_OFFSET))+
    to_integer(unsigned(IPV4_TIME_TO_LIVE & IPV4_PROTOCOL_UDP))+
    -- CheckSum : set to zero 
    to_integer(unsigned(LOCAL_IP_ADDRESS(31 downto 16)))+
    to_integer(unsigned(LOCAL_IP_ADDRESS(15 downto 0)))+
    to_integer(unsigned(PC_IP_ADDRESS(31 downto 16)))+
    to_integer(unsigned(PC_IP_ADDRESS(15 downto 0)));
  
  -- MSW to LSW Folded 16 bit Sum
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW_1 : integer := IPV4_HEADER_PRECOMPUTED_SUM/ 65536;
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_LSW_1 : integer := IPV4_HEADER_PRECOMPUTED_SUM-65536*IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW_1;
  
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_1 : integer := IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW_1+IPVA_HEADER_PRECOMPUTED_CHECKSUM_LSW_1;
  
  -- MSW to LSW Folded 16 bit Sum (last carry fold)
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW : integer := IPVA_HEADER_PRECOMPUTED_CHECKSUM_1/ 65536;
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_LSW : integer := IPVA_HEADER_PRECOMPUTED_CHECKSUM_1-65536*IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW;
  
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM : integer := 65535-(IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW+IPVA_HEADER_PRECOMPUTED_CHECKSUM_LSW);
  
  -- FSM States
  type fsm_state_t is(
    FSM_1,
    FSM_2,
    FSM_3,
    FSM_4,
    FSM_5,
    FSM_6,
    FSM_7,
    FSM_8,
    FSM_9,
    FSM_10,
    FSM_11,
    FSM_12,
    FSM_13,
	 FSM_14,
	 FSM_15,
    FSM_16,
    FSM_17,
    FSM_18,
    FSM_19,
    FSM_20
  );

  -- Fsm Current State
  signal fsm_state_r : fsm_state_t;

  signal data_start_s : std_logic;
  signal data_s       : std_logic_vector(15 downto 0);
  signal data_zero_s  : std_logic;
  signal signal_s     : std_logic;
  
begin

  signal_o.done <= signal_s;
  
  udp_status_PROC : process(clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if (rst_i = '1') then
        signal_s               <= '0';
        fsm_state_r            <= FSM_1;
        tx_stream_o.ff_tx_sop  <= '0';
        tx_stream_o.ff_tx_eop  <= '0';
        tx_stream_o.ff_tx_mod  <= (others => '0');
        tx_stream_o.ff_tx_err  <= '0';
        tx_stream_o.ff_tx_wren <= '0';
      else
        if (tx_stream_i.ff_tx_ready = '1') then
          case fsm_state_r is
            when FSM_1 =>
              if (signal_i.send = '1') then
                --tx_stream_o.ff_tx_data <= X"0000" & PC_MAC_ADDRESS(47 downto 32);
					 tx_stream_o.ff_tx_data <= X"0000" & avalon_remote_MAC_MSB_i(15 downto 0);
                tx_stream_o.ff_tx_sop  <= '1';
                tx_stream_o.ff_tx_mod  <= std_logic_vector(to_unsigned(0, 2));
                tx_stream_o.ff_tx_wren <= '1';
                fsm_state_r            <= FSM_2;
              end if;
            when FSM_2 =>
              tx_stream_o.ff_tx_sop  <= '0';
              --tx_stream_o.ff_tx_data <= PC_MAC_ADDRESS(31 downto 0);
				  tx_stream_o.ff_tx_data <= avalon_remote_MAC_LSB_i(31 downto 0);
              fsm_state_r            <= FSM_3;
            when FSM_3 =>
              --tx_stream_o.ff_tx_data <= LOCAL_MAC_ADDRESS(47 downto 16);
				  tx_stream_o.ff_tx_data <= avalon_local_MAC_MSB_i(15 downto 0) & avalon_local_MAC_LSB_i(31 downto 16);
              fsm_state_r            <= FSM_4;
            when FSM_4 =>
              --tx_stream_o.ff_tx_data(31 downto 16) <= LOCAL_MAC_ADDRESS(15 downto 0);
				  tx_stream_o.ff_tx_data(31 downto 16) <= avalon_local_MAC_LSB_i(15 downto 0);
              tx_stream_o.ff_tx_data(15 downto 0)  <= ETHERNET_TYPE_IPV4;
              fsm_state_r                          <= FSM_5;
            when FSM_5 =>
              tx_stream_o.ff_tx_data(31 downto 28) <= IPV4_VERSION;
              tx_stream_o.ff_tx_data(27 downto 24) <= IPV4_IHL;
              tx_stream_o.ff_tx_data(23 downto 16) <= IPV4_SERVICE_TYPE;
              -- Length Ipv4 Header + Payload
              tx_stream_o.ff_tx_data(15 downto 0)  <= std_logic_vector(to_unsigned(IPV4_PACKET_LENGTH,16));
              fsm_state_r                          <= FSM_6;
            when FSM_6 =>
              -- Identification
              tx_stream_o.ff_tx_data(31 downto 16) <= (others => '0');
              -- Flags
              tx_stream_o.ff_tx_data(15 downto 13) <= (others => '0');
              -- Fragment Position
              tx_stream_o.ff_tx_data(12 downto 0)  <= (others => '0');
              fsm_state_r                          <= FSM_7;
            when FSM_7 =>
              -- Time To Live
              tx_stream_o.ff_tx_data(31 downto 24) <= IPV4_TIME_TO_LIVE;
              tx_stream_o.ff_tx_data(23 downto 16) <= IPV4_PROTOCOL_UDP;
              -- Ipv4 Header Checksum
              --tx_stream_o.ff_tx_data(15 downto 0)  <= std_logic_vector(to_unsigned(IPVA_HEADER_PRECOMPUTED_CHECKSUM,16));
				  tx_stream_o.ff_tx_data(15 downto 0)  <= avalon_checksum_i;
              fsm_state_r                          <= FSM_8;
            when FSM_8 =>
              --tx_stream_o.ff_tx_data(31 downto 0) <= LOCAL_IP_ADDRESS;
				  tx_stream_o.ff_tx_data(31 downto 0) <= avalon_local_IP_i;
              fsm_state_r                         <= FSM_9;
            when FSM_9 =>
              --tx_stream_o.ff_tx_data(31 downto 0) <= PC_IP_ADDRESS;
				  tx_stream_o.ff_tx_data(31 downto 0) <= avalon_remote_IP_i;
				  fsm_state_r                         <= FSM_10;
            when FSM_10 =>
              --tx_stream_o.ff_tx_data(31 downto 16) <= STATUS_PORT;
              --tx_stream_o.ff_tx_data(15 downto 0)  <= STATUS_PORT;
				  tx_stream_o.ff_tx_data(31 downto 16) <= avalon_local_port_i;
              tx_stream_o.ff_tx_data(15 downto 0)  <= avalon_remote_port_i;
              data_start_s                         <= '1';              
              fsm_state_r                          <= FSM_11;
            when FSM_11 =>
              -- Length Udp Header + Payload
              tx_stream_o.ff_tx_data(31 downto 16) <= std_logic_vector(to_unsigned(8+UDP_DATA_BYTE_LENGTH, 16));
              tx_stream_o.ff_tx_data(15 downto 0)  <= (others => '0');
              data_start_s                         <= '0';
              fsm_state_r                          <= FSM_12;
            -- Udp Payload (8 words)
            when FSM_12 => 
				 tx_stream_o.ff_tx_data(31 downto 0) <= avalon_status_register7_i(31 downto 0);
				 tx_stream_o.ff_tx_eop              <= '0';
             tx_stream_o.ff_tx_mod              <= std_logic_vector(to_unsigned(0, 2));
             signal_s                           <= '0';              
             fsm_state_r                        <= FSM_13; 
				when FSM_13 => 
				 tx_stream_o.ff_tx_data(31 downto 0) <= avalon_status_register6_i(31 downto 0);
				 tx_stream_o.ff_tx_eop              <= '0';
             tx_stream_o.ff_tx_mod              <= std_logic_vector(to_unsigned(0, 2));
             signal_s                           <= '0';              
             fsm_state_r                        <= FSM_14;
				when FSM_14 => 
				 tx_stream_o.ff_tx_data(31 downto 0) <= avalon_status_register5_i(31 downto 0);
				 tx_stream_o.ff_tx_eop              <= '0';
             tx_stream_o.ff_tx_mod              <= std_logic_vector(to_unsigned(0, 2));
             signal_s                           <= '0';              
             fsm_state_r                        <= FSM_15; 
				when FSM_15 => 
				 tx_stream_o.ff_tx_data(31 downto 0) <= avalon_status_register4_i(31 downto 0);
				 tx_stream_o.ff_tx_eop              <= '0';
             tx_stream_o.ff_tx_mod              <= std_logic_vector(to_unsigned(0, 2));
             signal_s                           <= '0';              
             fsm_state_r                        <= FSM_16;
				when FSM_16 => 
				 tx_stream_o.ff_tx_data(31 downto 0) <= avalon_status_register3_i(31 downto 0);	
				 tx_stream_o.ff_tx_eop              <= '0';
             tx_stream_o.ff_tx_mod              <= std_logic_vector(to_unsigned(0, 2));
             signal_s                           <= '0';              
             fsm_state_r                        <= FSM_17;
				when FSM_17 => 
				 tx_stream_o.ff_tx_data(31 downto 0) <= avalon_status_register2_i(31 downto 0);
				 tx_stream_o.ff_tx_eop              <= '0';
             tx_stream_o.ff_tx_mod              <= std_logic_vector(to_unsigned(0, 2));
             signal_s                           <= '0';              
             fsm_state_r                        <= FSM_18;
				when FSM_18 => 
				 tx_stream_o.ff_tx_data(31 downto 0) <= avalon_status_register1_i(31 downto 0);
				 tx_stream_o.ff_tx_eop              <= '0';
             tx_stream_o.ff_tx_mod              <= std_logic_vector(to_unsigned(0, 2));
             signal_s                           <= '0';              
             fsm_state_r                        <= FSM_19;				 
				when FSM_19 => 
				 tx_stream_o.ff_tx_data(31 downto 0) <= avalon_status_register0_i(31 downto 0);			 
             tx_stream_o.ff_tx_eop                <= '1';
             tx_stream_o.ff_tx_mod                <= std_logic_vector(to_unsigned(UDP_DATA_BYTE_LEFT, 2));
             signal_s                             <= '1';
             fsm_state_r                          <= FSM_20; 
            when FSM_20 =>  
              tx_stream_o.ff_tx_wren <= '0';
              tx_stream_o.ff_tx_eop  <= '0';
              signal_s               <= '0';
              fsm_state_r            <= FSM_1;  
            when others =>
              fsm_state_r <= FSM_1;
          end case;
        end if;
      end if;
    end if;
  end process;
    
--  DATA_COUNT_INST : counter
--   generic map (
--      COUNTER_SIZE => 16
--      )
--    port map (
--      clk_i           => clk_i,
--      rst_i           => rst_i,
--      data_to_load_i  => std_logic_vector(to_unsigned(UDP_DATA_FULL_WORD_LENGTH-1, 16)),
--      count_enable_i  => '1',
--      load_enable_i   => data_start_s,
--      up_down_i       => '0',
--      counter_value_o => data_s,
--      zero_flag_o     => data_zero_s
--      );
      
  -- line_load_s <= line_zero_s and signal_s;
  
  -- LINE_COUNT_INST : entity work.counter(counter_behavior)
    -- generic map (
      -- COUNTER_SIZE => 16
      -- )
    -- port map (
      -- Clk_i          => clk_i,
      -- Rst_i          => rst_i,
      -- DataToLoad_i   => std_logic_vector(to_unsigned(511, 16)),
      -- CountEnable_i  => signal_s,
      -- LoadEnable_i   => line_load_s,
      -- UpDown_i       => '0',
      -- CounterValue_o => line_s,
      -- ZeroFlag_o     => line_zero_s
      -- );      

end udp_status_arc;
