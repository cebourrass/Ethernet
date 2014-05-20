library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ev76c560_if_pack.all;
use work.spi_master_if_pack.all;
--use work.ticks_generator_pack.all;
use work.reset_generator_pack.all;

package ev76c560_if_comp is

  -- constant CLOCK_FREQUENCY_MHZ : integer := 50;
  
  -- Port types 
  
  --! Output signals
  
  --! Ticks generator component 
  component ev76c560_if is
    port (
    clk_i              : in   std_ulogic;                    -- System clock
    -- Reset system
    rst_i              : in  ev76c560_rst_m2s_t;
    rst_o              : out ev76c560_rst_s2m_t;
    -- 
    clk_ev76c560_ref_i : in   std_ulogic;                    -- Image sensor clock
    --ticks_i            : in   ticks_t;                       -- Ticks for time count
    -- Image sensor interface
    clk_ref_o          : out  std_ulogic;                    -- Reference clock
    clk_fix_o          : out  std_ulogic;                    -- Clock
    reset_n_o          : out  std_ulogic;                    -- Sensor reset
    trig_o             : out  std_ulogic;                    -- Acquisition trig.    
    data_clk_i         : in   std_ulogic;                    -- Data clock
    fen_i              : in   std_ulogic;                    -- Vertical synch.
    len_i              : in   std_ulogic;                    -- Horizontal sync.
    flo_i              : in   std_ulogic;                    -- Illumination ctrl
    data_i             : in   std_logic_vector(9 downto 0);  -- Pixel data bus
    -- User interface
    usr_bus_i          : in  user_bus_i_t;
    usr_bus_o          : out user_bus_o_t;
    -- Spi mater interface
    spi_chan_i         : out spi_chan_i_t;
    spi_chan_o         : in  spi_chan_o_t
  );
  end component ev76c560_if;  

end ev76c560_if_comp;