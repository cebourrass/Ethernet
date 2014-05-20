--! @file
--! @author Thierry Tixier
--! @mail ttixier@free.free
--! @version  (heads/devel)
--! @date 2012-11-16
--! @brief Counter module
--! @details
--! This module implements a synchronous counter with load, count up/down and
--! count enable capabilities.\n
--! For details, see @ref p_201207111609 page.
--!
--! @page p_201207111609 Counter module
--!
--! @section s_201207111610 Revisions
--! - 2011-07-11 : Created
--! @todo update code to map count_enable signal on ena latch pin. 
--!
--! @section sec_001 Block diagram
--! @image html counter-block_diagram.png "Counter module block diagram"
--!
--! @section s_201207111611 Concepts
--! Synchronous counter.\n
--!
--! @section s_201207111612 Behavior
--! \c rst_i reset input operate in asynchronous mode.\n
--! Counter state change occur on rising edge of \c clk_i clock signal:\n
--! - \c load_enable = 0
--!  - \c count_enable = 0
--!   - Nothing happens
--!  - \c count_enable = 1
--!   - \c up_down = 0
--!    - Substract one to \c counter_value
--!   - \c up_down = 1
--!    - Add one to \c counter_value
--! - \c load_enable = 1
--!  - \c counter_value initialized with \c data_to_load 
-------------------------------------------------------------------------------
-- Counter module
-------------------------------------------------------------------------------
--! libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
--! Counter Entity
entity counter_entity is
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
end counter_entity;
-------------------------------------------------------------------------------
--! Counter Architecture
architecture counter_arc of counter_entity is
  --! Counter current value
  signal current_value_s : std_logic_vector (COUNTER_SIZE -1 downto 0) :=
    (others => '0');
begin
  --! Counter behavior process
  COUNTER_PROC : process (clk_i, rst_i)
  begin
    -- Asynchronous reset
    if (rst_i = '1') then
      -- Set counter in initial value to zero
      current_value_s <= (others => '0');
    else
      -- Clock rising edge
      if clk_i'event and clk_i = '1' then
        if load_enable_i = '1' then
          current_value_s <= data_to_load_i;
        else
          if count_enable_i = '1' then
            case up_down_i is
              when '1' =>
                current_value_s <= current_value_s + 1;
              when '0' =>
                current_value_s <= current_value_s - 1;
              when others =>
                current_value_s <= current_value_s;
            end case;
          else
            current_value_s <= current_value_s;
          end if;
        end if;
      end if;
    end if;
  end process;
  counter_value_o <= current_value_s;
  -- Zero value detection
  zero_flag_o     <= '1' when (current_value_s = 0) else '0';
end architecture counter_arc;
