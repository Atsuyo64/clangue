yacc -o build/y.tab.c -d -v -t src/anasynt.yacc
flex -o build/lex.yy.c src/analex.lex
gcc build/y.tab.c build/lex.yy.c -o build/yacc.out
build/yacc.out < $1
if [[ $? != 0 ]]; then
    echo ERROR, running lex
    ./run_lex.sh $1
fi