%start program

%union {int nb;char* id;int* ptr;}

%token tEQ tOB tCB tSEM tCOMMA tWHILE tVOID tIF tOP tCP tMAIN tELSE tOSB tCSB tADD tSUB tMUL tDIV

%right tEQ
%left tADD tSUB
%left tMUL tDIV

//TODO: test dangling elses
//FIXME: elevate around rvalues !

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
        {elevate(&vec);} rvalue {deletave(&vec);}
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
        tTYPE tID 
        {
            int* ptr = push(&vec,$2);
            elevate(&vec);
        } 
        tEQ rvalue
        {
            fprintf(file,"LOAD %p %p\n",ptr,$4); //FIXME: AFC -> LOAD
            delevate(&vec);
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
        tID 
        {
            int* ptr = push(&vec,$1);
            elevate(&vec);
        } 
        tEQ rvalue
        {
            fprintf(file,"LOAD %p %p\n",ptr,$3); //FIXME: AFC -> LOAD
            delevate(&vec);
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
        tWHILE tOP {elevate(&vec);} rvalue {delevate(&vec);} tCP
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
        tIF tOP {elevate(&vec);} rvalue {delevate(&vec);} tCP 
        {
            fprintf(file,"NOZ $3\n");
            fprintf(file,"JMF %s\n",getCurrentIfElseFlag());
        }
        statement 
        {
            delevate(&vec);
            fprintf(file,"JMP %s\n",getCurrentIfEndFlag());
            fprintf(file,"%s:\n",getCurrentIfElseFlag());
            elevate(&vec);
        }
        if_part_2
        {
            fprintf(file,"%s:\n",endIf());
            delevate(&vec);
        }
    ;

if_part_2:
        /*empty*/
    |
        tELSE statement
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
            int* ptr = push(&vec,getTempVarName());
            fprintf(file,"AFC %p #%i\n",ptr,$1);
            $$=ptr;
        }
    |
        tADD rvalue { //+10 conflits de canard ???
            $$=$2;
        } %prec'*'
    |
        tSUB rvalue { //+10 conflits de canard ???
            int* ptr = push(&vec,getTempVarName());
            fprintf(file,"AFC %p #0\n",ptr);
            fprintf(file,"SUB %p %p %p\n",ptr,ptr,$2);
            $$=ptr;
        } %prec'*'
    |
        lvalue
    |
        {
            int* ptr = push(&vec,getTempVarName());
            elevate(&vec);
        }
        rvalue tADD rvalue {
            fprintf(file,"ADD %p %p %p\n",ptr,$1,$3);
            $$=ptr;
            delevate(&vec);
        }
    |
    
        {
            int* ptr = push(&vec,getTempVarName());
            elevate(&vec);
        }
        rvalue tSUB rvalue {
            fprintf(file,"SUB %p %p %p\n",ptr,$1,$3);
            $$=ptr;
            delevate(&vec);
        }
    |
        {
            int* ptr = push(&vec,getTempVarName());
            elevate(&vec);
        }
        rvalue tMUL rvalue {
            fprintf(file,"MUL %p %p %p\n",ptr,$1,$3);
            $$=ptr;
            delevate(&vec);
        }
    |
        {
            int* ptr = push(&vec,getTempVarName());
            elevate(&vec);
        }
        rvalue tDIV rvalue {
            fprintf(file,"DIV %p %p %p\n",ptr,$1,$3);
            $$=ptr;
            delevate(&vec);
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