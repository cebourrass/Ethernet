-- -------------------------------------------------------- Doxygen header ---
--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2013-04-01
--! @brief Spi Master Interface
--! @details
-- -------------------------------------------- Doxygen documentation page ---
--! @page p_201304040918 Spi Master Interface
--! This page describes Spi master interface contents.
--! @section sec_201304040913 Revisions
--! - 2012-09-10 : Created
--! - 2013-02-14 : Documentation
--! @section sec_201304041530 Symbol
--! @image html spi_master_if-symbol.png "Spi master interface symbol"
--! @section sec_201304040914 Block diagram
--! @image html spi_master_interface-block_diagram.png "Spi master interface block diagram"
--! @section sec_201304040915 Concepts
--! @subsection sec_201304040916 Channels
--! Spi master interface provides multiple channels to access spi bus. Each channel can access spi bus for reading and writing.
--! @subsubsection sec_201304040917 Signal description
--! Channel signal are synchronous to clk_i clock.
--! - Channel managment
--!   - req (in): one clock period signal high pulse request a spi master access.
--!   - ack (out): one clock period signal high pulse acknolegment. When received, the channel is connected with the spi bus.
--!   - rel (in): one clock periode high pulse release spi bus. While not released, the channel keeps access with spi bus and no other channel may access spi bus.
--! - Spi bus access
--!   - mode (in): mode selection
--!   - go (in): one clock high pulse. Starts a spi bus transfer (read or write)
--!   - burst (in): sampled when done is high :
--!     - low: spi bus transfer stops
--!     - low: spi bus transfer go one and send next data data
--!   - paddr (in): address of spi slave involve in transfer. 
--!   - data (in): data to send on spi bus.
--!   - data (out): data received on spi bus.
--!   - done (out): one clock period high pulse. When received, indicates than spi bus transfer end.
--! @section sec_201304041317 Sub modules
--!  - @subpage p_201304041327
--!  - @subpage p_201304040925
--!  - @subpage p_201304040926
--!  - @subpage p_201304041328
-- ----------------------------------------------------------- Source code ---

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.spi_master_if_pack.all;
use work.reset_generator_pack.all;

--! @brief Spi master interface entity
entity spi_master_if is
  port (
      --! Clock input
      clk_i : in std_ulogic;
      --! Reset system
      rst_i : in spi_master_rst_m2s_t;
      rst_o : out spi_master_rst_s2m_t;
      --! Spi bus : clock signal
      sck_o  : out std_ulogic;
      --! Spi bus : master out slave in signal
      mosi_o : out std_ulogic;
      --! Spi bus : master in slave out signal
      miso_i : in  std_ulogic;
      --! Spi bus : Slave chip select signals
      ss_o : out ss_t;
      --! Spi control channels : inputs
      spi_chan_array_i : in  spi_chan_array_i_t;
      --! Spi control channels : outputs
      spi_chan_array_o : out spi_chan_array_o_t
    );
end spi_master_if;

--! @brief Spi master interface architecture
architecture spi_master_if_arc of spi_master_if is

  --! Wire from master to arbiter
  signal master_arbiter_s : spi_chan_o_t;
  --! Wire from arbiter to master
  signal arbiter_master_s : spi_chan_i_t;

begin

  rst_o.rst_done <= not rst_i.rst;
  rst_o.rst_status <= NO_ERROR;
  
  --! @brief Controller instance
  CONTROLLER_INST : entity work.controller(controller_arc)
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i.rst,
      sck_o      => sck_o,
      mosi_o     => mosi_o,
      miso_i     => miso_i,
      ss_o       => ss_o,
      spi_chan_i => arbiter_master_s,
      spi_chan_o => master_arbiter_s
      );

  --! @brief Arbiter instance
  ARBITER_INST : entity work.arbiter(arbiter_arc)
    port map (
      clk_i               => clk_i,
      rst_i               => rst_i.rst,
      spi_chan_in_array_i => spi_chan_array_i,
      spi_chan_in_array_o => spi_chan_array_o,
      spi_chan_out_i      => master_arbiter_s,
      spi_chan_out_o      => arbiter_master_s
      );

end spi_master_if_arc;
