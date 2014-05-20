library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

entity rgmii_if_tb is
end rgmii_if_tb;

architecture sim of rgmii_if_tb is

signal clk_s       : std_logic;
signal rst_n_s     : std_logic;
signal gtx_clk_o_s : std_logic;
signal tx_en_o_s   : std_logic;
signal tx_data_o_s : std_logic_vector (3 downto 0);
signal rx_clk_i_s  : std_logic;
signal rx_en_i_s   : std_logic;
signal rx_data_i_s : std_logic_vector (3   downto 0);

begin

  rx_clk_i_s  <= gtx_clk_o_s;
  rx_en_i_s   <= tx_en_o_s;
  rx_data_i_s <= tx_data_o_s;
  
  DUT : entity work.rgmii_if(be_rgmii_if)
    port map (
      clk_i     => clk_s,    
      rst_n_i   => rst_n_s,    
    
      gtx_clk_o => gtx_clk_o_s,
      tx_en_o   => tx_en_o_s,  
      tx_data_o => tx_data_o_s, 
       
      rx_clk_i  => rx_clk_i_s, 
      rx_en_i   => rx_en_i_s,  
      rx_data_i => rx_data_i_s,
      
      eth_reset_n_o => open ,
      eth_mdc_o     => open,
      eth_mdio_i    => '0'
    );

  CLK_PROC: process
  begin
    while true loop
      clk_s <= '0';
      wait for 4 ns;
      clk_s <= '1';
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