library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ticks_generator_pack.all;

package ticks_generator_comp is
 
  --! Ticks generator component 
  component ticks_generator is
    port (
      --! Master clock input
      clk_i   : in  std_logic;
      --! Reset input
      rst_i   : in  std_logic;
      --! Synchronization input
      sync_i  : in  std_logic;
      --! Ticks output pluses
      ticks_o : out ticks_t
      );
  end component ticks_generator;  

end ticks_generator_comp;