import sys

instructions = {
    "ADD":1,
    "MUL":2,
    "SUB":3,
    "DIV":4,
    "COP":5,
    "AFC":6,
    "JMP":7,
    "JNE":8,
    "NOZ":9,
}

labels = {}
line = 0

if len(sys.argv) != 3:
    print("Incorrect args, usage python asm2machineCode.py [infile] [outfile]\nGot : "+sys.argv)
    sys.exit(1)


try:
    src = open(sys.argv[1],"r")
except OSError as e:
    print("Could not open "+sys.argv[1],e)
    sys.exit(1)
try:
    out = open(sys.argv[2],"wb")
except OSError as e:
    print("Could not open "+sys.argv[2],e)
    src.close()
    sys.exit(1)

for line in src.readlines():
    if line.endswith('\n'):
        line = line[:-1]
    if line.endswith(':'):
        labels[line[:-1]] = line
    else:
        args = line.split()
        if args[0] not in instructions.keys():
            print("Unknown instruction: "+args[0])
            break
        

src.close()
out.close()