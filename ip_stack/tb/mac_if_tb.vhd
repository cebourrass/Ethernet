library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fpga_pack.all;

entity mac_if_tb is
end mac_if_tb;

architecture mac_if_tb_arc of mac_if_tb is

    constant OSCILLATOR_FREQUENCY : real := 50000000.0;
    constant OSCILLATOR_DUTYCYCLE : real := 0.5;
    constant RESET_LEVEL    : integer := 1;
    constant RESET_DURATION : time    := 50 ns;
    
    signal clk_s                 : std_logic;
    signal rst_i_s               : com_rst_m2s_t;
    signal ff_rx_ready_s         : std_logic;
    signal ff_rx_data_s          : std_logic_vector(31 downto 0);
    signal ff_rx_mod_s           : std_logic_vector(1 downto 0);
    signal ff_rx_sop_s           : std_logic;
    signal ff_rx_eop_s           : std_logic;
    signal ff_rx_err_s           : std_logic_vector(5 downto 0);
    signal ff_rx_val_s           : std_logic;
    signal ff_tx_ready_s         : std_logic;
    signal ff_tx_data_s          : std_logic_vector(31 downto 0);
    signal ff_tx_mod_s           : std_logic_vector(1 downto 0);
    signal ff_tx_sop_s           : std_logic;
    signal ff_tx_eop_s           : std_logic;
    signal ff_tx_err_s           : std_logic; --std_logic_vector(5 downto 0);
    signal ff_tx_wren_s          : std_logic;
    signal tse_cfg_address_s     : std_logic_vector(9 downto 0);
    signal tse_cfg_write_s       : std_logic;   
    signal tse_cfg_read_s        : std_logic;   
    signal tse_cfg_writedata_s   : std_logic_vector(31 downto 0);
    signal tse_cfg_readdata_s    : std_logic_vector(31 downto 0);
    signal tse_cfg_waitrequest_s : std_logic;
    signal test_pin_s            : std_logic_vector(7 downto 0);
    
