library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;


library work;
use work.debug_pack.all;
use work.ethernet_package.all;
use work.reset_generator_pack.all;
use work.ticks_generator_pack.all;
use work.rgmii_if_pack.all;
use work.etm_mac_pack.all;
use work.com_eth_if_pack.all;

entity com_eth_if is
  port (
    -- System clock
    clk_50mhz_i    : in    std_logic;
    clk_100mhz_i   : in    std_logic;
    -- 
    clk_125mhz_i   : in    std_logic;    
    -- System reset
    rst_i          : in    com_rst_m2s_t;
    rst_o          : out   com_rst_s2m_t;
    -- System ticks
    ticks_i        : in    ticks_t;
    -- Rgmii interface               
    rgmii_i        : in    rgmii_i_t;
    rgmii_o        : out   rgmii_o_t;
    -- Rmii interface
    gmii_i         : in    gmii_i_t;
    gmii_o         : out   gmii_o_t;      
    -- Marvell 
    eth_reset_n_o  : out   std_logic;
    eth_mdc_o      : out   std_logic;
    eth_mdio_io    : inout std_logic;
    -- Debug
    debug_o        : out   debug_o_t;
    -- udp
    udp_send_video_line_i	: in std_logic;
    pixel_ready_i		      : in std_logic;
    pixel_read_o          : out std_logic;
    pixel_i               : in std_logic_vector(31 downto 0);
	
	 fifo_empty_i : in std_logic;
	 rd_fifo_o : out std_logic;
	 
	-- Avalon interface
	 avalon_status_register0_i : in std_logic_vector(31 downto 0);
	 avalon_status_register1_i : in std_logic_vector(31 downto 0);
	 avalon_status_register2_i : in std_logic_vector(31 downto 0);
	 avalon_status_register3_i : in std_logic_vector(31 downto 0);
	 avalon_status_register4_i : in std_logic_vector(31 downto 0);
	 avalon_status_register5_i : in std_logic_vector(31 downto 0);
	 avalon_status_register6_i : in std_logic_vector(31 downto 0);
	 avalon_status_register7_i : in std_logic_vector(31 downto 0);
	 
	 udp_send_status_i : in std_logic;
	 udp_signal_o      : out udp_signal_t;
	 configuration_packet_o : out configuration_packet_t;	 
	 
    av_eth_config_0_conduit_end_local_port_i     : in std_logic_vector(15 downto 0);
	 av_eth_config_0_conduit_end_remote_port_i    : in std_logic_vector(15 downto 0); 
	 av_eth_config_0_conduit_end_local_IP_i       : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_remote_IP_i      : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_local_MAC_LSB_i  : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_local_MAC_MSB_i  : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_remote_MAC_LSB_i : in std_logic_vector(31 downto 0); 
	 av_eth_config_0_conduit_end_checksum_i       : in std_logic_vector(15 downto 0);
	 av_eth_config_0_conduit_end_remote_MAC_MSB_i : in std_logic_vector(31 downto 0);

	 av_sendpacket_0_conduit_end_checksum_i       : in std_logic_vector(15 downto 0);                    -- checksum_o
  	 av_sendpacket_0_conduit_end_local_port_i     : in std_logic_vector(15 downto 0);                    -- local_port_o
    av_sendpacket_0_conduit_end_remote_port_i    : in std_logic_vector(15 downto 0);                    -- remote_port_o
    av_sendpacket_0_conduit_end_remote_IP_i      : in std_logic_vector(31 downto 0);                    -- remote_IP_o
    av_sendpacket_0_conduit_end_remote_MAC_MSB_i : in std_logic_vector(31 downto 0);                    -- remote_MAC_MSB_o
    av_sendpacket_0_conduit_end_remote_MAC_LSB_i : in std_logic_vector(31 downto 0); 
	 av_sendpacket_0_conduit_end_length_i			 : in std_logic_vector(15 downto 0)
	 
    );
end com_eth_if;

