------------------------------------------------------------------------------
-- Title      : Fpga vhdl source code
-- Project    : Dream Camera
------------------------------------------------------------------------------
-- File       : asram_if.vhd
-- Author     : Thierry Tixier
-- Company    : Institut Pascal - UMR CNRS/UBP/IFMA 6602
-- Group      : ISPR/DREAM
-- Created    : 2013-02-14
------------------------------------------------------------------------------
-- Description: 
------------------------------------------------------------------------------
-- Copyright (c) 2013 
------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-05-14  1.0      T. Tixier       Created
-- 2012-06-20  1.0      T. Tixier       Modified architeture without
--  external counters
------------------------------------------------------------------------------
--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2012-11-16
--! @brief Ticks pulse generator module
--! @details
--! This module implements periodic ticks generator : second, ms, us\n.
--! For details, see @ref p_201207121130 page.
--!
--! @page p_201207121130 Counter module
--!
--! @section s_201207121131 Revisions
--! - 2011-07-12 : Created
-------------------------------------------------------------------------------
-- Ticks pulse generator module
-------------------------------------------------------------------------------
--! libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library work;
use work.ticks_generator_pack.all;
use work.counter_comp.all;
-------------------------------------------------------------------------------
--! Ticks pulse generator Entity
entity ticks_generator_entity is
  port (
    --! Master clock input (clk_i>1Mhz)
    clk_i       : in  std_logic;
    --! Reset input
    rst_i       : in  std_logic;
    --! Synchronization input
    sync_i      : in  std_logic;
    --! Ticks output pluses
    ticks_o     : out ticks_t
    );
end entity ticks_generator_entity;
-------------------------------------------------------------------------------
--! Ticks pulse generator Architecture
architecture ticks_generator_arc of ticks_generator_entity is

  -- Generic dependant constants
  
  --! Compute us counter size according to clock frequency input
  constant US_COUNTER_SIZE : integer :=
    integer(log2(real(CLOCK_FREQUENCY_MHZ)+1.0));
  
  
  -- Signals
  signal counter_1us_zero_flag_s     : std_logic;
  signal counter_1us_load_enable_s   : std_logic;
  signal counter_10us_zero_flag_s    : std_logic;
  signal counter_10us_load_enable_s  : std_logic;
  signal counter_100us_zero_flag_s   : std_logic;
  signal counter_100us_load_enable_s : std_logic;  
  signal counter_1ms_zero_flag_s     : std_logic;
  signal counter_1ms_load_enable_s   : std_logic;
  signal counter_1s_zero_flag_s      : std_logic;
  signal counter_1s_load_enable_s    : std_logic;
  
