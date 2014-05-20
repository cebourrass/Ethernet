library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.ticks_generator_pack.all;

entity tb_ev76c560_eth_if is
end tb_ev76c560_eth_if;

architecture be_tb_ev76c560_eth_if of tb_ev76c560_eth_if is

	signal clk_s					: std_logic;
	signal rst_s					: std_logic;
	signal pixel_read_s				: std_logic;
	signal udp_send_video_line_s	: std_logic;
	signal pixel_ready_s			: std_logic;
	signal pixel_s					: std_logic_vector(31 downto 0);
	signal start_read_s				: std_logic;
	signal data_s					: std_logic_vector(15 downto 0);
	signal eof_s					: std_logic;
	signal mem_addr_s				: std_logic_vector(19 downto 0);
	signal ticks_s					: ticks_t;
	signal sync_s					: std_logic;

begin

	uut : entity work.ev76c560_eth_if(be_ev76c560_eth_if)
	port map (
		clk_i 					=> clk_s,
		rst_i 					=> rst_s,
		-- Ethernet
		pixel_read_i			=> pixel_ready_s,
		udp_send_video_line_o	=> udp_send_video_line_s,
		pixel_ready_o			=> pixel_ready_s,
		pixel_o					=> pixel_s,
		-- mémoire
		start_read_i			=> start_read_s,
		data_i					=> data_s,
		eof_o					=> eof_s,
		mem_addr_o				=> mem_addr_s,
		-- ticks
		ticks_i					=> ticks_s
	);
	
	uut1 : entity work.ticks_generator_entity(ticks_generator_arc_1)
	port map (
		clk_i => clk_s,
		rst_i => rst_s,
		sync_i => sync_s,
		ticks_o => ticks_s
	);
	
	data_s <= mem_addr_s(15 downto 0) after 10 ns;
	
	clk_s_process : process 
	begin
		clk_s <= '0';
		wait for 10 ns;
		clk_s <= '1';
		wait for 10 ns;
	end process;
	
	rst_s_process : process
	begin
		rst_s <= '0';
		wait for 50 ns;
		rst_s <= '1';
		wait for 50 ns;
		rst_s <= '0';
		wait;
	end process;
	
	-- ip_stack_process : process
	-- begin
		-- pixel_read_s <='0';
		-- wait until udp_send_video_line_s='1';
		-- wait for 100 ns;
		-- wait until clk_s'event and clk_s='1';
		-- pixel_read_s <= pixel_ready_s;
		-- wait;
		-- wait for 5160 ns;
		-- pixel_read_s <='0';
	-- end process;
	
	mem_controller_process : process
	begin
		start_read_s <= '0';
		wait for 80 ns;
		start_read_s <= '1';
		wait until eof_s='1';
		wait until clk_s'event and clk_s='1';
		start_read_s <= '0';
	end process;
	
		
end be_tb_ev76c560_eth_if;
