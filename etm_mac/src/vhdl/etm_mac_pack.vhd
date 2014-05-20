library ieee;
use     ieee.std_logic_1164.all;

package etm_mac_pack is
  component mac_top
    port (
      -- System signals
      Reset              : in  std_logic;
      Clk_125M           : in  std_logic;
      Clk_user           : in  std_logic;
      Clk_reg            : in  std_logic;
      Speed              : out std_logic_vector(2 downto 0);
      -- User interface 
      Rx_mac_ra          : out std_logic;
      Rx_mac_rd          : in  std_logic;
      Rx_mac_data        : out std_logic_vector(31 downto 0);
      Rx_mac_BE          : out std_logic_vector(1 downto 0);
      Rx_mac_pa          : out std_logic;
      Rx_mac_sop         : out std_logic;
      Rx_mac_eop         : out std_logic;
      -- User interface 
      Tx_mac_wa          : out std_logic;
      Tx_mac_wr          : in  std_logic;
      Tx_mac_data        : in  std_logic_vector(31 downto 0);
      Tx_mac_BE          : in  std_logic_vector(1 downto 0);
      Tx_mac_sop         : in  std_logic;
      Tx_mac_eop         : in  std_logic;
      -- Pkg_lgth fifo
      Pkg_lgth_fifo_rd   : in  std_logic;
      Pkg_lgth_fifo_ra   : out std_logic;
      Pkg_lgth_fifo_data : out std_logic_vector(15 downto 0);
      -- Phy interface          
      Gtx_clk            : out std_logic;
      Rx_clk             : in  std_logic;
      Tx_clk             : in  std_logic;
      Tx_er              : out std_logic;
      Tx_en              : out std_logic;
      Txd                : out std_logic_vector(7 downto 0);
      Rx_er              : in  std_logic;
      Rx_dv              : in  std_logic;
      Rxd                : in  std_logic_vector(7 downto 0);
      Crs                : in  std_logic;
      Col                : in  std_logic;
      -- Host interface
      CSB                : in  std_logic;
      WRB                : in  std_logic;
      CD_in              : in  std_logic_vector(15 downto 0);
      CD_out             : out std_logic_vector(15 downto 0);
      CA                 : in  std_logic_vector(7 downto 0);
      -- Mdx
      Mdo                : out std_logic;
      MdoEn              : out std_logic;
      Mdi                : in  std_logic;
      Mdc                : out std_logic;
      
      debug              : out std_logic_vector(3 downto 0);
      
      MCrs_dv            : in  std_logic;
      MRxD               : in  std_logic_vector(7 downto 0);      
      MRxErr             : in  std_logic
    );
  end component;
  
  type tx_mac_i_t is record
    wr   : std_logic;
    data : std_logic_vector(31 downto 0);
    BE   : std_logic_vector(1 downto 0);
    sop  : std_logic;
    eop  : std_logic;
  end record;
  
  type tx_mac_o_t is record
    wa : std_logic;
  end record;
  
end package;