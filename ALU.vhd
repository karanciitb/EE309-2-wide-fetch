library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(
		A, B       : in    std_logic_vector(15 downto 0); -- ALU inputs
		Y          : out   std_logic_vector(15 downto 0); -- ALU output 
		ALU_opcode : in    std_logic; -- Operation Code as in table above
		Z_var      : out   std_logic;   -- Zero flag
		C_var      : out   std_logic    -- Carry flag
	);
end entity ALU;

architecture behave of ALU is
	signal S0,op	      : std_logic_vector(15 downto 0);
begin
	ADDER: entity work.ADDER_16 port map(A,B,S0,C_var);
	op <= S0 when alu_opcode='0'
	 else (A NAND B);
	Z_var <= not (op(0) or op(1) or op(2) or op(3) or op(4) or op(5) or op(6) or op(7) or op(8) or op(9) or op(10) or op(11) or op(12) or op(13) or op(14) or op(15));
	Y <= op;
end architecture behave;
