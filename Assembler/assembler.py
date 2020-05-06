import sys
print('RV32I assembler')
#all opcode
instructions = {
	"lui": [0b0110111, "u"],
	"auipc": [0b0010111, "u"],
	"jal": [0b1101111, "j"],
	"jalr": [0b1100111, "j"],
	"beq": [0b1100011, "b"],
	"bne": [0b1100011, "b"],
	"blt": [0b1100011, "b"],
	"bge": [0b1100011, "b"],
	"bltu": [0b1100011, "b"],
	"bgeu": [0b1100011, "b"],
	"lb": [0b0000011, "l"],
	"lh": [0b0000011, "l"],
	"lw": [0b0000011, "l"],
	"lbu": [0b0000011, "l"],
	"lhu": [0b0000011, "l"],
	"sb": [0b0100011, "s"],
	"sh": [0b0100011, "s"],
	"sw": [0b0100011, "s"],
	"addi": [0b0010011, "i"],
	"slti": [0b0010011, "i"],
	"sltiu": [0b0010011, "i"],
	"xori": [0b0010011, "i"],
	"ori": [0b0010011, "i"],
	"andi": [0b0010011, "i"],
	"slli": [0b0010011, "i"],
	"srli": [0b0010011, "i"],
	"srai": [0b0010011, "i"],
	"add": [0b0110011, "r"],
	"sub": [0b0110011, "r"],
	"slt": [0b0110011, "r"],
	"sltu": [0b0110011, "r"],
	"xor": [0b0110011, "r"],
	"or": [0b0110011, "r"],
	"and": [0b0110011, "r"],
	"sll": [0b0110011, "r"],
	"srl": [0b0110011, "r"],
	"sra": [0b0110011, "r"],
}
#function code
branch_func3 = {
	"beq": 0,
	"bne": 1,
	"blt": 4,
	"bge": 5,
	"bltu": 6,
	"bgeu": 7
}
load_func3 = {
	"lb": 0,
	"lh": 1,
	"lw": 2,
	"lbu": 4,
	"lhu": 5
}

store_func3 = {
	"sb": 0,
	"sh": 1,
	"sw": 2
}

imm_func3 = {
	"addi": 0,
	"slti": 2,
	"sltiu": 3,
	"xori": 4,
	"ori": 6,
	"andi": 7,
	"slli": 1,
	"srli": 5,
	"srai": 5
}

arith_func3 = {
	"add": 0,
	"sub": 0,
	"slt": 2,
	"sltu": 3,
	"xor": 4,
	"or": 6,
	"and": 7,
	"sll": 1,
	"srl": 5,
	"sra": 5
}
registers = {
	"x0": 0,
	"x1": 1,
	"x2": 2,
	"x3": 3,
	"x4": 4,
	"x5": 5,
	"x6": 6,
	"x7": 7,
	"x8": 8,
	"x9": 9,
	"x10": 10,
	"x11": 11,
	"x12": 12,
	"x13": 13,
	"x14": 14,
	"x15": 15,
	"x16": 16,
	"x17": 17,
	"x18": 18,
	"x19": 19,
	"x20": 20,
	"x21": 21,
	"x22": 22,
	"x23": 23,
	"x24": 24,
	"x25": 25,
	"x26": 26,
	"x27": 27,
	"x28": 28,
	"x29": 29,
	"x30": 30,
	"x31": 31
}
def convert_r(op,token,opcode):
	func3 = arith_func3[op] << 12 
	if op != "sub" and op != "sra":
		func7 = 0
	else:
		func7 = 1 << 30
	rd = token[0] << 7
	rs1 = token[1] << 15
	rs2 = token[2] << 20
	return hex((0 | opcode | rd | func3 | rs1 | rs2 | func7) + 2 ** 32)

