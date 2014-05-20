library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library work;
use work.rgmii_if_pack.all;
use work.com_eth_if_pack.all;

entity tb_com_eth_if is
end tb_com_eth_if;

architecture sim of tb_com_eth_if is

signal clk_50mhz_s        : std_logic;
signal clk_125mhz_s : std_logic;
signal rst_n_s        : std_logic;
signal rgmii_i_s    : rgmii_i_t;
signal rgmii_o_s    : rgmii_o_t;

begin

  rgmii_i_s.rx_clk  <= rgmii_o_s.gtx_clk;
  rgmii_i_s.rx_ctrl <= '0'; --rgmii_o_s.tx_ctrl;
  rgmii_i_s.rx_data <= (others => '0'); --rgmii_o_s.tx_data;
  
  -- DUT : com_eth_if
    -- port map (
      -- clk_i          => clk_50mhz_s,
      -- clk_125mhz_i   => clk_125mhz_s,
      -- rst_i          => rst_n_s,    

      -- rgmii_i        => rgmii_i_s,
      -- rgmii_o        => rgmii_o_s,
      
      -- eth_reset_n_o  =>open, 
      -- eth_mdc_o      =>open, 
      -- eth_mdio_i     =>'0'
    -- );
  FPGA_TOP_LEVEL : entity work.fpga_top_level
  port map(
    -- System clock
    clk_50mhz_i    => clk_50mhz_s,
    -- 
    clk_125mhz_i   => clk_125mhz_s,     
    -- System reset
    rst_n_i        => rst_n_s,
    -- Rgmii interface               
    rgmii_i        => rgmii_i_s,
    rgmii_o        => rgmii_o_s,
    -- Marvell 
    eth_reset_n_o  => open,
    eth_mdc_o      => open,
    eth_mdio_i     => '0',
    -- Watchdog ticks
    watchdog_wdi_o => open,
    -- Led display
    test_led_o     => open
    );

  CLK_50MHZ_PROC: process
  begin
    while true loop
      clk_50mhz_s <= '0';
      wait for 10 ns;
      clk_50mhz_s <= '1';
      wait for 10 ns;
    end loop;
  end process;

  CLK_125MHZ_PROC: process
  begin
    while true loop
      clk_125mhz_s <= '0';
      wait for 4 ns;
      clk_125mhz_s <= '1';
      wait for 4 ns;
    end loop;
  end process;  
  
  RSY_PROC : process
  begin
    rst_n_s <= '0';
    wait for 1 us;
    rst_n_s <= '1';
    wait;
  end process;
end;