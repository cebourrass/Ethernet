library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
-- use ieee.std_logic_misc.all;
-- use ieee.numeric_std.all;
library work;
use work.debug_pack.all;
use work.reset_generator_pack.all;
use work.ticks_generator_pack.all;
use work.com_eth_if_pack.all;
use work.rgmii_if_pack.all;
use work.reset_generator_comp.all;
use work.ticks_generator_comp.all;
use work.reset_generator_pack.all;
use work.ev76c560_if_pack.all;
use work.ev76c560_if_comp.all;
use work.spi_master_if_pack.all;
use work.spi_master_if_comp.all;
-- use work.mem_controler.all;

entity tse_nios is
  port (
    -- Oscillators -----------------------------------------------------------
    clk_50mhz_i             : in  	std_logic;
    clk_125mhz_i            : in 	std_logic;
    
    -- Watchdog --------------------------------------------------------------
    rst_n_i                 : in  	std_logic;
    wdi_o                   : out 	std_logic;
    
    -- Trigger ---------------------------------------------------------------
    pin_trigger_i           : in  	std_logic;
    pin_trigger_o           : out 	std_logic;
    pin_trigger_ms_o        : out 	std_logic;
    
    -- Ethernet interface ----------------------------------------------------
    eth_reset_n_o           : out   std_logic;
    
    -- Management data interface
    eth_mdc_o               : out   std_logic;
    eth_mdio_io             : inout std_logic;
    
    -- Rgmii interface
    rgmii_i                 : in    rgmii_i_t;
    rgmii_o                 : out   rgmii_o_t;
    
    -- Gmii interface
    gmii_i                  : in    gmii_i_t;
    gmii_o                  : out   gmii_o_t;      
    
    -- Display led -----------------------------------------------------------
    led_o                   : out   std_logic;
	led						: out 	std_logic;
    
    -- Debug port ------------------------------------------------------------
    debug_o                 : out   debug_o_t;

	 -- Camera interface ------------------------------------------------------
	rst_o                 	: out 	ev76c560_rst_s2m_t;
	-- Image sensor interface
	clk_ref_o          		: out  	std_ulogic;                    -- Reference clock
	clk_fix_o          		: out  	std_ulogic;                    -- Clock
	reset_n_o          		: out  	std_ulogic;                    -- Sensor reset
	trig_o             		: out  	std_ulogic;                    -- Acquisition trig.    
	data_clk_i         		: in   	std_ulogic;                    -- Data clock
	fen_i              		: in   	std_ulogic;                    -- Vertical synch.
	len_i              		: in   	std_ulogic;                    -- Horizontal sync.
	flo_i              		: in   	std_ulogic;                    -- Illumination ctrl
	data_i             		: in   	std_logic_vector(9 downto 0);  -- Pixel data bus
	
	-- spi physical component interface 
    miso_i  			 	: in 	std_ulogic;
    mosi_o 				 	: out 	std_ulogic;
	sck_o  				 	: out 	std_logic;
	csn_o 				 	: out 	ss_t;
	
	--! Synchronization input for ticks_generator component 
    sync_i       			: in  	std_logic;

	 -- spi interface for potentiometer IP
	cs_var_no 				: out 	std_logic;
	sck_var_o 				: out 	std_logic;
	si_var_o  				: out 	std_logic;
	
	test : out std_logic
	
  );
end tse_nios;

