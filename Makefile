INCLUDE=-Isrc

all: yacc

lex:
	flex -o build/lex.yy.c src/analex.lex
	gcc build/lex.yy.c src/lex_launcher.c -o build/lex.out

testlex:
	flex -o build/lex.yy.c src/analex.lex
	gcc -D DEBUG_LEX build/lex.yy.c src/lex_launcher.c -o build/lex.out
	build/lex.out < tests/correct-examples/basic.c

yacc:# build/src/vector.o build/src/utils.o
	yacc -o build/y.tab.c -d -v -t src/anasynt.yacc
	flex -o build/lex.yy.c src/analex.lex
	gcc $(INCLUDE) build/y.tab.c build/lex.yy.c src/vector.c src/utils.c -o build/yacc.out

testyacc: yacc
	build/yacc.out < tests/correct-examples/basic.c

#build/src/vector.o: src/vector.h src/vector.c
#	gcc -c -o build/src/vector.o $INCLUDE src/vector.c
#
#build/src/utils.o: src/utils.h src/utils.c
#	gcc -c -o build/src/utils.o $INCLUDE src/utils.c