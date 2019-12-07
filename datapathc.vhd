library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapathc is
	port(
		clk : in std_logic;
		clk_50 : in std_logic; -- @suppress "Unused port: clk_50 is not used in work.datapathc(datapathc_arc)"
		reset : in std_logic;
		PCout  : out std_logic_vector(15 downto 0);
		R0	  : out std_logic_vector(15 downto 0);
		R1	  : out std_logic_vector(15 downto 0);
		R2	  : out std_logic_vector(15 downto 0);
		R3	  : out std_logic_vector(15 downto 0);
		R4	  : out std_logic_vector(15 downto 0);
		R5	  : out std_logic_vector(15 downto 0);
		R6	  : out std_logic_vector(15 downto 0);
		R7o	  : out std_logic_vector(15 downto 0)
	);
end entity datapathc;
architecture datapathc_arc of datapathc is
	constant ADD: std_logic_vector(3 downto 0) := "0000";
	constant ADI: std_logic_vector(3 downto 0) := "0001";
	constant NND: std_logic_vector(3 downto 0) := "0010";
	constant LHI: std_logic_vector(3 downto 0) := "0011";
	constant LW:  std_logic_vector(3 downto 0) := "0100";
	constant SW:  std_logic_vector(3 downto 0) := "0101";
	constant LM:  std_logic_vector(3 downto 0) := "0110";
	constant SM:  std_logic_vector(3 downto 0) := "0111";
	constant BEQ: std_logic_vector(3 downto 0) := "1100";
	constant JAL: std_logic_vector(3 downto 0) := "1000";
	constant JLR: std_logic_vector(3 downto 0) := "1001";
	constant R7:  std_logic_vector(2 downto 0) := "111";
	signal rst : std_logic;
	signal PC : std_logic_vector(15 downto 0);
	signal Iout1 : std_logic_vector(15 downto 0);
	signal Iout2 : std_logic_vector(15 downto 0);
	signal pc_stop : std_logic;
	signal IF_en : std_logic;
	signal PC_IF : std_logic_vector(15 downto 0);
	signal IR_IF_1 : std_logic_vector(15 downto 0);
	signal IR_IF_2 : std_logic_vector(15 downto 0);
	signal valid_IF_1 : std_logic;
	signal valid_IF_2 : std_logic;
	signal opcode_1 : std_logic_vector(3 downto 0);
	signal opcode_2 : std_logic_vector(3 downto 0);
	signal flush_till_RR_Ex : std_logic;
	signal queue_rst : std_logic;
	signal queue_read : std_logic;
	signal queue_write : std_logic;
	signal queue_full : std_logic;
	signal queue_empty : std_logic;
	signal queue_stall : std_logic;
	signal pack_1_queueout : std_logic_vector(58 downto 0);
	signal pack_2_queueout : std_logic_vector(58 downto 0);
	signal sb_rst : std_logic;
	signal sb_write_after_flush_1 : std_logic;
	signal sb_write_after_flush_2 : std_logic;
	signal sb_wr1 : std_logic;
	signal sb_wr2 : std_logic;
	signal sb_clr1 : std_logic;
	signal sb_clr2 : std_logic;
	signal regwr_1 : std_logic_vector(2 downto 0);
	signal regwr_2 : std_logic_vector(2 downto 0);
	signal PC_ID_1 : std_logic_vector(15 downto 0);
	signal PC_ID_2 : std_logic_vector(15 downto 0);
	signal opcode_ID_1 : std_logic_vector(3 downto 0);
	signal opcode_ID_2 : std_logic_vector(3 downto 0);
	signal A1_ID_1 : std_logic_vector(2 downto 0);
	signal A2_ID_1 : std_logic_vector(2 downto 0);
	signal Aw_ID_1 : std_logic_vector(2 downto 0);
	signal A1_ID_2 : std_logic_vector(2 downto 0);
	signal A2_ID_2 : std_logic_vector(2 downto 0);
	signal Aw_ID_2 : std_logic_vector(2 downto 0);
	signal outA_1 : std_logic_vector(15 downto 0);
	signal outB_1 : std_logic_vector(15 downto 0);
	signal outA_2 : std_logic_vector(15 downto 0);
	signal outB_2 : std_logic_vector(15 downto 0);
	signal sbA_1 : std_logic;
	signal sbB_1 : std_logic;
	signal sbA_2 : std_logic;
	signal sbB_2 : std_logic;
	signal sbC_1 : std_logic;
	signal sbC_2 : std_logic;
	signal sb_stall_1 : std_logic;
	signal sb_stall_2 : std_logic;
	signal write1 : std_logic_vector(15 downto 0);
	signal wSel1 : std_logic_vector(2 downto 0);
	signal wEN1 : std_logic;
	signal write2 : std_logic_vector(15 downto 0);
	signal wSel2 : std_logic_vector(2 downto 0);
	signal wEN2 : std_logic;
	signal PCin : std_logic_vector(15 downto 0);
	signal wPC : std_logic;
	signal dirty : std_logic;
	signal haz_type1 : std_logic;
	signal haz_lw_lm_r7_1 : std_logic;
	signal haz_lw_lm_r7_2 : std_logic;
	signal haz_ex_R7_2 : std_logic;
	signal haz_ex_R7_1 : std_logic;
	signal haz_beq_jal_1 : std_logic;
	signal haz_beq_jal_2 : std_logic;
	signal haz_lhi_R7_1 : std_logic;
	signal haz_lhi_R7_2 : std_logic;
	signal haz_jlr_1 : std_logic;
	signal haz_jlr_2 : std_logic;
	signal haz_jal_jlr_r7_1 : std_logic;
	signal haz_jal_jlr_r7_2 : std_logic;
	signal haz_jal_jlr_r7 : std_logic;
	signal haz_flag_dependency : std_logic;
	signal haz_both_MA : std_logic;
	signal haz_ADZ_LW : std_logic;
	signal haz_interdependence : std_logic;
	signal flush_MA_1 : std_logic;
	signal flush_MA_2 : std_logic;
	signal flush_Ex_1 : std_logic;
	signal flush_Ex_2 : std_logic;
	signal flush_RR_1 : std_logic;
	signal flush_RR_2 : std_logic;
	signal flush_ID_1 : std_logic;
	signal flush_ID_2 : std_logic;
	signal Aw_RR_1 : std_logic_vector(2 downto 0);
	signal SEa_RR_1 : std_logic;
	signal PCstore_RR_1 : std_logic;
	signal valid_RR_1 : std_logic;
	signal Reg_wr_RR_1 : std_logic;
	signal CZ_RR_1 : std_logic_vector(1 downto 0);
	signal ALU_op_RR_1 : std_logic;
	signal Cmod_RR_1 : std_logic;
	signal Zmod_RR_1 : std_logic;
	signal lmsm_sel_RR : std_logic;
	signal lmsm_write_RR : std_logic;
	signal D1_1 : std_logic_vector(15 downto 0);
	signal D2_1 : std_logic_vector(15 downto 0);
	signal PC_RR_1 : std_logic_vector(15 downto 0);
	signal SE_RR_1 : std_logic_vector(15 downto 0);
	signal opcode_RR_1 : std_logic_vector(3 downto 0);
	signal PCcompute_RR_1 : std_logic;
	signal SE_ID_1 : std_logic_vector(15 downto 0);
	signal SEa_ID_1 : std_logic;
	signal PCstore_ID_1 : std_logic;
	signal valid_RRvar_1 : std_logic;
	signal Reg_wr_ID_1 : std_logic;
	signal CZ_ID_1 : std_logic_vector(1 downto 0);
	signal ALUop_ID_1 : std_logic;
	signal Cmod_ID_1 : std_logic;
	signal Zmod_ID_1 : std_logic;
	signal D1var_1 : std_logic_vector(15 downto 0);
	signal D2var_1 : std_logic_vector(15 downto 0);
	signal lmsm_write : std_logic;
	signal lmsm_sel : std_logic;
	signal PCcompute_ID_1 : std_logic;
	signal Aw_RR_2 : std_logic_vector(2 downto 0);
	signal SEa_RR_2 : std_logic;
	signal PCstore_RR_2 : std_logic;
	signal valid_RR_2 : std_logic;
	signal Reg_wr_RR_2 : std_logic;
	signal CZ_RR_2 : std_logic_vector(1 downto 0);
	signal ALU_op_RR_2 : std_logic;
	signal Cmod_RR_2 : std_logic;
	signal Zmod_RR_2 : std_logic;
	signal D1_2 : std_logic_vector(15 downto 0);
	signal D2_2 : std_logic_vector(15 downto 0);
	signal PCcompute_RR_2 : std_logic;
	signal opcode_RR_2 : std_logic_vector(3 downto 0);
	signal SEa_ID_2 : std_logic;
	signal PCstore_ID_2 : std_logic;
	signal Reg_wr_ID_2 : std_logic;
	signal CZ_ID_2 : std_logic_vector(1 downto 0);
	signal ALUop_ID_2 : std_logic;
	signal Cmod_ID_2 : std_logic;
	signal Zmod_ID_2 : std_logic;
	signal D1var_2 : std_logic_vector(15 downto 0);
	signal D2var_2 : std_logic_vector(15 downto 0);
	signal PCcompute_ID_2 : std_logic;
	signal valid_RRvar_2 : std_logic;
	signal valid_ID_1 : std_logic;
	signal valid_ID_2 : std_logic;
	signal PC_RR_2 : std_logic_vector(15 downto 0);
	signal SE_RR_2 : std_logic_vector(15 downto 0);
	signal SE_ID_2 : std_logic_vector(15 downto 0);
	signal eq_1 : std_logic;
	signal eq_2 : std_logic;
	signal ALU_A_1 : std_logic_vector(15 downto 0);
	signal ALU_B_1 : std_logic_vector(15 downto 0);
	signal lmsm_next : std_logic_vector(15 downto 0);
	signal ALU_Y_1 : std_logic_vector(15 downto 0);
	signal Z_var_1 : std_logic;
	signal C_var_1 : std_logic;
	signal D_EXvar_1 : std_logic_vector(15 downto 0);
	signal Addr_EXvar_1 : std_logic_vector(15 downto 0);
	signal C_mod_var_1 : std_logic;
	signal Z_mod_var_1 : std_logic;
	signal Reg_wr_Exvar_1 : std_logic;
	signal Z_LWvar : std_logic;
	signal RAMout : std_logic_vector(15 downto 0);
	signal D_EX_1 : std_logic_vector(15 downto 0);
	signal Addr_EX_1 : std_logic_vector(15 downto 0);
	signal Aw_EX_1 : std_logic_vector(2 downto 0);
	signal opcode_EX_1 : std_logic_vector(3 downto 0);
	signal Reg_wr_Ex_1 : std_logic;
	signal supposed_to_write_Ex_1 : std_logic;
	signal valid_EX_1 : std_logic;
	signal valid_EXvar_1 : std_logic;
	signal ALU_A_2 : std_logic_vector(15 downto 0);
	signal ALU_B_2 : std_logic_vector(15 downto 0);
	signal ALU_Y_2 : std_logic_vector(15 downto 0);
	signal Z_var_2 : std_logic;
	signal C_var_2 : std_logic;
	signal D_EXvar_2 : std_logic_vector(15 downto 0);
	signal C_mod_var_2 : std_logic;
	signal Z_mod_var_2 : std_logic;
	signal Reg_wr_Exvar_2 : std_logic;
	signal valid_EX_2 : std_logic;
	signal Reg_wr_Ex_2 : std_logic;
	signal Aw_EX_2 : std_logic_vector(2 downto 0);
	signal supposed_to_write_Ex_2 : std_logic;
	signal D_EX_2 : std_logic_vector(15 downto 0);
	signal Addr_EX_2 : std_logic_vector(15 downto 0);
	signal opcode_EX_2 : std_logic_vector(3 downto 0);
	signal valid_EXvar_2 : std_logic;
	signal lmsm_initial_address : std_logic_vector(15 downto 0);
	signal Cout : std_logic;
	signal Zout : std_logic;
	signal lw_flag_update : std_logic;
	signal C : std_logic;
	signal Z : std_logic;
	signal RAM_address : std_logic_vector(15 downto 0);
	signal RAM_datain : std_logic_vector(15 downto 0);
	signal wRAM : std_logic;
	signal D_MAvar_1 : std_logic_vector(15 downto 0);
	signal valid_MAvar_1 : std_logic;
	signal valid_MA_1 : std_logic;
	signal Reg_wr_MA_1 : std_logic;
	signal supposed_to_write_MA_1 : std_logic;
	signal D_MAvar_2 : std_logic_vector(15 downto 0);
	signal valid_MAvar_2 : std_logic;
	signal valid_MA_2 : std_logic;
	signal Reg_wr_MA_2 : std_logic;
	signal supposed_to_write_MA_2 : std_logic;
	signal pack_1 : std_logic_vector(58 downto 0);
	signal pack_2 : std_logic_vector(58 downto 0);
	signal SE6_1 : std_logic_vector(15 downto 0);
	signal SE6_2 : std_logic_vector(15 downto 0);
	signal valid_ID_var_1 : std_logic;
	signal valid_ID_var_2 : std_logic;
	signal some_sig2 : std_logic_vector(7 downto 0);
	signal lmsm_locations : std_logic_vector(7 downto 0);
	signal temp1 : std_logic_vector(7 downto 0);
	signal temp2 : std_logic_vector(7 downto 0);
	signal temp3 : std_logic_vector(7 downto 0);
	signal temp4 : std_logic_vector(2 downto 0);
	signal some_sig : std_logic;
	signal lmsm_locations_next : std_logic_vector(7 downto 0);
	signal lmsm_run : std_logic;
	signal ID_en : std_logic;
	signal PC_ID_1var : std_logic_vector(15 downto 0);
	signal A1_ID_1var : std_logic_vector(2 downto 0);
	signal A2_ID_1var : std_logic_vector(2 downto 0);
	signal Aw_ID_1var : std_logic_vector(2 downto 0);
	signal SEa_ID_1var : std_logic;
	signal CZ_ID_1var : std_logic_vector(1 downto 0);
	signal ALUop_ID_1var : std_logic;
	signal Zmod_ID_1var : std_logic;
	signal Cmod_ID_1var : std_logic;
	signal opcode_ID_1var : std_logic_vector(3 downto 0);
	signal PCstore_ID_1var : std_logic;
	signal PCcompute_ID_1var : std_logic;
	signal valid_ID_1var : std_logic;
	signal Reg_wr_ID_1var : std_logic;
	signal lmsm_write_1var : std_logic;
	signal lmsm_sel_1var : std_logic;
	signal readA_1var : std_logic;
	signal readB_1var : std_logic;
	signal SE_ID_1var : std_logic_vector(15 downto 0);
	signal lmsm_state : std_logic;
	signal lmsm_stall : std_logic;
	signal pack_1_var : std_logic_vector(58 downto 0);
	signal A1_ID_2var : std_logic_vector(2 downto 0);
	signal A2_ID_2var : std_logic_vector(2 downto 0);
	signal Aw_ID_2var : std_logic_vector(2 downto 0);
	signal SEa_ID_2var : std_logic;
	signal CZ_ID_2var : std_logic_vector(1 downto 0);
	signal ALUop_ID_2var : std_logic;
	signal Cmod_ID_2var : std_logic;
	signal Zmod_ID_2var : std_logic;
	signal opcode_ID_2var : std_logic_vector(3 downto 0);
	signal PCstore_ID_2var : std_logic;
	signal PCcompute_ID_2var : std_logic;
	signal valid_ID_2var : std_logic;
	signal Reg_wr_ID_2var : std_logic;
	signal readA_2var : std_logic;
	signal readB_2var : std_logic;
	signal SE_ID_2var : std_logic_vector(15 downto 0);
	signal PC_ID_2var : std_logic_vector(15 downto 0);
	signal pack_2_var : std_logic_vector(58 downto 0);
	signal readA_1 : std_logic;
	signal readB_1 : std_logic;
	signal readA_2 : std_logic;
	signal readB_2 : std_logic;
	signal unused1 : std_logic; -- @suppress "signal unused1 is never read"
	signal unused2 : std_logic; -- @suppress "signal unused2 is never read"
	signal state,wr7var : std_logic;
	signal PC_Ex,PC_MA : std_logic_vector(15 downto 0);
