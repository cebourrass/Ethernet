library ieee;
use ieee.std_logic_1164.all;

package counter_comp is
  
  -- Port types 

  --! Ticks generator component 
  component counter is
    generic (
      --! Size (in bits) of counter
      COUNTER_SIZE : integer := 8
      );
    port (
      --! Master clock
      clk_i           : in  std_logic;
      --! Master global reset
      rst_i           : in  std_logic;
      --! Load input
      data_to_load_i  : in  std_logic_vector (COUNTER_SIZE-1 downto 0);
      --! Count enable (active high)
      count_enable_i  : in  std_logic;
      --! Load  enable (active high)
      load_enable_i   : in  std_logic;
      --! Count dirstion (0: down, 1: up)
      up_down_i       : in  std_logic;
      --! Counter current value
      counter_value_o : out std_logic_vector (COUNTER_SIZE-1 downto 0);
      --! Zero value detection flag (1: counter_value is null)
      zero_flag_o     : out std_logic
      );
  end component counter;  

end counter_comp;