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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ethernet_package.all;
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
	 
	 fifo_empty_i : in std_logic;
	 rd_fifo_o : out std_logic;
		
    
	 pixel_i               : in  std_logic_vector(31 downto 0);
	 avalon_local_port_i     : in std_logic_vector(15 downto 0);                    -- local_port_o
	 avalon_remote_port_i    : in std_logic_vector(15 downto 0);                    -- remote_port_o
	 avalon_local_IP_i       : in std_logic_vector(31 downto 0);                    -- local_IP_o
	 avalon_remote_IP_i      : in std_logic_vector(31 downto 0);                    -- remote_IP_o
	 avalon_local_MAC_LSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_LSB_o
	 avalon_local_MAC_MSB_i  : in std_logic_vector(31 downto 0);                    -- local_MAC_MSB_o
	 avalon_remote_MAC_LSB_i : in std_logic_vector(31 downto 0);                    -- remote_MAC_LSB_o
	 avalon_checksum_i       : in std_logic_vector(15 downto 0);                    -- checksum_o
	 avalon_remote_MAC_MSB_i : in std_logic_vector(31 downto 0);                     -- remote_MAC_MSB_o
	 avalon_length_i 			 : in std_logic_vector(15 downto 0)
    );
end udp_video_entity;
--------------------------------------------------------------------------------
--! udp video stream out architecture
architecture udp_video_arc of udp_video_entity is

 -- Data Byte Length
  constant UDP_DATA_BYTE_LENGTH : integer := 32;
  -- 32 bit Data Word Length
  constant UDP_DATA_FULL_WORD_LENGTH : integer := UDP_DATA_BYTE_LENGTH/4;
  -- Byte Reminder
  constant UDP_DATA_BYTE_LEFT : integer := UDP_DATA_BYTE_LENGTH-4*UDP_DATA_FULL_WORD_LENGTH;
  

  constant IPV4_PACKET_LENGTH        : integer :=
    IPV4_HEADER_LENGTH + UDP_HEADER_LENGTH + UDP_DATA_BYTE_LENGTH;
---- FSM States
--  type fsm_state_t is(
--    IDLE,      -- Wait for send line request
--    H1,        -- Send header word #01
--    H2,        -- Send header word #02
--    H3,        -- Send header word #03
--    H4,        -- Send header word #04
--    H5,        -- Send header word #05
--    H6,        -- Send header word #06
--    H7,        -- Send header word #07
--    H8,        -- Send header word #08
--    H9,        -- Send header word #09
--    H10,       -- Send header word #10
--    H11,       -- Send header word #11
--    DATA,      -- Send data words (all bu the last one)
--    LAST_DATA, -- Send last data word
--    SEND_DONE  -- Return done ack
--    );
--	 
	 
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
	 
	 
--  attribute enum_encoding : string;
--  -- default
--  -- gray
--  -- sequential
--  -- johnson
--  -- one-hot
--  -- list of values
--  attribute enum_encoding of fsm_state_t : type is "gray";    
--  
--  signal current_state_r : fsm_state_t;
--  signal next_state_s    : fsm_state_t;
--  
--  signal byte_to_send_r : std_logic_vector(15 downto 0);
--  signal line_num_r     : std_logic_vector(15 downto 0);
  
  signal signal_s     : std_logic;
  signal data_start_s : std_logic;
  signal data_s       : std_logic_vector(15 downto 0);
  signal data_zero_s  : std_logic;
  
  signal counter : std_logic_vector(15 downto 0);
  
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
		  rd_fifo_o <= '0';
		  counter <= X"0000";
      else
        if (tx_stream_i.ff_tx_ready = '1') then
          case fsm_state_r is
            when FSM_1 =>
             if (signal_i.send = '1') then
		--		  if (pixel_ready_i = '1') then -- line ready en fait 
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
              --tx_stream_o.ff_tx_data(15 downto 0)  <= std_logic_vector(to_unsigned(IPV4_PACKET_LENGTH,16));
				  tx_stream_o.ff_tx_data(15 downto 0)  <= avalon_length_i + X"001C";
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
              --tx_stream_o.ff_tx_data(31 downto 16) <= std_logic_vector(to_unsigned(8+UDP_DATA_BYTE_LENGTH, 16));
				  tx_stream_o.ff_tx_data(31 downto 16) <= avalon_length_i + X"08";
              tx_stream_o.ff_tx_data(15 downto 0)  <= (others => '0');
              data_start_s                         <= '0';
              fsm_state_r                          <= FSM_12;
				  rd_fifo_o <= '1';
            -- Udp Payload (8 words)
				
				-- start to send Datas -- depile external FIFO 
            when FSM_12 => 
				
				 if fifo_empty_i='0' then 
					rd_fifo_o <= '1';
				 else 
					rd_fifo_o <= '0';
				 end if;
				 
				tx_stream_o.ff_tx_data(31 downto 0) <= pixel_i;
				tx_stream_o.ff_tx_mod              <= std_logic_vector(to_unsigned(0, 2));
				
				 -- avalon_length_i  => Length from NIOS register
				 if (counter <  avalon_length_i) then 
					fsm_state_r                        <= FSM_12; 
					counter <= counter+std_logic_vector(to_unsigned(4,16));
					tx_stream_o.ff_tx_eop              <= '0';	
					signal_s                           <= '0'; 
				 else
					tx_stream_o.ff_tx_eop              <= '1';
					signal_s                           <= '1';
					fsm_state_r                        <= FSM_13; 
					counter <= X"0000";
				end if;

            when FSM_13 =>  
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
  
  
  
