--! @file
--! @author Thierry Tixier
--! @version  (heads/devel)
--! @date 2012-11-16
--! @brief Tse Configuration Module
--! @details
--!
--! @page p_Tse_Configuration_Module Tse Configuration Module
--! This page describes Tse Configuration Module contents.
--! @section sec_000 Revisions
--! - 2012-05-10 : Created
--! @section sec_001 Block diagram
--! @image html p_tse_configuration_module-block_diagram.png "Tse Configuration Module block diagram"
--! @section sec_002 Concepts
--! On reset :
--! - Waits for 5ms
--! - Configure tse mac registers : 
--!  - Mdio address 0 : 12
--!  - Mdio register 20
--!  - Mdio register 27
--!  - Mdio register 16
--!  - Mdio register 4
--!  - Mdio register 0
--!  - Mdio register 25 (non)
--!  - R02
--! - Generate reset low
--! @section sec_003 Input Output Detail
--! @subsection ssec001 Outputs
--! - tse_cfg_rst      
--! - tse_cfg_address  
--! - tse_cfg_write    
--! - tse_cfg_read     
--! - tse_cfg_writedata
--! @subsection ssec001 Inputs
--! - tse_cfg_readdata
--! - tse_cfg_waitrequest

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_package.all;
use work.counter_comp.all;

entity tse_config_entity is
  port(
    clk_i : in std_logic;
    rst_i : in std_logic;
    
    tse_cfg_i : in tse_cfg_i_t;
    tse_cfg_o : out tse_cfg_o_t
    );
end tse_config_entity;

architecture tse_config_arc of tse_config_entity is

  type tse_cfg_state_t is(
    TRIGGER_DELAY_5MS,
    WAIT_FOR_DELAY_5MS_DONE,
    TSEMAC_SET_CMD_CONFIG,
    TSEMAC_SET_MDIO_ADDR0,
    TSEMAC_SET_MDIO_REG_00,
    TSEMAC_SET_MDIO_REG_04,
    TSEMAC_SET_MDIO_REG_16,
    TSEMAC_SET_MDIO_REG_20,
    TSEMAC_SET_MDIO_REG_25,
    TSEMAC_SET_MDIO_REG_27,
    IDLE
  );

  signal tse_cfg_state_r       : tse_cfg_state_t;
  signal delay_5ms_done_s      : std_logic;
  signal delay_5ms_pending_s   : std_logic;
  signal delay_5ms_start_s     : std_logic;
  signal tse_cfg_waitrequest_s : std_logic;
  signal wait_state_s          : std_logic;
  
