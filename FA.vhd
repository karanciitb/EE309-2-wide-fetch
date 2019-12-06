library ieee;
use ieee.std_logic_1164.all;
use work.Gates.all;

entity FA is
	port(A, B, Cin : in std_logic; S, Cout : out std_logic);
end entity FA;
architecture Struct of FA is
	signal tC, tS, V : std_logic;
begin
	ha1 : HA
		port map(A => A, B => B, S => tS, C => tC);

	a1 : AND_2 port map(A => tS, B => Cin, Y => V);
	o1 : OR_2 port map(A => V, B => tC, Y => Cout);
	x1 : XOR_2 port map(A => tS, B => Cin, Y => S);

end Struct;
