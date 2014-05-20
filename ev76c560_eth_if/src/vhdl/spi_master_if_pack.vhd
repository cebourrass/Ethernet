-- -------------------------------------------------------- Doxygen header ---
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2013-04-01
--! @brief Spi Master Interface : configuration package
--! @details
-- -------------------------------------------- Doxygen documentation page ---
--! @page p_201304041327 Configuration package
--! This page descibes the Spi Master Interface configuration package
-- ----------------------------------------------------------- Source code ---

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package spi_master_if_pack is


-- Configuration parameters

  --! System clock frequency value in mhz
  constant SYSTEM_CLOCK_FREQUENCY_VALUE_MHZ : positive := 200;

  --! Spi clock frequency value in mhz
  constant SPI_CLOCK_FREQUENCY_VALUE_MHZ : positive := 10;

  --! Size of the spi register in bit
  constant REGISTER_WIDTH_BIT : positive := 24;

  --! Number of channel used to access spi peripherals
  constant SPI_MASTER_CHAN_NUM : positive := 1;

  --! Number of spi peripherals
  constant SPI_PERIPH_NUM : positive := 1;

  --! Computed value of Spi peripheral address bus width
  constant SPI_PERIH_ADDR_WIDTH : positive :=
    positive(log(real(SPI_PERIPH_NUM))/log(real(2))+1.0);
  
  --! Assigned peripheral #0
  constant SPI_PERIPH_0 :
    std_ulogic_vector(SPI_PERIH_ADDR_WIDTH-1 downto 0) :=
    std_ulogic_vector(to_unsigned(0, SPI_PERIH_ADDR_WIDTH));

  -- Congiguration option types
  type spi_mode_t is (
    SPI_MODE_0,
    SPI_MODE_1,
    SPI_MODE_2,
    SPI_MODE_3
    );

  type ss_pol_t is (
    SS_ACTIVE_LOW,
    SS_ACTIVE_HIGH
    );
    
  constant SPI_MODE : spi_mode_t := SPI_MODE_0;
  constant SS_POL   : ss_pol_t   := SS_ACTIVE_LOW;
  
  type cpol_t is (
    '0',
    '1'
    );

  type cpha_t is (
    '0',
    '1'
    );

  subtype ss_t is std_ulogic_vector(SPI_PERIH_ADDR_WIDTH-1 downto 0);
  subtype data_t is std_ulogic_vector(REGISTER_WIDTH_BIT-1 downto 0);
  
  --! @brief Spi control channel input type  
  --! - req   : Spi bus access request
  --! - rel   : Spi bus access release
  --! - mode  : Spi bus control mode
  --! - go    : Spi bus transfer start
  --! - go    : Spi bus burst mode transfer
  --! - paddr : Peripheral address
  --! - data  : Data to mosi
  type spi_chan_i_t is record
    req   : std_ulogic;
    rel   : std_ulogic;
    mode  : std_ulogic;
    go    : std_ulogic;
    burst : std_ulogic;
    paddr : ss_t;
    data  : data_t;
  end record;

  --! @brief Spi control channel output type  
  --! - ack  : Spi bus access acknowledge
  --! - done : Spi bus transfer finished
  --! - data : Data from MISO
  type spi_chan_o_t is record
    ack  : std_ulogic;
    done : std_ulogic;
    data : data_t;
  end record;

  --! @brief Spi control channel array input type  
  type spi_chan_array_i_t is array (0 to SPI_MASTER_CHAN_NUM-1) of spi_chan_i_t;
  --! @brief Spi control channel array output type  
  type spi_chan_array_o_t is array (0 to SPI_MASTER_CHAN_NUM-1) of spi_chan_o_t;

end package spi_master_if_pack;
