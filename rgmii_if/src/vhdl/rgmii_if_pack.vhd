library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

package rgmii_if_pack is

  type gmii_o_t is record
    gtx_clk : std_logic;
    tx_en   : std_logic;
    tx_er   : std_logic;
    tx_data : std_logic_vector (7 downto 0);
  end record;
  
  type gmii_i_t is record
    tx_clk  : std_logic;
    rx_clk  : std_logic;
    rx_dv   : std_logic;
    rx_er   : std_logic;
    rx_data : std_logic_vector (7 downto 0);
    crs     : std_logic;
    col     : std_logic;
  end record;  

  type rgmii_o_t is record
    gtx_clk : std_logic;
    tx_ctrl : std_logic;
    tx_data : std_logic_vector (3 downto 0);
  end record;
  
  type rgmii_i_t is record
    rx_clk  : std_logic;
    rx_ctrl : std_logic;
    rx_data : std_logic_vector (3 downto 0);
  end record;  
  
  component rgmii_if
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
  end component;
    
  component pll
    port (
      inclk0 : in std_logic  := '0';
      c0     : out std_logic ;
      c1     : out std_logic 
    );
  end component;
  
  component ddio_out
    port (
      datain_h   : in std_logic_vector (4 downto 0);
      datain_l   : in std_logic_vector (4 downto 0);
      outclock   : in std_logic;
      dataout    : out std_logic_vector (4 downto 0)
    );
  end component;
  
  component ddio_in
    port (
      datain		: in std_logic_vector (4 downto 0);
      inclock		: in std_logic ;
      dataout_h	: out std_logic_vector (4 downto 0);
      dataout_l	: out std_logic_vector (4 downto 0)
    );
  end component;  
end package;
