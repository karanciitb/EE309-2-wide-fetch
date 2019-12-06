library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	port(
		-- Master clock
		clk   : in  std_logic;
		rst: in std_logic;
		-- First read 1
		out1A  : out std_logic_vector(15 downto 0);
		sel1A  : in  std_logic_vector(2 downto 0);
		-- Second read 1
		out1B  : out std_logic_vector(15 downto 0);
		sel1B  : in  std_logic_vector(2 downto 0);
		-- First read 2
		out2A  : out std_logic_vector(15 downto 0);
		sel2A  : in  std_logic_vector(2 downto 0);
		-- Second read 2
		out2B  : out std_logic_vector(15 downto 0);
		sel2B  : in  std_logic_vector(2 downto 0);
		-- Write 1
		write1 : in  std_logic_vector(15 downto 0);
		wSel1  : in  std_logic_vector(2 downto 0);
		wEN1   : in  std_logic;
		-- Write 2
		write2 : in  std_logic_vector(15 downto 0);
		wSel2  : in  std_logic_vector(2 downto 0);
		wEN2   : in  std_logic;
		R7in  : in  std_logic_vector(15 downto 0);
		wR7   : in  std_logic;

		R0	  : out std_logic_vector(15 downto 0);
		R1	  : out std_logic_vector(15 downto 0);
		R2	  : out std_logic_vector(15 downto 0);
		R3	  : out std_logic_vector(15 downto 0);
		R4	  : out std_logic_vector(15 downto 0);
		R5	  : out std_logic_vector(15 downto 0);
		R6	  : out std_logic_vector(15 downto 0);
		R7	  : out std_logic_vector(15 downto 0)
	);
end register_file;

architecture behav of register_file is
	type registerArray is array (0 to 7) of std_logic_vector(15 downto 0);
	signal registers : registerArray;
begin
	out1A  <= registers(to_integer(unsigned(sel1A)));
	out1B  <= registers(to_integer(unsigned(sel1B)));
	out2A  <= registers(to_integer(unsigned(sel2A)));
	out2B  <= registers(to_integer(unsigned(sel2B)));
	R0	<= registers(0);
	R1	<= registers(1);
	R2	<= registers(2);
	R3	<= registers(3);
	R4	<= registers(4);
	R5	<= registers(5);
	R6	<= registers(6);
	R7  <= registers(7);
	regs : process(clk,rst) is
	begin
		if rst='1' then
		forg:	for i in 0 to 7 loop
				registers(i) <= (others => '0');
			end loop;
		elsif rising_edge(clk) then
				if wEN1 = '1' and wEN2='1' and wSel1=wSel2 then
					registers(to_integer(unsigned(wSel1))) <= write2;
				else
					if (wEN1='1') then
						registers(to_integer(unsigned(wSel1))) <= write1;
					end if;
					if (wEN2='1') then
						registers(to_integer(unsigned(wSel2))) <= write2;
					end if;
				end if;
				if wR7 = '1' then
					registers(7) <= R7in;
				end if;
		end if;
	end process;
end behav;