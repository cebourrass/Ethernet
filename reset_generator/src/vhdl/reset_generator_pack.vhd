library ieee;
use ieee.std_logic_1164.all;

library work;

package reset_generator_pack is

  constant RESET_PULSE_WIDTH_MS : integer := 10;

  type com_rst_m2s_t is record
    rst : std_logic;
  end record;

  type com_status_t is (COM_RESET, COM_CONFIG_DONE);
  
  type com_rst_s2m_t is record
    rst_done : std_logic;
    rst_status : com_status_t;
  end record;
  
  type asram_rst_m2s_t is record
    rst : std_logic;
  end record;

  type asram_status_t is (NO_ERROR, ERROR);
  
  type asram_rst_s2m_t is record
    rst_done : std_logic;
    rst_test_1_status : asram_status_t;
    rst_test_2_status : asram_status_t;
  end record;  

  type core_rst_m2s_t is record
    rst : std_logic;
  end record;

  type core_status_t is (NO_ERROR, ERROR);
  
  type core_rst_s2m_t is record
    rst_done   : std_logic;
    rst_status : core_status_t;
  end record; 

  type ev76c560_rst_m2s_t is record
    rst : std_logic;
  end record;

  type ev76c560_status_t is (NO_ERROR, ERROR);
  
  type ev76c560_rst_s2m_t is record
    rst_done   : std_logic;
    rst_status : ev76c560_status_t;
  end record; 
  
   type spi_master_rst_m2s_t is record
    rst : std_logic;
  end record;

  type spi_master_status_t is (NO_ERROR, ERROR);
  
  type spi_master_rst_s2m_t is record
    rst_done   : std_logic;
    rst_status : spi_master_status_t;
  end record;
  
end reset_generator_pack;