architecture syn of tse_nios is

  signal clk_100mhz_s			: std_logic;  
  signal rst_n_s         		: std_logic;  
  signal rst_s           		: std_logic;  
  signal com_rst_i_s     		: com_rst_m2s_t;  
  signal com_rst_o_s     		: com_rst_s2m_t;  
  
  signal ticks_s         		: ticks_t;
  
  signal debug_s         		: debug_o_t;
  
  signal udp_send_video_line_s	: std_logic;
  signal pixel_read_s			: std_logic;
  signal pixel_ready_s			: std_logic;
  signal pixel_s				: std_logic_vector(31 downto 0);
  
  signal start_read_s			: std_logic; --signal usb_active_tp			: std_logic;
  signal eof_s					: std_logic; --  signal usb_desable_tp			: std_logic;
  signal data_s					: std_logic_vector(15 downto 0); --signal usb_data_tp		: std_logic_vector(15 downto 0);
  signal mem_addr_s				: std_logic_vector(19 downto 0); --signal usb_mem_addr_tp  : std_logic_vector(19 downto 0);
  
  signal write_data 			: std_logic;
  signal start_write			: std_logic;

  signal counter 				: integer range 0 to 1000:=0 ; --20 us  when using 50 MHz frequency 

  signal clk_24mhz_tp 			: std_logic; -- !! see  to use the pll for other clock rate 
  signal clk_48MHz_tp 			: std_logic; -- !! see  to use the pll for other clock rate 
  signal clk_fix_tp 			: std_logic; -- !! see  to use the pll for other clock rate 
  signal reset_tp   			: std_logic :='1';
  signal trig_temp     			: std_logic :='1';
  signal csn_temp      			: std_logic :='1';
  signal adc_ref_temp  			: std_logic :='0';
  signal neant         			: spi_master_rst_s2m_t:=('0',NO_ERROR);

  signal spi_chan_i_tp 			: spi_chan_i_t;
  signal spi_chan_o_tp 			: spi_chan_o_t;
  --signal ticks_tp     		: ticks_t;  
  signal rst_tp1				: std_logic;   
  signal rst_tp2				: std_logic;   
  
  signal av_status_reg_0_conduit_end_udp_send : std_logic;
  signal av_status_reg_0_conduit_end_status_reg0_o :  std_logic_vector(31 downto 0);        -- status_reg0_o
  signal av_status_reg_0_conduit_end_status_reg1_o :  std_logic_vector(31 downto 0);        -- status_reg1_o
  signal av_status_reg_0_conduit_end_status_reg2_o :  std_logic_vector(31 downto 0);        -- status_reg2_o
  signal av_status_reg_0_conduit_end_status_reg3_o :  std_logic_vector(31 downto 0);        -- status_reg3_o
  signal av_status_reg_0_conduit_end_status_reg4_o :  std_logic_vector(31 downto 0);        -- status_reg4_o
  signal av_status_reg_0_conduit_end_status_reg5_o :  std_logic_vector(31 downto 0);        -- status_reg5_o
  signal av_status_reg_0_conduit_end_status_reg6_o :  std_logic_vector(31 downto 0);        -- status_reg6_o
  signal av_status_reg_0_conduit_end_status_reg7_o :  std_logic_vector(31 downto 0); 
  
  signal av_config_reg_0_conduit_end_reg_0          :   std_logic_vector(31 downto 0) := (others => 'X'); -- reg_0
  signal	av_config_reg_0_conduit_end_reg_1          :   std_logic_vector(31 downto 0) := (others => 'X'); -- reg_1
  signal	av_config_reg_0_conduit_end_reg_2          :   std_logic_vector(31 downto 0) := (others => 'X'); -- reg_2
  signal	av_config_reg_0_conduit_end_reg_3          :   std_logic_vector(31 downto 0) := (others => 'X'); -- reg_3
  signal	av_config_reg_0_conduit_end_reg_4          :   std_logic_vector(31 downto 0) := (others => 'X'); -- reg_4
  signal	av_config_reg_0_conduit_end_reg_5          :   std_logic_vector(31 downto 0) := (others => 'X'); -- reg_5
  signal	av_config_reg_0_conduit_end_reg_6          :   std_logic_vector(31 downto 0) := (others => 'X'); -- reg_6
  signal	av_config_reg_0_conduit_end_reg_7          :   std_logic_vector(31 downto 0) := (others => 'X'); -- reg_7
  signal av_config_reg_0_conduit_end_udp_data_valid :   std_logic                     := 'X';              -- udp_data_valid

  signal av_eth_config_0_conduit_end_local_port     : std_logic_vector(15 downto 0);                    -- local_port_o
  signal	av_eth_config_0_conduit_end_remote_port    : std_logic_vector(15 downto 0);                    -- remote_port_o
  signal	av_eth_config_0_conduit_end_local_IP       : std_logic_vector(31 downto 0);                    -- local_IP_o
  signal av_eth_config_0_conduit_end_remote_IP      : std_logic_vector(31 downto 0);                    -- remote_IP_o
  signal	av_eth_config_0_conduit_end_local_MAC_LSB  : std_logic_vector(31 downto 0);                    -- local_MAC_LSB_o
  signal	av_eth_config_0_conduit_end_local_MAC_MSB  : std_logic_vector(31 downto 0);                    -- local_MAC_MSB_o
  signal	av_eth_config_0_conduit_end_remote_MAC_LSB : std_logic_vector(31 downto 0);                    -- remote_MAC_LSB_o
  signal	av_eth_config_0_conduit_end_checksum       : std_logic_vector(15 downto 0);                    -- checksum_o
  signal	av_eth_config_0_conduit_end_remote_MAC_MSB : std_logic_vector(31 downto 0);                     -- remote_MAC_MSB_o
	
  signal	av_sendpacket_0_conduit_end_checksum       : std_logic_vector(15 downto 0);                    -- checksum_o
  signal	av_sendpacket_0_conduit_end_local_port     : std_logic_vector(15 downto 0);                    -- local_port_o
  signal av_sendpacket_0_conduit_end_remote_port    : std_logic_vector(15 downto 0);                    -- remote_port_o
  signal	av_sendpacket_0_conduit_end_remote_IP      : std_logic_vector(31 downto 0);                    -- remote_IP_o
  signal	av_sendpacket_0_conduit_end_remote_MAC_MSB : std_logic_vector(31 downto 0);                    -- remote_MAC_MSB_o
  signal	av_sendpacket_0_conduit_end_remote_MAC_LSB : std_logic_vector(31 downto 0);                    -- remote_MAC_LSB_o
  signal	av_sendpacket_0_conduit_end_udp_sendpacket : std_logic;                                         -- udp_sendpacket
  signal av_sendpacket_0_conduit_end_length :std_logic_vector(15 downto 0);
  
  signal fifo_empty :std_logic;
  signal rd_fifo :std_logic; 
  signal pixel : std_logic_vector(7 downto 0);
		
 component nios_system is
		port (
			clk_clk                                      : in  std_logic                     := 'X';             -- clk
			reset_reset_n                                : in  std_logic                     := 'X';             -- reset_n
			pio_0_external_connection_export             : out std_logic;                                        -- export
			av_config_reg_0_conduit_end_reg_0            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- reg_0
			av_config_reg_0_conduit_end_reg_1            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- reg_1
			av_config_reg_0_conduit_end_reg_2            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- reg_2
			av_config_reg_0_conduit_end_reg_3            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- reg_3
			av_config_reg_0_conduit_end_reg_4            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- reg_4
			av_config_reg_0_conduit_end_reg_5            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- reg_5
			av_config_reg_0_conduit_end_reg_6            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- reg_6
			av_config_reg_0_conduit_end_reg_7            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- reg_7
			av_config_reg_0_conduit_end_udp_data_valid   : in  std_logic                     := 'X';             -- udp_data_valid
			av_eth_config_0_conduit_end_local_port_o     : out std_logic_vector(15 downto 0);                    -- local_port_o
			av_eth_config_0_conduit_end_remote_port_o    : out std_logic_vector(15 downto 0);                    -- remote_port_o
			av_eth_config_0_conduit_end_local_IP_o       : out std_logic_vector(31 downto 0);                    -- local_IP_o
			av_eth_config_0_conduit_end_remote_IP_o      : out std_logic_vector(31 downto 0);                    -- remote_IP_o
			av_eth_config_0_conduit_end_local_MAC_LSB_o  : out std_logic_vector(31 downto 0);                    -- local_MAC_LSB_o
			av_eth_config_0_conduit_end_local_MAC_MSB_o  : out std_logic_vector(31 downto 0);                    -- local_MAC_MSB_o
			av_eth_config_0_conduit_end_remote_MAC_LSB_o : out std_logic_vector(31 downto 0);                    -- remote_MAC_LSB_o
			av_eth_config_0_conduit_end_checksum_o       : out std_logic_vector(15 downto 0);                    -- checksum_o
			av_eth_config_0_conduit_end_remote_MAC_MSB_o : out std_logic_vector(31 downto 0);                    -- remote_MAC_MSB_o
			av_status_reg_0_conduit_end_udp_send         : out std_logic;                                        -- udp_send
			av_status_reg_0_conduit_end_status_reg0_o    : out std_logic_vector(31 downto 0);                    -- status_reg0_o
			av_status_reg_0_conduit_end_status_reg1_o    : out std_logic_vector(31 downto 0);                    -- status_reg1_o
			av_status_reg_0_conduit_end_status_reg2_o    : out std_logic_vector(31 downto 0);                    -- status_reg2_o
			av_status_reg_0_conduit_end_status_reg3_o    : out std_logic_vector(31 downto 0);                    -- status_reg3_o
			av_status_reg_0_conduit_end_status_reg4_o    : out std_logic_vector(31 downto 0);                    -- status_reg4_o
			av_status_reg_0_conduit_end_status_reg5_o    : out std_logic_vector(31 downto 0);                    -- status_reg5_o
			av_status_reg_0_conduit_end_status_reg7_o    : out std_logic_vector(31 downto 0);                    -- status_reg7_o
			av_status_reg_0_conduit_end_status_reg6_o    : out std_logic_vector(31 downto 0);                     -- status_reg6_o
				
			av_sendpacket_0_conduit_end_checksum_o       : out std_logic_vector(15 downto 0);                    -- checksum_o
			av_sendpacket_0_conduit_end_local_port_o     : out std_logic_vector(15 downto 0);                    -- local_port_o
			av_sendpacket_0_conduit_end_remote_port_o    : out std_logic_vector(15 downto 0);                    -- remote_port_o
			av_sendpacket_0_conduit_end_remote_IP_o      : out std_logic_vector(31 downto 0);                    -- remote_IP_o
			av_sendpacket_0_conduit_end_remote_MAC_MSB_o : out std_logic_vector(31 downto 0);                    -- remote_MAC_MSB_o
			av_sendpacket_0_conduit_end_remote_MAC_LSB_o : out std_logic_vector(31 downto 0);                    -- remote_MAC_LSB_o
			av_sendpacket_0_conduit_end_length_o         : out std_logic_vector(15 downto 0);                    -- length_o
			av_sendpacket_0_conduit_end_udp_sendpacket   : out std_logic                                         -- udp_sendpacket
		);
	end component nios_system;