begin
	PCout <= PC;
	rst <= not reset;
	rom : entity work.ROM_memory
		port map(
			address     => PC,
			Mem_dataout1 => Iout1,
			Mem_dataout2 => Iout2
		);
	PCregister : process (rst, clk)
	begin
	  if (rst = '1') then
	    PC <= x"0000";
	  elsif (rising_edge(clk) and wPC='1') then
		PC <= PCin;
	  end if;
	end process PCregister;
-- Instruction Fetch
	IF_PP : process(clk, rst) is -- @suppress "Incomplete sensitivity list. Missing signals: Iout2(15 downto 12), Iout2, Iout1, Iout1(15 downto 12)"
		variable Iout1var,PCvar: std_logic_vector(15 downto 0);
		variable next_state,pc_stopvar : std_logic:='0';
		variable valid_IF_1var,valid_IF_2var: std_logic := '0';
	begin
		pcvar := PC;
		next_state := state;
		Iout1var:= Iout1;
		valid_IF_1var:='1';
		valid_IF_2var:='1';
		pc_stopvar := '0';
		if (IF_en = '1') then
			case(state) is
				when '0' =>
					if (Iout1(15 downto 13)="011" or Iout2(15 downto 13)="011") then
						next_state:='1';
						valid_IF_2var:='0';
						pc_stopvar := '1';
					end if;
				when '1' =>
					next_state:='0';
					valid_IF_2var:='0';
					Iout1var:=Iout2;
					pc_stopvar := '0';
					pcvar := std_logic_vector(unsigned(PC)+1);
				when others => null;
			end case;
		end if;
			if(flush_till_RR_Ex='1') then
				valid_IF_1var:='0';
				valid_IF_2var:='0';
				pc_stopvar:='0';
			end if;
		if (rst='1') then
			pc_stop  <= '0';
		elsif (falling_edge(clk) and IF_en='1') then
			pc_stop <= pc_stopvar;
		end if;
		if rst = '1' then
			PC_IF <= (others => '0');
			IR_IF_1 <= (others => '0');
			IR_IF_2 <= (others => '0');
			valid_IF_1 <= '0';
			valid_IF_2 <= '0';
			state <= '0';
		elsif rising_edge(clk) and IF_en = '1' then
			PC_IF <= PCvar;
			IR_IF_1 <= Iout1var;
			IR_IF_2 <= Iout2;
			valid_IF_1 <= valid_IF_1var;
			valid_IF_2 <= valid_IF_2var;
			state <= next_state;
		end if;
	end process IF_PP;