-- Etm mac instance
architecture be_com_eth_if of com_eth_if is

  signal rst_n_s         : std_logic;  
  signal rst_s           : std_logic;  

  signal com_rst_m2s_s   : com_rst_m2s_t;
  signal com_rst_s2m_s   : com_rst_s2m_t;
  
  signal rgmii_i_s : rgmii_i_t;
  signal rgmii_o_s : rgmii_o_t;

  signal gmii_i_s : gmii_i_t;
  signal gmii_o_s : gmii_o_t;  
  
  -- signal tx_mac_wa_s     : std_logic;
  -- signal tx_mac_wr_s     : std_logic;
  -- signal tx_mac_sop_s    : std_logic;
  -- signal tx_mac_eop_s    : std_logic;
  -- signal tx_mac_data_s   : std_logic_vector(31 downto 0);
  -- signal tx_mac_be_s     : std_logic_vector(1 downto 0);

  signal tx_wa_s         : std_logic;
  signal tx_wr_s         : std_logic;
  signal tx_sop_s        : std_logic;
  signal tx_eop_s        : std_logic;
  signal tx_data_s       : std_logic_vector(31 downto 0);
  signal tx_be_s         : std_logic_vector(1 downto 0);
  
  signal rx_ra_s         : std_logic;
  signal rx_rd_s         : std_logic;
  signal rx_data_s       : std_logic_vector(31 downto 0);
  signal rx_be_s         : std_logic_vector(1 downto 0);
  signal rx_pa_s         : std_logic;
  signal rx_sop_s        : std_logic;
  signal rx_eop_s        : std_logic;
  
  signal ff_tx_ready_s   : std_logic;
  signal ff_tx_data_s    : std_logic_vector(31 downto 0);
  signal ff_tx_mod_s     : std_logic_vector(1 downto 0);
  signal ff_tx_sop_s     : std_logic;
  signal ff_tx_eop_s     : std_logic;
  signal ff_tx_wren_s    : std_logic;

  signal ff_rx_ready_s   : std_logic;
  signal ff_rx_data_s    : std_logic_vector(31 downto 0);
  signal ff_rx_mod_s     : std_logic_vector(1 downto 0);
  signal ff_rx_sop_s     : std_logic;
  signal ff_rx_eop_s     : std_logic;
  signal ff_rx_val_s     : std_logic;

  signal Gtx_clk_s       : std_logic;
  signal Rx_clk_s        : std_logic;
  signal Tx_clk_s        : std_logic;
  signal Tx_er_s         : std_logic;
  signal Tx_en_s         : std_logic;
  signal Txd_s           : std_logic_vector (7 downto 0);
  signal Rx_er_s         : std_logic;
  signal Rx_dv_s         : std_logic; 
  signal Rxd_s           : std_logic_vector (7 downto 0);
  signal Crs_s           : std_logic;
  signal Col_s           : std_logic;
  
  signal csb_s           : std_logic; 
  signal wrb_s           : std_logic;
  signal cd_in_s         : std_logic_vector(15 downto 0);
  signal cd_out_s        : std_logic_vector(15 downto 0);
  signal ca_s            : std_logic_vector(7 downto 0);
  
  type fsm_t is (
    RESET,
    FSM1,
    FSM2,
    FSM3,
    FSM4,
    FSM5,
    FSM6,
    FSM7,
    FSM11,
    FSM12,
    FSM13,
    FSM14,
    FSM15,
    FSM16,
    FSM17,
    FSM21,
    FSM22,
    FSM23,
    FSM24,
    FSM25,
    FSM26,
    FSM27,     
    FSM100
    );
  signal fsm_r : fsm_t;
  
  signal ticks_1ms_cntr_s : std_logic_vector(3 downto 0);
  
  signal rgmii_clk_s     : std_logic;  
  signal rgmii_clk_90d_s : std_logic;  
  
  signal cntr_s          : std_logic_vector(12 downto 0);
  signal line_cntr_s     : std_logic_vector(15 downto 0);
  signal frame_cntr_s    : std_logic_vector(15 downto 0);
  signal pixel_s         : std_logic_vector(31 downto 0);
  
  signal packet_s        : packet_t := PACKET_TEST;
  signal send_s          : std_logic;
  
  signal ff_rx_reg_s     : std_logic_vector(15 downto 0);
  
  signal mdo_s           : std_logic;
  signal mdi_s           : std_logic;
  signal mdoen_s         : std_logic;
  
  signal ticks_s         : ticks_t; 
  
  signal debug_s         : std_logic_vector(3 downto 0);
  
  signal configuration_packet_s         : configuration_packet_t; 
	
  
