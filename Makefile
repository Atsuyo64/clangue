all: yacc

lex:
	flex -o build/lex.yy.c src/analex.lex
	gcc build/lex.yy.c src/lex_launcher.c -o build/lex.out

testlex:
	flex -o build/lex.yy.c src/analex.lex
	gcc -D DEBUG_LEX build/lex.yy.c src/lex_launcher.c -o build/lex.out
	build/lex.out < tests/correct-examples/basic.c

yacc:
	yacc -o build/y.tab.c -d -v -t src/anasynt.yacc
	flex -o build/lex.yy.c src/analex.lex
	gcc build/y.tab.c build/lex.yy.c -o build/yacc.out

testyacc: yacc
	build/yacc.out < tests/correct-examples/basic.c
