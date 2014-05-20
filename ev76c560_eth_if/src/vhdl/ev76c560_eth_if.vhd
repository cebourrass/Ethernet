library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.ticks_generator_pack.all;

entity ev76c560_eth_if is
  port (
	-- clock
	clk_i					: in	std_logic;
	-- reset
	rst_i					: in 	std_logic;
	-- Ethernet
	pixel_read_i			: in 	std_logic;
	udp_send_video_line_o	: out 	std_logic;
	pixel_ready_o			: out 	std_logic;
	pixel_o					: out	std_logic_vector(31 downto 0);
	-- mémoire
	start_read_i			: in	std_logic;
	data_i					: in	std_logic_vector(15 downto 0);
	eof_o					: out	std_logic;
	mem_addr_o				: out	std_logic_vector(19 downto 0);
	-- ticks
	ticks_i					: in ticks_t
  );
end ev76c560_eth_if;

architecture be_ev76c560_eth_if of ev76c560_eth_if is
	
	constant NUM_PIX_LINE	: positive:=512;
	constant NUM_LINE		: positive:=512;
	signal data_s			: std_logic_vector(15 downto 0):=(others => '0');
	signal data_r			: std_logic_vector(15 downto 0):=(others => '0');
	signal cpt_lgn			: std_logic_vector(9 downto 0):=(others => '0');
	signal cpt_pix			: std_logic_vector(8 downto 0):=(others => '0');
	signal cpt_raz			: std_logic:='0';
	signal cpt_pix_raz		: std_logic:='0';
	signal send_en			: std_logic:='0';
	-- signal pixel_ready_s	: std_logic:='0';
	
begin
	
	-- if cpt_pix=0 then
		-- data_s <= cpt_lgn(7 downto 0) & X"0000000" & cpt_lgn(8);
	-- else
		-- data_s <= data_i;
	-- end if;
	data_s <= data_i(7 downto 0) & data_i(7 downto 0);

	mem_addr_o <= "0" & cpt_lgn & cpt_pix(8 downto 0);
	
	-- pixel_ready_o <= pixel_ready_s;
	
	-- Process de contrôle :
	CTRL_PROC : process(clk_i,rst_i)
	begin
		if rst_i='1' then
			udp_send_video_line_o <= '0';
			eof_o <= '0';
			cpt_raz <= '1';
			pixel_ready_o <= '0';
			send_en <= '0';
		else
			if clk_i'event and clk_i='1' then
				if start_read_i='1' then
					if ticks_i.ticks_100us='1' then
						udp_send_video_line_o <= '1';
						cpt_pix_raz <= '1';
						cpt_raz <= '0';
						send_en <= '1';
					else
						udp_send_video_line_o <= '0';
						cpt_pix_raz <= '0';
					end if;
					if cpt_pix(0)='0' and send_en='1' then
						pixel_ready_o <= '1';
					elsif pixel_read_i='1' then
						pixel_ready_o <= '0';
					end if;
					if cpt_pix=NUM_PIX_LINE/2-1 then
						send_en <= '0';
					end if;
					if cpt_lgn=NUM_LINE then
						eof_o <= '1';
						pixel_ready_o <= '0';
						send_en <= '0';
						cpt_raz <= '1';
					end if;
					-- if pixel_read_i='1' then
						-- if cpt_pix=0 then
							-- cpt_en <= '1';
							-- cpt_raz <= '0';
						-- else
							-- pixel_ready_s <= not pixel_ready_s;
						-- end if;
					-- elsif cpt_lgn=NUM_LINE-1 then
						-- eof_o <= '1';
						-- pixel_ready_s <= '0';
						-- cpt_en <= '0';
						-- cpt_raz <= '1';
					-- else
						-- cpt_en <= '0';
						-- pixel_ready_s <= '0';
					-- end if;
				else
					eof_o <= '0';
				end if;	
			end if;
		end if;
	end process;
	
	-- Process de changement de taille de data :
	
	-- pixel_o <= data_r & data_s;
	
	--data_s(15 downto 8) <= data_s(7 downto 0);
	
	DATA_PACK_PROC : process(clk_i)
	begin
		pixel_o <= data_r & data_s;
		if clk_i'event and clk_i='1' then
			if cpt_pix=0 then
				data_r <= cpt_lgn(7 downto 0) & "0000000" & cpt_lgn(8);
			elsif cpt_pix(0)='0' then 
				data_r <= data_s;
			end if;
		end if;
	end process;
	
	-- Process de génération des addresses :
	GEN_ADDR_PROC : process(clk_i,rst_i)
	begin
		if rst_i='1' then
			cpt_lgn <= (others => '0');
			cpt_pix <= (others => '0');
		else
			if clk_i'event and clk_i='1' then
				if cpt_raz='1' then
					cpt_lgn <= (others => '0');
					cpt_pix <= (others => '0');
				else
					if cpt_pix_raz='1' then
						cpt_pix <= (others => '0');
					end if;
					if cpt_pix(0)='0' then
						cpt_pix <= cpt_pix + 1;
						if cpt_pix=NUM_PIX_LINE/2-1 then
							cpt_lgn <= cpt_lgn + 1;
							cpt_pix <= (others => '0');
						end if;
					end if;
					if cpt_pix(0)='1' and pixel_read_i='1' then
						cpt_pix <= cpt_pix + 1;
						if cpt_pix=NUM_PIX_LINE/2-1 then
							cpt_lgn <= cpt_lgn + 1;
							cpt_pix <= (others => '0');
						end if;
					end if;
				end if;
			end if;
		end if;	
	end process;

end be_ev76c560_eth_if;