begin
  DUT : entity work.mac_if_entity(mac_if_arc)
  port map (
  clk_i        => clk_s,         
  com_rst_i    => rst_i_s,         
  ff_rx_ready  => ff_rx_ready_s, 
  ff_rx_data   => ff_rx_data_s,  
  ff_rx_mod    => ff_rx_mod_s,   
  ff_rx_sop    => ff_rx_sop_s,   
  ff_rx_eop    => ff_rx_eop_s,   
  ff_rx_err    => ff_rx_err_s,   
  ff_rx_val    => ff_rx_val_s,   
  ff_tx_ready  => ff_tx_ready_s, 
  ff_tx_data   => ff_tx_data_s,  
  ff_tx_mod    => ff_tx_mod_s,   
  ff_tx_sop    => ff_tx_sop_s,   
  ff_tx_eop    => ff_tx_eop_s,   
  ff_tx_err    => ff_tx_err_s,   
  ff_tx_wren   => ff_tx_wren_s,
  tse_cfg_address     => tse_cfg_address_s,
  tse_cfg_write       => tse_cfg_write_s,
  tse_cfg_read        => tse_cfg_read_s,
  tse_cfg_writedata   => tse_cfg_writedata_s,
  tse_cfg_readdata    => tse_cfg_readdata_s,
  tse_cfg_waitrequest => tse_cfg_waitrequest_s,
  
  configuration_packet_o => open,
  udp_send_video_line_i  => '0',
  pixel_ready_i          => '0',
  pixel_read_o           => open,
  pixel_i                => (others => '0'),
  debug_bus_o            => open
  );
  
  process
  begin
    ff_rx_data_s <= (others => '0');
    ff_rx_mod_s  <= (others => '0');
    ff_rx_sop_s  <= '0';
    ff_rx_eop_s  <= '0'; 
    ff_rx_err_s  <= (others => '0');
    ff_rx_val_s  <= '0';
    
    ff_tx_ready_s <= '1';
    wait until rst_i_s.rst='1';
    wait for 500 ns;
    
    wait until clk_s'event and clk_s='1';
      ff_rx_data_s <= X"0000FFFF";
      ff_rx_sop_s <= '1';
      ff_rx_val_s <= '1';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"FFFFFFFF";
      ff_rx_sop_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"54424987";
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      -- ARP request
      ff_rx_data_s <= X"3B740806";
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"00010800";
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"06040001";
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"54424987"; 
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s(31 downto 16) <= X"3B74"; 
      ff_rx_data_s(15 downto 8) <= std_logic_vector(to_unsigned(192, 8));
      ff_rx_data_s(7 downto 0) <= std_logic_vector(to_unsigned(168, 8));
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(0, 8)); 
      ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(1, 8));
      ff_rx_data_s(15 downto 0) <= X"0000"; 
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"00000000"; 
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(192, 8)); 
      ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(168, 8));
      ff_rx_data_s(15 downto 8) <= std_logic_vector(to_unsigned(0, 8)); 
      ff_rx_data_s(7 downto 0) <=  std_logic_vector(to_unsigned(2, 8));
      ff_rx_eop_s <= '1';
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_eop_s <= '0';
      ff_rx_data_s <= X"00000000";
      
    wait for 350 ns;
    
    wait until clk_s'event and clk_s='1';
      ff_rx_data_s <= X"0000FFFF";
      ff_rx_sop_s <= '1';
      ff_rx_val_s <= '1';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"FFFFFFFF";
      ff_rx_sop_s <= '0';
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"54424987";
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      -- IPV4
      ff_rx_data_s <= X"3B740800";
    wait until clk_s'event and clk_s='1'; 
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Version
        ff_rx_data_s(31 downto 24) <= X"45"; 
        -- Service
        ff_rx_data_s(23 downto 16) <= X"00"; 
        -- Length   
        ff_rx_data_s(15 downto 0) <= X"0000"; 
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- ID
        ff_rx_data_s(31 downto 16) <= X"ABCD"; 
        -- Flags
        ff_rx_data_s(15 downto 13) <= "000"; 
        -- Fragment Position
        ff_rx_data_s(12 downto 0) <= "0000000000000"; 
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- TTL
        ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(1, 8)); 
        -- Protocol
        ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(1, 8));
        -- CS
        ff_rx_data_s(15 downto 0) <= X"1234"; 
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Source Ip
        ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(192, 8)); 
        ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(168, 8));
        ff_rx_data_s(15 downto 8) <= std_logic_vector(to_unsigned(0, 8)); 
        ff_rx_data_s(7 downto 0) <=  std_logic_vector(to_unsigned(1, 8));
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Destination Ip
        ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(192, 8)); 
        ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(168, 8));
        ff_rx_data_s(15 downto 8) <= std_logic_vector(to_unsigned(0, 8)); 
        ff_rx_data_s(7 downto 0) <=  std_logic_vector(to_unsigned(2, 8));  
    wait until clk_s'event and clk_s='1';  
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Type
        ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(8, 8)); 
        -- Code
        ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(0, 8)); 
        -- CheckSum
        ff_rx_data_s(15 downto 0) <= std_logic_vector(to_unsigned(1024, 16));            
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- ID
        ff_rx_data_s(31 downto 16) <= std_logic_vector(to_unsigned(784, 16)); 
        -- Sequence Number  
        ff_rx_data_s(15 downto 0) <= std_logic_vector(to_unsigned(65333, 16)); 
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        DATA_PACKET : for i in 0 to 6 loop
          ff_rx_data_s(31 downto 0) <= std_logic_vector(to_unsigned(i, 32));     
          wait until clk_s'event and clk_s='1';
            ff_rx_val_s <= '0';
          wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        end loop;
        ff_rx_data_s(31 downto 0) <= X"12345678";   
        ff_rx_eop_s <= '1';
    wait until clk_s'event and clk_s='1';  
      ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_eop_s <= '0';
      
    wait for 350 ns;
        
    wait until clk_s'event and clk_s='1';
      ff_rx_data_s <= X"0000FFFF";
      ff_rx_sop_s <= '1';
      --ff_rx_val_s <= '1';
    wait until clk_s'event and clk_s='1';
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"FFFFFFFF";
      ff_rx_sop_s <= '0';
    wait until clk_s'event and clk_s='1';  
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      ff_rx_data_s <= X"54424987";
    wait until clk_s'event and clk_s='1';
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
      -- IPV4
      ff_rx_data_s <= X"3B740800";
    wait until clk_s'event and clk_s='1'; 
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Version
        ff_rx_data_s(31 downto 24) <= X"45"; 
        -- Service
        ff_rx_data_s(23 downto 16) <= X"00"; 
        -- Length   
        ff_rx_data_s(15 downto 0) <= X"0000"; 
    wait until clk_s'event and clk_s='1';  
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- ID
        ff_rx_data_s(31 downto 16) <= X"ABCD"; 
        -- Flags
        ff_rx_data_s(15 downto 13) <= "000"; 
        -- Fragment Position
        ff_rx_data_s(12 downto 0) <= "0000000000000"; 
    wait until clk_s'event and clk_s='1';  
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- TTL
        ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(1, 8)); 
        -- Protocol
        ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(17, 8));
        -- CS
        ff_rx_data_s(15 downto 0) <= X"1234"; 
    wait until clk_s'event and clk_s='1';
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Source Ip
        ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(192, 8)); 
        ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(168, 8));
        ff_rx_data_s(15 downto 8) <= std_logic_vector(to_unsigned(0, 8)); 
        ff_rx_data_s(7 downto 0) <=  std_logic_vector(to_unsigned(1, 8));
    wait until clk_s'event and clk_s='1';  
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Destination Ip
        ff_rx_data_s(31 downto 24) <= std_logic_vector(to_unsigned(192, 8)); 
        ff_rx_data_s(23 downto 16) <= std_logic_vector(to_unsigned(168, 8));
        ff_rx_data_s(15 downto 8) <= std_logic_vector(to_unsigned(0, 8)); 
        ff_rx_data_s(7 downto 0) <=  std_logic_vector(to_unsigned(2, 8));  
     wait until clk_s'event and clk_s='1';  
        ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Source Port
        ff_rx_data_s(31 downto 16) <= std_logic_vector(to_unsigned(23, 16)); 
        -- Destination Port
        ff_rx_data_s(15 downto 0) <= std_logic_vector(to_unsigned(4660, 16));    
    wait until clk_s'event and clk_s='1';  
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- Data Length
        ff_rx_data_s(31 downto 16) <= std_logic_vector(to_unsigned(784, 16)); 
        -- CheckSum
        ff_rx_data_s(15 downto 0) <= std_logic_vector(to_unsigned(33, 16));            
    wait until clk_s'event and clk_s='1';  
       ff_rx_val_s <= '0';
    wait until clk_s'event and clk_s='1';
      ff_rx_val_s <= '1';
        -- First data
        ff_rx_data_s(31 downto 0) <= X"12345678";     
        ff_rx_eop_s <= '1';
    wait until clk_s'event and clk_s='1';  
      ff_rx_eop_s <= '0';
      
    wait;
  end process;
  
   process
  begin
    tse_cfg_waitrequest_s <= '0';
    while (true) loop
      wait until tse_cfg_write_s = '1';
      tse_cfg_waitrequest_s <= '1';
      wait for 100 ns;
      wait until clk_s'event and clk_s='1';
      tse_cfg_waitrequest_s <= '0';
    end loop;
  end process;
  
  process
  begin
    -- tse_cgf_address_s <= (others => '0');
    -- tse_cgf_write_s <= '0';
    -- tse_cgf_read_s <= '0';
    -- tse_cgf_writedata_s <= (others => '0');
    tse_cfg_readdata_s <= (others => '0');
    wait;
  end process; 
 
  process
  begin
    while (true) loop
      clk_s <= '1';
      wait for ((OSCILLATOR_DUTYCYCLE * 1000000000.0)/OSCILLATOR_FREQUENCY) * 1 ns;
      clk_s <= '0';
      wait for (((1.0 - OSCILLATOR_DUTYCYCLE) * 1000000000.0) / OSCILLATOR_FREQUENCY) * 1 ns;
    end loop;
  end process;
  
  process
  begin
    report "Hello" severity NOTE;
    if RESET_LEVEL = 1 then
      rst_i_s.rst <= '1';
    else
      rst_i_s.rst <= '0';
    end if;
    wait for RESET_DURATION;
    rst_i_s.rst <= not rst_i_s.rst;
    wait;
  end process;
  
end mac_if_tb_arc;