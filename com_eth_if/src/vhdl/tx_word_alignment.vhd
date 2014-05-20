library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity tx_word_alignment is
  port (
    -- System clock
    clk_100mhz_i : in    std_logic;
    -- Reset
    rst_i        : in    std_logic;
    -- Ip_stack Tx Stream         
    ff_tx_ready  : out std_logic;
    ff_tx_data   : in  std_logic_vector(31 downto 0);
    ff_tx_mod    : in  std_logic_vector(1 downto 0);
    ff_tx_sop    : in  std_logic;
    ff_tx_eop    : in  std_logic;
    ff_tx_err    : in  std_logic;
    ff_tx_wren   : in  std_logic;   
    -- ETM TX Stream 
    Tx_mac_wa    : in  std_logic;
    Tx_mac_wr    : out std_logic;
    Tx_mac_data  : out std_logic_vector(31 downto 0);
    Tx_mac_BE    : out std_logic_vector(1 downto 0);
    Tx_mac_sop   : out std_logic;
    Tx_mac_eop   : out std_logic
    );
end tx_word_alignment;

architecture bypass of tx_word_alignment is
begin
ff_tx_ready  <= Tx_mac_wa;
Tx_mac_wr    <= ff_tx_wren;
Tx_mac_data  <= ff_tx_data;
Tx_mac_BE    <= ff_tx_mod;
Tx_mac_sop   <= ff_tx_sop;
Tx_mac_eop   <= ff_tx_eop;
end;

architecture simple_shift of tx_word_alignment is
  signal ff_tx_reg_s     : std_logic_vector(20 downto 0);
begin
  ff_tx_ready               <= Tx_mac_wa;
  Tx_mac_wr                 <= ff_tx_reg_s(20);
  Tx_mac_sop                <= ff_tx_reg_s(19);
  Tx_mac_eop                <= ff_tx_reg_s(18);
  Tx_mac_BE                 <= ff_tx_reg_s(17 downto 16);
  Tx_mac_data(31 downto 16) <= ff_tx_reg_s(15 downto 0);
  Tx_mac_data(15 downto 0)  <= ff_tx_data(31 downto 16);
  
  TX_WORD_ALIGN_PROC : process(clk_100mhz_i, rst_i)    
    begin
      if rst_i='1' then
        ff_tx_reg_s <= (others => '0');
      else
        if clk_100mhz_i'event and clk_100mhz_i='1' then
          if Tx_mac_wa='1' then
            ff_tx_reg_s(20)           <= ff_tx_wren;
            ff_tx_reg_s(19)           <= ff_tx_sop;
            ff_tx_reg_s(18)           <= ff_tx_eop;
            ff_tx_reg_s(17 downto 16) <= ff_tx_mod;
            if ff_tx_wren='1' then
              ff_tx_reg_s(15 downto 0)  <= ff_tx_data(15 downto 0);
            end if;
          end if;
        end if;
      end if;
    end process;
end simple_shift;

architecture regen_1 of tx_word_alignment is

  type fsm_state_t is(
    WAIT_FOR_SOP,
    WAIT_FOR_EOP,
    LAST_PACKET
  );
  attribute enum_encoding : string;
  -- default
  -- gray
  -- sequential
  -- johnson
  -- one-hot
  -- list of values
  attribute enum_encoding of fsm_state_t : type is "gray";   
  signal current_state_r  : fsm_state_t;
  signal next_state_s     : fsm_state_t;
  signal ff_tx_lsw_data_r : std_logic_vector(15 downto 0);
  signal ff_tx_mod_r      : std_logic_vector(1 downto 0);
  signal ff_tx_sop_r      : std_logic;
  signal ff_tx_eop_r      : std_logic;
begin
-------------------------------------------------------------- ff tx latch ---
  DATA_DELAY_PROC : process(clk_100mhz_i, rst_i)
  begin
    if  rst_i='1' then
      ff_tx_lsw_data_r <= (others => '0');
      ff_tx_mod_r      <= (others => '0');
      ff_tx_sop_r      <= '0';
      ff_tx_eop_r      <= '0';
    else
      if clk_100mhz_i'event and clk_100mhz_i='1' then
        if ff_tx_wren='1' then
          ff_tx_lsw_data_r <= ff_tx_data(15 downto 0);
          ff_tx_mod_r      <= ff_tx_mod;
          ff_tx_sop_r      <= ff_tx_sop;
          ff_tx_eop_r      <= ff_tx_eop;
        end if;
      end if;
    end if;
  end process;
  
  -- Build data word
  Tx_mac_data <= ff_tx_lsw_data_r & ff_tx_data(31 downto 16);
  Tx_mac_sop  <= ff_tx_sop_r;
  
-------------------------------------------- Finite state machine register ---
-- Register
  FSM_SYNC_PROC : process(clk_100mhz_i, rst_i)
  begin
    if  rst_i='1' then
      current_state_r <= WAIT_FOR_SOP;
    else
      if clk_100mhz_i'event and clk_100mhz_i='1' then
        current_state_r <= next_state_s;
      end if;
    end if;
  end process;
  
-- Next state logic
  next_state_s <= 
    WAIT_FOR_SOP when
      ( current_state_r = LAST_PACKET and
          Tx_mac_wa='1' ) or
      ( current_state_r = WAIT_FOR_EOP and
          ff_tx_wren='1' and
          ff_tx_eop = '1' and
          (ff_tx_mod="01" or ff_tx_mod="10"))
    else WAIT_FOR_EOP when
      current_state_r = WAIT_FOR_SOP and
        ff_tx_wren ='1' and 
        ff_tx_sop = '1'
    else LAST_PACKET   when
      current_state_r = WAIT_FOR_EOP and
        ff_tx_wren='1' and
        ff_tx_eop = '1' and
        (ff_tx_mod="11" or ff_tx_mod="00")
    else current_state_r;

-- Moore output logic
-- Mealy output logic
  ff_tx_ready <=
    '1' when
      current_state_r = WAIT_FOR_SOP or
      ( current_state_r = WAIT_FOR_EOP and Tx_mac_wa='1')
    else '0';
    
  Tx_mac_wr <= 
    '1' when
      (current_state_r = WAIT_FOR_EOP and
        ff_tx_wren='1' and
        Tx_mac_wa='1' ) or
      (current_state_r = LAST_PACKET and
        Tx_mac_wa='1' )
    else 
      '0';
        
  Tx_mac_eop <= 
    '1' when
      (current_state_r = WAIT_FOR_EOP and
        ff_tx_eop_r='1') or
      current_state_r = LAST_PACKET
    else
      '0';

  Tx_mac_BE <= 
    ff_tx_mod_r when
      current_state_r = WAIT_FOR_EOP
    else ff_tx_mod_r-std_logic_vector(to_unsigned(2,2)) when
      current_state_r = LAST_PACKET
    else
      std_logic_vector(to_unsigned(0,2));
      
end regen_1;