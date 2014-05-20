--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2012-11-16
--! @brief Reset generator module
--! @details
--! This module implements a reset systems in order to generate the right
--! timing for reset.\n
--! For details, see @ref p_201207121118 page.
--!
--! @page p_201207121118 Reset generator module
--!
--! @section s_201207121119 Revisions
--! - 2011-07-12 : Created
-------------------------------------------------------------------------------
-- Reset generator module
-------------------------------------------------------------------------------
--! libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.reset_generator_pack.all;
use work.counter_comp.all;
-------------------------------------------------------------------------------
--! Reset generator Entity
entity reset_generator_entity is
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
end entity reset_generator_entity;
-------------------------------------------------------------------------------
--! Reset generator Architecture
architecture reset_generator_arc of reset_generator_entity is

  constant RESET_PULSE_WIDTH_COUNTER_RELOAD_VALUE : integer :=
    RESET_PULSE_WIDTH_MS;
    
  constant RESET_PULSE_WIDTH_COUNTER_SIZE : integer :=
    integer(log2(real(RESET_PULSE_WIDTH_COUNTER_RELOAD_VALUE))+1.0);

  signal reload_value_s :
    std_logic_vector(RESET_PULSE_WIDTH_COUNTER_SIZE-1 downto 0);

  signal global_reset_s : std_logic;

  signal count_enable_s : std_logic;
  signal zero_flag_s    : std_logic;
  signal system_reset_s : std_logic;
  
begin

  --! System reset (hard or soft)
  system_reset_s <= hard_reset_i or soft_reset_i;
  --! global reset pulse
  global_reset_s <= not zero_flag_s;
  

  global_reset_o     <= global_reset_s;
    
  spi_master_rst_o.rst <= hard_reset_i;
  -- Interface resets
  com_rst_o.rst      <= hard_reset_i;
  asram_0_rst_o.rst  <= hard_reset_i;
  ev76c560_rst_o.rst <= not spi_master_rst_i.rst_done;

  -- Core reset
  -- Maintain core reset until each interface is ready
  core_rst_o.rst     <= hard_reset_i or
                          not (com_rst_i.rst_done) or
                          not (asram_0_rst_i.rst_done) or
                          not (ev76c560_rst_i.rst_done);
  
  
  count_enable_s <= ticks_1ms_i and not zero_flag_s;
  reload_value_s <=
    std_logic_vector(to_unsigned(RESET_PULSE_WIDTH_COUNTER_RELOAD_VALUE,
                                 RESET_PULSE_WIDTH_COUNTER_SIZE));
                                 
  --! Reset pulse width counter instance
  RESET_PULSE_WIDTH_COUNTER_INST : counter
    generic map (
      COUNTER_SIZE => RESET_PULSE_WIDTH_COUNTER_SIZE
      )
    port map (
      clk_i           => clk_i,
      rst_i           => '0',
      data_to_load_i  => reload_value_s,
      count_enable_i  => count_enable_s,
      load_enable_i   => system_reset_s,
      up_down_i       => '0',
      counter_value_o => open,
      zero_flag_o     => zero_flag_s
      );
end architecture reset_generator_arc;
