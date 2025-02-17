%start program

%token tNB tEQ tOB tCB tSEM tCOMMA tOPE tWHILE tVOID t tOP tCP tID tCOMM

%%
//rules

program:
        tOP tCP body
    ;

body:
        tOB expression tCB
    ;
expression:
        tSEM
        ;



%%

#include <stdio.h>

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s) ;
}

int main(){
    yydebug = 1;
    return yyparse();
}