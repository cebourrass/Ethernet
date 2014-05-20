library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_mac_top is
end tb_mac_top;

architecture sim of tb_mac_top is
  
  signal rst_n_s       : std_logic;
  signal rst_s         : std_logic;
  signal clk_user_s    : std_logic;
  signal clk_reg_s     : std_logic;
  signal clk_125mhz_s  : std_logic;
  
  signal tx_mac_wa_s   : std_logic;
  signal tx_mac_wr_s   : std_logic;
  signal tx_mac_sop_s  : std_logic;
  signal tx_mac_eop_s  : std_logic;
  signal tx_mac_data_s : std_logic_vector(31 downto 0);
  signal tx_mac_be_s : std_logic_vector(1 downto 0);
  
  
  signal etm_tx_en_s   : std_logic;
  signal etm_tx_data_s : std_logic_vector(7 downto 0);
  
  
  signal cntr_s : std_logic_vector(31 downto 0);
  
begin
  rst_n_s <= not rst_s;
  
  RGMII_IF_INST : entity work.rgmii_if
    port map (
    clk_i          => clk_user_s,
    rst_n_i        => rst_n_s,

    gtx_clk_o      => open,
    tx_en_o        => open,
    tx_data_o      => open,

    rx_clk_i       => '0',
    rx_en_i        => '0',
    rx_data_i      => (others => '0'),

    rx_data_o      => open,
    rx_en_o        => open,
    rx_err_o       => open,

    eth_reset_n_o  => open,
    eth_mdc_o      => open,
    eth_mdio_i     => '0',

    watchdog_wdi_o => open,
    test_led_o     => open
    );

  MAC_TOP_INST : entity work.mac_top(sim)
    port map (
      --system signals
      Reset              =>rst_s,     -- input           Reset                   ,
      Clk_125M           =>clk_125mhz_s,     -- input           Clk_125M                ,
      Clk_user           =>clk_user_s,     -- input           clk_user                ,
      clk_reg            =>clk_reg_s,     -- input           Clk_reg                 ,
      Speed              =>open,     -- output  [2:0]   Speed                   ,
      --user interface
      Rx_mac_ra          =>open,     -- output          Rx_mac_ra               ,
      Rx_mac_rd          =>'0',     -- input           Rx_mac_rd               ,
      Rx_mac_data        =>open,     -- output  [31:0]  Rx_mac_data             ,
      Rx_mac_BE          =>open,     -- output  [1:0]   Rx_mac_BE               ,
      Rx_mac_pa          =>open,     -- output          Rx_mac_pa               ,
      Rx_mac_sop         =>open,     -- output          Rx_mac_sop              ,
      Rx_mac_eop         =>open,     -- output          Rx_mac_eop              ,
      --user interface
      Tx_mac_wa          =>tx_mac_wa_s,     -- output          Tx_mac_wa               ,
      Tx_mac_wr          =>tx_mac_wr_s,     -- input           Tx_mac_wr               ,
      Tx_mac_data        =>tx_mac_data_s,     -- input   [31:0]  Tx_mac_data             ,
      Tx_mac_BE          =>tx_mac_be_s,     -- input   [1:0]   Tx_mac_BE               ,//big endian
      Tx_mac_sop         =>tx_mac_sop_s,     -- input           Tx_mac_sop              ,
      Tx_mac_eop         =>tx_mac_eop_s,     -- input           Tx_mac_eop              ,
      --pkg_lgth fifo
      Pkg_lgth_fifo_rd   =>'0',     -- input           Pkg_lgth_fifo_rd        ,
      Pkg_lgth_fifo_ra   =>open,     -- output          Pkg_lgth_fifo_ra        ,
      Pkg_lgth_fifo_data =>open,     -- output  [15:0]  Pkg_lgth_fifo_data      ,
      --Phy interface
      Gtx_clk            =>open,     -- output          Gtx_clk                 ,//used only in GMII mode
      Rx_clk             =>'0',     -- input           Rx_clk                  ,
      Tx_clk             =>'0',     -- input           Tx_clk                  ,//used only in MII mode
      Tx_er              =>open,     -- output          Tx_er                   ,
      Tx_en              =>etm_tx_en_s,     -- output          Tx_en                   ,
      Txd                =>etm_tx_data_s,     -- output  [7:0]   Txd                     ,
      Rx_er              =>'0',     -- input           Rx_er                   ,
      Rx_dv              =>'0',     -- input           Rx_dv                   ,
      Rxd                =>(others => '0'),     -- input   [7:0]   Rxd                     ,
      Crs                =>'0',     -- input           Crs                     ,
      Col                =>'0',     -- input           Col                     ,
      --host interface
      CSB                =>'0',     -- input           CSB                     ,
      WRB                =>'0',     -- input           WRB                     ,
      CD_in              =>(others => '0'),     -- input   [15:0]  CD_in                   ,
      CD_out             =>open,     -- output  [15:0]  CD_out                  ,
      CA                 =>(others => '0'),     -- input   [7:0]   CA                      ,                
      --mdx              
      Mdo						     =>open,     -- output          Mdo						,// MII Management Data Output
      MdoEn					     =>open,     -- output          MdoEn					,// MII Management Data Output Enable
      Mdi						     =>'0',     -- input           Mdi						,// MII Management Data Input
      Mdc                =>open     -- output          Mdc                      // MII Management Data Clock  
    );

  RESET_PROC : process 
    begin
      rst_s <= '1';
      wait for 10 us;
      rst_s <= '0';
      wait;
    end process;
    
  OSC_USER_PROC : process 
    begin
      while true loop
        clk_user_s <= '0';
        wait for 5 ns;
        clk_user_s <= '1';
        wait for 5 ns;
      end loop;
    end process;
    
  OSC_REG_PROC : process 
    begin
      while true loop
        clk_reg_s <= '0';
        wait for 5 ns;
        clk_reg_s <= '1';
        wait for 5 ns;
      end loop;
    end process;
    
  OSC_125M_PROC : process 
    begin
      while true loop
        clk_125mhz_s <= '0';
        wait for 4 ns;
        clk_125mhz_s <= '1';
        wait for 4 ns;
      end loop;
    end process;

  TX_PROC : process(clk_user_s, rst_s)
    begin
      if rst_s='1' then 
        tx_mac_wr_s   <= '0';
        tx_mac_sop_s  <= '0';
        tx_mac_eop_s  <= '0';
        tx_mac_data_s <= (others => '0');
        tx_mac_be_s   <= (others => '0');
        
        cntr_s <= (others => '0');
      else
        if clk_user_s'event and clk_user_s='1' then
          if tx_mac_wa_s='1' then
            cntr_s <= cntr_s+1;
            if cntr_s=0 then
              tx_mac_sop_s  <= '1';
              tx_mac_wr_s   <= '1';
            else
              tx_mac_sop_s  <= '0';
              if cntr_s<42 then
                tx_mac_data_s <= cntr_s;
              else
                if cntr_s=42 then
                  tx_mac_eop_s  <= '1';
                  tx_mac_data_s <= (others => '0');
                else
                  tx_mac_eop_s  <= '0';
                  tx_mac_wr_s   <= '0';
                    if cntr_s=50 then
                      cntr_s <= (others => '0');
                    end if;
                end if;
              end if;
            end if;
          end if;
        end if;
      end if;
    end process;
end sim;
