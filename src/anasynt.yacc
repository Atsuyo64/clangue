%start program

%union {int nb;char* id;int* ptr;}

%token tEQ tOB tCB tSEM tCOMMA tWHILE tVOID tIF tOP tCP tMAIN tELSE tOSB tCSB tADD tSUB tMUL tDIV

%right tEQ
%left tADD tSUB
%left tMUL tDIV


//TODO: dangling else 

%{
#include "stdio.h"
#include "vector.h"
#include "stdlib.h" //exit
#include "utils.h"

void yyerror(char *s); //
FILE* file;
vector vec;
TYPE currentType = INT;
int if_height = 0;
int while_height = 0;

%}

%token <nb> tNB
%token <id> tID tTYPE tOPE
%type <ptr> rvalue lvalue

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
            push(&vec,$2);
        }
    |
        tTYPE tID tCOMMA declaration {
            push(&vec,$2);
        }
    |
        tTYPE tID tEQ rvalue {
            int* ptr = push(&vec,$2);
            fprintf(file,"LOAD %p %p\n",ptr,$4);
        }
    ;

declaration:
        tID {
            push(&vec,$1);
        }
    |
        tID tCOMMA declaration {
            push(&vec,$1);
        }
    |
        tID tEQ rvalue {
            int* ptr = push(&vec,$1);
            fprintf(file,"LOAD %p %p\n",ptr,$3);
        }
    ;

whilif:
        if 
    |
        while
    ;

while:
        {   
            elevate(&vec);
            fprintf(file,"%s:\n",openWhile());
        }
        tWHILE tOP rvalue tCP
        {
            fprintf(file,"NOZ $3\n");
            fprintf(file,"JMF %s\n",getCurrentWhileEndFlag());
        }
        statement
        {
            fprintf(file,"JMP %s\n",getCurrentWhileStartFlag());
            fprintf(file,"%s:\n",endWhile());
            delevate(&vec);
        }
    ;

if:
        {
            elevate(&vec);
            openIf();
        }
        tIF tOP rvalue tCP 
        {
            fprintf(file,"NOZ $3\n");
            fprintf(file,"JMF %s\n",getCurrentIfEndFlag());
        }
        statement
        {
            fprintf(file,"%s:\n",endIf());
            delevate(&vec);
        }
    |
        //TODO: conflit ici
        {
            elevate(&vec);
            openIf();
        }
        tIF tOP rvalue tCP 
        {
            fprintf(file,"NOZ $3\n");
            fprintf(file,"JMF %s\n",getCurrentIfElseFlag());
        }
        statement 
        {
            fprintf(file,"JMP %s\n",getCurrentIfEndFlag());
            fprintf(file,"%s:\n",getCurrentIfElseFlag());
        }
        tELSE statement
        {
            fprintf(file,"%s:\n",endIf());
        }
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
lvalue: //ok
        tID {
            cell* data;
            if(data = find(&vec,$1)) {
                $$=data->ptr;
            }
            else{
                fprintf(stderr,"Undef symbol %s at line '%i'",$1,__LINE__);
                fprintf(file,"Undef symbol %s at line '%i'",$1,__LINE__);
                exit(1);
            }
        }
    |
        tID tOSB rvalue tCSB {
            fprintf(stderr,"Not implemented a[i]: (%i)",__LINE__);
            exit(1);
        }
    ;

rvalue:
        tNB {
            //TODO: elevate
            int* ptr = push(&vec,getTempVarName());
            fprintf(file,"AFC %p #%i\n",ptr,$1);
            $$=ptr;
        }
    |
        lvalue
    |
        rvalue tADD rvalue {
            int* ptr = push(&vec,getTempVarName());
            fprintf(file,"ADD %p %p %p\n",ptr,$1,$3);
            $$=ptr;
        }
    |
        rvalue tSUB rvalue {
            int* ptr = push(&vec,getTempVarName());
            fprintf(file,"SUB %p %p %p\n",ptr,$1,$3);
            $$=ptr;
        }
    |
        rvalue tMUL rvalue {
            int* ptr = push(&vec,getTempVarName());
            fprintf(file,"MUL %p %p %p\n",ptr,$1,$3);
            $$=ptr;
        }
    |
        rvalue tDIV rvalue {
            int* ptr = push(&vec,getTempVarName());
            fprintf(file,"DIV %p %p %p\n",ptr,$1,$3);
            $$=ptr;
        }
    |
        rvalue tOPE rvalue {
            fprintf(stderr,"Unsupported operation: %s (line %i)\n",$2,__LINE__);
            exit(1);
        }
    |
        lvalue tEQ rvalue {
            fprintf(file,"LOAD %p %p\n",$1,$3);
            $$=$1;
        }
    |
        tOP rvalue tCP {$$=$2;}
    ; 



%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s) ;
}

int main(int argv, char** argc){
    vec = newVector();
    if(argv==1){
        printf("WRITING TO STDOUT\n");
        file = stdout;
    }
    else
        file = fopen(argc[1],"w");
    yydebug = 1;
    int ret =  yyparse();
    if (file != stdout)
        fclose(file);
    return ret; 
}