component fifo
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
end component;

component pll_24MHz IS
		PORT(
			inclk0		: IN STD_LOGIC  := '0';
			c0			: OUT STD_LOGIC 
		);
	END component;
	
	component pll_48MHz IS
		PORT(
			inclk0		: IN STD_LOGIC  := '0';
			c0			: OUT STD_LOGIC 
		);	
	END component;
	
	component pll_114MHz IS
		PORT(
			inclk0		: IN STD_LOGIC  := '0';
			c0			: OUT STD_LOGIC 
		);
	END component;


begin
  --! Active high reset signal
  rst_s   <= not rst_n_i;
  --! Active low reset signal
  rst_n_s <= rst_n_i;
  
  --! Led display
  led_o   <= debug_s.phy_rxd_0;
  
  debug_o <= debug_s;
  
  -- data_s <= mem_addr_s(15 downto 0);
  
  NIOS_SYSTEM_INST : component nios_system
	port map(
			clk_clk =>			clk_50mhz_i,                 
			reset_reset_n =>	rst_n_i,     	  
			pio_0_external_connection_export => open,	
			av_status_reg_0_conduit_end_udp_send  =>   av_status_reg_0_conduit_end_udp_send,
			av_status_reg_0_conduit_end_status_reg0_o =>av_status_reg_0_conduit_end_status_reg0_o,        -- status_reg0_o
			av_status_reg_0_conduit_end_status_reg1_o =>av_status_reg_0_conduit_end_status_reg1_o,        -- status_reg1_o
			av_status_reg_0_conduit_end_status_reg2_o =>av_status_reg_0_conduit_end_status_reg2_o,        -- status_reg2_o
			av_status_reg_0_conduit_end_status_reg3_o =>av_status_reg_0_conduit_end_status_reg3_o,        -- status_reg3_o
			av_status_reg_0_conduit_end_status_reg4_o =>av_status_reg_0_conduit_end_status_reg4_o,       -- status_reg4_o
			av_status_reg_0_conduit_end_status_reg5_o =>av_status_reg_0_conduit_end_status_reg5_o,        -- status_reg5_o
			av_status_reg_0_conduit_end_status_reg6_o =>av_status_reg_0_conduit_end_status_reg6_o,        -- status_reg6_o
			av_status_reg_0_conduit_end_status_reg7_o  =>av_status_reg_0_conduit_end_status_reg7_o,
			av_config_reg_0_conduit_end_reg_0  => av_config_reg_0_conduit_end_reg_0,
			av_config_reg_0_conduit_end_reg_1  => av_config_reg_0_conduit_end_reg_1,
			av_config_reg_0_conduit_end_reg_2  => av_config_reg_0_conduit_end_reg_2,
			av_config_reg_0_conduit_end_reg_3  => av_config_reg_0_conduit_end_reg_3,
			av_config_reg_0_conduit_end_reg_4  => av_config_reg_0_conduit_end_reg_4,
			av_config_reg_0_conduit_end_reg_5  => av_config_reg_0_conduit_end_reg_5,
			av_config_reg_0_conduit_end_reg_6  => av_config_reg_0_conduit_end_reg_6,
			av_config_reg_0_conduit_end_reg_7  => av_config_reg_0_conduit_end_reg_7,
			av_config_reg_0_conduit_end_udp_data_valid =>av_config_reg_0_conduit_end_udp_data_valid,
			av_eth_config_0_conduit_end_local_port_o     => av_eth_config_0_conduit_end_local_port,
			av_eth_config_0_conduit_end_remote_port_o    => av_eth_config_0_conduit_end_remote_port,
			av_eth_config_0_conduit_end_local_IP_o       => av_eth_config_0_conduit_end_local_IP,
			av_eth_config_0_conduit_end_remote_IP_o      => av_eth_config_0_conduit_end_remote_IP,
			av_eth_config_0_conduit_end_local_MAC_LSB_o  => av_eth_config_0_conduit_end_local_MAC_LSB,
			av_eth_config_0_conduit_end_local_MAC_MSB_o  => av_eth_config_0_conduit_end_local_MAC_MSB,
			av_eth_config_0_conduit_end_remote_MAC_LSB_o => av_eth_config_0_conduit_end_remote_MAC_LSB,
			av_eth_config_0_conduit_end_checksum_o       => av_eth_config_0_conduit_end_checksum,
			av_eth_config_0_conduit_end_remote_MAC_MSB_o => av_eth_config_0_conduit_end_remote_MAC_MSB,
			
			av_sendpacket_0_conduit_end_checksum_o       => av_sendpacket_0_conduit_end_checksum,
			av_sendpacket_0_conduit_end_local_port_o     => av_sendpacket_0_conduit_end_local_port,
			av_sendpacket_0_conduit_end_remote_port_o    => av_sendpacket_0_conduit_end_remote_port,
			av_sendpacket_0_conduit_end_remote_IP_o      => av_sendpacket_0_conduit_end_remote_IP,
			av_sendpacket_0_conduit_end_remote_MAC_MSB_o => av_sendpacket_0_conduit_end_remote_MAC_MSB,
			av_sendpacket_0_conduit_end_remote_MAC_LSB_o => av_sendpacket_0_conduit_end_remote_MAC_LSB,
			av_sendpacket_0_conduit_end_length_o		   => av_sendpacket_0_conduit_end_length,
			av_sendpacket_0_conduit_end_udp_sendpacket   => av_sendpacket_0_conduit_end_udp_sendpacket			
	);
  
  
  -- Communication system
  COM_ETHERNET_INST : component com_eth_if
    port map (
      clk_50mhz_i   		=> clk_50mhz_i,
      clk_100mhz_i  		=> clk_100mhz_s,
      clk_125mhz_i  		=> clk_125mhz_i,
      rst_i         		=> com_rst_i_s,  
      rst_o         		=> com_rst_o_s, 
      ticks_i      		 	=> ticks_s,
      rgmii_i       		=> rgmii_i,
      rgmii_o       		=> rgmii_o,
      gmii_i        		=> (tx_clk  => '0',
								rx_clk  => '0',
								rx_dv   => '0',
								rx_er   => '0',
								rx_data => (others=>'0'),
								crs     => '0',
								col     => '0'),
      gmii_o        		=> open,
      eth_reset_n_o 		=> eth_reset_n_o,
      eth_mdc_o     		=> eth_mdc_o,
      eth_mdio_io   		=> eth_mdio_io,
      debug_o       		=> debug_s,
  
		udp_send_video_line_i	=> len_i and not fen_i,
		pixel_ready_i			=> '0',
      pixel_read_o          => pixel_read_s,
		
		fifo_empty_i => fifo_empty,
	   rd_fifo_o => rd_fifo,
		pixel_i                 => X"000000"& pixel,
		
		udp_send_status_i => av_status_reg_0_conduit_end_udp_send,
		
		avalon_status_register0_i =>av_status_reg_0_conduit_end_status_reg0_o,        -- status_reg0_o
		avalon_status_register1_i =>av_status_reg_0_conduit_end_status_reg1_o,        -- status_reg1_o
		avalon_status_register2_i =>av_status_reg_0_conduit_end_status_reg2_o,        -- status_reg2_o
		avalon_status_register3_i =>av_status_reg_0_conduit_end_status_reg3_o,        -- status_reg3_o
		avalon_status_register4_i =>av_status_reg_0_conduit_end_status_reg4_o,       -- status_reg4_o
		avalon_status_register5_i =>av_status_reg_0_conduit_end_status_reg5_o,        -- status_reg5_o
		avalon_status_register6_i =>av_status_reg_0_conduit_end_status_reg6_o,        -- status_reg6_o
		avalon_status_register7_i  =>av_status_reg_0_conduit_end_status_reg7_o,
		configuration_packet_o.reg_0 =>  av_config_reg_0_conduit_end_reg_0,
		configuration_packet_o.reg_1 =>  av_config_reg_0_conduit_end_reg_1,
		configuration_packet_o.reg_2 =>  av_config_reg_0_conduit_end_reg_2,
		configuration_packet_o.reg_3 =>  av_config_reg_0_conduit_end_reg_3,
		configuration_packet_o.reg_4 =>  av_config_reg_0_conduit_end_reg_4,
		configuration_packet_o.reg_5 =>  av_config_reg_0_conduit_end_reg_5,
		configuration_packet_o.reg_6 =>  av_config_reg_0_conduit_end_reg_6,
		configuration_packet_o.reg_7 =>  av_config_reg_0_conduit_end_reg_7,
		udp_signal_o.udp_data_valid => av_config_reg_0_conduit_end_udp_data_valid,
		av_eth_config_0_conduit_end_local_port_i     => av_eth_config_0_conduit_end_local_port,
		av_eth_config_0_conduit_end_remote_port_i    => av_eth_config_0_conduit_end_remote_port,
		av_eth_config_0_conduit_end_local_IP_i       => av_eth_config_0_conduit_end_local_IP,
		av_eth_config_0_conduit_end_remote_IP_i      => av_eth_config_0_conduit_end_remote_IP,
		av_eth_config_0_conduit_end_local_MAC_LSB_i  => av_eth_config_0_conduit_end_local_MAC_LSB,
		av_eth_config_0_conduit_end_local_MAC_MSB_i  => av_eth_config_0_conduit_end_local_MAC_MSB,
		av_eth_config_0_conduit_end_remote_MAC_LSB_i => av_eth_config_0_conduit_end_remote_MAC_LSB,
		av_eth_config_0_conduit_end_checksum_i       => av_eth_config_0_conduit_end_checksum,
		av_eth_config_0_conduit_end_remote_MAC_MSB_i => av_eth_config_0_conduit_end_remote_MAC_MSB,
		
		av_sendpacket_0_conduit_end_checksum_i       => av_sendpacket_0_conduit_end_checksum,
		av_sendpacket_0_conduit_end_local_port_i     => av_sendpacket_0_conduit_end_local_port,
		av_sendpacket_0_conduit_end_remote_port_i    => av_sendpacket_0_conduit_end_remote_port,
		av_sendpacket_0_conduit_end_remote_IP_i      => av_sendpacket_0_conduit_end_remote_IP,
		av_sendpacket_0_conduit_end_remote_MAC_MSB_i => av_sendpacket_0_conduit_end_remote_MAC_MSB,
		av_sendpacket_0_conduit_end_remote_MAC_LSB_i => av_sendpacket_0_conduit_end_remote_MAC_LSB,
		av_sendpacket_0_conduit_end_length_i => av_sendpacket_0_conduit_end_length
		
    );
	 
