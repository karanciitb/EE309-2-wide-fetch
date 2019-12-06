library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity RAM_data is
	port(address, RAM_datain : in  std_logic_vector(15 downto 0);
	     clk,rst,RAM_wr      : in  std_logic;
	     RAM_dataout         : out std_logic_vector(15 downto 0));
end entity;

architecture Form of RAM_data is
	type regarray is array (0 to 1023) of std_logic_vector(15 downto 0);
	signal Memory : regarray := (x"0001",x"0003",x"0005",x"000a",others => x"0000");
begin
	RAM_dataout <= Memory(conv_integer(address(9 downto 0)));
	--RAM_dataout <= Memory(conv_integer(address));
	Mem_write : process(RAM_wr, clk)
	begin
		if (RAM_wr = '1') then
			if (rising_edge(clk)) then
				Memory(conv_integer(address(9 downto 0))) <= RAM_datain;
				--Memory(conv_integer(address)) <= RAM_datain;
			end if;
		end if;
	end process;
end Form;