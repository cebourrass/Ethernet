library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Creer une donnee sur 32 bits pour UDP packet a partir de données 8 bits
entity adapt_data_size is
  port(
    -- Global Signals
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
   
	 data_in 	 : in std_logic_vector(8 downto 0);
	 data_out	 : out std_logic_vector(31 downto 0);
	 
	 data_rdy	 : out std_logic
    );
end adapt_data_size;
--------------------------------------------------------------------------------
--! udp video stream out architecture
architecture adapt_data_size_arc of adapt_data_size is

signal idata_out : std_logic_vector(31 downto 0);
signal idata_rdy : std_logic_vector;
  
signal d1: std_logic_vector(7 downto 0);
signal d2: std_logic_vector(7 downto 0);
signal d3: std_logic_vector(7 downto 0);
signal d4: std_logic_vector(7 downto 0);
 
variable cpt: integer range 0 to 3;

begin
  
  process(clk_i)
  begin
  if rst_i = '0' then
		idata_out <= X"00000000";
		idata_rdy <= '0';
		
  elsif rising_edge(clk_i) then
		case cpt is 
			when 0 => d1 <= data_in; idata_rdy <= '0';idata_out <= X"00000000";
			when 1 => d2 <= data_in;
			when 2 => d3 <= data_in;
			when 3 => d4 <= data_in; idata_rdy <= '1'; idata_out <= d1 & d2 & d3 & data_in;
		end case;
		cpt := cpt + 1;
		
  end if;
end process;

data_out <= idata_out;
end adapt_data_size_arc;      