-- -------------------------------------------------------- Doxygen header ---
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2013-04-01
--! @brief Spi Master Interface : arbiter
--! @details
-- -------------------------------------------- Doxygen documentation page ---
--! @page p_201304040925 Arbiter
--! This page descibes the Spi Master Arbiter module.
-- ----------------------------------------------------------- Source code ---
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.spi_master_if_pack.all;


entity arbiter is
  port (
    clk_i               : in  std_ulogic;
    rst_i               : in  std_ulogic;
    -- Spi Master control channels
    spi_chan_in_array_i : in  spi_chan_array_i_t;
    spi_chan_in_array_o : out spi_chan_array_o_t;
    -- Spi Master selected control channel
    spi_chan_out_i      : in  spi_chan_o_t;
    spi_chan_out_o      : out spi_chan_i_t
    );
end arbiter;

architecture arbiter_arc of arbiter is

begin
  assert SPI_MASTER_CHAN_NUM = 1
    report "Spi Master Interface: arbiter can't manage more than one channel for the momment."
    severity failure;
  
  spi_chan_in_array_o(0).ack <= spi_chan_in_array_i(0).req;

  spi_chan_out_o <= spi_chan_in_array_i(0);

  spi_chan_in_array_o(0).done <= spi_chan_out_i.done;
  spi_chan_in_array_o(0).data <= spi_chan_out_i.data;
  
end arbiter_arc;
