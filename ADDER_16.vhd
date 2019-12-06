library ieee;
use ieee.std_logic_1164.all;
entity ADDER_16 is 
port(
	A,B : in std_logic_vector(15 downto 0);
	Y: out std_logic_vector(15 downto 0);
	Cout: out std_logic
);
end entity ADDER_16;

architecture struct of addER_16 is
signal C: std_logic_vector(14 downto 0);
begin
ha1: entity work.HA port map(A(0),B(0),Y(0),C(0)); 
fa1: entity work.FA port map(A(1),B(1),C(0),Y(1),C(1));
fa2: entity work.FA port map(A(2),B(2),C(1),Y(2),C(2));
fa3: entity work.FA port map(A(3),B(3),C(2),Y(3),C(3));
fa4: entity work.FA port map(A(4),B(4),C(3),Y(4),C(4));
fa5: entity work.FA port map(A(5),B(5),C(4),Y(5),C(5));
fa6: entity work.FA port map(A(6),B(6),C(5),Y(6),C(6));
fa7: entity work.FA port map(A(7),B(7),C(6),Y(7),C(7));
fa8: entity work.FA port map(A(8),B(8),C(7),Y(8),C(8));
fa9: entity work.FA port map(A(9),B(9),C(8),Y(9),C(9));
fa10: entity work.FA port map(A(10),B(10),C(9),Y(10),C(10));
fa11: entity work.FA port map(A(11),B(11),C(10),Y(11),C(11));
fa12: entity work.FA port map(A(12),B(12),C(11),Y(12),C(12));
fa13: entity work.FA port map(A(13),B(13),C(12),Y(13),C(13));
fa14: entity work.FA port map(A(14),B(14),C(13),Y(14),C(14));
fa15: entity work.FA port map(A(15),B(15),C(14),Y(15),Cout); -- @suppress "Positional association should not be used, use named association instead"
end struct;