text1 = "PC_2var&A1_2var&A2_2var&Aw_2var&SE_2var&SEa_2var&CZ_2var&ALUop_2var&Cmod_2var&Zmod_2var&opcode_2var&PCstore_2var&PCcompute_2var&valid_2var&Reg_wr_2var&readA_2var&readB_2var&lmsm_write_2var&lmsm_sel_2var&"
li = text1.split("_2var&")
li = li[:-1]
li2 = [16,3,3,3,16,1,2,1,1,1,4,1,1,1,1,1,1,1,1]
total = sum(li2) - 1
for index,val in enumerate(li):
	if(li2[index]==1):
		print (f"{val} <= pack({total});")
	else:
		print (f"{val} <= pack({total} downto {total - li2[index]+1});")
	total = total - li2[index]
for index,val in enumerate(li):
	if(li2[index]==1):
		print(f"{val}: out std_logic;")
	else:
		print(f"{val}: out std_logic_vector({li2[index] - 1} downto 0);")