begin

  assert false
    report "Ticks_generator: US_COUNTER_SIZE is set to "
      & integer'image(US_COUNTER_SIZE) severity note;
  assert false
    report "Ticks_generator: MS_COUNTER_SIZE is set to "
      & integer'image(MS_COUNTER_SIZE) severity note;
  assert false
    report "Ticks_generator: S_COUNTER_SIZE is set to "
      & integer'image(S_COUNTER_SIZE) severity note;
 
  ticks_o.ticks_1us   <= counter_1us_zero_flag_s;
  ticks_o.ticks_10us  <= counter_10us_zero_flag_s and
                        counter_1us_zero_flag_s;
  ticks_o.ticks_100us <= counter_100us_zero_flag_s and
                         counter_10us_zero_flag_s and
                         counter_1us_zero_flag_s;
  ticks_o.ticks_1ms   <= counter_1ms_zero_flag_s and
                         counter_100us_zero_flag_s and
                         counter_10us_zero_flag_s and
                         counter_1us_zero_flag_s;
  ticks_o.ticks_1s    <= counter_1s_zero_flag_s and
                         counter_1ms_zero_flag_s and
                         counter_100us_zero_flag_s and
                         counter_10us_zero_flag_s and
                         counter_1us_zero_flag_s;
  counter_1us_load_enable_s <=
    -- Counter Reach Zero
    counter_1us_zero_flag_s or
    -- Synchro Requested
    (sync_i and not counter_1us_zero_flag_s);
  counter_10us_load_enable_s <=
    -- Counter Reach Zero
    (counter_10us_zero_flag_s and counter_1us_zero_flag_s)  or
    -- Synchro Requested
    (sync_i and not counter_10us_zero_flag_s);    
  counter_100us_load_enable_s <=
    -- Counter Reach Zero
    (counter_100us_zero_flag_s and
     counter_10us_zero_flag_s and
     counter_1us_zero_flag_s) or
    -- Synchro Requested
    (sync_i and not counter_100us_zero_flag_s);
  counter_1ms_load_enable_s <=
    -- Counter Reach Zero
    (counter_1ms_zero_flag_s and
     counter_100us_zero_flag_s and
     counter_10us_zero_flag_s and
     counter_1us_zero_flag_s) or
    -- Synchro Requested
    (sync_i and not counter_1ms_zero_flag_s);
  counter_1s_load_enable_s <=
    -- Counter Reach Zero  
    (counter_1s_zero_flag_s and
     counter_1ms_zero_flag_s and
     counter_100us_zero_flag_s and
     counter_10us_zero_flag_s and
     counter_1us_zero_flag_s) or
    -- Synchro Requested
    (sync_i and not counter_1s_zero_flag_s);
  --! One us counter instance
  COUNTER_1US_INST : counter
    generic map (
      COUNTER_SIZE => US_COUNTER_SIZE
      )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      data_to_load_i  =>
      std_logic_vector(to_unsigned(CLOCK_FREQUENCY_MHZ-1,
                                   US_COUNTER_SIZE)),
      count_enable_i  => '1',
      load_enable_i   => counter_1us_load_enable_s,
      up_down_i       => '0',
      counter_value_o => open,
      zero_flag_o     => counter_1us_zero_flag_s
      ); 
  --! Ten us counter instance
  COUNTER_10US_INST : counter
    generic map (
      COUNTER_SIZE => TUS_COUNTER_SIZE
      )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      data_to_load_i  => std_logic_vector(std_logic_vector(to_unsigned(9, TUS_COUNTER_SIZE))),
      count_enable_i  => counter_1us_load_enable_s,
      load_enable_i   => counter_10us_load_enable_s,
      up_down_i       => '0',
      counter_value_o => open,
      zero_flag_o     => counter_10us_zero_flag_s
      );
  --! Hundred us counter instance
  COUNTER_HUS_INST : counter
    generic map (
      COUNTER_SIZE => HUS_COUNTER_SIZE
      )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      data_to_load_i  => std_logic_vector(std_logic_vector(to_unsigned(9, HUS_COUNTER_SIZE))),
      count_enable_i  => counter_10us_load_enable_s,
      load_enable_i   => counter_100us_load_enable_s,
      up_down_i       => '0',
      counter_value_o => open,
      zero_flag_o     => counter_100us_zero_flag_s
      );      
  --! One ms counter instance
  COUNTER_1MS_INST : counter
    generic map (
      COUNTER_SIZE => MS_COUNTER_SIZE
      )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      data_to_load_i  => std_logic_vector(to_unsigned(9, MS_COUNTER_SIZE)),
      count_enable_i  => counter_100us_load_enable_s,
      load_enable_i   => counter_1ms_load_enable_s,
      up_down_i       => '0',
      counter_value_o => open,
      zero_flag_o     => counter_1ms_zero_flag_s
      );
  --! One s counter instance
  COUNTER_1S_INST : counter
    generic map (
      COUNTER_SIZE => S_COUNTER_SIZE
      )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      data_to_load_i  => std_logic_vector(to_unsigned(999, S_COUNTER_SIZE)),
      count_enable_i  => counter_1ms_load_enable_s,
      load_enable_i   => counter_1s_load_enable_s,
      up_down_i       => '0',
      counter_value_o => open,
      zero_flag_o     => counter_1s_zero_flag_s
      );      
end architecture ticks_generator_arc;

architecture ticks_generator_arc_1 of ticks_generator_entity is

  --! Compute us counter size according to clock frequency input
  constant US_COUNTER_SIZE : integer :=
    integer(log2(real(CLOCK_FREQUENCY_MHZ)+1.0));
    
  --! Micro-second counter register
  signal us_counter_r          : std_logic_vector(US_COUNTER_SIZE-1 downto 0):=(others => '0');
  --! Tens-micro-second counter register
  signal tens_us_counter_r     : std_logic_vector(3 downto 0):=(others => '0');
  --! Hundreds-micro-second counter register
  signal hundreds_us_counter_r : std_logic_vector(3 downto 0):=(others => '0');
  --! Milli-second counter register
  signal ms_counter_r          : std_logic_vector(3 downto 0):=(others => '0');
  --! Tens-milli-second counter register
  signal tens_ms_counter_r     : std_logic_vector(3 downto 0):=(others => '0');
  --! Hundreds-milli-second counter register
  signal hundreds_ms_counter_r : std_logic_vector(3 downto 0):=(others => '0');
  --! Second counter register
  signal s_counter_r           : std_logic_vector(3 downto 0):=(others => '0');
  