ETHFIFO: component fifo 
	PORT map
	(
		data		=> data_i (9 downto 2),
		rdclk		=> clk_50mhz_i,
		rdreq		=> rd_fifo,
		wrclk		=> clk_50mhz_i,
		wrreq		=> not len_i and data_clk_i,
		q			=> pixel,
		rdempty	=> fifo_empty,
		wrfull	=> open
	);


	
  -- Reset system
  RESET_GENERATOR_INST : configuration work.reset_generator_conf
    port map (
    clk_i            =>clk_50mhz_i,
    ticks_1ms_i      =>ticks_s.ticks_1ms,
    hard_reset_i     =>rst_s,
    soft_reset_i     =>'0',
    global_reset_o   =>open,
    com_rst_o        =>com_rst_i_s,
    com_rst_i        =>com_rst_o_s,
    -- asram_0_rst_o    =>,
    asram_0_rst_i    =>(rst_done=>'0', rst_test_1_status => ERROR, rst_test_2_status => ERROR),
    -- core_rst_o       =>,
    core_rst_i       =>(rst_done=>'0', rst_status => ERROR),
    -- ev76c560_rst_o   =>,
    ev76c560_rst_i   =>(rst_done=>'0', rst_status => ERROR),
    -- spi_master_rst_o =>,
    spi_master_rst_i =>(rst_done=>'0', rst_status => ERROR)
    );
   
  -- Ticks generator
  TICKS_GENERATOR_INST : configuration work.ticks_generator_conf
    port map (
    clk_i   => clk_50mhz_i,
    rst_i   => '0',
    sync_i  => '0',
    ticks_o => ticks_s
    );
  
  -- Pll
  PLL_TOP_INST : entity work.pll_top(SYN)
    port map (
      inclk0 => clk_50mhz_i,
      c0     => clk_100mhz_s
      );  
		
		  EV76C560_IF_INST : component ev76c560_if
	port map (
	  clk_i              => clk_48mhz_tp,
      -- Reset system
      rst_i.rst          => rst_s,
      rst_o.rst_done     => rst_tp1,
	  rst_o.rst_status   => open,
      -- 
      clk_ev76c560_ref_i => clk_24mhz_tp,    
      -- Image sensor interface
      clk_ref_o          => clk_ref_o, 
      clk_fix_o          => clk_fix_tp,
      reset_n_o          => reset_n_o, 
      trig_o             => trig_o,        
      data_clk_i         => data_clk_i,
      fen_i              => fen_i,     
      len_i              => len_i,     
      flo_i              => flo_i,     
      data_i             => data_i,    
      -- User interface
      usr_bus_i.rdreq    => '0',

      -- Spi mater interface
      spi_chan_i         => spi_chan_i_tp,
      spi_chan_o         => spi_chan_o_tp
  );
  
  SPI_MASTER_IF_INST : component spi_master_if
    port map (
		--! Clock input
		clk_i				 => clk_50mhz_i,
        --! Reset system
		rst_i.rst            => rst_s,
		rst_o.rst_done		 => rst_tp2,
		rst_o.rst_status     => neant.rst_status,
		--! Spi bus : clock signal
		sck_o  				 => sck_o,
		--! Spi bus : master out slave in signal
		mosi_o 				 => mosi_o,
		--! Spi bus : master in slave out signal
		miso_i 				 => miso_i,
		--! Spi bus : Slave chip select signals
		ss_o 				 => csn_o,
		--! Spi control channels : inputs
		spi_chan_array_i(0)  => spi_chan_i_tp,
		--! Spi control channels : outputs
		spi_chan_array_o (0) => spi_chan_o_tp
    );
	 
	 
 u6: pll_24MHz 
	PORT map ( 
		inclk0	  	=>clk_50mhz_i,
		c0		  	=>clk_24mhz_tp
	);
  u7: pll_48MHz 
	PORT map ( 
		inclk0  	=>clk_50mhz_i,
		c0			=>clk_48mhz_tp
	);
  u8: pll_114MHz 
	PORT map ( 
		inclk0  	=>clk_50mhz_i,
		c0		  	=>clk_fix_o
	);
	
	
  -- Makes watchdod sleeping forever...
  wdi_o <= 'Z';
  
	test <= '1';
  
end syn;