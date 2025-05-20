"""
R.I.C.A.R.D. : Renverse Ingenierie Clangue Assembleur Raisingue Debuggeur
Fonctionne sur jeu d'instructions BAR : Binaire Avancé Raisingue
"""

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
    "SRF":20, #Store Reference : SRF **@dest *@src
    "LRF":21, #Load Reference : LRF *@dest **@src
}

def op2ins(op):
    for k,v in instructions.items():
        if v == op:
            return k
    print(f"Unknown op: {op}")
    return None

if len(sys.argv) != 2:
    print("Incorrect args, usage python ricard.py [infile.bin]\nGot : "+' '.join(sys.argv))
    sys.exit(1)

lines = []
with open(sys.argv[1],"r") as file:
    for line in file.readlines():
        line = line[2:11]
        lines.append((op2ins(int(line[:2],16)),int(line[2:4],16),int(line[4:6],16),int(line[6:8],16)))

def print_line(line):
    if line[0] == "ADD":
        print(f"r{line[1]} := r{line[2]} + r{line[3]}")
    elif line[0] == "SUB":
        print(f"r{line[1]} := r{line[2]} - r{line[3]}")
    elif line[0] == "MUL":
        print(f"r{line[1]} := r{line[2]} * r{line[3]}")
    elif line[0] == "DIV":
        print(f"r{line[1]} := r{line[2]} / r{line[3]}")
    elif line[0] == "CLE":
        print(f"r{line[1]} := r{line[2]} <= r{line[3]}")
    elif line[0] == "CGE":
        print(f"r{line[1]} := r{line[2]} >= r{line[3]}")
    elif line[0] == "CLT":
        print(f"r{line[1]} := r{line[2]} < r{line[3]}")
    elif line[0] == "CGT":
        print(f"r{line[1]} := r{line[2]} > r{line[3]}")
    elif line[0] == "CEQ":
        print(f"r{line[1]} := r{line[2]} == r{line[3]}")
    elif line[0] == "CNE":
        print(f"r{line[1]} := r{line[2]} != r{line[3]}")
    elif line[0] == "LDR":
        print(f"r{line[1]} <- @{line[2]}")
    elif line[0] == "STR":
        print(f"@{line[1]} <- r{line[2]}")
    elif line[0] == "AFC":
        print(f"r{line[1]} := #{line[2]}")
    elif line[0] == "NOZ":
        print(f"flag := r{line[2]} != 0")
    elif line[0] == "JMP":
        print(f"goto {line[1]}")
    elif line[0] == "JMF":
        print(f"if (flag == false) goto {line[1]}")
    elif line[0] == "NOP":
        print(f"NOP")
    elif line[0] == "PRT":
        print(f"print(r{line[3]},r{line[2]})")
    elif line[0] == "GSW":
        print(f"r{line[1]} <- switch[r{line[2]}]")
    elif line[0] == "SRF":
        print(f"@at(r{line[2]}) <- r{line[3]}")
    elif line[0] == "LRF":
        print(f"r{line[1]} <- @at{line[2]}")
    else:
        print(f"Unknown: {line}")

def print_code(line_num):
    for i,line in enumerate(lines):
        if i == line_num:
            print(f">{i:3}: ",end='')
        else:
            print(f" {i:3}: ",end='')
        print_line(line)
    print()

def print_few_lines(center_line,size=3):
    mini = center_line - size
    maxi = center_line + size + 1
    if mini < 0:
        maxi -= mini
        mini = 0
    maxi = min(maxi,len(lines))
    for i in range(mini,maxi):
        if i == center_line:
            print(f">{i:3}: ",end='')
        else:
            print(f" {i:3}: ",end='')
        print_line(lines[i])
    print()

reg_mem = [0 for _ in range(16)]
data_mem = [0 for _ in range(256)]
flag = False
line_num = 0
print_whole_code = True
printed = False