-- Instruction Decode -------------------------------------------------------------------------------------
	opcode_1 <= IR_IF_1(15 downto 12);
	opcode_2 <= IR_IF_2(15 downto 12);
	SE6_1	<= std_logic_vector(resize(signed(IR_IF_1(5 downto 0)), 16));
	SE6_2	<= std_logic_vector(resize(signed(IR_IF_2(5 downto 0)), 16));
	valid_ID_var_1 <= valid_IF_1 and flush_ID_1;
	valid_ID_var_2 <= valid_IF_2 and flush_ID_2;
	---- Used in LM/SM
	some_sig2 <= lmsm_locations when some_sig='1'
			else IR_IF_1(7 downto 0);
	temp1 <= std_logic_vector(unsigned(some_sig2)-1);
	temp2 <= (temp1 XOR some_sig2);
	temp3 <= temp2 and some_sig2;
	temp4 <=	 "000" when temp3="00000001"
	                       else "001" when temp3="00000010"
	                       else "010" when temp3="00000100"
	                       else "011" when temp3="00001000"
	                       else "100" when temp3="00010000"
	                       else "101" when temp3="00100000"
	                       else "110" when temp3="01000000"
	                       else "111";
	lmsm_locations_next <= some_sig2 and temp1;
	lmsm_run  <= '0' when (opcode_1(3 downto 1)="011" and valid_IF_1='1') and (lmsm_locations_next="00000000" or IR_IF_1(7 downto 0)="00000000")
			else '1';
    -- First ID pipeline
	ID_PP_1 : process(clk, rst) is -- @suppress "Incomplete sensitivity list. Missing signals: ID_en"
	begin
		if rst = '1' then
			PC_ID_1var     <= (others => '0');
			A1_ID_1var     <= "000";
			A2_ID_1var     <= "000";
			Aw_ID_1var     <= "000";
			SE_ID_1var     <= (others => '0');
			SEa_ID_1var    <= '0';
			CZ_ID_1var     <= "00";
			ALUop_ID_1var     <= '0';
			Cmod_ID_1var   <= '0';
			Zmod_ID_1var   <= '0';
			opcode_ID_1var <= (others => '0');
			PCstore_ID_1var   <= '0';
			PCcompute_ID_1var <= '0';
			valid_ID_1var  <= '0';
			Reg_wr_ID_1var <= '0';
			lmsm_write_1var<= '0';
			lmsm_sel_1var  <= '0';
			lmsm_locations <= (others => '0');
			lmsm_state<= '0';
			some_sig  <= '0';
			readA_1var  <= '0';
			readB_1var  <= '0';
		elsif rising_edge(clk) and ID_en = '1' then
			PC_ID_1var        <= PC_IF;
			A1_ID_1var        <= "000";
			A2_ID_1var        <= "000";
			Aw_ID_1var        <= "000";
			SE_ID_1var        <= (others => '0');
			SEa_ID_1var       <= '0';
			CZ_ID_1var        <= "00";
			ALUop_ID_1var        <= '0';
			Cmod_ID_1var      <= '0';
			Zmod_ID_1var      <= '0';
			opcode_ID_1var    <= opcode_1;
			PCstore_ID_1var   <= '0';
			PCcompute_ID_1var <= '0';
			valid_ID_1var     <= valid_ID_var_1;
			Reg_wr_ID_1var    <= '0';
			lmsm_write_1var	 <= '0';
			lmsm_sel_1var	 <= '0';
			readA_1var  <= '1';
			readB_1var  <= '1';
			case opcode_1 is
				when ADD =>
					A1_ID_1var     <= IR_IF_1(11 downto 9);
					A2_ID_1var     <= IR_IF_1(8 downto 6);
					Aw_ID_1var     <= IR_IF_1(5 downto 3);
					CZ_ID_1var     <= IR_IF_1(1 downto 0);
					Cmod_ID_1var   <= '1';
					Zmod_ID_1var   <= '1';
					Reg_wr_ID_1var <= '1';
				when ADI =>
					A1_ID_1var     <= IR_IF_1(11 downto 9);
					SE_ID_1var     <= SE6_1;
					SEa_ID_1var    <= '1';
					Aw_ID_1var     <= IR_IF_1(8 downto 6);
					Cmod_ID_1var   <= '1';
					Zmod_ID_1var   <= '1';
					Reg_wr_ID_1var <= '1';
					readB_1var  <= '0';
				when NND =>
					A1_ID_1var     <= IR_IF_1(11 downto 9);
					A2_ID_1var     <= IR_IF_1(8 downto 6);
					Aw_ID_1var     <= IR_IF_1(5 downto 3);
					ALUop_ID_1var     <= '1';
					CZ_ID_1var     <= IR_IF_1(1 downto 0);
					Zmod_ID_1var   <= '1';
					Reg_wr_ID_1var <= '1';
				when LHI =>
					Aw_ID_1var     <= IR_IF_1(11 downto 9);
					SE_ID_1var(15 downto 7)<= IR_IF_1(8 downto 0);
					SE_ID_1var(6 downto 0)<= "0000000";
					Reg_wr_ID_1var <= '1';
					readA_1var  <= '0';
					readB_1var  <= '0';
				when LW =>
					A1_ID_1var     <= IR_IF_1(8 downto 6);
					Aw_ID_1var     <= IR_IF_1(11 downto 9);
					SE_ID_1var     <= SE6_1;
					SEa_ID_1var    <= '1';
					Reg_wr_ID_1var <= '1';
					readB_1var  <= '0';
				when SW =>
					A1_ID_1var   <= IR_IF_1(8 downto 6); -- regB
					A2_ID_1var  	<= IR_IF_1(11 downto 9); -- regA
					SE_ID_1var  	<= SE6_1;
					SEa_ID_1var 	<= '1';
				when LM =>
					Reg_wr_ID_1var<='1';
					Aw_ID_1var<= temp4;
					lmsm_locations<=lmsm_locations_next;
					if(lmsm_state='0') then
						lmsm_locations <= lmsm_locations_next;
						lmsm_write_1var <= '1';
						lmsm_state <= '1';
						A1_ID_1var <= IR_IF_1(11 downto 9);
						some_sig<='1';
						readB_1var  <= '0';
						if(lmsm_stall='0') then
							lmsm_state<='0';
							some_sig<='0';
							if(IR_IF_1(7 downto 0)="00000000") then
								valid_ID_1var <= '0';
							end if;
						end if;
					else
						readA_1var  <= '0';
						readB_1var  <= '0';
						lmsm_sel_1var<='1';
						if(lmsm_stall='0') then
							lmsm_state <= '0';
							some_sig   <= '0';
						end if;
					end if;
				when SM =>
					opcode_ID_1var <= SW; -- SW and Mem_write address generated in MA stage itself according to SW opcode
					lmsm_locations <= lmsm_locations_next;
					A2_ID_1var<= temp4;
					if(lmsm_state='0') then
						lmsm_write_1var <= '1';
						lmsm_state <= '1';
						A1_ID_1var <= IR_IF_1(11 downto 9);
						some_sig <= '1';
						if(lmsm_stall='0') then
							lmsm_state<='0';
							some_sig <= '0';
							if(IR_IF_1(7 downto 0)="00000000") then
								valid_ID_1var <= '0';
							end if;
						end if;
					else
						readA_1var<='0';
						lmsm_sel_1var<='1';
						if(lmsm_stall='0') then
							lmsm_state <= '0';
							some_sig<='0';
						end if;
					end if;
				when BEQ =>
					A1_ID_1var        <= IR_IF_1(11 downto 9);
					A2_ID_1var        <= IR_IF_1(8 downto 6);
					PCcompute_ID_1var <= '1';
					SE_ID_1var        <= SE6_1;
					SEa_ID_1var       <= '1';
				when JAL =>
					PCcompute_ID_1var <= '1';
					SE_ID_1var        <= std_logic_vector(resize(signed(IR_IF_1(8 downto 0)), 16));
					SEa_ID_1var       <= '1';
					PCstore_ID_1var   <= '1';
					Aw_ID_1var        <= IR_IF_1(11 downto 9);
					Reg_wr_ID_1var    <= '1';
				when JLR =>
					PCstore_ID_1var <= '1';
					Aw_ID_1var      <= IR_IF_1(11 downto 9);
					A1_ID_1var      <= IR_IF_1(8 downto 6);
					Reg_wr_ID_1var  <= '1';
					readB_1var  <= '0';
				when others =>
					valid_ID_1var <= '0';
			end case;
		end if;
	end process ID_PP_1;
	pack_1_var <= PC_ID_1var&A1_ID_1var&A2_ID_1var&Aw_ID_1var&SE_ID_1var&SEa_ID_1var&CZ_ID_1var&ALUop_ID_1var&Cmod_ID_1var&Zmod_ID_1var&opcode_ID_1var
		&PCstore_ID_1var&PCcompute_ID_1var&valid_ID_1var&Reg_wr_ID_1var&readA_1var&readB_1var&lmsm_write_1var&lmsm_sel_1var;
	ID_PP_2 : process(clk, rst) is -- @suppress "Incomplete sensitivity list. Missing signals: ID_en"
	begin
		if rst = '1' then
			PC_ID_2var     <= (others => '0');
			A1_ID_2var     <= "000";
			A2_ID_2var     <= "000";
			Aw_ID_2var     <= "000";
			SE_ID_2var     <= (others => '0');
			SEa_ID_2var    <= '0';
			CZ_ID_2var     <= "00";
			ALUop_ID_2var     <= '0';
			Cmod_ID_2var   <= '0';
			Zmod_ID_2var   <= '0';
			opcode_ID_2var <= (others => '0');
			PCstore_ID_2var   <= '0';
			PCcompute_ID_2var <= '0';
			valid_ID_2var  <= '0';
			Reg_wr_ID_2var <= '0';
			readA_2var  <= '0';
			readB_2var  <= '0';
		elsif rising_edge(clk) and ID_en = '1' then
			PC_ID_2var        <= std_logic_vector(unsigned(PC_IF)+1);
			A1_ID_2var        <= "000";
			A2_ID_2var        <= "000";
			Aw_ID_2var        <= "000";
			SE_ID_2var        <= (others => '0');
			SEa_ID_2var       <= '0';
			CZ_ID_2var        <= "00";
			ALUop_ID_2var        <= '0';
			Cmod_ID_2var      <= '0';
			Zmod_ID_2var      <= '0';
			opcode_ID_2var    <= opcode_2;
			PCstore_ID_2var   <= '0';
			PCcompute_ID_2var <= '0';
			valid_ID_2var     <= valid_ID_var_2;
			Reg_wr_ID_2var    <= '0';
			readA_2var  <= '1';
			readB_2var  <= '1';
			case opcode_2 is
				when ADD =>
					A1_ID_2var     <= IR_IF_2(11 downto 9);
					A2_ID_2var     <= IR_IF_2(8 downto 6);
					Aw_ID_2var     <= IR_IF_2(5 downto 3);
					CZ_ID_2var     <= IR_IF_2(1 downto 0);
					Cmod_ID_2var   <= '1';
					Zmod_ID_2var   <= '1';
					Reg_wr_ID_2var <= '1';
				when ADI =>
					A1_ID_2var     <= IR_IF_2(11 downto 9);
					SE_ID_2var     <= SE6_2;
					SEa_ID_2var    <= '1'; --ALU B control
					Aw_ID_2var     <= IR_IF_2(8 downto 6);
					Cmod_ID_2var   <= '1';
					Zmod_ID_2var   <= '1';
					Reg_wr_ID_2var <= '1';
					readB_2var  <= '0';
				when NND =>
					A1_ID_2var     <= IR_IF_2(11 downto 9);
					A2_ID_2var     <= IR_IF_2(8 downto 6);
					Aw_ID_2var     <= IR_IF_2(5 downto 3);
					ALUop_ID_2var     <= '1';
					CZ_ID_2var     <= IR_IF_2(1 downto 0);
					Zmod_ID_2var   <= '1';
					Reg_wr_ID_2var <= '1';
				when LHI =>
					Aw_ID_2var     <= IR_IF_2(11 downto 9);
					SE_ID_2var(15 downto 7)<= IR_IF_2(8 downto 0);
					SE_ID_2var(6 downto 0)<= "0000000";
					Reg_wr_ID_2var <= '1';
					readA_2var  <= '0';
					readB_2var  <= '0';
				when LW =>
					A1_ID_2var     <= IR_IF_2(8 downto 6);
					Aw_ID_2var     <= IR_IF_2(11 downto 9);
					SE_ID_2var     <= SE6_2;
					SEa_ID_2var    <= '1';
					Reg_wr_ID_2var <= '1';
					readB_2var  <= '0';
				when SW =>
					A1_ID_2var   <= IR_IF_2(8 downto 6); -- regB
					A2_ID_2var   <= IR_IF_2(11 downto 9);
					SE_ID_2var  	<= SE6_2;
					SEa_ID_2var 	<= '1';
				when BEQ =>
					A1_ID_2var        <= IR_IF_2(11 downto 9);
					A2_ID_2var        <= IR_IF_2(8 downto 6);
					PCcompute_ID_2var <= '1';
					SE_ID_2var        <= SE6_2;
					SEa_ID_2var       <= '1';
				when JAL =>
					PCcompute_ID_2var <= '1';
					SE_ID_2var        <= std_logic_vector(resize(signed(IR_IF_2(8 downto 0)), 16));
					SEa_ID_2var       <= '1';
					PCstore_ID_2var   <= '1';
					Aw_ID_2var        <= IR_IF_2(11 downto 9);
					Reg_wr_ID_2var    <= '1';
				when JLR =>
					PCstore_ID_2var <= '1';
					Aw_ID_2var      <= IR_IF_2(11 downto 9);
					A1_ID_2var      <= IR_IF_2(8 downto 6);
					Reg_wr_ID_2var  <= '1';
					readB_2var  <= '0';
				when others => valid_ID_2var <= '0';
			end case;
		end if;
	end process ID_PP_2;
	pack_2_var <= PC_ID_2var&A1_ID_2var&A2_ID_2var&Aw_ID_2var&SE_ID_2var&SEa_ID_2var&CZ_ID_2var&ALUop_ID_2var&Cmod_ID_2var&Zmod_ID_2var&opcode_ID_2var
		&PCstore_ID_2var&PCcompute_ID_2var&valid_ID_2var&Reg_wr_ID_2var&readA_2var&readB_2var&"00";