def convert_i (op,token,opcode):
	func3 = imm_func3[op] << 12
	if(token[2] > 511 or token[2] < -512):
		return 0
	if op != "srai":
		func7 = 0
	else:
		func7 = 1 << 30
	rd = token[0] << 7
	rs1 = token[1] << 15
	imm = token[2] << 20
	instr = 0 | opcode | rd | func3 | rs1 | imm

	if op in ["slli", "srli", "srai"]:
		instr = instr | func7

	return hex(instr + 2 ** 32)
def convert_s (op,token,opcode):
	func3 = store_func3[op] << 12
	rs1 = token[0] << 15
	rs2 = token[1] << 20
	imm11to5 = (token[2] >> 5) << 25
	imm4to0 = (token[2] & 0x1F) << 7
	return hex((0 | opcode | imm4to0 | func3 | rs1 | rs2 | imm11to5) + 2 ** 32)
	

def convert_b (op,token,opcode):
	func3 = branch_func3[op] << 12
	if token[2] > 511 or token[2] < -512:
		return 0
	rs1 = token[0] << 15
	rs2 = token[1] << 20
	imm = token[2]
	imm12 = (imm >> 11) << 31
	imm11 = ((imm >> 10) & 0x1) << 7
	imm10to5 = ((imm >> 4) & 0x3F) << 25
	imm4to1 = (imm & 0xF) << 8

	return  hex((0 | opcode | imm11 | imm4to1 | func3 | rs1 | rs2 | imm10to5 | imm12) + 2 ** 32)



def convert_u (op,token,opcode):
	if token[1] > 1048575 or token[1] < -1048576:
		return 0
	rd = token[0] << 7
	imm = token[1] << 12
	return hex((0 | opcode | rd | imm) + 2 ** 32)

def convert_j (op,token,opcode):
	rd = token[0] << 7
	if op == "jalr":
		if token[2] > 2047 or token[2] < -2048:
			return 0
		rs1 = token[1] << 15
		imm = (token[2] & 0xFFF) << 20
		return hex(0|opcode|rd|rs1|imm)
	
	imm = token[1]
	imm20 = ((imm >> 19) & 1) << 31
	imm10to1 = (imm & 0x3FF) << 21
	imm11 = ((imm >> 10) & 0x1) << 20
	imm19to12 = ((imm >> 11) & 0xFF) << 12
	return hex((0 | opcode | rd | imm19to12 | imm11 | imm10to1 | imm20) + 2 ** 32)

def convert_l (op,token,opcode):
	rd = token[0] << 7
	func3 = load_func3[op] << 12
	rs1 = token[1] << 15
	imm = token[2] << 20
	return hex((0|opcode|rd|func3|rs1|imm) + 2 **32)


def main():
	print "yes"
	instruction = open("instruction.txt","r")
	binary_instruction = open("binary_instruction.txt","w")
	lineI = instruction.readline()
	while lineI :
		splited = lineI.split()
		op = splited[0]
		opcode, instr_type = instructions[op]
		registerToken = splited[1].replace(" ", "").split(",")
		tokens = []
		for token in registerToken:
			if token in registers :
				tokens.append(registers[token])
			else:
				tokens.append(int(token))
		registerToken = tokens
		bin_instr = 0
		if instr_type == 'r':bin_instr = convert_r(op,registerToken,opcode)
		elif instr_type == 'i':bin_instr = convert_i(op,registerToken,opcode)
		elif instr_type == 's':bin_instr = convert_s(op,registerToken,opcode)
		elif instr_type == 'b':bin_instr = convert_b(op,registerToken,opcode)
		elif instr_type == 'u':bin_instr == convert_u(op,registerToken,opcode)
		elif instr_type == 'j':bin_instr = convert_j(op,registerToken,opcode)
		elif instr_type == 'l':bin_instr = convert_l(op,registerToken,opcode)
		print(bin_instr)
		binary_instruction.write(bin_instr + '\n')
		lineI = instruction.readline()
	binary_instruction.close()
	instruction.close()

if __name__ == "__main__":
	# execute only if run as a script
	main()







