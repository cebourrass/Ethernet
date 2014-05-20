library ieee;
use ieee.std_logic_1164.all;
library work;
use work.reset_generator_pack.all;

package reset_generator_comp is
  
  -- Port types 

  --! Ticks generator component 
  component reset_generator is
    port (
    --! Master clock input
    clk_i          : in  std_logic;
    --! One ms input pulse
    ticks_1ms_i    : in  std_logic;
    --! Reset from watchdog
    hard_reset_i   : in  std_logic;
    --! Internal reset
    soft_reset_i   : in  std_logic;
    --! Internal global reset
    global_reset_o : out std_logic;
    -- Communication system reset
    com_rst_o      : out com_rst_m2s_t;
    com_rst_i      : in com_rst_s2m_t;
    -- Asram bank 0 system reset;
    asram_0_rst_o  : out asram_rst_m2s_t;
    asram_0_rst_i  : in asram_rst_s2m_t;
    -- Smart camera core reset;
    core_rst_o     : out core_rst_m2s_t;
    core_rst_i     : in  core_rst_s2m_t;
    -- Image sensor reset
    ev76c560_rst_o : out ev76c560_rst_m2s_t;
    ev76c560_rst_i : in  ev76c560_rst_s2m_t;     
    -- Spi master reset
    spi_master_rst_o : out spi_master_rst_m2s_t;
    spi_master_rst_i : in  spi_master_rst_s2m_t   
    );
  end component reset_generator;  

end reset_generator_comp;