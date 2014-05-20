library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

package debug_pack is

  type debug_o_t is record
    etm_rx_pa      : std_logic;
    phy_rx_er      : std_logic;
    phy_rx_clk     : std_logic;
    phy_rx_dv      : std_logic;
    phy_rxd_0      : std_logic;
    phy_rxd_1      : std_logic;
    phy_rxd_2      : std_logic;
    phy_rxd_3      : std_logic;
  end record;

end package;
