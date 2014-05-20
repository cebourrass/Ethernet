--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2012-10-24
--! @brief TX arbiter
--! @details
--!
--! @page p_Tx_Arbiter
--! This page describes Tx arbiter contents.
--! @section sec_000 Revisions
--! - 2012-10-23 : Created
--! @section sec_001 Block diagram
--! @image html tx_arbiter-block_diagram.png "tx_arbiter block diagram"
--! @section sec_002 Concepts
--! 
-------------------------------------------------------------------------------
--! Librairies
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ethernet_package.all;
--! Tx arbiter entity
entity tx_arbiter is
  port (
    --! Master Clock
    clk_i        : in  std_logic;
    -- System Reset     
    rst_i        : in std_logic;
    --! Tx arbiter inputs
    tx_arbiter_i : in tx_arbiter_i_t;
    --! Tx arbiter outputs
    tx_arbiter_o : out tx_arbiter_o_t
  );
end tx_arbiter;
--! Tx arbiter architecture
architecture tx_arbiter_arc of tx_arbiter is
  --! Pending signal
  signal pending_s : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
  signal memorized_s : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
  signal accepted_s : std_logic_vector(TX_ARBITER_CHANNNEL_NUMBER-1 downto 0);
  signal tx_arbiter_s : tx_arbiter_o_t;
begin
  tx_arbiter_o <= tx_arbiter_s;
  
  CHANNEL_GENE : for channel in 0 to TX_ARBITER_CHANNNEL_NUMBER-1 generate
    CHANNNEL_PROC : process(clk_i, rst_i)
    variable fsm_channel_state_r : tx_arbiter_fsm_channel_state_t;
    begin
      if (rst_i = '1') then
        fsm_channel_state_r := TX_ARBITER_CHANNEL_IDLE;
        tx_arbiter_s.acknowledge(channel) <= '0';
        tx_arbiter_s.pending(channel)     <= '0';
        tx_arbiter_s.memorized(channel)   <= '0';
      else
        if (clk_i'event and clk_i = '1') then
          case fsm_channel_state_r is
            when TX_ARBITER_CHANNEL_IDLE =>
              tx_arbiter_s.acknowledge(channel) <= '0';
              tx_arbiter_s.pending(channel)     <= '0';
              tx_arbiter_s.memorized(channel)   <= '0';
              if tx_arbiter_i.request(channel)='1' then
                fsm_channel_state_r := TX_ARBITER_CHANNEL_WAIT;
              end if;
            when TX_ARBITER_CHANNEL_WAIT =>
              tx_arbiter_s.acknowledge(channel) <= '0';
              tx_arbiter_s.pending(channel)     <= '0';
              tx_arbiter_s.memorized(channel)   <= '1';
              if accepted_s(channel)='1' then
                fsm_channel_state_r := TX_ARBITER_CHANNEL_ACK;
              end if;
            when TX_ARBITER_CHANNEL_ACK =>
              tx_arbiter_s.acknowledge(channel) <= '1';
              tx_arbiter_s.pending(channel)     <= '1';
              tx_arbiter_s.memorized(channel)   <= '0';
              fsm_channel_state_r := TX_ARBITER_CHANNEL_PROCESS;
            when TX_ARBITER_CHANNEL_PROCESS =>
              tx_arbiter_s.acknowledge(channel) <= '0';
              tx_arbiter_s.pending(channel)     <= '1';
              tx_arbiter_s.memorized(channel)   <= '0';
              if tx_arbiter_i.release(channel)='1' then
                fsm_channel_state_r := TX_ARBITER_CHANNEL_IDLE;
              end if;  
              when others =>
              fsm_channel_state_r := TX_ARBITER_CHANNEL_IDLE;
          end case;
        end if;
      end if;
    end process;
  end generate;
  --! Fixed priority encoder
  memorized_s(0) <= '0';
  memorized_s(1) <= tx_arbiter_s.memorized(0);
  MEMORIZED_GENE : for channel in 2 to TX_ARBITER_CHANNNEL_NUMBER-1 generate
    memorized_s(channel) <= tx_arbiter_s.memorized(channel-1) or memorized_s(channel-2);
  end generate;
  --! Rise to one as soon as a channel is in use
  pending_s(0) <= tx_arbiter_s.pending(0);
  PENDING_GENE : for channel in 1 to TX_ARBITER_CHANNNEL_NUMBER-1 generate
  pending_s(channel) <= tx_arbiter_s.pending(channel) or pending_s(channel-1);
  end generate;
  --! Compute channel activation and priority
  ACCEPTED_GENE : for channel in 0 to TX_ARBITER_CHANNNEL_NUMBER-1 generate
    accepted_s(channel) <= tx_arbiter_s.memorized(channel) and  -- There is a request 
                           not (pending_s(TX_ARBITER_CHANNNEL_NUMBER-1)) and -- No channel in use
                           not (memorized_s(channel)); -- No channel request whith higher priority
  end generate;
end architecture tx_arbiter_arc;