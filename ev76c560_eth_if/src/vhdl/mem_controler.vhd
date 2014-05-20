library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY std;

entity mem_controler is 
port(
		data_clk	  :		in std_logic;
		data_i		  :		in std_logic_vector(9 downto 0);
		fen			  :		in std_logic;
		len			  :		in std_logic;
		rst			  :		in std_logic:='0';
		--------------memory  interface ---------------------------
		  mem1_ce_n_o	  :		out std_logic	:='1';					
		  mem1_oe_n_o	  :     out std_logic	:='1';
        mem1_we_n_o	  :     out std_logic;
        mem1_addr_o	  :		out std_logic_vector(19 downto 0) :=x"00000";
        mem1_data_io  :		inout std_logic_vector(15 downto 0);
		--------------usb 	interface  -----------------------------
		usb_data	   : 	out  std_logic_vector(15 downto 0);
		usb_mem_addr: 	in std_logic_vector(19 downto 0):=x"00000";
		usb_start_rd:	out  std_logic:='0';
		usb_eof		:	in std_logic:='1';
		-------------------test------------------------------------
		start_led	:	out std_logic
	);	
	end mem_controler;
architecture rtl of mem_controler is 

type state_control is (init,start,mem_wr,mem_rd);
signal mem_state : state_control	:= init;

signal 		int_mem_add		:	std_logic_vector(19 downto 0):=x"00000";
signal 		int_mem_data	:	std_logic_vector(15 downto 0);
signal 		mem_usb_select	:	std_logic := '1';
signal 		int_we_n			:	std_logic;
signal		start_s 			:	std_logic:='0';
signal		count_tp			:	integer range 0 to 640*640  :=0;

begin 
			--mem1_ce_n_o    <= '0';
			--mem1_oe_n_o		<= '0';
			mem1_we_n_o		<= int_we_n;
			mem1_addr_o		<= int_mem_add when mem_usb_select= '1' else usb_mem_addr;
			mem1_data_io	<= int_mem_data when mem_usb_select= '1' else (others => 'Z');
			usb_data		   <= mem1_data_io;
			usb_start_rd   <= not(mem_usb_select) ;
			start_led		<=start_s;
--			start_s<= not fen ;
--			mem1_ce_n_o    <= ce_i; 
			
start_detection: process (data_clk,rst)
			begin 
			if rst='1' then 
					count_tp			<=	0;
				   start_s			<='0';
				   mem1_ce_n_o    <= '1';
				
			elsif (data_clk'event and data_clk='0') then 
					if fen='0' and len='0' then
						if count_tp <512*512 -1 then 
							count_tp<=count_tp+1; 
							if count_tp = 1 then 
								start_s		<='1';
								mem1_ce_n_o <= '0'; 
							else 
								start_s<='0';
							end if;
						else 
								count_tp<=0; 
						end if;
					end if;
			end if;
			end process start_detection;
			
acquisition:process(data_clk,usb_eof)
		begin
		if( usb_eof = '1')then
			int_mem_add <= (others => '0');
			mem_usb_select<= '1';
			int_we_n		<= '1';
			mem1_oe_n_o		<= '1';
			mem_state		<= init;
		elsif( rising_edge (data_clk) )then
			case mem_state is
				when init =>
					if( start_s = '1' )then
					   int_mem_add	<= (others=>'0');
						mem_state <= start;
					else
						mem_state <= init;
					end if;
					
				when start =>
						int_we_n <= '0';
						mem_state	<= mem_wr;			
					
				when mem_wr =>
					if( len = '0' )then
						if( int_mem_add = std_logic_vector(to_unsigned(0,20)) )then
							int_mem_data<= x"1010";
							int_mem_add	<= int_mem_add + 1;
						elsif( int_mem_add < std_logic_vector(to_unsigned(512*512,20)) )then
							int_mem_add	<= int_mem_add + 1;
							int_mem_data<= x"00"&data_i(9 downto 2);
							mem_state	<= mem_wr;
						else
							mem_state <= mem_rd;
						end if;
					end if;
				
				when mem_rd =>
				   if usb_eof='0' then
					int_we_n 		<= '1';
					mem_usb_select	<= '0';
					mem1_oe_n_o		<= '0';
		         else 
		         int_we_n 		<= '1';
					mem_usb_select	<= '1';
					mem1_oe_n_o		<= '1';
		         mem_state <= init;	
					end if;
			   when others =>
		         int_we_n 		<= '1';
					mem_usb_select	<= '1';
					mem1_oe_n_o		<= '1';
		         mem_state <= init;			
			
			end case;
		end if;
	end process acquisition;
	end rtl;