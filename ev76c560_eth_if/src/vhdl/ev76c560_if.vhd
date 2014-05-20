
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ev76c560_if_pack.all;
use work.spi_master_if_pack.all;
use work.reset_generator_pack.all;
--use work.ticks_generator_pack.all;

entity ev76c560_if is
  port (
    clk_i              : in   std_ulogic;                    -- System clock
    -- Reset system
    rst_i              : in  ev76c560_rst_m2s_t;
    rst_o              : out ev76c560_rst_s2m_t;
    -- 
    clk_ev76c560_ref_i : in   std_ulogic;                    -- Image sensor clock
    --ticks_i            : in   ticks_t;                       -- Ticks for time count
    -- Image sensor interface
    clk_ref_o          : out  std_ulogic;                    -- Reference clock
    clk_fix_o          : out  std_ulogic;                    -- Clock
    reset_n_o          : out  std_ulogic;                    -- Sensor reset
    trig_o             : out  std_ulogic;                    -- Acquisition trig.    
    data_clk_i         : in   std_ulogic;                    -- Data clock
    fen_i              : in   std_ulogic;                    -- Vertical synch.
    len_i              : in   std_ulogic;                    -- Horizontal sync.
    flo_i              : in   std_ulogic;                    -- Illumination ctrl
    data_i             : in   std_logic_vector(9 downto 0);  -- Pixel data bus
    -- User interface
    usr_bus_i          : in  user_bus_i_t;
    usr_bus_o          : out user_bus_o_t;
    -- Spi mater interface
    spi_chan_i         : out spi_chan_i_t;
    spi_chan_o         : in  spi_chan_o_t
	
  );
end ev76c560_if;

architecture ev76c560_if_arc of ev76c560_if is

  type fsm_seq_state_t is (UNKNOWN_0, UNKNOWN_1, STANDBY_0, STANDBY_1, 
                                                  STANDBY_2, WAKE_UP, IDLE, INTEGRATION, READOUT);
  
  type fsm_cfg_state_t is (RESET, CHAN_REQ, INIT_0, INIT_0_DONE, INIT_1,INIT_1_DONE,INIT_1_1,INIT_1_1_DONE,INIT_2,
									 INIT_2_DONE,INIT_2_2,INIT_2_2_DONE, INIT_3,INIT_3_DONE,INIT_4, 
									 INIT_4_DONE,INIT_4_2, INIT_4_2_DONE,INIT_5,INIT_5_DONE,INIT_5_1,INIT_5_1_DONE,INIT_6, 
									 INIT_6_DONE,INIT_6_1,INIT_6_1_DONE,INIT_7, INIT_7_DONE,INIT_8, INIT_8_DONE,INIT_8_1, INIT_8_1_DONE,
									 INIT_9, INIT_9_DONE,INIT_10, INIT_10_DONE,CHAN_REL, IDLE);
  
  signal fsm_cfg_state_r : fsm_cfg_state_t;
  signal fsm_seq_state_r : fsm_seq_state_t;
  signal data_wr_s : std_logic:='1';
  
  signal cfg_start_s : std_logic;
  signal cfg_done_s  : std_logic;
  signal ready       : std_logic:='0';
  signal pix_counter_w :integer range 0 to 512*512:=0;
 -- signal line_counter_w :integer range 0 to 8:=0;
  signal data_tp       :std_logic_vector(9 downto 0); 
  signal first_l        :std_logic;
  signal shift_time :integer range 0 to 200 :=0;  
  signal wrclk_i  : std_logic;
  begin

