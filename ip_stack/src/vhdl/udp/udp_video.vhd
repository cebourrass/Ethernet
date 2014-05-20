--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2012-11-16
--! @brief Udp Video Streaming
--! @details
--!
--! @page p_201210251019 Udp Video Streaming
--! This page describes Udp Video Streaming contents.
--! @section sec_201210251021 Revisions
--! - 2012-07-10 : Created
--! @section sec_201210251020 Block diagram
--! @image html udp_video_streaming_diagram.png "Udp Video Streaming block diagram"
--! @section sec_ Concepts
--! When signal_i is active, then generate udp packet field with one line pixels.
--! Set signal_o active at packet end in order to free tx path.
--! @section sec_201210251019 Check sum computation
--! Check sum computation is static.
--!
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
library work;
use work.ethernet_package.all;
use work.counter_comp.all;
--------------------------------------------------------------------------------
--! udp video stream out entity
entity udp_video_entity is
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
    pixel_i               : in  std_logic_vector(31 downto 0)
    );
end udp_video_entity;
--------------------------------------------------------------------------------
--! udp video stream out architecture
architecture udp_video_arc of udp_video_entity is

  -- Data Byte Length
  constant UDP_DATA_BYTE_LENGTH      : integer :=
    512;
  -- 32 Bit Data Word Length
  constant UDP_DATA_FULL_WORD_LENGTH : integer :=
    UDP_DATA_BYTE_LENGTH/4;
  -- Byte Reminder
  constant UDP_DATA_BYTE_LEFT        : integer :=
    UDP_DATA_BYTE_LENGTH-4*UDP_DATA_FULL_WORD_LENGTH;
  -- 
  constant UDP_DATA_WORD_LENGTH      : integer := 
    UDP_DATA_FULL_WORD_LENGTH;
  -- Ipv4 Packet Length
  constant IPV4_PACKET_LENGTH        : integer :=
    IPV4_HEADER_LENGTH + UDP_HEADER_LENGTH + UDP_DATA_BYTE_LENGTH;
--------------------------------------------------------------------------------
  -- Precomputed Ipv4 Header Checsum

  -- Sum of 16 Bit Header Data
  constant IPV4_HEADER_PRECOMPUTED_SUM : integer :=
    to_integer(unsigned(IPV4_VERSION & IPV4_IHL & IPV4_SERVICE_TYPE))+
    IPV4_PACKET_LENGTH+
    to_integer(unsigned(IPV4_ID))+
    to_integer(unsigned(IPV4_FLAGS & IPV4_FRAGMENT_OFFSET))+
    to_integer(unsigned(IPV4_TIME_TO_LIVE & IPV4_PROTOCOL_UDP))+
    -- CheckSum field : set to zero 
    to_integer(unsigned(LOCAL_IP_ADDRESS(31 downto 16)))+
    to_integer(unsigned(LOCAL_IP_ADDRESS(15 downto 0)))+
    to_integer(unsigned(PC_IP_ADDRESS(31 downto 16)))+
    to_integer(unsigned(PC_IP_ADDRESS(15 downto 0)));

  -- MSW to LSW Folded 16 bit Sum
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW_1 : integer :=
    IPV4_HEADER_PRECOMPUTED_SUM/ 65536;
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_LSW_1 : integer :=
    IPV4_HEADER_PRECOMPUTED_SUM-65536*IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW_1;

  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_1 : integer :=
    IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW_1+
    IPVA_HEADER_PRECOMPUTED_CHECKSUM_LSW_1;

  -- MSW to LSW Folded 16 bit Sum (last carry fold)
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW : integer := 
    IPVA_HEADER_PRECOMPUTED_CHECKSUM_1/ 65536;
  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM_LSW : integer := 
    IPVA_HEADER_PRECOMPUTED_CHECKSUM_1-
    65536*IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW;

  constant IPVA_HEADER_PRECOMPUTED_CHECKSUM : integer :=
    65535-
    (IPVA_HEADER_PRECOMPUTED_CHECKSUM_MSW+IPVA_HEADER_PRECOMPUTED_CHECKSUM_LSW);