-- Register Read access -----------------------------------------------------------------------------------
	--Queue
	que: entity work.queue
		generic map(
			DATA_WIDTH => 59,
			ADDR_WIDTH => 5
		)
		port map(
			clk       => clk,
			rst       => queue_rst,
			rd_en     => queue_read,
			wr_en     => queue_write,
			data_in1  => pack_1_var,
			data_in2  => pack_2_var,
			data_out1 => pack_1_queueout,
			data_out2 => pack_2_queueout,
			empty     => queue_empty,
			full      => queue_full
		);
	queue_rst <= rst or flush_till_RR_Ex;
	queue_write <= '1' when ((queue_stall='1' and queue_empty='1') or (queue_empty='0' and ((queue_full='1' and queue_read='1') or queue_full='0')) ) and haz_jal_jlr_r7='0' else '0';
	queue_read <= '1' when (queue_stall='0' and queue_empty='0') else '0';
	pack_1 <= pack_1_queueout when queue_empty='0' else pack_1_var; -- instructions which will be finally taken
	pack_2 <= pack_2_queueout when queue_empty='0' else pack_2_var;
	unpack1: entity work.unpack
		generic map(
			width => 59
		)
		port map(
			pack       => pack_1,
			PC         => PC_ID_1,
			A1         => A1_ID_1,
			A2         => A2_ID_1,
			Aw         => Aw_ID_1,
			SE         => SE_ID_1,
			SEa        => SEa_ID_1,
			CZ         => CZ_ID_1,
			ALUop      => ALUop_ID_1,
			Cmod       => Cmod_ID_1,
			Zmod       => Zmod_ID_1,
			opcode     => opcode_ID_1,
			PCstore    => PCstore_ID_1,
			PCcompute  => PCcompute_ID_1,
			valid      => valid_ID_1,
			Reg_wr     => Reg_wr_ID_1,
			readA      => readA_1,
			readB      => readB_1,
			lmsm_write => lmsm_write,
			lmsm_sel   => lmsm_sel
		);
	unpack2: entity work.unpack
		generic map(
			width => 59
		)
		port map(
			pack       => pack_2,
			PC         => PC_ID_2,
			A1         => A1_ID_2,
			A2         => A2_ID_2,
			Aw         => Aw_ID_2,
			SE         => SE_ID_2,
			SEa        => SEa_ID_2,
			CZ         => CZ_ID_2,
			ALUop      => ALUop_ID_2,
			Cmod       => Cmod_ID_2,
			Zmod       => Zmod_ID_2,
			opcode     => opcode_ID_2,
			PCstore    => PCstore_ID_2,
			PCcompute  => PCcompute_ID_2,
			valid      => valid_ID_2,
			Reg_wr     => Reg_wr_ID_2,
			readA      => readA_2,
			readB      => readB_2,
			lmsm_write => unused1,
			lmsm_sel   => unused2
		);
	-- Scoreboard
	scoreboard:entity work.scoreboard
		port map(
			clk  	=> clk,
			rst     => sb_rst,
			wr1     => sb_wr1,
			wr2     => sb_wr2,
			clr1    => sb_clr1,
			clr2    => sb_clr2,
			regwr_1 => regwr_1,
			regwr_2 => regwr_2,
			regclr1 => wSel1,
			regclr2 => wSel2,
			regA_1  => A1_ID_1,
			regB_1  => A2_ID_1,
			regA_2  => A1_ID_2,
			regB_2  => A2_ID_2,
			regC_1  => Aw_ID_1,
			regC_2  => Aw_ID_2,
			doutA_1 => sbA_1,
			doutB_1 => sbB_1,
			doutA_2 => sbA_2,
			doutB_2 => sbB_2,
			doutC_1 => sbC_1,
			doutC_2 => sbC_2
		);
	sb_rst <= flush_till_RR_Ex or rst;
	sb_write_after_flush_1 <= '1' when (opcode_RR_1=JLR or (sb_write_after_flush_2='1' and Reg_wr_RR_1='1') or (opcode_RR_2=LHI and Aw_RR_2=R7)) and valid_RR_1='1' else '0';
	sb_write_after_flush_2 <= '1' when opcode_RR_2=JLR and valid_RR_2='1' else '0';
	sb_wr1 <= (Reg_wr_ID_1 and valid_RRvar_1) or sb_write_after_flush_1;
	sb_wr2 <= (Reg_wr_ID_2 and valid_RRvar_2) or sb_write_after_flush_2;
	regwr_1 <= Aw_RR_1 when sb_write_after_flush_1='1' else Aw_ID_1;
	regwr_2 <= Aw_RR_2 when sb_write_after_flush_2='1' else Aw_ID_2;
	sb_clr1 <= (supposed_to_write_MA_1 and valid_MA_1);
	sb_clr2	<= (supposed_to_write_MA_2 and valid_MA_2);
	sb_stall_1 <= '1' when (((sbA_1='1' and readA_1='1' and A1_ID_1/=R7) or (sbB_1='1' and readB_1='1' and A2_ID_1/=R7) or (sbC_1='1' and Reg_wr_ID_1='1' and Aw_ID_1/=R7)) and valid_ID_1='1' and dirty='0')
			else '0';
	sb_stall_2 <= '1' when (((sbA_2='1' and readA_2='1' and A1_ID_2/=R7) or (sbB_2='1' and readB_2='1' and A2_ID_2/=R7) or (sbC_2='1' and Reg_wr_ID_2='1' and Aw_ID_2/=R7)) and valid_ID_2='1')
			else '0';
	--
	wR7var <= valid_MA_1 or valid_MA_2;
	rf : entity work.register_file
		port map(
			clk   => clk,
			rst	=> rst,
			out1A  => outA_1,
			sel1A  => A1_ID_1,
			out1B  => outB_1,
			sel1B  => A2_ID_1,
			out2A  => outA_2,
			sel2A  => A1_ID_2,
			out2B  => outB_2,
			sel2B  => A2_ID_2,
			write1 => write1,
			wSel1  => wSel1,
			wEN1   => wEN1,
			write2 => write2,
			wSel2  => wSel2,
			wEN2   => wEN2,
			R7in   => PC_MA,
			wR7    => wR7var,
			R0	   => R0,
			R1	   => R1,
			R2	   => R2,
			R3	   => R3,
			R4	   => R4,
			R5	   => R5,
			R6	   => R6,
			R7     => R7o
		);
	D1var_1 <= PC_ID_1 when (A1_ID_1=R7) else outA_1;
	D2var_1 <= PC_ID_1 when (A2_ID_1=R7) else outB_1;
	valid_RRvar_1 <= valid_ID_1 and flush_RR_1 and (not dirty);
	RR_PP_1 : process(clk, rst) is
	begin
		if rst = '1' then
			PC_RR_1 	   <= x"0000";
			Aw_RR_1      <= "000";
			SE_RR_1      <= x"0000";
			SEa_RR_1     <= '0';
			opcode_RR_1  <= x"0";
			PCstore_RR_1 <= '0';
			valid_RR_1   <= '0';
			Reg_wr_RR_1  <= '0';
			CZ_RR_1      <= "00";
			ALU_op_RR_1  <= '0';
			Cmod_RR_1	   <= '0';
			Zmod_RR_1    <= '0';
			lmsm_sel_RR <= '0';
			lmsm_write_RR<= '0';
			D1_1 		<= x"0000";
			D2_1 		<= x"0000";
			PCcompute_RR_1<= '0';
		elsif rising_edge(clk) then
			PC_RR_1 	   <= PC_ID_1;
			Aw_RR_1      <= Aw_ID_1;
			SE_RR_1      <= SE_ID_1;
			SEa_RR_1     <= SEa_ID_1;
			opcode_RR_1  <= opcode_ID_1;
			PCstore_RR_1 <= PCstore_ID_1;
			valid_RR_1   <= valid_RRvar_1;
			Reg_wr_RR_1  <= Reg_wr_ID_1;
			CZ_RR_1      <= CZ_ID_1;
			ALU_op_RR_1  <= ALUop_ID_1;
			Cmod_RR_1    <= Cmod_ID_1;
			Zmod_RR_1    <= Zmod_ID_1;
			D1_1		 <= D1var_1;
			D2_1		 <= D2var_1;
			lmsm_write_RR<= lmsm_write;
			lmsm_sel_RR <= lmsm_sel;
			PCcompute_RR_1<=PCcompute_ID_1;
		end if;
	end process RR_PP_1;
	D1var_2 <= PC_ID_2 when (A1_ID_2=R7) else outA_2;
	D2var_2 <= PC_ID_2 when (A2_ID_2=R7) else outB_2;
	valid_RRvar_2 <= valid_ID_2 and flush_RR_2;
	RR_PP_2 : process(clk, rst) is
	begin
		if rst = '1' then
			PC_RR_2 	   <= x"0000";
			Aw_RR_2      <= "000";
			SE_RR_2      <= x"0000";
			SEa_RR_2     <= '0';
			opcode_RR_2  <= "0000";
			PCstore_RR_2 <= '0';
			valid_RR_2   <= '0';
			Reg_wr_RR_2  <= '0';
			CZ_RR_2      <= "00";
			ALU_op_RR_2  <= '0';
			Cmod_RR_2	   <= '0';
			Zmod_RR_2    <= '0';
			D1_2 		<= x"0000";
			D2_2 		<= x"0000";
			PCcompute_RR_2<= '0';
		elsif rising_edge(clk) then
			PC_RR_2 	 <= PC_ID_2;
			Aw_RR_2      <= Aw_ID_2;
			SE_RR_2      <= SE_ID_2;
			SEa_RR_2     <= SEa_ID_2;
			opcode_RR_2  <= opcode_ID_2;
			PCstore_RR_2 <= PCstore_ID_2;
			valid_RR_2   <= valid_RRvar_2;
			Reg_wr_RR_2  <= Reg_wr_ID_2;
			CZ_RR_2      <= CZ_ID_2;
			ALU_op_RR_2  <= ALUop_ID_2;
			Cmod_RR_2    <= Cmod_ID_2;
			Zmod_RR_2    <= Zmod_ID_2;
			D1_2		 <= D1var_2;
			D2_2		 <= D2var_2;
			PCcompute_RR_2<=PCcompute_ID_2;
		end if;
	end process RR_PP_2;

	dirty_bit : process (rst, clk)
	begin
		if (rst = '1') then
			dirty <= '0';
		elsif (rising_edge(clk)) then
			if (queue_read='1' or queue_rst='1') then
				dirty <= '0';
			end if;
			if(haz_type1='1') then
				dirty <= '1';
			end if;
		end if;
	end process dirty_bit;
