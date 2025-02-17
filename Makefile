all:
	flex source.lex
	gcc lex.yy.c -o lex.out

test: all
	./lex.out < src/test.c > WIP/test.c.txt
	cat WIP/test.c.txt