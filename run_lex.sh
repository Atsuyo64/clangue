flex -o build/lex.yy.c src/analex.lex
gcc -D DEBUG_LEX build/lex.yy.c src/lex_launcher.c -o build/lex.out
build/lex.out < $1