begin
  
  tse_cfg_waitrequest_s <= tse_cfg_i.tse_cfg_waitrequest;

  process (clk_i, rst_i)
  begin
    if (rst_i = '1') then
        tse_cfg_o.tse_cfg_address   <= (others => '0');
        tse_cfg_o.tse_cfg_write     <= '0';
        tse_cfg_o.tse_cfg_read      <= '0';
        tse_cfg_o.tse_cfg_writedata <= (others => '0');
        tse_cfg_o.tse_cfg_rst       <= '1';
        tse_cfg_state_r <= TRIGGER_DELAY_5MS;
        delay_5ms_start_s <= '0';
        wait_state_s <= '0';
    else
      if (clk_i'event and clk_i = '1') then
      
        case tse_cfg_state_r is
        
          when TRIGGER_DELAY_5MS =>
            delay_5ms_start_s <= '1';
            tse_cfg_state_r <= WAIT_FOR_DELAY_5MS_DONE;
            
          when WAIT_FOR_DELAY_5MS_DONE =>
            delay_5ms_start_s <= '0';
            if delay_5ms_done_s = '1' and delay_5ms_start_s = '0' then
              tse_cfg_state_r <= TSEMAC_SET_MDIO_ADDR0;
            end if;
            
          when TSEMAC_SET_MDIO_ADDR0 =>
            tse_cfg_o.tse_cfg_write     <= '1';
            wait_state_s <= '1';
            -- Mdio Address 0 Register (0x0F)
            --tse_cfg_o.tse_cfg_address   <= "0000111100";
            tse_cfg_o.tse_cfg_address   <= "0000111100";
            -- Phy address (cf phy hardware configuration CONFIG0 and CONFIG1)
            tse_cfg_o.tse_cfg_writedata <= X"00000012";
            
            if tse_cfg_waitrequest_s = '0' and wait_state_s = '1' then
              tse_cfg_o.tse_cfg_write     <= '0';
              wait_state_s <= '0';
              tse_cfg_state_r <= TSEMAC_SET_MDIO_REG_20;
            else
              tse_cfg_o.tse_cfg_write     <= '1';
            end if;
          
          when TSEMAC_SET_MDIO_REG_20 => 
            tse_cfg_o.tse_cfg_write     <= '1';
            wait_state_s <= '1';
            -- Mdio Space 0 (0x80) - Register 20 (0x14)
            --tse_cfg_o.tse_cfg_address   <= "1001010000";
            tse_cfg_o.tse_cfg_address   <= "1001010000";
            tse_cfg_o.tse_cfg_writedata <= X"000006E8";
            
            if tse_cfg_waitrequest_s = '0' and wait_state_s = '1' then
              tse_cfg_o.tse_cfg_write     <= '0';
              wait_state_s <= '0';
              tse_cfg_state_r <= TSEMAC_SET_MDIO_REG_27;
            else
              tse_cfg_o.tse_cfg_write     <= '1';
            end if;
          
          when TSEMAC_SET_MDIO_REG_27 => 
            tse_cfg_o.tse_cfg_write     <= '1';
            wait_state_s <= '1';
            -- Mdio Space 0 (0x80) - Register 27 (0x1B)
            --tse_cfg_o.tse_cfg_address   <= "1001101100";
            tse_cfg_o.tse_cfg_address   <= "1001101100";
            tse_cfg_o.tse_cfg_writedata <= X"0000808B";
            
            if tse_cfg_waitrequest_s = '0' and wait_state_s = '1' then
              tse_cfg_o.tse_cfg_write     <= '0';
              wait_state_s <= '0';
              tse_cfg_state_r <= TSEMAC_SET_MDIO_REG_16;
            else
              tse_cfg_o.tse_cfg_write     <= '1';
            end if;

          when TSEMAC_SET_MDIO_REG_16 => 
            tse_cfg_o.tse_cfg_write     <= '1';
            wait_state_s <= '1';
            -- Mdio Space 0 (0x80) - Register 16 (0x10)
            --tse_cfg_o.tse_cfg_address   <= "1001000000";
            tse_cfg_o.tse_cfg_address   <= "1001000000";
            tse_cfg_o.tse_cfg_writedata <= X"00000018";
            
            if tse_cfg_waitrequest_s = '0' and wait_state_s = '1' then
              tse_cfg_o.tse_cfg_write     <= '0';
              wait_state_s <= '0';
              tse_cfg_state_r <= TSEMAC_SET_MDIO_REG_04;
            else
              tse_cfg_o.tse_cfg_write     <= '1';
            end if;

            when TSEMAC_SET_MDIO_REG_04 => 
            tse_cfg_o.tse_cfg_write     <= '1';
            wait_state_s <= '1';
            -- Mdio Space 0 (0x80) - Register 4 (0x04)
            --tse_cfg_o.tse_cfg_address   <= "1000010000";
            tse_cfg_o.tse_cfg_address   <= "1000010000";
            tse_cfg_o.tse_cfg_writedata <= X"00000DE1";
            
            if tse_cfg_waitrequest_s = '0' and wait_state_s = '1' then
              tse_cfg_o.tse_cfg_write     <= '0';
              wait_state_s <= '0';
              tse_cfg_state_r <= TSEMAC_SET_MDIO_REG_00;
            else
              tse_cfg_o.tse_cfg_write     <= '1';
            end if;
            
          when TSEMAC_SET_MDIO_REG_00 => 
            tse_cfg_o.tse_cfg_write     <= '1';
            wait_state_s <= '1';
            -- Mdio Space 0 (0x80) - Register 0 (0x00)
            --tse_cfg_o.tse_cfg_address   <= "1000000000";
            tse_cfg_o.tse_cfg_address   <= "1000000000";
            tse_cfg_o.tse_cfg_writedata <= X"00009140";
            
            if tse_cfg_waitrequest_s = '0' and wait_state_s = '1' then
              tse_cfg_o.tse_cfg_write     <= '0';
              wait_state_s <= '0';
              tse_cfg_state_r <= TSEMAC_SET_CMD_CONFIG;
            else
              tse_cfg_o.tse_cfg_write     <= '1';
            end if;
            
          when TSEMAC_SET_MDIO_REG_25 => 
            tse_cfg_o.tse_cfg_write     <= '1';
            wait_state_s <= '1';
            -- Mdio Space 0 (0x80) - Register 25 (0x19)
            --tse_cfg_o.tse_cfg_address   <= "1001100100";
            tse_cfg_o.tse_cfg_address   <= "1001100100";
            tse_cfg_o.tse_cfg_writedata <= X"0000FFFF";
            
            if tse_cfg_waitrequest_s = '0' and wait_state_s = '1' then
              tse_cfg_o.tse_cfg_write     <= '0';
              wait_state_s <= '0';
              tse_cfg_state_r <= TSEMAC_SET_CMD_CONFIG;
            else
              tse_cfg_o.tse_cfg_write     <= '1';
            end if;
                       
          when TSEMAC_SET_CMD_CONFIG => 
            tse_cfg_o.tse_cfg_write     <= '1';
            wait_state_s <= '1';
            --tse_cfg_o.tse_cfg_address   <= "0000001000";
            tse_cfg_o.tse_cfg_address   <= "0000001000";
            tse_cfg_o.tse_cfg_writedata <= X"0400001B";
            
            if tse_cfg_waitrequest_s = '0' and wait_state_s = '1' then
              tse_cfg_o.tse_cfg_write     <= '0';
              wait_state_s <= '0';
              tse_cfg_state_r <= IDLE;
            else
              tse_cfg_o.tse_cfg_write     <= '1';
            end if;
              
          when IDLE => 
            tse_cfg_o.tse_cfg_write     <= '0';
            wait_state_s           <= '0';
            -- Release Global Reset
            tse_cfg_o.tse_cfg_rst      <= '0';
            tse_cfg_state_r <= IDLE;
            
          when others =>
            tse_cfg_state_r <= TRIGGER_DELAY_5MS;
            
        end case;
      end if;
    end if;  
  end process;
  
  delay_5ms_pending_s <= not delay_5ms_done_s;
  
  -- 5.24ms Delay (cf. Reset Timing Marvell Datasheet p.207 fig. 43) 
  COUNTER_DELAY_RST_TO_WR_INST : counter
    generic map (
      COUNTER_SIZE => 8--18
      )
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      data_to_load_i  => (others => '1'),
      count_enable_i  => delay_5ms_pending_s,
      load_enable_i   => delay_5ms_start_s,
      up_down_i       => '0',
      counter_value_o => open,
      zero_flag_o     => delay_5ms_done_s
      );
      
end tse_config_arc;