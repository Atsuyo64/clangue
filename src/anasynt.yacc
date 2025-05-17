%start program

%union {int nb;char* id;int* ptr;}

%token tEQ tOB tCB tSEM tCOMMA tWHILE tFOR tVOID tPRINTF tIF tOP tCP tMAIN tELSE tOSB tCSB tADD tSUB tMUL tDIV tREADSW

%token <nb> tNB
%token <id> tID tTYPE tOPE
%type <ptr> rvalue lvalue

%nonassoc REDUCE 
%nonassoc tELSE

%right tEQ
%left tADD tSUB
%left tMUL tDIV tOPE

%{
#include "stdio.h"
#include "vector.h"
#include "stdlib.h" //exit
#include "utils.h"

#define YYDEBUG 1

extern int yylex (void);
void yyerror(const char *s); //
extern int yylineno;
extern char *yytext;

void yyerror(const char *s) {
    fprintf(stderr, "Y a une saucisse dans mon cassoulet !\nErreur à la con à la ligne %d putaingue, près de \"%s\": %s\n", yylineno, yytext, s);
}

FILE* file;
vector vec;
TYPE currentType = INT;
int if_height = 0;
int while_height = 0;

%}


%%

program:
        tMAIN tOP tCP body
        /* |
        tMAIN tOP tCP body error { // FIXME: marche pas snif
            yyerror("Missing '}' at end of main");
            yyerrok;
        } */
    ;

body:
        tOB {elevate(&vec);} expressions tCB {delevate(&vec);}
        /* |
        tOB {elevate(&vec);} expressions tCB error { // FIXME: marche pas snif
            yyerror("Missing '}' at end of body");
            yyerrok;
        } */
    ;

expressions: 
        /* empty */
        |
        tSEM expressions /* moche mais fait partie de la spec C */
        |
        statement expressions
    ;

expression:
        {elevate(&vec);} rvalue {delevate(&vec);}
    |
        tPRINTF tOP {elevate(&vec);} rvalue {fprintf(file,"PRT %p\n",$4); delevate(&vec);} tCP 
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
            push_ptr(push(&vec,$2));
            elevate(&vec);
        } 
        tEQ rvalue
        {
            fprintf(file,"COP %p %p\n",pop_ptr(),$5); //FIXME: AFC -> COP
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
            push_ptr(push(&vec,$1));
            elevate(&vec);
        } 
        tEQ rvalue
        {
            fprintf(file,"COP %p %p\n",pop_ptr(),$4); //FIXME: AFC -> COP
            delevate(&vec);
        }
    ;

whilif:
        if 
    |
        while
    ;

while:
        tWHILE 
        {   
            elevate(&vec);
            fprintf(file,"%s:\n",openWhile());
        }
        tOP {elevate(&vec);} rvalue {delevate(&vec);} tCP
        {
            fprintf(file,"NOZ %p\n",$5);
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
        tIF 
        {
            elevate(&vec);
            openIf();
        }
        tOP {elevate(&vec);} rvalue {delevate(&vec);} tCP 
        {
            fprintf(file,"NOZ %p\n",$5);
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
        /*empty*/ %prec REDUCE
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
        tADD rvalue {
            $$=$2;
        } 
    |
        tSUB rvalue {
            int* ptr = push(&vec,getTempVarName());
            fprintf(file,"AFC %p #0\n",ptr);
            fprintf(file,"SUB %p %p %p\n",ptr,ptr,$2);
            $$=ptr;
        }
    |
        lvalue
    |
        tREADSW tOP {
                push_ptr(push(&vec,getTempVarName()));
                elevate(&vec);
            } rvalue tCP {
                int* ptr = pop_ptr();
                fprintf(file,"GSW %p %p\n",$4, ptr);
                $$=ptr;
                delevate(&vec);
            }
    |
        rvalue tADD
        {
            push_ptr(push(&vec,getTempVarName()));
            elevate(&vec);
        }
        rvalue {
            int* ptr = pop_ptr();
            fprintf(file,"ADD %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    |
        rvalue tSUB
        {
            push_ptr(push(&vec,getTempVarName()));
            elevate(&vec);
        }
        rvalue {
            int* ptr = pop_ptr();
            fprintf(file,"SUB %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    |
        rvalue tMUL
        {
            push_ptr(push(&vec,getTempVarName()));
            elevate(&vec);
        }
        rvalue {
            int* ptr = pop_ptr();
            fprintf(file,"MUL %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    |
        rvalue tDIV
        {
            push_ptr(push(&vec,getTempVarName()));
            elevate(&vec);
        }
        rvalue {
            int* ptr = pop_ptr();
            fprintf(file,"DIV %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    |
        rvalue tOPE rvalue {
            fprintf(stderr,"Unsupported operation: %s (line %i)\n",$2,__LINE__);
            exit(1);
        }
    |
        lvalue tEQ {elevate(&vec);} rvalue {
            delevate(&vec);
            fprintf(file,"COP %p %p\n",$1,$4);
            $$=$1;
        }
    |
        tOP rvalue tCP {$$=$2;}
    ; 



%%

/* void yyerror(char *s) {
    fprintf(stderr, "%s\n", s) ;
} */

int main(int argc, char** argv){
    vec = newVector();
    if(argc==1){
        printf("WRITING TO STDOUT\n");
        file = stdout;
    }
    else
        file = fopen(argv[1],"w");
    yydebug = argc > 2;
    int ret =  yyparse();
    if (file != stdout)
        fclose(file);
    return ret; 
}