-- Instruction Execute ------------------------------------------------------------------------------------
	eq_1 <= '1' when D1_1=D2_1 else '0';
	eq_2 <= '1' when D1_2=D2_2 else '0';

	ALU_A_1 <= PC_RR_1 when PCcompute_RR_1='1'
	              else lmsm_initial_address when lmsm_sel_RR='1'
	              else D1_1;
	ALU_B_1 <= SE_RR_1 when SEa_RR_1='1'
	      else lmsm_next when lmsm_sel_RR='1'
          else D2_1;
	alu1 : entity work.ALU
		port map(
			A          => ALU_A_1,
			B          => ALU_B_1,
			Y          => ALU_Y_1,
			ALU_opcode => ALU_op_RR_1,
			Z_var      => Z_var_1,
			C_var      => C_var_1
		);
	D_EXvar_1 <= D2_1 when opcode_RR_1 = SW
	              else PC_RR_1 when PCstore_RR_1 = '1'
	              else SE_RR_1 when opcode_RR_1 = LHI
	              else ALU_Y_1;
	Addr_EXvar_1 <= D1_1 when lmsm_write_RR='1'
    		else ALU_Y_1;

	C_mod_var_1    <= '0' when (CZ_RR_1 = "10" and C = '0') else '1';
	Z_mod_var_1    <= '0' when (CZ_RR_1 = "01" and Z = '0') else '1';
	Reg_wr_Exvar_1 <= Reg_wr_RR_1 and C_mod_var_1 and Z_mod_var_1;
	Z_LWvar <= '1' when (RAMout=x"0000") else '0';
	lw_flag_update <= '1' when ((valid_RR_1 = '0' or Zmod_RR_1 = '0') and (valid_RR_2 = '0' or Zmod_RR_2 = '0')) and ((opcode_EX_1 = LW and valid_EX_1 = '1') or (opcode_EX_2 = LW and valid_EX_2 = '1')) else '0';
	Zout<= Z_LWvar when lw_flag_update='1'
	                  else Z_var_2 when (Zmod_RR_2='1' and valid_RR_2='1')
	                  else Z_var_1;
	Cout <= C_var_2 when (Cmod_RR_2='1' and valid_RR_2='1')
		else C_var_1;

	valid_EXvar_1 <= valid_RR_1 and flush_Ex_1;
	EX_PP_1 : process(clk, rst) is
	begin
		if rst = '1' then
			D_EX_1      <= (others => '0');
			Addr_EX_1   <= (others => '0');
			opcode_EX_1 <= (others => '0');
			valid_EX_1  <= '0';
			Reg_wr_Ex_1 <= '0';
			Aw_EX_1	  <= "000";
			supposed_to_write_Ex_1 <= '0';
			PC_Ex	  <= x"0000";
		elsif rising_edge(clk) then
			PC_Ex       <= PC_RR_1;
			D_EX_1      <= D_EXvar_1;
			Addr_EX_1   <= Addr_EXvar_1;
			Aw_EX_1     <= Aw_RR_1;
			opcode_EX_1 <= opcode_RR_1;
			valid_EX_1  <= valid_EXvar_1;
			Reg_wr_Ex_1 <= Reg_wr_Exvar_1;
			supposed_to_write_Ex_1 <= Reg_wr_RR_1; -- for conditional CZ opn's to update the scoreboard
		end if;
	end process EX_PP_1;

	ALU_A_2 <= PC_RR_2 when PCcompute_RR_2='1'
			else D1_2;
	ALU_B_2 <= SE_RR_2 when SEa_RR_2='1'
		  else D2_2;
	alu2 : entity work.ALU
		port map(
			A          => ALU_A_2,
			B          => ALU_B_2,
			Y          => ALU_Y_2,
			ALU_opcode => ALU_op_RR_2,
			Z_var      => Z_var_2,
			C_var      => C_var_2
		);
	D_EXvar_2 <= D2_2 when opcode_RR_2 = SW
	             else PC_RR_2 when PCstore_RR_2='1'
	             else SE_RR_2 when opcode_RR_2 = LHI
	             else ALU_Y_2;

	C_mod_var_2    <= '0' when (CZ_RR_2 = "10" and C = '0') else '1';
	Z_mod_var_2    <= '0' when (CZ_RR_2 = "01" and Z = '0') else '1';
	Reg_wr_Exvar_2 <= Reg_wr_RR_2 and C_mod_var_2 and Z_mod_var_2;
	valid_EXvar_2 <= valid_RR_2 and flush_Ex_2;
	EX_PP_2 : process(clk, rst) is
	begin
		if rst = '1' then
			D_EX_2      <= (others => '0');
			Addr_EX_2   <= (others => '0');
			opcode_EX_2 <= (others => '0');
			valid_EX_2  <= '0';
			Reg_wr_Ex_2 <= '0';
			Aw_EX_2	  <= "000";
			supposed_to_write_Ex_2 <= '0';
		elsif rising_edge(clk) then
			D_EX_2      <= D_EXvar_2;
			Addr_EX_2   <= ALU_Y_2;
			Aw_EX_2     <= Aw_RR_2;
			opcode_EX_2 <= opcode_RR_2;
			valid_EX_2  <= valid_EXvar_2;
			Reg_wr_Ex_2 <= Reg_wr_Exvar_2;
			supposed_to_write_Ex_2 <= Reg_wr_RR_2;
		end if;
	end process EX_PP_2;
	flags : process (rst, clk)
	begin
		if (rst = '1') then
			C <= '0';
			Z <= '0';
			lmsm_initial_address<=(others => '0');
			lmsm_next <= x"0001";
		elsif (rising_edge(clk)) then
			if (Cmod_RR_1 = '1' and C_mod_var_1 = '1' and valid_RR_1='1') or (Cmod_RR_2 = '1' and C_mod_var_2 = '1' and valid_RR_2='1') then
				C <= Cout;
			end if;
			if (Zmod_RR_1 = '1' and Z_mod_var_1 = '1' and valid_RR_1='1') or (Zmod_RR_2 = '1' and Z_mod_var_2 = '1' and valid_RR_2='1') or lw_flag_update='1' then
				Z <= Zout;
			end if;
			if(lmsm_write_RR='1') then
				lmsm_initial_address <= D1_1;
				lmsm_next <= x"0001";
			else
				lmsm_next <= std_logic_vector(unsigned(lmsm_next)+1);
			end if;
		end if;
	end process flags;