begin
  -- Debug
  debug_o.etm_rx_pa      <= rx_pa_s;
  debug_o.phy_rx_er      <= Rx_er_s;
  debug_o.phy_rx_clk     <= Rx_clk_s;
  debug_o.phy_rx_dv      <= Rx_dv_s;
  debug_o.phy_rxd_0      <= not(configuration_packet_s.reg_7(31));
  debug_o.phy_rxd_1      <= debug_s(1);
  debug_o.phy_rxd_2      <= debug_s(2);
  debug_o.phy_rxd_3      <= debug_s(3);  
  -- debug_o.phy_rxd_0      <= debug_s(0);
  -- debug_o.phy_rxd_1      <= debug_s(1);
  -- debug_o.phy_rxd_2      <= debug_s(2);
  -- debug_o.phy_rxd_3      <= debug_s(3);
  -- debug_o.phy_rxd_0      <= Rxd_s(2);
  -- debug_o.phy_rxd_1      <= Rxd_s(3);
  -- debug_o.phy_rxd_2      <= Rxd_s(6);
  -- debug_o.phy_rxd_3      <= Rxd_s(7);
  
  --! Active high reset signal
  rst_s   <= rst_i.rst;
  --! Avtive low reset signal
  rst_n_s <= not rst_i.rst;
  
	configuration_packet_o <= configuration_packet_s;
  
  -- Marvell
  eth_reset_n_o <= rst_n_s;
  eth_mdio_io   <= mdo_s when mdoen_s='0' else 'Z';
  mdi_s         <= eth_mdio_io;
  
  rgmii_o.gtx_clk   <= rgmii_o_s.gtx_clk;
  rgmii_o.tx_ctrl   <= rgmii_o_s.tx_ctrl;
  rgmii_o.tx_data   <= rgmii_o_s.tx_data;
  
  rgmii_i_s.rx_clk  <= rgmii_i.rx_clk;
  rgmii_i_s.rx_ctrl <= rgmii_i.rx_ctrl;
  rgmii_i_s.rx_data <= rgmii_i.rx_data;
  
  -- Etm_mac instance
  ETM_MAC_INST : component mac_top
    port map (
      --system signals
      Reset              =>rst_s,
      Clk_125M           =>rgmii_clk_s,
      Clk_user           =>clk_100mhz_i,
      clk_reg            =>clk_100mhz_i,
      Speed              =>open,
      --user interface
      Rx_mac_ra          =>rx_ra_s,
      Rx_mac_rd          =>rx_rd_s,
      Rx_mac_data        =>rx_data_s,
      Rx_mac_BE          =>rx_be_s,
      Rx_mac_pa          =>rx_pa_s,
      Rx_mac_sop         =>rx_sop_s,
      Rx_mac_eop         =>rx_eop_s,
      --user interface
      Tx_mac_wa          =>tx_wa_s, 
      Tx_mac_wr          =>tx_wr_s, 
      Tx_mac_data        =>tx_data_s,
      Tx_mac_BE          =>tx_be_s, 
      Tx_mac_sop         =>tx_sop_s,
      Tx_mac_eop         =>tx_eop_s,
      --pkg_lgth fifo
      Pkg_lgth_fifo_rd   =>rst_s,
      Pkg_lgth_fifo_ra   =>open,
      Pkg_lgth_fifo_data =>open,
      --Phy interface
      Gtx_clk            =>Gtx_clk_s,
      Rx_clk             =>Rx_clk_s,
      Tx_clk             =>Tx_clk_s,
      Tx_er              =>Tx_er_s,
      Tx_en              =>Tx_en_s,
      Txd                =>Txd_s,
      Rx_er              =>Rx_er_s,
      Rx_dv              =>Rx_dv_s, 
      Rxd                =>Rxd_s,
      Crs                =>Crs_s,
      Col                =>Col_s,
      -- Host interface
      CSB                =>csb_s,
      WRB                =>wrb_s,
      CD_in              =>cd_in_s,
      CD_out             =>cd_out_s,
      CA                 =>ca_s,
      -- Management data in/out interface
      Mdo						     =>mdo_s,
      MdoEn					     =>mdoen_s,
      Mdi						     =>mdi_s,
      Mdc                =>eth_mdc_o,
      debug              =>debug_s,
      MCrs_dv            =>Rx_dv_s,
      MRxD               =>Rxd_s,     
      MRxErr             =>Rx_er_s
    );
  
  -- Ip stack instance
  IP_STACK_INST : configuration work.ip_stack_conf
    port map (
      clk_i                  => clk_100mhz_i,
      com_rst_i              => com_rst_m2s_s,
      com_rst_o              => com_rst_s2m_s,
      ff_rx_ready            => ff_rx_ready_s,
      ff_rx_data             => ff_rx_data_s, 
      ff_rx_mod              => ff_rx_mod_s,  
      ff_rx_sop              => ff_rx_sop_s,  
      ff_rx_eop              => ff_rx_eop_s,  
      ff_rx_err              => (others => '0'),  
      ff_rx_val              => ff_rx_val_s,  
      ff_tx_ready            => ff_tx_ready_s,
      ff_tx_data             => ff_tx_data_s,
      ff_tx_mod              => ff_tx_mod_s,
      ff_tx_sop              => ff_tx_sop_s,
      ff_tx_eop              => ff_tx_eop_s,
      ff_tx_err              => open,
      ff_tx_wren             => ff_tx_wren_s,
      tse_cfg_address        => open,
      tse_cfg_write          => open,
      tse_cfg_read           => open,
      tse_cfg_writedata      => open,
      tse_cfg_readdata       => (others => '0'),
      tse_cfg_waitrequest    => '0',
      configuration_packet_o => configuration_packet_s,
      udp_send_status_i      => udp_send_status_i,
      udp_send_video_line_i  => udp_send_video_line_i, -- send_s,
      pixel_ready_i          => pixel_ready_i, -- cntr_s(0),
      pixel_read_o           => pixel_read_o, -- open,
      pixel_i                => pixel_i, -- pixel_s
		fifo_empty_i =>fifo_empty_i,
		rd_fifo_o =>rd_fifo_o,
		avalon_status_register0 => avalon_status_register0_i,
		avalon_status_register1 => avalon_status_register1_i,
		avalon_status_register2 => avalon_status_register2_i,
		avalon_status_register3 => avalon_status_register3_i,
		avalon_status_register4 => avalon_status_register4_i,
		avalon_status_register5 => avalon_status_register5_i,
		avalon_status_register6 => avalon_status_register6_i,
		avalon_status_register7 => avalon_status_register7_i,
		udp_signal_s		=> udp_signal_o,
		av_eth_config_0_conduit_end_local_port_i     => av_eth_config_0_conduit_end_local_port_i,
		av_eth_config_0_conduit_end_remote_port_i    => av_eth_config_0_conduit_end_remote_port_i,
		av_eth_config_0_conduit_end_local_IP_i       => av_eth_config_0_conduit_end_local_IP_i,
		av_eth_config_0_conduit_end_remote_IP_i      => av_eth_config_0_conduit_end_remote_IP_i,
		av_eth_config_0_conduit_end_local_MAC_LSB_i  => av_eth_config_0_conduit_end_local_MAC_LSB_i,
		av_eth_config_0_conduit_end_local_MAC_MSB_i  => av_eth_config_0_conduit_end_local_MAC_MSB_i,
		av_eth_config_0_conduit_end_remote_MAC_LSB_i => av_eth_config_0_conduit_end_remote_MAC_LSB_i,
		av_eth_config_0_conduit_end_checksum_i       => av_eth_config_0_conduit_end_checksum_i,
		av_eth_config_0_conduit_end_remote_MAC_MSB_i => av_eth_config_0_conduit_end_remote_MAC_MSB_i,
		
		av_sendpacket_0_conduit_end_checksum_i       => av_sendpacket_0_conduit_end_checksum_i,
		av_sendpacket_0_conduit_end_local_port_i     => av_sendpacket_0_conduit_end_local_port_i,
		av_sendpacket_0_conduit_end_remote_port_i    => av_sendpacket_0_conduit_end_remote_port_i,
		av_sendpacket_0_conduit_end_remote_IP_i      => av_sendpacket_0_conduit_end_remote_IP_i,
		av_sendpacket_0_conduit_end_remote_MAC_MSB_i => av_sendpacket_0_conduit_end_remote_MAC_MSB_i,
		av_sendpacket_0_conduit_end_remote_MAC_LSB_i => av_sendpacket_0_conduit_end_remote_MAC_LSB_i,
		av_sendpacket_0_conduit_end_length_i =>  av_sendpacket_0_conduit_end_length_i
		);
		
   pixel_s <= line_cntr_s(7 downto 0) & "0000000" & line_cntr_s(8) & frame_cntr_s(7 downto 0) & cntr_s(7 downto 0); 
    
  com_rst_m2s_s.rst <= rst_s;


  -- Rx Word alignement
  rx_rd_s <= rx_ra_s;
  
  ff_rx_val_s <= rx_pa_s;
  ff_rx_sop_s <= rx_sop_s;
  ff_rx_eop_s <= rx_eop_s;
  ff_rx_mod_s <= rx_be_s;
  ff_rx_data_s(31 downto 16) <=ff_rx_reg_s;
  ff_rx_data_s(15 downto 0)  <=rx_data_s(31 downto 16);
  
  RX_WORD_ALIGN_PROC : process(clk_100mhz_i, rst_s)    
    begin
      if rst_s='1' then
        ff_rx_reg_s <= (others => '0');
      else
        if clk_100mhz_i'event and clk_100mhz_i='1' then
          if rx_pa_s='1' then
            ff_rx_reg_s <= rx_data_s(15 downto 0);
          else
            ff_rx_reg_s <= (others => '0');
          end if;
        end if;
      end if;
    end process;
  -- Tx Word alignement
  -- TX_WORD_ALIGNMENT_INST : entity work.tx_word_alignment(simple_shift)
  TX_WORD_ALIGNMENT_INST : entity work.tx_word_alignment(regen_1)
    port map (
      clk_100mhz_i => clk_100mhz_i,
      rst_i        => rst_s,
      ff_tx_ready  => ff_tx_ready_s,
      ff_tx_data   => ff_tx_data_s,
      ff_tx_mod    => ff_tx_mod_s,
      ff_tx_sop    => ff_tx_sop_s,
      ff_tx_eop    => ff_tx_eop_s,
      ff_tx_err    => '0',
      ff_tx_wren   => ff_tx_wren_s,
      Tx_mac_wa    => tx_wa_s,
      Tx_mac_wr    => tx_wr_s,
      Tx_mac_data  => tx_data_s,
      Tx_mac_BE    => tx_be_s,
      Tx_mac_sop   => tx_sop_s,
      Tx_mac_eop   => tx_eop_s      
    );
    
  -- Marvell configuration
  CONFIG_PROC : process(clk_100mhz_i, rst_s)    
    begin
      if rst_s='1' then
        fsm_r<=RESET;
        csb_s    <='1';
        wrb_s    <='1';
        cd_in_s  <=(others => '0');
        ca_s     <=(others => '0');
        
        ticks_1ms_cntr_s <= x"5"; -- 5ms
        rst_o.rst_done <= '0';
        rst_o.rst_status <= COM_RESET;
      else
        if clk_100mhz_i'event and clk_100mhz_i='1' then
          case fsm_r is
            when RESET => -- Waits for 5ms 
              if ticks_i.ticks_1ms='1' then
                ticks_1ms_cntr_s <= ticks_1ms_cntr_s-1;
                if ticks_1ms_cntr_s=0 then
                  fsm_r <= FSM1;
                end if;
              end if;
