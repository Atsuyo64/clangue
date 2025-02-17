all:
	flex analex.lex
	yacc -v anasynt.yacc
	gcc lex.yy.c y.tab.c -o out.out

lex:
	flex analex.lex
	gcc lex.yy.c lex_launcher.c -o lex.out

testlex: lex
	./lex.out < src/test.c > WIP/test.c.txt
	cat WIP/test.c.txt