import sys

instructions = {
    "NOP":0,
    "ADD":1,
    "MUL":2,
    "SUB":3,
    "DIV":4,
    "COP":5,
    "AFC":6,
    "JMP":7,
    "JMF":8, #jump false
    "NOZ":9,
    "STR":10,
    "LDR":11, #LDR @reg @mem
    "PRT":12,
    "GSW":13,
    "CLE":14,
    "CGE":15,
    "CLT":16,
    "CGT":17,
    "CEQ":18,
    "CNE":19,
    # "LRF":14, #Load Reference : LRF @dest *@src
}

##NOTE: ADD A B C ≡ A := B + C

labels = {}
instr_counter = 0

if len(sys.argv) != 3:
    print("Incorrect args, usage python asm2machineCode.py [infile] [outfile]\nGot : "+str(sys.argv))
    sys.exit(1)

def print_hexa(hexa):
    op = ""
    for k,v in instructions.items():
        if hexa>>24 == v:
            op = k
            break
    print(f"{op} {(hexa>>16)&0xff:02x} {(hexa>>8)&0xff:02x} {(hexa>>0)&0xff:02x}")

def append_nop(count):
    global instr_counter
    # return
    for i in range(count):
        #print_hexa(0)
        assert 13 == out.write(f'x"00000000",\n')
        instr_counter+=1


def append_instruction(hexa):
    global instr_counter
    print_hexa(hexa)
    assert 13 == out.write(f'x"{hexa:08x}",\n')
    # append_nop(4)
    # instr_counter+=5
    instr_counter+=1

def append_jmp(opcode,label):
    """For JMP and JMF instructions"""
    global instr_counter
    if opcode == instructions["JMP"]:
        print("JMP",label)
    elif opcode == instructions["JMF"]:
        print("JMF",label)
    else:
        print(f"Error: opcode {opcode} is not a jump instruction")
        return
    out.write(f'x"{opcode:02x}{label}",\n')
    instr_counter += 1

def print_instr(hexa):
    print(f'x"{hexa:08x}",')

def append_load(reg_num,addr):
    assert reg_num < 16
    assert addr < 256
    append_instruction(instructions["LDR"]<<24 | reg_num<<16 | addr<<8 | 0x00)

def append_store(reg_num,addr):
    assert reg_num < 16
    assert addr < 256
    append_instruction(instructions["STR"]<<24 | addr<<16 | reg_num<<8 | 0x00)

try:
    src = open(sys.argv[1],"r")
except OSError as e:
    print("Could not open "+sys.argv[1],e)
    sys.exit(1)
try:
    out = open(sys.argv[2],"w")
except OSError as e:
    print("Could not open "+sys.argv[2],e)
    src.close()
    sys.exit(1)

for line in src.readlines():
    if line.startswith('\n') or line.startswith('#'):
        continue
    if line.endswith('\n'):
        line = line[:-1]
    if line.endswith(':'):
        labels[line[:-1]] = instr_counter
    else:
        args = line.split()
        if args[0] not in instructions.keys():
            print("Unknown instruction: "+args[0])
            break
        opcode = instructions[args[0]]
        if args[0] == "ADD" or args[0] == "SUB" or args[0] == "MUL" or args[0] == "DIV" or args[0] == "CLE" or args[0] == "CGE" or args[0] == "CLT" or args[0] == "CGT" or args[0] == "CEQ" or args[0] == "CNE":
            if len(args) != 4:
                print("Error at line "+line+": incorrect num of args")
                break
            A,B,C = [int(x,16)//4 for x in args[1:]]
            append_load(1,B)
            append_load(2,C)
            append_instruction(opcode<<24 | 0<<16 | 1<<8 | 2<<0)
            append_store(0,A)
        elif args[0] == "COP":
            if len(args) != 3:
                print("Error at line "+line)
                break
            A,B = [int(x,16)//4 for x in args[1:]] # A <- B
            append_load(1,B)
            # append_instruction(opcode<<24 | 0<<16 | 1<<8 | 0<<0)
            append_store(1,A)
        elif args[0] == "AFC":
            if len(args) != 3:
                print("Error at line "+line)
                break
            A,B = int(args[1],16)//4, int(args[2][1:])
            append_instruction(opcode<<24 | 0<<16 | B<<8 | 0<<0)
            append_store(0,A)
        elif args[0] == "NOZ":
            if len(args) != 2:
                print("Error at line "+line)
                break
            B = int(args[1],16)//4
            append_load(3,B)
            append_instruction(opcode<<24 | 0<<16 | 3<<8 | 0<<0)
        elif args[0] == "JMP" or args[0] == "JMF":
            if len(args) != 2:
                print("Error at line "+line)
                break
            label = args[1]
            append_jmp(opcode,label)
        elif args[0] == "PRT":
            if len(args) != 3:
                print("Error at line "+line)
                break
            A,B = [int(x,16)//4 for x in args[1:]]
            append_load(7,A)
            append_load(8,B)
            append_instruction(opcode<<24 | 0<<16 | 8<<8 | 7<<0)
        elif args[0] == "GSW":
            if len(args) != 3:
                print("Error at line "+line)
                break
            A,B = [int(x,16)//4 for x in args[1:]] # A <- B
            append_load(2,A)
            append_instruction(opcode<<24 | 1<<16 | 2<<8 | 0<<0)
            append_store(1,B)
        # elif args[0] == "LRF":
        #     if len(args) != 3:
        #         print("Error at line "+line)
        #         break
        #     A,B = [int(x,16)//4 for x in args[1:]] # A <- B
        #     append_load(2,A)
        #     append_instruction(opcode<<24 | 1<<16 | 2<<8 | 0<<0)
        #     append_store(1,B)
        else:
            print("Not implemented instruction: "+args[0]+" at line "+line)
            break

src.close()

out.close()

final_code = ""
with open(sys.argv[2],"r") as almost_done_file:
    final_code = ''.join(almost_done_file.readlines())

for k,v in labels.items():
    # value = f'@@0000'
    value = f'{v:02x}0000'
    final_code = final_code.replace(k,value)

with open(sys.argv[2],"w") as final_file:
    final_file.writelines(final_code)
