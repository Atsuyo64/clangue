all: yacc

lex:
	flex analex.lex
	gcc lex.yy.c lex_launcher.c -o lex.out

testlex: lex
	./lex.out < src/test.c > WIP/test.c.txt
	cat WIP/test.c.txt

yacc:
	flex analex.lex
	yacc -d -v -t anasynt.yacc
	gcc y.tab.c lex.yy.c -o yacc.out

testyacc: yacc
	./yacc.out < src/test.c > WIP/test.c.txt
	cat WIP/test.c.txt
