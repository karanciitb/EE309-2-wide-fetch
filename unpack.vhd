library ieee;
use ieee.std_logic_1164.all;

entity unpack is
	generic(width : integer := 59);
	port(
		pack       : in  std_logic_vector(width-1 downto 0);
		PC         : out std_logic_vector(15 downto 0);
		A1         : out std_logic_vector(2 downto 0);
		A2         : out std_logic_vector(2 downto 0);
		Aw         : out std_logic_vector(2 downto 0);
		SE         : out std_logic_vector(15 downto 0);
		SEa        : out std_logic;
		CZ         : out std_logic_vector(1 downto 0);
		ALUop      : out std_logic;
		Cmod       : out std_logic;
		Zmod       : out std_logic;
		opcode     : out std_logic_vector(3 downto 0);
		PCstore    : out std_logic;
		PCcompute  : out std_logic;
		valid      : out std_logic;
		Reg_wr     : out std_logic;
		readA      : out std_logic;
		readB      : out std_logic;
		lmsm_write : out std_logic;
		lmsm_sel   : out std_logic
	);
end unpack;

architecture unpack_arc of unpack is
begin
PC <= pack(58 downto 43);
A1 <= pack(42 downto 40);
A2 <= pack(39 downto 37);
Aw <= pack(36 downto 34);
SE <= pack(33 downto 18);
SEa <= pack(17);
CZ <= pack(16 downto 15);
ALUop <= pack(14);
Cmod <= pack(13);
Zmod <= pack(12);
opcode <= pack(11 downto 8);
PCstore <= pack(7);
PCcompute <= pack(6);
valid <= pack(5);
Reg_wr <= pack(4);
readA <= pack(3);
readB <= pack(2);
lmsm_write <= pack(1);
lmsm_sel <= pack(0);
end unpack_arc;