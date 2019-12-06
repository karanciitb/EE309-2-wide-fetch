library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions

entity queue is
  generic (
      DATA_WIDTH : integer := 59;
      ADDR_WIDTH : integer := 2
    );
  port (
    clk,rst,rd_en,wr_en : in std_logic;
    data_in1,data_in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out1,data_out2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
    empty,full : out std_logic
  );
end queue;

architecture queue_arc of queue is
  constant RAM_DEPTH :integer := 2**ADDR_WIDTH;
  signal wr_pointer : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rd_pointer : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal status_cnt,zeroo : std_logic_vector(ADDR_WIDTH downto 0) := (others=> '0');
  signal fullvar: std_logic;
  type regarray is array (RAM_DEPTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal FIFO: regarray := (others => (others=>'0'));
begin
  fullvar <= '1' when (status_cnt=(RAM_DEPTH)) else '0';
  full <= fullvar;
  empty <= '1' when (status_cnt=zeroo) else '0';
  data_out1 <= FIFO(conv_integer(rd_pointer));
  data_out2 <= FIFO(conv_integer(rd_pointer)+1);
pointers : process (rst, clk)
variable wr_pointer_var,rd_pointer_var : std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
  if (rising_edge(clk)) then
    if (rst = '1') then
    wr_pointer <= (others=>'0');
    rd_pointer <= (others=>'0');
    else
    wr_pointer_var := wr_pointer;
    rd_pointer_var := rd_pointer;
    if (wr_en = '1' and (fullvar='0' or (fullvar='1' and rd_en='1'))) then
      FIFO(conv_integer(wr_pointer_var)) <= data_in1;
      FIFO(conv_integer(wr_pointer_var)+1) <= data_in2;
      wr_pointer_var := std_logic_vector(unsigned(wr_pointer_var)+2);
    else
      wr_pointer_var:= wr_pointer_var;
    end if;
    if (rd_en = '1') then
      rd_pointer_var := std_logic_vector(unsigned(rd_pointer_var)+2);
    else
      rd_pointer_var:= rd_pointer_var;
    end if;
    wr_pointer <= wr_pointer_var;
    rd_pointer <= rd_pointer_var;
  end if;
  end if;
end process pointers;

STATUS : process (rst, clk)
variable status_cntvar:std_logic_vector(ADDR_WIDTH downto 0);
begin
  status_cntvar:=status_cnt;
  if (rising_edge(clk)) then
    if (rst = '1') then
    status_cnt <= (others => '0');
    else
    if (rd_en='1' and wr_en='1') then
      status_cntvar := status_cntvar;
    elsif (rd_en='1') then
      status_cntvar := std_logic_vector(unsigned(status_cntvar)-2);
    elsif (wr_en='1' and fullvar='0') then
      status_cntvar := std_logic_vector(unsigned(status_cntvar)+2);
    else 
      status_cntvar := status_cntvar;
    end if;
  status_cnt <= status_cntvar;
end if;
end if;
end process STATUS;
end queue_arc;