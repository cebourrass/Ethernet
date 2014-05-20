-- todo
-- remplace tx_en_o par tx_ctl_o
-- remplace rx_en_i par rx_ctl_i

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.rgmii_if_pack.all;

entity rgmii_if is
  port (
    clk_i       : in  std_logic;
    clk_90d_i   : in  std_logic;
    rst_i       : in  std_logic; 
    -- Rgmii output interface
    rgmii_i     : in  rgmii_i_t;
    rgmii_o     : out rgmii_o_t;
    -- Gmii input interface
    gmii_i      : in  gmii_o_t;
    gmii_o      : out gmii_i_t
    );
end rgmii_if;

architecture be_rgmii_if of rgmii_if is

  signal datain_h_s  : std_logic_vector (4 downto 0);
  signal datain_l_s  : std_logic_vector (4 downto 0);
  signal dataout_s   : std_logic_vector (4 downto 0);

  signal datain_s    : std_logic_vector (4 downto 0);
  signal dataout_h_s : std_logic_vector (4 downto 0);
  signal dataout_l_s : std_logic_vector (4 downto 0);

begin 
  
  datain_h_s      <= gmii_i.tx_en & gmii_i.tx_data(3 downto 0);
  datain_l_s      <= (gmii_i.tx_er xor gmii_i.tx_en)  & gmii_i.tx_data(7 downto 4);
  rgmii_o.tx_data <= dataout_s(3 downto 0); 

  rgmii_o.tx_ctrl <= dataout_s(4); 
  rgmii_o.gtx_clk <= clk_90d_i;

  DDIO_OUT_INST : ddio_out
    port map (
      datain_h   => datain_h_s,
      datain_l   => datain_l_s,
      outclock   => clk_i,
      dataout    => dataout_s
      );

  datain_s(4)          <= rgmii_i.rx_ctrl;
  datain_s(3 downto 0) <= rgmii_i.rx_data;
  
  gmii_o.rx_data <= dataout_h_s(3 downto 0) & dataout_l_s(3 downto 0);
  gmii_o.rx_dv   <= dataout_l_s(4);
  -- gmii_o.rx_er   <= dataout_h_s(4) xor dataout_l_s(4);
  gmii_o.rx_er   <= '0';
  gmii_o.rx_clk  <= rgmii_i.rx_clk;
  gmii_o.tx_clk  <= '0';
  gmii_o.col     <= '0';
  gmii_o.crs     <= '0';
  
  DDIO_IN_INST : ddio_in
    port map (
      datain    => datain_s,
      inclock	  => rgmii_i.rx_clk,
      dataout_h => dataout_h_s,
      dataout_l => dataout_l_s
      );
end be_rgmii_if;
