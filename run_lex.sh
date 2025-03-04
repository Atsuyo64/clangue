flex analex.lex
gcc -D DEBUG_LEX lex.yy.c lex_launcher.c -o lex.out
./lex.out < $1