begin
  
  US_COUNTER_PROC : process(clk_i, rst_i)
  begin
    if rst_i='1' then
      us_counter_r <= std_logic_vector(to_unsigned(CLOCK_FREQUENCY_MHZ-1,US_COUNTER_SIZE));
      ticks_o.ticks_1us   <= '0';
    else
      if clk_i'event and clk_i='1' then
        if sync_i='1' then
            us_counter_r <= std_logic_vector(to_unsigned(CLOCK_FREQUENCY_MHZ-1,US_COUNTER_SIZE));
            ticks_o.ticks_1us <= '0';
          else
          if us_counter_r=0 then
            ticks_o.ticks_1us <= '1';
            us_counter_r <= std_logic_vector(to_unsigned(CLOCK_FREQUENCY_MHZ-1,US_COUNTER_SIZE));
          else
            us_counter_r <= us_counter_r-1;
            ticks_o.ticks_1us <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  TENS_US_COUNTER_PROC : process(clk_i, rst_i)
  begin
    if rst_i='1' then
      tens_us_counter_r <= std_logic_vector(to_unsigned(9,4));
      ticks_o.ticks_10us  <= '0';
    else
      if clk_i'event and clk_i='1' then
        if us_counter_r=0 then
          if tens_us_counter_r=0 or sync_i='1' then
            ticks_o.ticks_10us <= '1';
            tens_us_counter_r <= std_logic_vector(to_unsigned(9,4));
          else
            tens_us_counter_r <= tens_us_counter_r-1;
          end if;
        else
          ticks_o.ticks_10us <= '0';
        end if;
      end if;
    end if;
  end process;

HUNDREDS_US_COUNTER_PROC : process(clk_i, rst_i)
  begin
    if rst_i='1' then
      hundreds_us_counter_r <= std_logic_vector(to_unsigned(9,4));
      ticks_o.ticks_100us  <= '0';
    else
      if clk_i'event and clk_i='1' then
        if tens_us_counter_r=0 and us_counter_r=0 then
          if hundreds_us_counter_r=0 or sync_i='1' then
            ticks_o.ticks_100us <= '1';
            hundreds_us_counter_r <= std_logic_vector(to_unsigned(9,4));
          else
            hundreds_us_counter_r <= hundreds_us_counter_r-1;
          end if;
        else
          ticks_o.ticks_100us <= '0';
        end if;
      end if;
    end if;
  end process;
  
MS_COUNTER_PROC : process(clk_i, rst_i)
  begin
    if rst_i='1' then
      ms_counter_r <= std_logic_vector(to_unsigned(9,4));
      ticks_o.ticks_1ms  <= '0';
    else
      if clk_i'event and clk_i='1' then
        if hundreds_us_counter_r=0 and tens_us_counter_r=0 and us_counter_r=0 then
          if ms_counter_r=0 or sync_i='1' then
            ticks_o.ticks_1ms <= '1';
            ms_counter_r <= std_logic_vector(to_unsigned(9,4));
          else
            ms_counter_r <= ms_counter_r-1;
          end if;
        else
          ticks_o.ticks_1ms <= '0';
        end if;
      end if;
    end if;
  end process;  
  
TENS_MS_COUNTER_PROC : process(clk_i, rst_i)
  begin
    if rst_i='1' then
      tens_ms_counter_r <= std_logic_vector(to_unsigned(9,4));
      ticks_o.ticks_10ms  <= '0';
    else
      if clk_i'event and clk_i='1' then
        if ms_counter_r=0 and hundreds_us_counter_r=0 and tens_us_counter_r=0 and us_counter_r=0 then
          if tens_ms_counter_r=0 or sync_i='1' then
            ticks_o.ticks_10ms <= '1';
            tens_ms_counter_r <= std_logic_vector(to_unsigned(9,4));
          else
            tens_ms_counter_r <= tens_ms_counter_r-1;
          end if;
        else
          ticks_o.ticks_10ms <= '0';
        end if;
      end if;
    end if;
  end process;    
  
hundreds_ms_COUNTER_PROC : process(clk_i, rst_i)
  begin
    if rst_i='1' then
      hundreds_ms_counter_r <= std_logic_vector(to_unsigned(9,4));
      ticks_o.ticks_100ms  <= '0';
    else
      if clk_i'event and clk_i='1' then
        if tens_ms_counter_r=0 and ms_counter_r=0 and hundreds_us_counter_r=0 and tens_us_counter_r=0 and us_counter_r=0 then
          if hundreds_ms_counter_r=0 or sync_i='1' then
            ticks_o.ticks_100ms <= '1';
            hundreds_ms_counter_r <= std_logic_vector(to_unsigned(9,4));
          else
            hundreds_ms_counter_r <= hundreds_ms_counter_r-1;
          end if;
        else
          ticks_o.ticks_100ms <= '0';
        end if;
      end if;
    end if;
  end process;   

s_COUNTER_PROC : process(clk_i, rst_i)
  begin
    if rst_i='1' then
      s_counter_r <= std_logic_vector(to_unsigned(9,4));
      ticks_o.ticks_1s  <= '0';
    else
      if clk_i'event and clk_i='1' then
        if hundreds_ms_counter_r=0 and tens_ms_counter_r=0 and ms_counter_r=0 and hundreds_us_counter_r=0 and tens_us_counter_r=0 and us_counter_r=0 then
          if s_counter_r=0 or sync_i='1' then
            ticks_o.ticks_1s <= '1';
            s_counter_r <= std_logic_vector(to_unsigned(9,4));
          else
            s_counter_r <= s_counter_r-1;
          end if;
        else
          ticks_o.ticks_1s <= '0';
        end if;
      end if;
    end if;
  end process;    
  
end ticks_generator_arc_1;