-- reg 20          
            when FSM1 => -- Address
              csb_s    <='0';
              wrb_s    <='0';
              cd_in_s  <=X"1412";
              ca_s     <=X"4A";
              fsm_r <= FSM2;
            when FSM2 => -- Data
              csb_s    <='0';
              wrb_s    <='0';
              -- cd_in_s  <=X"06E8";
              -- cd_in_s  <=X"0CE1";
              cd_in_s  <=X"06E9";
              ca_s     <=X"4C";
              fsm_r <= FSM3;
            when FSM3 => -- Write
              csb_s    <='0';
              wrb_s    <='0';
              cd_in_s  <=X"0004";
              ca_s     <=X"48";
              fsm_r <= FSM4;           
            when FSM4 => -- Wait one cycle
              csb_s    <='1';
              wrb_s    <='1';
              ca_s     <=(others => '0');
              cd_in_s  <=(others => '0');
              fsm_r <= FSM5;               
            when FSM5 => -- Read status register
              csb_s    <='0';
              wrb_s    <='1';
              ca_s     <=X"50";
              cd_in_s  <=(others => '0');
              fsm_r <= FSM6; 
            when FSM6 => -- Wait one cycle
              csb_s    <='1';
              wrb_s    <='1';
              ca_s     <=(others => '0');
              cd_in_s  <=(others => '0');
              fsm_r <= FSM7;              
            when FSM7 => -- Wait for mdio ready
              csb_s    <='1';
              wrb_s    <='1';
              if cd_out_s(1)='1' then
                fsm_r <= FSM5;
              else
                fsm_r <= FSM21;
              end if;