--------------------------------------------------------------------------------
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
    FSM_13
    );

  -- Fsm Current State
  signal fsm_state_r : fsm_state_t;

  signal data_start_s           : std_logic;
  signal data_s                 : std_logic_vector(15 downto 0);
  signal line_s                 : std_logic_vector(15 downto 0);
  signal data_zero_s            : std_logic;
  signal line_zero_s            : std_logic;
  signal line_load_s            : std_logic;
  signal line_to_load_s         : std_logic_vector(15 downto 0);
  signal signal_s               : std_logic;
  signal pixel_read_s           : std_logic;
  --! Set to 1 during FSM12 first clock period
  signal fsm_12_first_cycle_s   : std_logic;
  signal ff_tx_wren_s           : std_logic;

begin
  tx_stream_o.ff_tx_wren <= ff_tx_wren_s;
--------------------------------------------------------------------------------
  signal_o.done <= signal_s;
--------------------------------------------------------------------------------
  pixel_read_o <= pixel_read_s;
--------------------------------------------------------------------------------
  -- tx_stream_o.ff_tx_wren <= '1' 
    -- when
      -- rst_i = '0' and
      -- ( not (fsm_state_r = FSM_12 or 
             -- fsm_state_r = FSM_1 
            -- )  or 
        -- ((fsm_state_r = FSM_12 and
          -- pixel_ready_i = '1'
         -- ) or
         -- fsm_12_first_cycle_s='1'
        -- )
      -- ) 
    -- else '0';
--------------------------------------------------------------------------------  
  pixel_read_s <= '1'
    when
      rst_i = '0' and 
      fsm_state_r = FSM_12 and
      pixel_ready_i = '1' and not fsm_12_first_cycle_s='1'
    else '0';