def exec_line():
    global line_num
    global flag
    global reg_mem
    global data_mem
    global lines
    global printed
    if line_num >= len(lines):
        return
    line = lines[line_num]
    if line[0] == "ADD":
        reg_mem[line[1]] = (reg_mem[line[2]] + reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "SUB":
        reg_mem[line[1]] = (reg_mem[line[2]] - reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "MUL":
        reg_mem[line[1]] = (reg_mem[line[2]] * reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "DIV":
        reg_mem[line[1]] = (reg_mem[line[2]] // reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "CLE":
        reg_mem[line[1]] = (reg_mem[line[2]] <= reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "CGE":
        reg_mem[line[1]] = (reg_mem[line[2]] >= reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "CLT":
        reg_mem[line[1]] = (reg_mem[line[2]] < reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "CGT":
        reg_mem[line[1]] = (reg_mem[line[2]] > reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "CEQ":
        reg_mem[line[1]] = (reg_mem[line[2]] == reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "CNE":
        reg_mem[line[1]] = (reg_mem[line[2]] != reg_mem[line[3]])%256
        line_num += 1
    elif line[0] == "LDR":
        reg_mem[line[1]] = data_mem[line[2]]
        line_num += 1
    elif line[0] == "STR":
        data_mem[line[1]] = reg_mem[line[2]]
        line_num += 1
    elif line[0] == "AFC":
        reg_mem[line[1]] =line[2]
        line_num += 1
    elif line[0] == "NOZ":
        flag = reg_mem[line[2]] != 0
        line_num += 1
    elif line[0] == "JMP":
        line_num = line[1]
    elif line[0] == "JMF":
        if flag == False:
            line_num = line[1]
        else:
            line_num += 1
    elif line[0] == "NOP":
        line_num += 1
    elif line[0] == "PRT":
        print(f"PRINT {reg_mem[line[3]]} {reg_mem[line[2]]:02x}")
        printed = True
        line_num += 1
    elif line[0] == "GSW":
        v = input(f"Switch n# {reg_mem[line[2]]}?\n > ")
        if len(v) == 0:
            v = 0
        else:
            if v[0]=='0':
                v = 0
            else:
                v = 1
        reg_mem[line[1]] = v
        line_num += 1
    elif line[0] == "SRF":
        print(f"exec srf : {line}")
        data_mem[reg_mem[line[2]]//4] = reg_mem[line[3]]
        line_num += 1
    elif line[0] == "LRF":
        reg_mem[line[1]] = data_mem[reg_mem[line[2]]//4]
        line_num += 1
    else:
        print(f"Unknown: {line}")
        line_num += 1

def print_data():
    for i in range(16):
        for j in range(16):
            index = i*16+j
            print(f"{data_mem[index]:2x} ",end='')
        print()

def print_reg():
    global flag
    global reg_mem
    for i in range(16):
        print(f"r{i:<2}|",end='')
    print()
    for i in range(16):
        print(f"{reg_mem[i]:2x} |",end='')
    print()
    print(f"NOZ: "+str(flag))

print_code(line_num)
while True:
    inpu = input("[D]ata, [R]eg, [L]ist, [T]oggle_whole_code, [C]ontinue, [E]xit: (default: C)" )
    args=[]
    if len(inpu) == 0:
        command = "C"
    else:
        command = inpu[0].capitalize()
        args=inpu.split()[1:]
    if command == "C":
        if len(args) != 0:
            for i in range(int(args[0])):
                exec_line()
        else:
            exec_line()
        if print_whole_code:
            print_code(line_num)
        else:
            print_few_lines(line_num)
    elif command == "D":
        print_data()
    elif command == "R":
        print_reg()
    elif command == "E":
        break
    elif command == "L":
        if print_whole_code:
            print_few_lines(line_num)
        else:
            print_code(line_num)
    elif command == "T":
        print_whole_code = not print_whole_code
    elif command == "P":
        while not printed:
            exec_line()
        printed=False
        if print_whole_code:
            print_code(line_num)
        else:
            print_few_lines(line_num)