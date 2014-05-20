library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ethernet_package.all;

entity tx_arbiter_tb is
end tx_arbiter_tb;

architecture tx_arbiter_tb_sim of tx_arbiter_tb is

    constant OSCILLATOR_FREQUENCY : real := 50000000.0;
    constant OSCILLATOR_DUTYCYCLE : real := 0.5;
    constant RESET_LEVEL    : integer := 1;
    constant RESET_DURATION : time    := 50 ns;
    
    signal clk_s                 : std_logic;
    signal rst_s                 : std_logic;
    signal tx_arbiter_i_s        : tx_arbiter_i_t;
    signal tx_arbiter_o_s        : tx_arbiter_o_t;


begin
  OSCILLATOR : entity work.oscillator(oscillator_sim)
  generic map(
    OSCILLATOR_FREQUENCY => OSCILLATOR_FREQUENCY,
    OSCILLATOR_DUTYCYCLE => OSCILLATOR_DUTYCYCLE
  )
  port map(
    clk_o => clk_s
  );
  
  WATCHDOG : entity work.watchdog(watchdog_sim)
  generic map(
    RESET_LEVEL => RESET_LEVEL,
    RESET_DURATION => RESET_DURATION
  )
  port map(
    rst_o => rst_s
  );
  
  DUT : entity work.tx_arbiter(tx_arbiter_arc)
  port map (
  clk_i        => clk_s,         
  rst_i        => rst_s,         
  tx_arbiter_i => tx_arbiter_i_s,
  tx_arbiter_o => tx_arbiter_o_s
  );
  
  process
  begin
    -- Initialization
    for i in 0 to TX_ARBITER_CHANNNEL_NUMBER-1 loop
      tx_arbiter_i_s.request(i) <= '0';
      tx_arbiter_i_s.release(i) <= '0';
    end loop;
    -- Reset
    wait for RESET_DURATION*2;
    -- Channel 0 request
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.request(0) <= '1';
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.request(0) <= '0';
    wait until tx_arbiter_o_s.acknowledge(0) = '1';
    wait for 3 us;
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(0) <= '1';  
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(0) <= '0';  
    -- Simultaneous request
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.request(0) <= '1';
      tx_arbiter_i_s.request(1) <= '1';
      tx_arbiter_i_s.request(2) <= '1';
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.request(0) <= '0';
      tx_arbiter_i_s.request(1) <= '0';
      tx_arbiter_i_s.request(2) <= '0';
    wait until tx_arbiter_o_s.acknowledge(0) = '1';
    wait for 3 us;
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(0) <= '1';  
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(0) <= '0'; 
    wait until tx_arbiter_o_s.acknowledge(1) = '1';
    wait for 3 us;
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(1) <= '1';  
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(1) <= '0'; 
    wait until tx_arbiter_o_s.acknowledge(2) = '1';
    wait for 1 us;
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.request(1) <= '1';
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.request(1) <= '0';
    wait for 1 us;
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.request(0) <= '1';
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.request(0) <= '0';   
    wait for 1 us;
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(2) <= '1';  
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(2) <= '0';
    wait until tx_arbiter_o_s.acknowledge(0) = '1';
    wait for 5 us;  
    wait for 3 us;
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(0) <= '1';  
    wait until clk_s'event and clk_s='1';
      tx_arbiter_i_s.release(0) <= '0'; 
    wait;
  end process;
  
end tx_arbiter_tb_sim;