--------------------------------------------------------------------------------  
  UDP_VIDEO_PROC : process(clk_i, rst_i)
  begin
    if (rst_i = '1') then
      signal_s               <= '0';
      fsm_state_r            <= FSM_1;
      tx_stream_o.ff_tx_sop  <= '0';
      tx_stream_o.ff_tx_eop  <= '0';
      tx_stream_o.ff_tx_mod  <= (others => '0');
      tx_stream_o.ff_tx_err  <= '0';
      data_start_s <= '0';
      fsm_12_first_cycle_s <= '0';
      ff_tx_wren_s  <= '0';
      --tx_stream_o.ff_tx_wren <= '0';
    else
      if (clk_i'event and clk_i = '1') then
        
        if (tx_stream_i.ff_tx_ready = '1') then
          case fsm_state_r is
            when FSM_1 =>
              if (signal_i.send = '1') then
                ff_tx_wren_s <= '1';
                tx_stream_o.ff_tx_data <= X"0000" & PC_MAC_ADDRESS(47 downto 32);
                tx_stream_o.ff_tx_sop  <= '1';
                tx_stream_o.ff_tx_mod  <= std_logic_vector(to_unsigned(0, 2));
                --tx_stream_o.ff_tx_wren <= '1';
                fsm_state_r            <= FSM_2;
              end if;
            when FSM_2 =>
              tx_stream_o.ff_tx_sop  <= '0';
              tx_stream_o.ff_tx_data <= PC_MAC_ADDRESS(31 downto 0);
              fsm_state_r            <= FSM_3;
            when FSM_3 =>
              tx_stream_o.ff_tx_data <= LOCAL_MAC_ADDRESS(47 downto 16);
              fsm_state_r            <= FSM_4;
            when FSM_4 =>
              tx_stream_o.ff_tx_data(31 downto 16) <= LOCAL_MAC_ADDRESS(15 downto 0);
              tx_stream_o.ff_tx_data(15 downto 0)  <= ETHERNET_TYPE_IPV4;
              fsm_state_r                          <= FSM_5;
            when FSM_5 =>
              tx_stream_o.ff_tx_data(31 downto 28) <= IPV4_VERSION;
              tx_stream_o.ff_tx_data(27 downto 24) <= IPV4_IHL;
              tx_stream_o.ff_tx_data(23 downto 16) <= IPV4_SERVICE_TYPE;
              -- Length Ipv4 Header + Payload
              tx_stream_o.ff_tx_data(15 downto 0)  <= std_logic_vector(to_unsigned(IPV4_PACKET_LENGTH, 16));
              fsm_state_r                          <= FSM_6;
            when FSM_6 =>
              -- Identification
              tx_stream_o.ff_tx_data(31 downto 16) <= line_s(15 downto 0);
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
              tx_stream_o.ff_tx_data(15 downto 0)  <= std_logic_vector(to_unsigned(IPVA_HEADER_PRECOMPUTED_CHECKSUM-to_integer(unsigned(line_s(15 downto 0))), 16));
              fsm_state_r                          <= FSM_8;
            when FSM_8 =>
              tx_stream_o.ff_tx_data(31 downto 0) <= LOCAL_IP_ADDRESS;
              fsm_state_r                         <= FSM_9;
            when FSM_9 =>
              tx_stream_o.ff_tx_data(31 downto 0) <= PC_IP_ADDRESS;
              fsm_state_r                         <= FSM_10;
            when FSM_10 =>
              tx_stream_o.ff_tx_data(31 downto 16) <= VIDEO_PORT;
              tx_stream_o.ff_tx_data(15 downto 0)  <= VIDEO_PORT;
              fsm_state_r                          <= FSM_11;
            when FSM_11 =>
              -- Length Udp Header + Payload
              tx_stream_o.ff_tx_data(31 downto 16) <= std_logic_vector(to_unsigned(8+UDP_DATA_BYTE_LENGTH, 16));
              -- Checksum: force to zero
              tx_stream_o.ff_tx_data(15 downto 0)  <= (others => '0');
              --pixel_row_o.pixel_read               <= '1';
              fsm_state_r                          <= FSM_12;
              fsm_12_first_cycle_s <= '0';
              data_start_s                         <= '1';
              -- Udp Payload
            when FSM_12 =>
              data_start_s                         <= '0';
              fsm_12_first_cycle_s <= '0';
              tx_stream_o.ff_tx_data <= pixel_i;
              ff_tx_wren_s <= pixel_read_s;
              -- All But the Last Data
              if data_zero_s = '0' then
                tx_stream_o.ff_tx_eop <= '0';
                tx_stream_o.ff_tx_mod <= std_logic_vector(to_unsigned(0, 2));
                signal_s              <= '0';
                fsm_state_r           <= FSM_12;
                -- Last Data
              else
                tx_stream_o.ff_tx_eop  <= '1';
                tx_stream_o.ff_tx_mod  <= std_logic_vector(to_unsigned(UDP_DATA_BYTE_LEFT, 2));
                --pixel_row_o.pixel_read <= '0';
                signal_s               <= '1';
                fsm_state_r            <= FSM_13;
              end if;
            when FSM_13 =>
              ff_tx_wren_s <= '0';
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
--------------------------------------------------------------------------------
  DATA_COUNT_INST : counter
    generic map (
      COUNTER_SIZE => 16
      )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      data_to_load_i  => std_logic_vector(to_unsigned(UDP_DATA_FULL_WORD_LENGTH-1, 16)),
      count_enable_i  => ff_tx_wren_s,
      load_enable_i   => data_start_s,
      up_down_i       => '0',
      counter_value_o => data_s,
      zero_flag_o     => data_zero_s
      );

  line_load_s    <= line_zero_s and signal_s;
  line_to_load_s <= std_logic_vector(to_unsigned(to_integer(unsigned(configuration_packet_i.video_stream_out_frame_height)), 16)-1);
--------------------------------------------------------------------------------
  LINE_COUNT_INST : counter
    generic map (
      COUNTER_SIZE => 16
      )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      data_to_load_i  => line_to_load_s,
      count_enable_i  => signal_s,
      load_enable_i   => line_load_s,
      up_down_i       => '0',
      counter_value_o => line_s,
      zero_flag_o     => line_zero_s
      );      
--------------------------------------------------------------------------------
end udp_video_arc;