-- **************** wait for 10 us between two state ********************
shift: process (clk_i,rst_i.rst)
begin 
  if rst_i.rst ='1'then 
                  ready <='0';
					  shift_time<=0;
					  
  elsif (clk_i'event and clk_i='1') then
      if shift_time < 200 then
			        ready <='0';
					  shift_time<=shift_time +1;
					  
				else 
				      ready <='1';
						shift_time<=0;
						
			  end if ;
	end if;

		end process shift;
  wrclk_i<=not(data_clk_i);
  data_wr_s <= not len_i;
  data_tp<=b"00"&data_i(9 downto 2);
  -- Clk_ref comes from pll
  clk_ref_o <= clk_ev76C560_ref_i;
  --clk_fix_o <= '0';   ***************used
    
  --! Configuration process
  CONFIGURE_PROC : process(clk_i, rst_i.rst)
  begin
    if rst_i.rst='1' then
      rst_o.rst_done <= '0';
      rst_o.rst_status <= NO_ERROR;
      fsm_cfg_state_r <= RESET;
      cfg_done_s <='0';
      spi_chan_i.mode <= '0';
      spi_chan_i.req <= '0';
      spi_chan_i.rel <= '0';
      spi_chan_i.go <= '0';
      spi_chan_i.burst <= '0';
      spi_chan_i.paddr <= SPI_PERIPH_0;
      spi_chan_i.data <= (others => '0');
    else
      if clk_i'event and clk_i='1' then
        case fsm_cfg_state_r is
          when RESET =>
            -- Wait for IDLE state
            if fsm_seq_state_r=IDLE then
              fsm_cfg_state_r <= CHAN_REQ;
            end if;
          when CHAN_REQ => 
            spi_chan_i.req <= '1';
            if spi_chan_o.ack = '1' then
              spi_chan_i.req <= '0';
              fsm_cfg_state_r <= INIT_0;
            end if;
				-- 8 bits reg access*************************************************
				--************** no burst mode in reg0 (0) /8 bit reg  800000********
			when INIT_0 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '1';
            spi_chan_i.data <= X"800000"; -- the 8 in msb is used when writing$
				fsm_cfg_state_r <= INIT_0_DONE; 
 
			--***********************************************************************
          when INIT_0_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_1;  
            end if; 
        --**************  reg_soft_reset just read or write any things /8 bit reg *
			when INIT_1 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '1';
            spi_chan_i.data <= X"810000"; -- the 8 in msb is used when writing$
				fsm_cfg_state_r <= INIT_1_DONE; 
 
			--***********************************************************************
          when INIT_1_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_2;  
            end if; 
          -- 16-bit register access*********************************************** 
			 --------------------- pattern test -----------------------------------
         when INIT_1_1 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"870A21"; 
				fsm_cfg_state_r <= INIT_1_1_DONE; 
 
			--***********************************************************************
          when INIT_1_1_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_2;  
            end if; 		
	  ---------------------------------------- end pattern-------------------------

	
			 -------------------  timing conf --------------------------------------- 
			 --**************** adc clock , chan clock from pll ********************* 
			 --*****************X"885321"********** clk_ctrl= 57mhz/clk_fix=114mhz***
          when INIT_2 => 
            spi_chan_i.go <= '1';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"885331";        --  2: adc_clk from clk_fix 
            fsm_cfg_state_r <= INIT_2_DONE;      -- div_ctrl , div_chan : 3 1  
          when INIT_2_DONE => 
            spi_chan_i.go <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <=INIT_2_2;  
            end if;
         
			
			 --************* pll E2V config  p=d4 / h6,n=d4 /h1 , m=d16/ h07* 24mhz******** 
			 --************* pll E2V config  p=d4 / h6,n=d6 /h2 , m=d50/ h18   50mhz********  
          when INIT_2_2 => 
            spi_chan_i.go <= '1';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"89611F";        
            fsm_cfg_state_r <= INIT_2_2_DONE;       
          when INIT_2_2_DONE => 
            spi_chan_i.go <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <=INIT_3;  
            end if;
			---------------------end timing conf---------------------------------------
			--********pin trig_o enabled/stdby_rqst desabled/lsb C video mode  enabled *
			when INIT_3 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"8B010C"; 
				fsm_cfg_state_r <= INIT_3_DONE; 
          when INIT_3_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <=INIT_4_2;  
            end if;
				
			--*clk_data is always active not just during the whole acquisition *******
					when INIT_4 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"0B0000";                       
				fsm_cfg_state_r <= INIT_4_DONE; 
			
 
			--***********************************************************************
          when INIT_4_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_4_2;  
            end if;
				
				--------------------------  frame periode          -----------------------
				when INIT_4_2=> 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"8C0000"; -- frame periode in video mode $
				fsm_cfg_state_r <= INIT_4_2_DONE; 
          when INIT_4_2_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <=INIT_5_1;  
            end if;
				
				--*****************************read reg_miscel2 is it in h0A01 state***
					when INIT_5 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"3E0000";                       
				fsm_cfg_state_r <= INIT_5_DONE; 
			
			
 
			--***********************************************************************
          when INIT_5_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_5_1;  
            end if;
			
	     -- ***********image resize to 1024 X 512 from reg_roi1 **********************
		  --**************horizontal width add valu  h0000 @ h12********************
					when INIT_5_1 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"920000";                       
				fsm_cfg_state_r <= INIT_5_1_DONE; 
			
			
 
			--***********************************************************************
          when INIT_5_1_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_6;  
            end if;		  
		  
		--**************line size h0200  d512 @ h13******************************* *******
					when INIT_6 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"930200";                       
				fsm_cfg_state_r <= INIT_6_DONE; 
			
			
 
			--***********************************************************************
          when INIT_6_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_6_1;  
            end if;
				
			--**************first shift colum to 0 **************************** *******
					when INIT_6_1 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"940000";                       
				fsm_cfg_state_r <= INIT_6_1_DONE; 
			
			
 
			--***********************************************************************
          when INIT_6_1_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_7;  
            end if;	
				
				--*********coulum size h0400  d1024 @ h15 *****************************
					when INIT_7 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"950200";                       
				fsm_cfg_state_r <= INIT_7_DONE; 
			
			
 
			--***********************************************************************
          when INIT_7_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_8_1;  -- compression enable skyped
            end if;
	 	--*********just roi 1 will be taken  @ h0A val h0000 *************************
		--------------------enable compression  @ h0A val hxx1x 
					when INIT_8 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"8A0010";                       
				fsm_cfg_state_r <= INIT_8_DONE; 
			
			
 
			--***********************************************************************
          when INIT_8_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <=INIT_8_1;  
            end if;	
			--********* roi 1 integration time   @ h0E val h0200 *************************
					when INIT_8_1 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"8E004D";                        
				fsm_cfg_state_r <= INIT_8_1_DONE; 
			
			
 
			--***********************************************************************
          when INIT_8_1_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_9 ;  
            end if;			
			--********* roi 1 analog and digital gain  @ h11 val h00 00 *************************
					when INIT_9 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"910000";                       
				fsm_cfg_state_r <= INIT_9_DONE; 
			
			
 
			--***********************************************************************
          when INIT_9_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= INIT_10;  
            end if;				
				-------- 10 -> 8 compression function / range_coeff @h06 val hxx5A***    
					when INIT_10 => 
			   spi_chan_i.go <= '1';
				spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            spi_chan_i.data <= X"86D040";                       
				fsm_cfg_state_r <= INIT_10_DONE; 
			
			
 
			--***********************************************************************
          when INIT_10_DONE => 
			   spi_chan_i.go <= '0';
            spi_chan_i.burst <= '0';
            spi_chan_i.mode <= '0';
            if spi_chan_o.done='1' then
              fsm_cfg_state_r <= CHAN_REL;  
            end if;				
				
				
          when CHAN_REL => 
            spi_chan_i.rel <= '1';
            fsm_cfg_state_r <= IDLE;  
          when IDLE => 
            spi_chan_i.rel <= '0';
            rst_o.rst_done <= '1';
            rst_o.rst_status <= NO_ERROr;
          when others =>
            fsm_cfg_state_r <= RESET;
        end case;
      end if;
    end if;
  end process;
 
  --! Sequencer process
  SEQ_PROC : process(clk_i, rst_i.rst)
  begin
    if rst_i.rst='1' then
      fsm_seq_state_r <= UNKNOWN_0;
      reset_n_o <= '0';
      trig_o    <= '0';
    else
      if clk_i'event and clk_i='1' then
        case fsm_seq_state_r is
          when UNKNOWN_0 =>  
            --if ticks_i.ticks_1us='1' then
				if ready = '1' then 
              fsm_seq_state_r <= UNKNOWN_1;
            end if;
          when UNKNOWN_1 =>  
           -- if ticks_i.ticks_1us='1' then
			  if ready = '1' then
               reset_n_o <= '1';
               fsm_seq_state_r <= STANDBY_0;
           end if;
          when STANDBY_0 =>  
           -- if ticks_i.ticks_1ms='1' then
			  if ready = '1' then
               fsm_seq_state_r <= STANDBY_1;
            end if;
          when STANDBY_1 =>  
           -- if ticks_i.ticks_1ms='1' then
			  if ready = '1' then
               fsm_seq_state_r <= STANDBY_2;
            end if;
          when STANDBY_2 =>  
           -- if ticks_i.ticks_1ms='1' then
			  if ready = '1' then
               fsm_seq_state_r <= IDLE;
            end if;
          when IDLE =>
               trig_o <= '1';
              -- wait until end of configuration 
              if fsm_cfg_state_r=IDLE then
                fsm_seq_state_r <= INTEGRATION;
              end if;
          when INTEGRATION =>  
            if fen_i='0' then
               trig_o <= '0';
               fsm_seq_state_r <= READOUT;
            end if;            
          when READOUT =>  
            if fen_i='1' then
               fsm_seq_state_r <= IDLE;
            end if;
          when others =>
            fsm_seq_state_r <= UNKNOWN_0;
        end case;
      end if;
    end if;
  end process;

end ev76c560_if_arc;