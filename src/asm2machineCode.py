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
}

##NOTE TO SELF: ADD A B C ≡ A := B + C

##TODO: diviser addresses

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
    print(f"{op} {(hexa>>16)&0xff:02} {(hexa>>8)&0xff:02} {(hexa>>0)&0xff:02}")

def append_instruction(hexa):
    print_hexa(hexa)
    assert 13 == out.write(f'x"{hexa:08x}",\n')

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
        if args[0] == "ADD" or args[0] == "SUB" or args[0] == "MUL" or args[0] == "DIV":
            if len(args) != 4:
                print("Error at line "+line+": incorrect num of args")
                break
            A,B,C = [int(x,16) for x in args[1:]]
            append_load(1,B)
            append_load(2,C)
            append_instruction(opcode<<24 | 0<<16 | 1<<8 | 2<<0)
            append_store(0,A)
            instr_counter+=4
        elif args[0] == "COP":
            if len(args) != 3:
                print("Error at line "+line)
                break
            A,B = [int(x,16) for x in args[1:]] # A <- B
            append_load(1,B)
            # append_instruction(opcode<<24 | 0<<16 | 1<<8 | 0<<0)
            append_store(1,A)
            instr_counter+=2
        elif args[0] == "AFC":
            if len(args) != 3:
                print("Error at line "+line)
                break
            A,B = int(args[1],16), int(args[2][1:])
            append_instruction(opcode<<24 | 0<<16 | B<<8 | 0<<0)
            append_store(0,A)
            instr_counter+=2
        else:
            print("Not implemented instruction: "+args[0]+" at line "+line)
            break

src.close()



out.close()