-- Memory access ------------------------------------------------------------------------------------------
	ram : entity work.RAM_data
		port map(
			address    => RAM_address,
			RAM_datain => RAM_datain,
			clk         => clk,
			rst 		=> rst,
			RAM_wr		=> wRAM,
			RAM_dataout=> RAMout
		);
	RAM_address <= Addr_EX_2 when (opcode_EX_2=LW or opcode_EX_2=LM or opcode_EX_2=SW) and valid_EX_2='1'
			  else Addr_EX_1;
	RAM_datain <= D_EX_2 when (opcode_EX_2=LW or opcode_EX_2=LM or opcode_EX_2=SW) and valid_EX_2='1'
			 else D_EX_1;
	D_MAvar_1 <= RAMout when (opcode_EX_1=LW or opcode_EX_1=LM) and valid_EX_1='1' 
	      else D_EX_1;
	wRAM  <= '1' when (opcode_EX_2 = SW and valid_EX_2 = '1') or (opcode_EX_1 = SW and valid_EX_1 = '1')
	    else '0';
	valid_MAvar_1 <= valid_EX_1 and flush_MA_1;
	MA_PP_1 : process(clk, rst) is
	begin
		if rst = '1' then
			wSel1       <= (others => '0');
			write1      <= (others => '0');
			valid_MA_1  <= '0';
			Reg_wr_MA_1 <= '0';
			supposed_to_write_MA_1 <= '0';
			PC_MA 		<= x"0000";
		elsif rising_edge(clk) then
			PC_MA		<= PC_Ex;
			write1      <= D_MAvar_1;
			wSel1       <= Aw_EX_1;
			valid_MA_1  <= valid_MAvar_1;
			Reg_wr_MA_1 <= Reg_wr_Ex_1;
			supposed_to_write_MA_1 <= supposed_to_write_Ex_1;
		end if;
	end process MA_PP_1;
	D_MAvar_2 <= RAMout when (opcode_EX_2=LW or opcode_EX_2=LM) and valid_EX_2='1' 
	      else D_EX_2;
	valid_MAvar_2 <= valid_EX_2 and flush_MA_2;
	MA_PP_2 : process(clk, rst) is
	begin
		if rst = '1' then
			wSel2       <= (others => '0');
			write2      <= (others => '0');
			valid_MA_2  <= '0';
			Reg_wr_MA_2 <= '0';
			supposed_to_write_MA_2 <= '0';
		elsif rising_edge(clk) then
			write2      <= D_MAvar_2;
			wSel2       <= Aw_EX_2;
			valid_MA_2  <= valid_MAvar_2;
			Reg_wr_MA_2 <= Reg_wr_Ex_2;
			supposed_to_write_MA_2 <= supposed_to_write_Ex_2;
		end if;
	end process MA_PP_2;