-- reg 25          
            when FSM11 => -- Address
              csb_s    <='0';
              wrb_s    <='0';
              cd_in_s  <=X"1912";
              ca_s     <=X"4A";
              fsm_r <= FSM12;
            when FSM12 => -- Data
              csb_s    <='0';
              wrb_s    <='0';
              cd_in_s  <=X"FFFF";
              ca_s     <=X"4C";
              fsm_r <= FSM13;
            when FSM13 => -- Write
              csb_s    <='0';
              wrb_s    <='0';
              cd_in_s  <=X"0004";
              ca_s     <=X"48";
              fsm_r <= FSM14;           
            when FSM14 => -- Wait one cycle
              csb_s    <='1';
              wrb_s    <='1';
              ca_s     <=(others => '0');
              cd_in_s  <=(others => '0');
              fsm_r <= FSM15;               
            when FSM15 => -- Read status register
              csb_s    <='0';
              wrb_s    <='1';
              ca_s     <=X"50";
              cd_in_s  <=(others => '0');
              fsm_r <= FSM16; 
            when FSM16 => -- Wait one cycle
              csb_s    <='1';
              wrb_s    <='1';
              ca_s     <=(others => '0');
              cd_in_s  <=(others => '0');
              fsm_r <= FSM17;              
            when FSM17 => -- Wait for mdio ready
              csb_s    <='1';
              wrb_s    <='1';
              if cd_out_s(1)='1' then
                fsm_r <= FSM15;
              else
                fsm_r <= FSM21;
              end if;              
