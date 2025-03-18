%start program

%union {int nb;char* id;}

%token tEQ tOB tCB tSEM tCOMMA tOPE tWHILE tVOID tIF tOP tCP tMAIN tELSE tOSB tCSB

%{
#include "stdio.h"
#include "vector.h"
FILE* file;
vector vec;
TYPE currentType = INT;
%}

%token <nb> tNB
%token <id> tID tTYPE
%type <nb> rvalue

%%

program:
        tMAIN tOP tCP body 
    ;

body:
        tOB {elevate(&vec);} expressions tCB {delevate(&vec);} 
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
        tTYPE tID {
            cell data = {$2,vec.max_height,NULL,str2type($1)};
            push(&vec,data);
        }
    |
        tTYPE {currentType=str2type($1);} tID tCOMMA declaration {
            cell data = {$2,vec.max_height,NULL,currentType};
            push(&vec,data);
        }
    |
        tTYPE tID tEQ rvalue {
            //FIXME: use rvalue !
            cell data = {$2,vec.max_height,NULL,str2type($1)};
            push(&vec,data);
        }
    ;

declaration:
        tID {
            cell data = {$1,vec.max_height,NULL,currentType};
            push(&vec,data);
        }
    |
        tID tCOMMA declaration {
            cell data = {$1,vec.max_height,NULL,currentType};
            push(&vec,data);
        }
    |
        tID tEQ rvalue {
            cell data = {$1,vec.max_height,NULL,currentType};
            push(&vec,data);
        }
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
        tID tOSB rvalue tCSB
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

int main(int argv, char** argc){
    vec = newVector();
    if(argv==1)
        file = stdin;
    else
        file = fopen(argc[1],"w");
    yydebug = 1;
    return yyparse();
}