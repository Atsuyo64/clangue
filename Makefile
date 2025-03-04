all: yacc

lex:
	flex analex.lex
	gcc lex.yy.c lex_launcher.c -o lex.out

testlex:
	flex analex.lex
	gcc -D DEBUG_LEX lex.yy.c lex_launcher.c -o lex.out
	./lex.out < src/test.c > WIP/test.c.txt
	cat WIP/test.c.txt

yacc:
	yacc -d -v -t anasynt.yacc
	flex analex.lex
	gcc y.tab.c lex.yy.c -o yacc.out

testyacc: yacc
	./yacc.out < tests/correct-examples/basic.c > WIP/test.c.txt
	cat WIP/test.c.txt