-- reg 0 : sorft reset
            when FSM21 => -- Address
              csb_s    <='0';
              wrb_s    <='0';
              cd_in_s  <=X"0012";
              ca_s     <=X"4A";
              fsm_r <= FSM22;
            when FSM22 => -- Data
              csb_s    <='0';
              wrb_s    <='0';
              cd_in_s  <=X"9140";
              ca_s     <=X"4C";
              fsm_r <= FSM23;
            when FSM23 => -- Write
              csb_s    <='0';
              wrb_s    <='0';
              cd_in_s  <=X"0004";
              ca_s     <=X"48";
              fsm_r <= FSM24;           
            when FSM24 => -- Wait one cycle
              csb_s    <='1';
              wrb_s    <='1';
              ca_s     <=(others => '0');
              cd_in_s  <=(others => '0');
              fsm_r <= FSM25;               
            when FSM25 => -- Read status register
              csb_s    <='0';
              wrb_s    <='1';
              ca_s     <=X"50";
              cd_in_s  <=(others => '0');
              fsm_r <= FSM26; 
            when FSM26 => -- Wait one cycle
              csb_s    <='1';
              wrb_s    <='1';
              ca_s     <=(others => '0');
              cd_in_s  <=(others => '0');
              fsm_r <= FSM27;              
            when FSM27 => -- Wait for mdio ready
              csb_s    <='1';
              wrb_s    <='1';
              if cd_out_s(1)='1' then
                fsm_r <= FSM25;
              else
                fsm_r <= FSM100;
              end if;
            when FSM100 =>
              rst_o.rst_done <= '1';
              rst_o.rst_status <= COM_CONFIG_DONE;
              fsm_r <= FSM100;
            when others => 
              fsm_r<=RESET;
          end case;
        end if;
      end if;
   end process;
  -- Altera Cyclone III specific ---------------------------------------------
  -- Pll
  PLL_INST : pll
    port map (
      inclk0 => clk_50mhz_i,
      c0     => rgmii_clk_s,
      c1     => rgmii_clk_90d_s
      );

    -- Rgmii_if
  RGMII_IF_INST : rgmii_if
    port map (
      clk_i     => rgmii_clk_s,        
      clk_90d_i => rgmii_clk_90d_s,        
      rst_i     => rst_s,      

      rgmii_i   => rgmii_i_s,
      rgmii_o   => rgmii_o_s,
      
      gmii_i    => gmii_o_s,
      gmii_o    => gmii_i_s
    );
  gmii_o_s.gtx_clk <= Gtx_clk_s;
  gmii_o_s.tx_er   <= Tx_er_s;
  gmii_o_s.tx_en   <= Tx_en_s;
  gmii_o_s.tx_data <= Txd_s;

  
  -- Rgmii: rgmii_if connected to marvell
  Rx_clk_s      <= gmii_i_s.rx_clk;
  Tx_clk_s      <= gmii_i_s.tx_clk;
  Rx_er_s       <= gmii_i_s.rx_er;
  Rx_dv_s       <= gmii_i_s.rx_dv;
  Rxd_s         <= gmii_i_s.rx_data;
  Crs_s         <= gmii_i_s.crs;
  Col_s         <= gmii_i_s.col;
  
  -- Gmii: etm_mac connected to marvell
  -- Rx_clk_s      <= gmii_i.rx_clk;
  -- Tx_clk_s      <= gmii_i.tx_clk;
  -- Rx_er_s       <= gmii_i.rx_er;
  -- Rx_dv_s       <= gmii_i.rx_dv;
  -- Rxd_s         <= gmii_i.rx_data;
  -- Crs_s         <= gmii_i.crs;
  -- Col_s         <= gmii_i.col;  
    
    
  -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG 
  -- TX test process  
  -- TX_PROC : process(clk_50mhz_i, rst_s)
    -- begin
      -- if rst_s='1' then 
        -- tx_mac_wr_s   <= '0';
        -- tx_mac_sop_s  <= '0';
        -- tx_mac_eop_s  <= '0';
        -- tx_mac_data_s <= (others => '0');
        -- tx_mac_be_s   <= (others => '0');
        -- cntr_s <= (others => '0');
      -- else
        -- if clk_50mhz_i'event and clk_50mhz_i='1' then
          -- if tx_mac_wa_s='1' then
            -- cntr_s <= cntr_s+1;
            -- tx_mac_data_s <= packet_s(to_integer(unsigned(cntr_s(4 downto 0))));
            -- if cntr_s=0 then
              -- tx_mac_sop_s  <= '1';
              -- tx_mac_wr_s   <= '1';
            -- else
              -- tx_mac_sop_s  <= '0';
              -- if cntr_s<11 then
              -- else
                -- if cntr_s=11 then
                  -- tx_mac_eop_s  <= '1';
                  -- tx_mac_be_s   <= "01";
                -- else
                  -- tx_mac_eop_s  <= '0';
                  -- tx_mac_wr_s   <= '0';
                    -- if cntr_s=255 then
                      -- cntr_s <= (others => '0');
                    -- end if;
                -- end if;
              -- end if;
            -- end if;
          -- end if;
        -- end if;
      -- end if;
    -- end process;    
    
  TX_TICKS_PROC : process(clk_100mhz_i, rst_s)    
    begin
      if rst_s='1' then
        cntr_s <= (others => '0');
        line_cntr_s <= (others => '0');
        frame_cntr_s <= (others => '0');
        send_s <= '0';
      else
        if clk_100mhz_i'event and clk_100mhz_i='1' then
          if fsm_r=FSM100 then
            cntr_s <= cntr_s+1;
            if cntr_s=0 then
              -- send_s <= '0';
              send_s <= '1';
              if line_cntr_s=1023 then
                line_cntr_s <= (others => '0');
                frame_cntr_s <= frame_cntr_s+1;
              else
                line_cntr_s <= line_cntr_s+1;
              end if;
            else
              send_s <= '0';
            end if;
          end if;
        end if;
      end if;
    end process;
    
end be_com_eth_if;
