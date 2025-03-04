yacc -d -v -t anasynt.yacc
flex analex.lex
gcc y.tab.c lex.yy.c -o yacc.out
./yacc.out < $1
if [[ $? != 0 ]]; then
    echo ERROR, running lex
    ./run_lex.sh $1
fi