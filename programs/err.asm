AFC 0x8 #254
COP 0x4 0x8
__WHILE_0:
AFC 0x8 #1
NOZ 0x8
JMF __END_WHILE_0
AFC 0xc #1
ADD 0x8 0x4 0xc
COP 0x4 0x8
AFC 0xc #104
COP 0x8 0xc
AFC 0x10 #1
ADD 0xc 0x8 0x10
COP 0x8 0xc
JMP __WHILE_0
__END_WHILE_0:
AFC 0xc #1
COP 0x8 0xc
AFC 0xc #5
COP 0x8 0xc
