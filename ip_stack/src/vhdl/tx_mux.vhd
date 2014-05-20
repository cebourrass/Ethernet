--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2012-11-16
--! @brief Tse Mac Interface
--! @details
--!
--! @page p_Tse_Mac_Interface Tse Mac Interface
--! This page describes Tse Mac Interface contents.
--! @section sec_000 Revisions
--! - 2012-04-10 : Created
--! @section sec_001 Block diagram
--! @image html tse_mac_interface-block_diagram.png "Tse_Mac_Interface block diagram"
--! @section sec_002 Concepts
--! Tse Mac Interface implements Ip stack up to Udp protocol.
--! Tse Mac Interface comunicates with Tse Mac Ip for transmiting, receiving packets, and configuring Tse Mac Ip and Marvell Physical Interface.
-------------------------------------------------------------------------------
--! Librairies
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.ethernet_package.all;
use work.ip_stack_pack.all;
-------------------------------------------------------------------------------
--! Tse Mac Interface Entity
entity tx_mux_entity is
  port(
    vector_i   : in tx_mux_vector_i_t;
    scalar_o   : out tx_stream_o_t;
    channel_i  : in std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0)
    );
end tx_mux_entity;

architecture tx_mux_arc of tx_mux_entity is

  constant TX_ARBITER_CHANNEL_ADDRESS_BUS_WIDTH : integer :=
    integer(ceil(log2(real(TX_ARBITER_CHANNNEL_NUMBER)))+1.0);   
  signal b0_s : std_logic_vector(TX_ARBITER_CHANNEL_ADDRESS_BUS_WIDTH-1 downto 0);

  
begin

  scalar_o <= vector_i(0) when channel_i(0) = '1' else
              vector_i(1) when channel_i(1) = '1' else
              vector_i(2) when channel_i(2) = '1' else
              vector_i(3) when channel_i(3) = '1' else
              TX_STREAM_O_IDLE;
  
end tx_mux_arc;
