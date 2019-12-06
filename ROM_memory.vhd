library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM_memory is
	port(address     : in  std_logic_vector(15 downto 0);
	     Mem_dataout1,Mem_dataout2 : out std_logic_vector(15 downto 0));
end entity;

architecture Form of ROM_memory is
	type regarray is array (0 to 129) of std_logic_vector(15 downto 0);
	signal Memory : regarray := (
		x"6055",
		"0011001111111111",	--0
		"0001001001111111",	--1
						"0011010000000001",	--2
						"0000001010011010",	--3
						"0011100000000000", --4
						"0100101100000001",	--5
						"0000101010100000",	--6
						"0010011100010000",	--7
						"0011011111011010",	--8
						"1100010011000010",	--9
						"0011011000000000",	--A
						"0000011100010000",	--B
						"0010010010001000",	--C
						"0010010001001001",	--D
						"1000011000000010",	--E
						"0011011000000000",	--F
						"0000010001001000",	--10
						"0000011001011010",	--11
						"0011000000000000",	--12
						"0001000000010110",	--13
						"1001110000000000",	--14
						"0010110110110010",	--15
						"0010110001110010",	--16
						"0010110001110000",	--17
						"0011000000000000",	--18
						"0011110001101000",	--19
						"0001110110000001",	--1A
						"0101110000011100",	--1B
						"0011010000000001",	--1C
						"0000010000001000",	--1D
						"0110000001000100",	--1E
						"0000010110010000",	--1F
						"0000010110110000",	--20
						"0011010000001000",	--21
						"0001010010001000",	--22
						"0011100000001110",	--23
						"0001100100010000",	--24
						"0001000000011111",	--25
						"0001000000001001",	--26
						"0111000000010100",	--27
						"0011111000000000", --Loop 28
		others => "1111111111111111"
		);
begin
	Mem_dataout1 <= Memory(to_integer(unsigned((address(6 downto 0)))));
	Mem_dataout2 <= Memory(to_integer(unsigned((address(6 downto 0)))) + 1);
--	Mem_dataout1 <= Memory(to_integer(unsigned((address))));
--	Mem_dataout2 <= Memory(to_integer(unsigned((address))) + 1);
end Form;