--
--------------------------------------------------------------- Line counter ---
--  LINE_COUNT_PROC : process(clk_i, rst_i)
--  begin
--    if  rst_i='1' then
--      line_num_r <= (others => '0');
--    else
--      if clk_i'event and clk_i='1' then
--        if current_state_r = H1 and tx_stream_i.ff_tx_ready = '1' then
--          if line_num_r=std_logic_vector(to_unsigned(511,16)) then
--            line_num_r<= std_logic_vector(to_unsigned(0,16));
--          else
--            line_num_r <= line_num_r+std_logic_vector(to_unsigned(1,16));
--          end  if;
--        end if;
--      end if;
--    end if;
--  end process;  
--------------------------------------------------------------- Byte counter ---
--  BYTE_COUNT_PROC : process(clk_i, rst_i)
--  begin
--    if  rst_i='1' then
--      byte_to_send_r <= (others => '0');
--    else
--      if clk_i'event and clk_i='1' then
--        -- Count down only when data exists and ff_tx ready
--        if current_state_r = DATA then
--          if pixel_ready_i = '1' and tx_stream_i.ff_tx_ready = '1' then
--            byte_to_send_r <= byte_to_send_r-std_logic_vector(to_unsigned(4,16));
--          end if;
--        elsif current_state_r = LAST_DATA then
--          if pixel_ready_i = '1' and tx_stream_i.ff_tx_ready = '1' then
--            byte_to_send_r <= (others => '0');
--          end if;
--        else
--          byte_to_send_r <= std_logic_vector(to_unsigned(UDP_DATA_BYTE_LENGTH,16));
--        end if;
--      end if;
--    end if;
--  end process;
--  
---------------------------------------------- Finite state machine register ---
---- Register
--  FSM_SYNC_PROC : process(clk_i, rst_i)
--  begin
--    if  rst_i='1' then
--      current_state_r <= IDLE;
--    else
--      if clk_i'event and clk_i='1' then
--        current_state_r <= next_state_s;
--      end if;
--    end if;
--  end process;
--
---- Next state logic  
--  next_state_s <= 
--    IDLE when
--      current_state_r = SEND_DONE
--    else H1 when
--      current_state_r = IDLE and (
--        -- IDLE state: when send requiered jump to H1
--        signal_i.send = '1'
--      )
--    else H2 when
--      current_state_r = H1 and (
--        -- H1 state: jump to H2 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'    
--      )
--    else H3 when
--      current_state_r = H2 and (
--        -- H2 state: jump to H3 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'  
--      )
--    else H4 when
--      current_state_r = H3 and (
--        -- H3 state: jump to H4 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'
--      )
--    else H5 when
--      current_state_r = H4 and (
--        -- H4 state: jump to H5 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'  
--      )
--    else H6 when
--      current_state_r = H5 and (
--        -- H5 state: jump to H6 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'
--      )
--    else H7 when
--      current_state_r = H6 and (
--        -- H6 state: jump to H7 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'  
--      )
--    else H8 when
--      current_state_r = H7 and (
--        -- H7 state: jump to H8 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'  
--      )
--    else H9 when
--      current_state_r = H8 and (
--        -- H8 state: jump to H9 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'        
--      )
--    else H10 when
--      current_state_r = H9 and (
--        -- H9 state: jump to H10 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'        
--      )
--    else H11 when
--      current_state_r = H10 and (
--        -- H10 state: jump to H11 as soon as ff_tx_ready is set
--        tx_stream_i.ff_tx_ready = '1'
--      )
--    else DATA when
--      current_state_r = H11 and (
--        -- H11 state: jump to DATA as soon as ff_tx_ready is set and
--        -- more than 4 bytes to send
--        tx_stream_i.ff_tx_ready = '1' and
--        byte_to_send_r > std_logic_vector(to_unsigned(4,16))
--      )
--    else LAST_DATA when
--      (
--        current_state_r = H11 and
--        -- H11 state: jump to LAST_DATA as soon as ff_tx_ready is set and
--        -- less than 5 bytes to send
--          tx_stream_i.ff_tx_ready = '1' and
--          byte_to_send_r < std_logic_vector(to_unsigned(5,16))
--      ) or (
--        current_state_r = DATA and
--          -- DATA state: jump to LAST_DATA as soon as ff_tx_ready and 
--          -- pixel_ready_i are set and less than 9 bytes to send
--          -- ( 4 bytes to send on last DATA state and
--          -- reminder bytes on LAST_DATA
--          pixel_ready_i = '1' and
--          tx_stream_i.ff_tx_ready = '1' and
--          byte_to_send_r <= std_logic_vector(to_unsigned(9,16))
--      )
--    else SEND_DONE when
--      current_state_r = LAST_DATA and (
--        -- LAST_DATA state: jump to SEND_DONE as soon as ff_tx_ready and 
--        -- pixel_ready_i are set
--        tx_stream_i.ff_tx_ready = '1' and
--        pixel_ready_i = '1'
--      )           
--    else current_state_r;
--      
---- Moore output logic
--  -- 
--  tx_stream_o.ff_tx_wren <=
--    '1' when
--      tx_stream_i.ff_tx_ready = '1' and (
--        current_state_r = H1 or
--        current_state_r = H2 or
--        current_state_r = H3 or
--        current_state_r = H4 or
--        current_state_r = H5 or
--        current_state_r = H6 or
--        current_state_r = H7 or
--        current_state_r = H8 or
--        current_state_r = H9 or
--        current_state_r = H10 or
--        current_state_r = H11 or (
--          (current_state_r = DATA or current_state_r = LAST_DATA) and
--          pixel_ready_i='1'
--        )
--      )
--    else
--      '0';
--      
--    -- 
--    tx_stream_o.ff_tx_sop <=
--      '1' when
--        current_state_r = H1
--      else
--        '0';
--        
--    --
--    tx_stream_o.ff_tx_eop <=
--      '1' when
--        current_state_r = LAST_DATA
--      else
--        '0';
--      
--    --
--    tx_stream_o.ff_tx_mod <=
--      byte_to_send_r(1 downto 0) when
--        current_state_r = LAST_DATA
--      else
--        std_logic_vector(to_unsigned(0, 2));
--    
--    --     
--    tx_stream_o.ff_tx_err <=
--      '0';
--
--    tx_stream_o.ff_tx_data <=
--      -- Header word 1:
--      -- X"0000" & PC_MAC_ADDRESS(47 downto 32) when
--		X"0000" & avalon_remote_MAC_MSB_i(15 downto 0) when
--        current_state_r = H1
--      else
--        -- Header word 2:
--        --PC_MAC_ADDRESS(31 downto 0) when
--		  avalon_remote_MAC_LSB_i(31 downto 0) when
--          current_state_r = H2
--      else 
--        -- Header word 3:
--        --LOCAL_MAC_ADDRESS(47 downto 16) when
--		 avalon_local_MAC_MSB_i(15 downto 0) &  avalon_local_MAC_LSB_i(31 downto 16) when 
--          current_state_r = H3
--      else
--        -- Header word 4:
--        --LOCAL_MAC_ADDRESS(15 downto 0) &
--        --ETHERNET_TYPE_IPV4 when
--		  avalon_local_MAC_LSB_i(15 downto 0) & ETHERNET_TYPE_IPV4 when
--		  current_state_r = H4
--      else
--        -- Header word 5:
--        IPV4_VERSION &
--        IPV4_IHL &
--        IPV4_SERVICE_TYPE &
--        -- Length Ipv4 Header + Payload
--        std_logic_vector(to_unsigned(IPV4_PACKET_LENGTH, 16)) when
--          current_state_r = H5
--      else
----        -- Header word 6:
----        --  - Identification
----        line_num_r(15 downto 0) &
----        --  - Flags
----        std_logic_vector(to_unsigned(0, 3)) &
----        --  - Fragment Position
----        std_logic_vector(to_unsigned(0, 13))   
--			(others => '0')
--		  when
--          current_state_r = H6
--      else
--        -- Header word 7:
--        IPV4_TIME_TO_LIVE &
--        IPV4_PROTOCOL_UDP &
--		  avalon_checksum_i when
--        --std_logic_vector(to_unsigned(IPVA_HEADER_PRECOMPUTED_CHECKSUM-to_integer(unsigned(line_num_r(15 downto 0))), 16)) when
--          current_state_r = H7
--      else
--        -- Header word 8:
--        --LOCAL_IP_ADDRESS when
--		  avalon_local_IP_i when
--          current_state_r = H8
--      else
--        -- Header word 9:
--        --PC_IP_ADDRESS when
--		  avalon_remote_IP_i when
--          current_state_r = H9
--      else
--        -- Header word 10:
--        avalon_local_port_i & avalon_remote_port_i when
--          current_state_r = H10
--      else
--        -- Header word 11:
--        --  - Length Udp Header + Payload
--        std_logic_vector(to_unsigned(8+UDP_DATA_BYTE_LENGTH, 16)) &
--        --  - Checksum: intentionally left null
--        X"0000" when
--          current_state_r = H11
--      else
--        -- DATA or LAST DATA:
--        pixel_i when
--          current_state_r = DATA or
--          current_state_r = LAST_DATA
--      else
--        (others => 'U');
--        
--    --
--    pixel_read_o <=
--      '1' when
--        (
--          current_state_r = DATA or
--          current_state_r = LAST_DATA
--        ) and
--        pixel_ready_i = '1' and 
--        tx_stream_i.ff_tx_ready = '1'
--      else 
--        '0';
--      
--    -- 
--    signal_o.done <=
--      '1' when
--        current_state_r = SEND_DONE
--      else
--        '0';
--        
end udp_video_arc;      