-- -------------------------------------------------------- Doxygen header ---
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2013-04-01
--! @brief Spi Master Interface : component package
--! @details
-- -------------------------------------------- Doxygen documentation page ---
--! @page p_201304041328 Configuration package
--! This page descibes the Spi Master Interface configuration package
-- ----------------------------------------------------------- Source code ---

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.spi_master_if_pack.all;
use work.reset_generator_pack.all;  --** this package  does not exist ----****

package spi_master_if_comp is

  --! Spi master interface component 
  component spi_master_if is
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
  end component spi_master_if;

end spi_master_if_comp;
