library ieee;
use ieee.std_logic_1164.all;
package Gates is
	component INVERTER is
		port(A : in std_logic; Y : out std_logic);
	end component INVERTER;

	component AND_2 is
		port(A, B : in std_logic; Y : out std_logic);
	end component AND_2;

	component NAND_2 is
		port(A, B : in std_logic; Y : out std_logic);
	end component NAND_2;

	component OR_2 is
		port(A, B : in std_logic; Y : out std_logic);
	end component OR_2;

	component NOR_2 is
		port(A, B : in std_logic; Y : out std_logic);
	end component NOR_2;

	component XOR_2 is
		port(A, B : in std_logic; Y : out std_logic);
	end component XOR_2;

	component XNOR_2 is
		port(A, B : in std_logic; Y : out std_logic);
	end component XNOR_2;

	component HA is
		port(A, B : in std_logic; S, C : out std_logic);
	end component HA;

	component AND_3
		port(
			A, B, C : in  std_logic;
			Y       : out std_logic
		);
	end component AND_3;

	component NAND_3
		port(
			A, B, C : in  std_logic;
			Y       : out std_logic
		);
	end component NAND_3;

	component NOR_3
		port(
			A, B, C : in  std_logic;
			Y       : out std_logic
		);
	end component NOR_3;

	component OR_3
		port(
			A, B, C : in  std_logic;
			Y       : out std_logic
		);
	end component OR_3;

end package Gates;

library ieee;
use ieee.std_logic_1164.all;
entity INVERTER is
	port(A : in std_logic; Y : out std_logic);
end entity INVERTER;

architecture Equations of INVERTER is
begin
	Y <= not A;
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity AND_2 is
	port(A, B : in std_logic; Y : out std_logic);
end entity AND_2;

architecture Equations of AND_2 is
begin
	Y <= A and B;
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity NAND_2 is
	port(A, B : in std_logic; Y : out std_logic);
end entity NAND_2;

architecture Equations of NAND_2 is
begin
	Y <= not (A and B);
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity OR_2 is
	port(A, B : in std_logic; Y : out std_logic);
end entity OR_2;

architecture Equations of OR_2 is
begin
	Y <= A or B;
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity NOR_2 is
	port(A, B : in std_logic; Y : out std_logic);
end entity NOR_2;

architecture Equations of NOR_2 is
begin
	Y <= not (A or B);
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity XOR_2 is
	port(A, B : in std_logic; Y : out std_logic);
end entity XOR_2;

architecture Equations of XOR_2 is
begin
	Y <= A xor B;
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity XNOR_2 is
	port(A, B : in std_logic; Y : out std_logic);
end entity XNOR_2;

architecture Equations of XNOR_2 is
begin
	Y <= not (A xor B);
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity HA is
	port(A, B : in std_logic; S, C : out std_logic);
end entity HA;

architecture Equations of HA is
begin
	S <= (A xor B);
	C <= (A and B);
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity AND_3 is
	port(A, B, C : in std_logic; Y : out std_logic);
end entity AND_3;

architecture Equations of AND_3 is
begin
	Y <= A and B and C;
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity NAND_3 is
	port(A, B, C : in std_logic; Y : out std_logic);
end entity NAND_3;

architecture Equations of NAND_3 is
begin
	Y <= not (A and B and C);
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity OR_3 is
	port(A, B, C : in std_logic; Y : out std_logic);
end entity OR_3;

architecture Equations of OR_3 is
begin
	Y <= A or B or C;
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity NOR_3 is
	port(A, B, C : in std_logic; Y : out std_logic);
end entity NOR_3;

architecture Equations of NOR_3 is
begin
	Y <= not (A or B or C);
end Equations;

library ieee;
use ieee.std_logic_1164.all;
entity AND_OR is
	port(A1, A2, B : in std_logic; Y : out std_logic);
end entity;

architecture Equations of AND_OR is
	signal temp : std_logic;
begin
	temp <= (A1 and A2);
	Y <= B or temp;
end Equations;

