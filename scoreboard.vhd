library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
entity scoreboard is
	port (
		clk,rst,wr1,wr2,clr1,clr2 : in std_logic;
		regwr_1,regwr_2,regclr1,regclr2: in std_logic_vector(2 downto 0);
		regA_1,regB_1,regA_2,regB_2: in std_logic_vector(2 downto 0);
		doutA_1,doutB_1,doutA_2,doutB_2: out std_logic
	);
end scoreboard;

architecture scoreboard_arc of scoreboard is
	type regarray is array (0 to 7) of std_logic;
	signal board : regarray := (others => '0');
begin
doutA_1 <= board(conv_integer(regA_1));
doutB_1 <= board(conv_integer(regB_1));
doutA_2 <= board(conv_integer(regA_2));
doutB_2 <= board(conv_integer(regB_2));
proa : process (rst,clk)
variable to_clr1,to_clr2: std_logic;
begin
  to_clr1:='0';
  to_clr2:='0';
  if(clr1='1' and wr1='1' and regclr1=regwr_1) then
    to_clr1:='1';
  end if;
  if(clr1='1' and wr2='1' and regclr1=regwr_2) then
    to_clr1:='1';
  end if;
  if(clr2='1' and wr1='1' and regclr2=regwr_1) then
    to_clr2:='1';
  end if;
  if(clr2='1' and wr2='1' and regclr2=regwr_2) then
    to_clr2:='1';
  end if;
  if (rising_edge(clk)) then
  if (clr1='1') then
  	board(conv_integer(regclr1)) <= to_clr1;
  end if;
  if (clr2='1') then
  	board(conv_integer(regclr2)) <= to_clr2;
  end if;
  if (wr1='1') then 
  	board(conv_integer(regwr_1)) <= '1';
  end if;
  if (wr2='1') then 
  	board(conv_integer(regwr_2)) <= '1';
  end if;
  if (rst = '1') then
    forg: for i in 0 to 7 loop
        board(i) <= '0';
      end loop;
    end if;
  end if;
end process proa;
end scoreboard_arc;