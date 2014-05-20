library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;


package ticks_generator_pack is
  
  constant SEEDUP : positive := 1;
  constant CLOCK_FREQUENCY_MHZ : positive := 50/SEEDUP;
  
  --! Output ticks signals
  type ticks_t is record
    ticks_1us   : std_logic;
    ticks_10us  : std_logic;
    ticks_100us : std_logic;
    ticks_1ms   : std_logic;
    ticks_10ms  : std_logic;
    ticks_100ms : std_logic;
    ticks_1s    : std_logic;
  end record;
  --! ms counter size : count up to 1000 us
  constant TUS_COUNTER_SIZE : integer := 4;
  constant HUS_COUNTER_SIZE : integer := 4;
  constant MS_COUNTER_SIZE : integer := 4;
  --! ms counter size : count up to 1000 ms
  constant S_COUNTER_SIZE : integer := 10;

  -- Local types
  
end ticks_generator_pack;