-- Register Write Back ------------------------------------------------------------------------------------
	wEN1   <= Reg_wr_MA_1 and valid_MA_1;
	wEN2   <= Reg_wr_MA_2 and valid_MA_2;

	PCin 	 <= RAMout when haz_lw_lm_r7_1='1' or haz_lw_lm_r7_2='1'
	        else ALU_Y_1 when haz_ex_R7_1='1' or haz_beq_jal_1='1'
	        else ALU_Y_2 when haz_ex_R7_2='1' or haz_beq_jal_2='1'
	        else SE_ID_1 when haz_lhi_R7_1='1'
	        else SE_ID_2 when haz_lhi_R7_2='1'
	        else D2var_1 when haz_jlr_1='1' or haz_jal_jlr_r7_1='1'
	        else D2var_2 when haz_jlr_2='1' or haz_jal_jlr_r7_2='1'
	        else std_logic_vector(unsigned(PC)+2);
-- Hazards,Flushes and Stalls
	-- PC Hazards
	haz_lw_lm_r7_1 <= '1' when ((opcode_EX_1=LW or opcode_EX_1=LM) and Aw_EX_1=R7 and valid_EX_1='1') else '0';
	haz_lw_lm_r7_2 <= '1' when ((opcode_EX_2=LW or opcode_EX_2=LM) and Aw_EX_2=R7 and valid_EX_2='1') else '0';
	haz_ex_R7_2    <= '1' when (not(opcode_RR_2=LW or opcode_RR_2=LM) and Reg_wr_Exvar_2='1' and Aw_RR_2=R7 and valid_RR_2='1') else '0';
	haz_ex_R7_1    <= '1' when (not(opcode_RR_1=LW or opcode_RR_1=LM) and Reg_wr_Exvar_1='1' and Aw_RR_1=R7 and valid_RR_1='1') else '0';
	haz_beq_jal_1  <= '1' when (((opcode_RR_1=BEQ and eq_1='1') or opcode_RR_1=JAL) and valid_RR_1='1') else '0';
	haz_beq_jal_2  <= '1' when (((opcode_RR_2=BEQ and eq_2='1') or opcode_RR_2=JAL) and valid_RR_2='1') else '0';
	haz_lhi_R7_1   <= '1' when (opcode_ID_1=LHI and Aw_ID_1=R7 and valid_ID_1='1') else '0';
	haz_lhi_R7_2   <= '1' when (opcode_ID_2=LHI and Aw_ID_2=R7 and valid_ID_2='1' and queue_stall='0') else '0';
	haz_jlr_1 	   <= '1' when (opcode_ID_1=JLR and valid_ID_1='1' and sb_stall_1='0') else '0';
	haz_jlr_2      <= '1' when (opcode_ID_2=JLR and valid_ID_2='1' and queue_stall='0') else '0'; -- covers both sb_stall_1 and sb_stall_2
	haz_jal_jlr_r7_1 <= '1' when ((opcode_ID_1=JLR or opcode_ID_1=JAL) and valid_ID_1='1' and Aw_ID_1=R7) else '0';
	haz_jal_jlr_r7_2 <= '1' when ((opcode_ID_2=JLR or opcode_ID_2=JAL) and valid_ID_2='1' and sb_stall_1='0' and Aw_ID_2=R7) else '0';
	haz_jal_jlr_r7  <= haz_jal_jlr_r7_1 or haz_jal_jlr_r7_2;
	-- Other hazards
	haz_flag_dependency <= '1' when ((CZ_ID_2="10" and Cmod_ID_1='1') or (CZ_ID_2="01" and Zmod_ID_1='1')) and (sb_stall_1='0') and (valid_ID_1='1' and valid_ID_2='1') else '0';
	haz_both_MA <= '1' when ((opcode_ID_1=LW or opcode_ID_1=SW) and (opcode_ID_2=LW or opcode_ID_2=SW)) and (sb_stall_1='0') else '0';
	haz_ADZ_LW  <= '1' when (((CZ_ID_1="01" and valid_ID_1='1') or (CZ_ID_2="01" and valid_ID_2='1')) and ((opcode_RR_1=LW and valid_RR_1='1') or (opcode_RR_2=LW and valid_RR_2='1'))) else '0';
	haz_interdependence <= '1' when ((A1_ID_2=Aw_ID_1 and readA_2='1' and sbA_2='0') or (A2_ID_2=Aw_ID_1 and readB_2='1' and sbB_2='0')) and sb_stall_1='0' and valid_ID_1='1' and valid_ID_2='1' and opcode_ID_1/=JLR else '0'; -- to handle pending dependent writes
	haz_type1 	  <= '1' when (haz_flag_dependency='1' or haz_interdependence='1' or haz_both_MA='1' or haz_jal_jlr_r7_2='1') and dirty='0' else '0';
	-- Flushes
	flush_MA_1    <= '0' when haz_lw_lm_r7_1='1' else '1';
	flush_MA_2    <= '0' when haz_lw_lm_r7_2='1' or haz_lw_lm_r7_1='1' else '1';
	flush_Ex_1	  <= '0' when haz_ex_R7_1='1' or haz_lw_lm_r7_1='1' or haz_lw_lm_r7_2='1' else '1';
	flush_Ex_2	  <= '0' when haz_ex_R7_2='1' or haz_beq_jal_1='1' or haz_ex_R7_1='1' or haz_lw_lm_r7_1='1' or haz_lw_lm_r7_2='1' else '1';
	flush_RR_1    <= '0' when (queue_stall='1' and haz_type1='0') or (flush_till_RR_Ex='1' and haz_jlr_1='0' and haz_jlr_2='0' and haz_lhi_R7_2='0') or haz_jal_jlr_r7_1='1' else '1';
	flush_RR_2	  <= '0' when queue_stall='1' or (flush_till_RR_Ex='1' and haz_jlr_2='0') or haz_jal_jlr_r7='1' else '1';
	flush_ID_1	  <= not flush_till_RR_Ex;
	flush_ID_2	  <= flush_ID_1;
	flush_till_RR_Ex <= haz_beq_jal_2 or haz_beq_jal_1 or haz_ex_R7_1 or haz_ex_R7_2 or haz_lw_lm_r7_1 or haz_lw_lm_r7_2 or haz_lhi_R7_1 or haz_lhi_R7_2 or haz_jlr_1 or haz_jlr_2;
	--Stalls
	queue_stall	  <= (haz_type1 or haz_ADZ_LW or sb_stall_1 or sb_stall_2 or haz_jal_jlr_r7) and flush_till_RR_Ex;
	lmsm_stall <= '1' when (opcode_1(3 downto 1)="011" and lmsm_run='1' and valid_IF_1='1' and flush_ID_1='1') else '0';
	IF_en <= not ((queue_full and not queue_read) or haz_jal_jlr_r7 or lmsm_stall);
	ID_en <= not ((queue_full and not queue_read) or haz_jal_jlr_r7);
	wPC   <= not ((queue_full and not queue_read) or lmsm_stall or pc_stop);
end datapathc_arc;