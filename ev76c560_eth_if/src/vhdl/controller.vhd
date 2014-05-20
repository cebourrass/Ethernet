-- -------------------------------------------------------- Doxygen header ---
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2013-04-01
--! @brief Spi Master Interface : controller module
--! @details
-- -------------------------------------------- Doxygen documentation page ---
--! @page p_201304040926 Controller module
--! This page descibes the Spi Master controller module.
-- ----------------------------------------------------------- Source code ---

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.spi_master_if_pack.all;

--! @brief Spi master entity
entity controller is
  port (
    --! Clock input
    clk_i      : in  std_ulogic;
    --! Reset input (active high)
    rst_i      : in  std_ulogic;
    --! Spi bus : clock signal
    sck_o      : out std_ulogic;
    --! Spi bus : master out slave in signal
    mosi_o     : out std_ulogic;
    --! Spi bus : master in slave out signal
    miso_i     : in  std_ulogic;
    --! Spi bus : Slave chip select signals
    ss_o       : out ss_t;
    --! Spi control channel : inputs
    spi_chan_i : in  spi_chan_i_t;
    --! Spi control channel : outputs
    spi_chan_o : out spi_chan_o_t
    );
end controller;

--! @brief Spi master architecture
architecture controller_arc of controller is
  --! Computed counter width
  constant COUNTER_WIDTH : positive :=
   positive(log(real(REGISTER_WIDTH_BIT))/log(real(2))+1.0);

  --! Computed spi clock divider value  
  constant SPI_CLOCK_DIVIDER_VALUE : positive :=
    SYSTEM_CLOCK_FREQUENCY_VALUE_MHZ/2/SPI_CLOCK_FREQUENCY_VALUE_MHZ;

  -- Wires
  signal spi_selelct_s : std_ulogic;
  signal spi_sample_s  : std_ulogic;
  signal spi_reload_s  : std_ulogic;
  signal tck_ena_s     : std_ulogic;

  -- Registers

  --! Registered go signal
  signal go_r : std_ulogic;

  --! Registered mode signal
  signal mode_r : std_ulogic;

  --! Registered data input signal
  signal data_r : data_t;

  --! Spi shift register
  signal spi_r : data_t;

  --! Counter : frequency divider 
  signal counter_value_r : std_logic_vector(COUNTER_WIDTH downto 0);
  
begin
  --! @brief Spi clock generation
  SCK_COMB : sck_o <= counter_value_r(0);

  --! @brief Extract shift register MSB
  MOSI_COMB : mosi_o <= spi_r(spi_r'high);

  --! @brief Chip select
  SS_COMB : process (spi_chan_i.paddr, spi_selelct_s)
  begin
    -- for each ss_o bit
    for i in 0 to SPI_PERIPH_NUM-1 loop
      if i = conv_integer(std_logic_vector(spi_chan_i.paddr)) then
        ss_o(i) <= not spi_selelct_s;
      else
        ss_o(i) <= '1';
      end if;
    end loop;
  end process;

  --! @brief Done signal: one clock period pulse width
  DONE_COMB : spi_chan_o.done <= spi_reload_s and tck_ena_s;

  -- ! @brief Data out 
  DATA_OUT_COMB : spi_chan_o.data <= spi_r;

  --! @brief Spi master process
  SPI_MASTER_PROC : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      counter_value_r <= (others => '0');
      spi_selelct_s   <= '0';
      spi_sample_s    <= '0';
      spi_reload_s    <= '0';
      spi_r           <= (others => '0');
      -- spi_chan_o.data <= (others => '0') ;
    else
      -- System clock rising edge
      if clk_i'event and clk_i = '1' then
        -- Clock divider
        if tck_ena_s = '1' then
          -- Counter value is not zero
          if counter_value_r > std_logic_vector(to_unsigned(0, COUNTER_WIDTH)) then
            -- Count down
            counter_value_r <= counter_value_r - 1;
            spi_selelct_s   <= '1';
            -- Sample on even count values, shift on odd
            if counter_value_r(0) = '0' then
              -- Sample
              spi_sample_s <= miso_i;
            else
              -- Shift bits 
              for i in spi_r'high downto spi_r'low+1 loop
                spi_r(i) <= spi_r(i-1);
              end loop;
              -- Feed shift register LSB with actual sampled data
              spi_r(spi_r'low) <= spi_sample_s;
            end if;
            if counter_value_r = std_logic_vector(to_unsigned(1, COUNTER_WIDTH)) then
              spi_reload_s <= '1';
            else
              spi_reload_s <= '0';
            end if;
          else
            spi_reload_s <= '0';
            if go_r = '1' or (spi_chan_i.burst = '1' and spi_reload_s = '1') then
              if mode_r = '0' then
                counter_value_r <= std_logic_vector(to_unsigned(2*REGISTER_WIDTH_BIT, COUNTER_WIDTH+1));
              else
                counter_value_r <= std_logic_vector(to_unsigned(2*16, COUNTER_WIDTH+1));
              end if;
              spi_r         <= data_r;
              -- spi_chan_o.data <= spi_r;
              spi_selelct_s <= '1';
            else
              spi_selelct_s <= '0';
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  --! @brief Spi clock divider
  CLOCK_DIVIDER_PROC : process(clk_i, rst_i)
    variable cntr : integer;
  begin
    if rst_i = '1' then
      cntr      := 0;
      tck_ena_s <= '0';
    else
      if clk_i'event and clk_i = '1' then
        -- Divide clk input
        cntr := cntr+1;
        if cntr = SPI_CLOCK_DIVIDER_VALUE then
          tck_ena_s <= '1';
          cntr      := 0;
        else
          tck_ena_s <= '0';
        end if;
      end if;
    end if;
  end process;

  --! @brief Go signal sample and hold process
  GO_SH_PROC : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      go_r <= '0';
    else
      if clk_i'event and clk_i = '1' then
        -- Sample and hold start signal
        if spi_chan_i.go = '1' then
          go_r <= '1';
        else
          if tck_ena_s = '1' then
            go_r <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  --! @brief Data input sample process
  DATA_IN_LATCH_PROC : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      data_r <= (others => '0');
    else
      if clk_i'event and clk_i = '1' then
        if (spi_chan_i.go = '1' and go_r = '0') or (spi_chan_i.burst = '1' and spi_reload_s = '1') then
          -- Sample data
          data_r <= spi_chan_i.data;
          mode_r <= spi_chan_i.mode;
        end if;
      end if;
    end if;
  end process;

end controller_arc;
