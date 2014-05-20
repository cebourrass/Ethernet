library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
library work;
use work.fpga_pack.all;
use work.ethernet_package.all;

package tx_mux_comp is

  -- Static constants 

  -- Local types
 
  -- Local components 
  component tx_mux is
    port(
      vector_i  : in tx_mux_vector_i_t;
      scalar_o  : out tx_stream_o_t;
      channel_i : in std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0)
      );
  end component tse_config;
  
end tx_mux_comp;