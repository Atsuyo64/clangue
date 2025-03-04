%start program

%token tNB tEQ tOB tCB tSEM tCOMMA tOPE tWHILE tVOID tIF tOP tCP tID tMAIN tELSE tTYPE

%%

program:
        tMAIN tOP tCP body
    ;

body:
        tOB expressions tCB
    ;

expressions: 
        /* empty */
        |
        tSEM expressions /* moche mais fait partie de la spec C */
        |
        statement expressions
    ;

expression:
        rvalue
    |
        declarations
    ;

declarations:
        tTYPE declaration
    ;

declaration:
        tID
    |
        tID tCOMMA declaration
    |
        tID tEQ rvalue
    ;

whilif:
        if
    |
        while
    ;

while:
        tWHILE tOP rvalue tCP statement
    ;

if:
        tIF tOP rvalue tCP statement
    |
        tIF tOP rvalue tCP statement tELSE statement
    ;

statement:
        body
    |
        expression tSEM
    |
        whilif
    ;

// TODO: *(ptr + 1)
// TODO: 13[ptr]
lvalue:
        tID
    |
        tID tOB rvalue tCB
    ;

rvalue:
        tNB
    |
        lvalue
    |
        rvalue tOPE rvalue
    |
        tNB tOPE rvalue
    |
        lvalue tEQ rvalue
    |
        tOP rvalue tCP
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