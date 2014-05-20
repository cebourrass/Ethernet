--! @version  (heads/devel)
--! @date 2013-04-01
--! @brief ev76c560 Image Sensor Interface Package
--! @details
-- -------------------------------------------- Doxygen documentation page ---
--! @page p_201304081014 ev76c560 Image Sensor Interface Package
--! This page describes ev76c560 Image Sensor Interface Package.
--! @section sec_201304081015 Revisions
--! - 2013-04-08 : Created
-- ----------------------------------------------------------- Source code ---

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package ev76c560_if_pack is

  --! User bus input signals
  type user_bus_i_t is record
    rdreq : std_ulogic;
  end record; 
  
  --! User bus output signals
  type user_bus_o_t is record
    data    : std_logic_vector(9 downto 0);
    rdempty : std_ulogic;
  end record; 
  
  --! ev56c760 8-bit registers
  type reg_8_t is record
    read    : std_ulogic;
    address : std_ulogic_vector (7 downto 0);
    data : std_ulogic_vector (7 downto 0);
  end record;
  
  --! ev56c760 16-bit registers
  type reg_16_t is record
    read    : std_ulogic;
    address : std_ulogic_vector (7 downto 0);
    data : std_ulogic_vector (15 downto 0);
  end record;
  
  -- 8-bit registers (00 to 03)
  --! Register 00 (8-bits)
  constant REG00_DEF : reg_8_t := ('0',b"0000_0000",b"0000_0000");
  --! Register 01 (8-bits)
  constant REG01_DEF : reg_8_t := ('0',b"0000_0001",b"0000_0000");
  --! Register 02 (8-bits)
  constant REG02_DEF : reg_8_t := ('0',b"0000_0010",b"0000_0000");
  --! Register 03 (8-bits)
  constant REG03_DEF : reg_8_t := ('0',b"0000_0011",b"0000_0000");
  
  --16-bit registers (04 to 3E, 49)
  --! Register 04 (16 bits)
  constant REG04_DEF : reg_16_t := ('0',b"0000_0100",b"0000_0000_0000_0000");
  --! Register 05 (16-bits)
  constant REG05_DEF : reg_16_t := ('0',b"0000_0101",b"0000_0000_0000_0000");
  --! Register 06 (16-bits)
  constant REG06_DEF : reg_16_t := ('0',b"0000_0110",b"0000_0000_0000_0000");
  --! Register 07 (16-bits)
  constant REG07_DEF : reg_16_t := ('0',b"0000_0111",b"0000_0000_0000_0000");
  --! Register 08 (16-bits)
  constant REG08_DEF : reg_16_t := ('0',b"0000_0000",b"0000_0000_0000_0000");
  --! Register 09 (16-bits)
  constant REG09_DEF : reg_16_t := ('0',b"0000_0001",b"0000_0000_0000_0000");
  --! Register 0A (16-bits)
  constant REG0A_DEF : reg_16_t := ('0',b"0000_1010",b"0000_0000_0000_0000");
  --! Register 0B (16-bits)
  constant REG0B_DEF : reg_16_t := ('0',b"0000_1011",b"0000_0000_0000_0000");
  --! Register 0C (16-bits)
  constant REG0C_DEF : reg_16_t := ('0',b"0000_1100",b"0000_0000_0000_0000");
  --! Register 0D (16-bits)
  constant REG0D_DEF : reg_16_t := ('0',b"0000_1101",b"0000_0000_0000_0000");
  --! Register 0E (16-bits)
  constant REG0E_DEF : reg_16_t := ('0',b"0000_1110",b"0000_0000_0000_0000");
  --! Register 0F (16-bits)
  constant REG0F_DEF : reg_16_t := ('0',b"0000_1111",b"0000_0000_0000_0000");
  --! Register 10 (16-bits)
  constant REG10_DEF : reg_16_t := ('0',b"0001_0000",b"0000_0000_0000_0000");
  --! Register 11 (16-bits)
  constant REG11_DEF : reg_16_t := ('0',b"0001_0001",b"0000_0000_0000_0000");
  --! Register 12 (16-bits)
  constant REG12_DEF : reg_16_t := ('0',b"0001_0010",b"0000_0000_0000_0000");
  --! Register 13 (16-bits)
  constant REG13_DEF : reg_16_t := ('0',b"0001_0011",b"0000_0000_0000_0000");
  --! Register 14 (16-bits)
  constant REG14_DEF : reg_16_t := ('0',b"0001_0100",b"0000_0000_0000_0000");
  --! Register 15 (16-bits)
  constant REG15_DEF : reg_16_t := ('0',b"0001_0101",b"0000_0000_0000_0000");
  --! Register 16 (16-bits)
  constant REG16_DEF : reg_16_t := ('0',b"0001_0110",b"0000_0000_0000_0000");
  --! Register 17 (16-bits)
  constant REG17_DEF : reg_16_t := ('0',b"0001_0111",b"0000_0000_0000_0000");
  --! Register 18 (16-bits)
  constant REG18_DEF : reg_16_t := ('0',b"0001_0000",b"0000_0000_0000_0000");
  --! Register 19 (16-bits)
  constant REG19_DEF : reg_16_t := ('0',b"0001_0001",b"0000_0000_0000_0000");
  --! Register 1A (16-bits)
  constant REG1A_DEF : reg_16_t := ('0',b"0001_1010",b"0000_0000_0000_0000");
  --! Register 1B (16-bits)
  constant REG1B_DEF : reg_16_t := ('0',b"0001_1011",b"0000_0000_0000_0000");
  --! Register 1C (16-bits)
  constant REG1C_DEF : reg_16_t := ('0',b"0001_1100",b"0000_0000_0000_0000");
  --! Register 1D (16-bits)
  constant REG1D_DEF : reg_16_t := ('0',b"0001_1101",b"0000_0000_0000_0000");
  --! Register 1E (16-bits)
  constant REG1E_DEF : reg_16_t := ('0',b"0001_1110",b"0000_0000_0000_0000");
  --! Register 1F (16-bits)
  constant REG1F_DEF : reg_16_t := ('0',b"0001_1111",b"0000_0000_0000_0000");
  --! Register 20 (16-bits)
  constant REG20_DEF : reg_16_t := ('0',b"0010_0000",b"0000_0000_0000_0000");
  --! Register 21 (16-bits)
  constant REG21_DEF : reg_16_t := ('0',b"0010_0001",b"0000_0000_0000_0000");
  --! Register 22 (16-bits)
  constant REG22_DEF : reg_16_t := ('0',b"0010_0010",b"0000_0000_0000_0000");
  --! Register 23 (16-bits)
  constant REG23_DEF : reg_16_t := ('0',b"0010_0011",b"0000_0000_0000_0000");
  --! Register 24 (16-bits)
  constant REG24_DEF : reg_16_t := ('0',b"0010_0100",b"0000_0000_0000_0000");
  --! Register 25 (16-bits)
  constant REG25_DEF : reg_16_t := ('0',b"0010_0101",b"0000_0000_0000_0000");
  --! Register 26 (16-bits)
  constant REG26_DEF : reg_16_t := ('0',b"0010_0110",b"0000_0000_0000_0000");
  --! Register 27 (16-bits)
  constant REG27_DEF : reg_16_t := ('0',b"0010_0111",b"0000_0000_0000_0000");
  --! Register 28 (16-bits)
  constant REG28_DEF : reg_16_t := ('0',b"0010_0000",b"0000_0000_0000_0000");
  --! Register 29 (16-bits)
  constant REG29_DEF : reg_16_t := ('0',b"0010_0001",b"0000_0000_0000_0000");
  --! Register 2A (16-bits)
  constant REG2A_DEF : reg_16_t := ('0',b"0010_1010",b"0000_0000_0000_0000");
  --! Register 2B (16-bits)
  constant REG2B_DEF : reg_16_t := ('0',b"0010_1011",b"0000_0000_0000_0000");
  --! Register 2C (16-bits)
  constant REG2C_DEF : reg_16_t := ('0',b"0010_1100",b"0000_0000_0000_0000");
  --! Register 2D (16-bits)
  constant REG2D_DEF : reg_16_t := ('0',b"0010_1101",b"0000_0000_0000_0000");
  --! Register 2E (16-bits)
  constant REG2E_DEF : reg_16_t := ('0',b"0010_1110",b"0000_0000_0000_0000");
  --! Register 2F (16-bits)
  constant REG2F_DEF : reg_16_t := ('0',b"0010_1111",b"0000_0000_0000_0000");
  --! Register 30 (16-bits)
  constant REG30_DEF : reg_16_t := ('0',b"0011_0000",b"0000_0000_0000_0000");
  --! Register 31 (16-bits)
  constant REG31_DEF : reg_16_t := ('0',b"0011_0001",b"0000_0000_0000_0000");
  --! Register 32 (16-bits)
  constant REG32_DEF : reg_16_t := ('0',b"0011_0010",b"0000_0000_0000_0000");
  --! Register 33 (16-bits)
  constant REG33_DEF : reg_16_t := ('0',b"0011_0011",b"0000_0000_0000_0000");
  --! Register 34 (16-bits)
  constant REG34_DEF : reg_16_t := ('0',b"0011_0100",b"0000_0000_0000_0000");
  --! Register 35 (16-bits)
  constant REG35_DEF : reg_16_t := ('0',b"0011_0101",b"0000_0000_0000_0000");
  --! Register 36 (16-bits)
  constant REG36_DEF : reg_16_t := ('0',b"0011_0110",b"0000_0000_0000_0000");
  --! Register 37 (16-bits)
  constant REG37_DEF : reg_16_t := ('0',b"0011_0111",b"0000_0000_0000_0000");
  --! Register 38 (16-bits)
  constant REG38_DEF : reg_16_t := ('0',b"0011_0000",b"0000_0000_0000_0000");
  --! Register 39 (16-bits)
  constant REG39_DEF : reg_16_t := ('0',b"0011_0001",b"0000_0000_0000_0000");
  --! Register EA (16-bits)
  constant REG3A_DEF : reg_16_t := ('0',b"0011_1010",b"0000_0000_0000_0000");
  --! Register 3B (16-bits)
  constant REG3B_DEF : reg_16_t := ('0',b"0011_1011",b"0000_0000_0000_0000");
  --! Register 3C (16-bits)
  constant REG3C_DEF : reg_16_t := ('0',b"0011_1100",b"0000_0000_0000_0000");
  --! Register 3D (16-bits)
  constant REG3D_DEF : reg_16_t := ('0',b"0011_1101",b"0000_0000_0000_0000");
  --! Register 3E (16-bits)
  constant REG3E_DEF : reg_16_t := ('0',b"0011_1110",b"0000_0000_0000_0000");
  --! Register 49 (16-bits)
  constant REG49_DEF : reg_16_t := ('0',b"0100_1001",b"0000_0000_0000_0000");
  
end ev76c560_if_pack;