%start program

%union {int nb;char* id;int* ptr;}

%token tEQ tOB tCB tSEM tCOMMA tWHILE tFOR tVOID tPRINTF tIF tOP tCP tMAIN tELSE tOSB tCSB tADD tSUB tMUL tDIV tREADSW tESP tLE tGE tLT tGT tCEQ tNEQ

%token <nb> tNB
%token <id> tID tTYPE tOPE
%type <ptr> rvalue lvalue rel_expr add_expr mul_expr unary primary //pointer
       /* non‐associative, highest precedence */


%nonassoc USTAR UADDR UPLUS USUB
/* %nonassoc USTAR  */
%nonassoc REDUCE 
%nonassoc tELSE


%left tESP
%left tADD tSUB
%left tMUL tDIV tOPE
%left tLE tGE tLT tGT tCEQ tNEQ
/* %left tLT tGT tLE tGE
%left tCEQ tNEQ */
%right tEQ

%{
#include "stdio.h"
#include "vector.h"
#include "stdlib.h" //exit
#include "utils.h"

#define YYDEBUG 1

extern int yylex (void);
extern int yylineno;
extern char *yytext;

void yyerror(const char *s) {
    fprintf(stderr, "Erreur à la ligne %d, près de \"%s\": %s\n", yylineno, yytext, s);
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
        {elevate(&vec);} rvalue {delevate(&vec);}
    |
        tPRINTF tOP {elevate(&vec);} rvalue tCOMMA rvalue {fprintf(file,"PRT %p %p\n",$4,$6); delevate(&vec);} tCP 
    |
        declarations
    ;

declarations:
        tTYPE tID {
            push_value(&vec,$2);
        }
    |
        tTYPE tID tCOMMA declaration {
            push_value(&vec,$2);
        }
    |
        tTYPE tID 
        {
            push_ptr(push_value(&vec,$2));
            elevate(&vec);
        } 
        tEQ rvalue
        {
            fprintf(file,"COP %p %p\n",pop_ptr(),$5);
            delevate(&vec);
        }
    |
        tTYPE tMUL tID                         
        { 
            /* allocate a pointer cell of ptr_level=1 */
            push_pointer(&vec, $3, /* ptr_level= */1);
        }
    | 
        tTYPE tMUL tID tEQ rvalue             
        {

            //FIXME: TEMPLATE ????
            int *dst = push_pointer(&vec, $3, /* ptr_level= */1);
            // fprintf(file, "AFC %p #%d\n", dst, $5);
            fprintf(file, "COP %p %p\n", dst, $5);
        }
    ;

/* pointer:
      /* empty *      { $$ = 0; }
    | tMUL pointer     { $$ = $2 + 1; /* nombur of ref (for instance **a has 2) * }
    ; */

declaration:
        tID {
            push_value(&vec,$1);
        }
    |
        tID tCOMMA declaration {
            push_value(&vec,$1);
        }
    |
        tID 
        {
            push_ptr(push_value(&vec,$1));
            elevate(&vec);
        } 
        tEQ rvalue
        {
            fprintf(file,"COP %p %p\n",pop_ptr(),$4);
            delevate(&vec);
        }
    | tMUL tID                         
      { push_pointer(&vec, $2, /* ptr_level= */1); }
    | tMUL tID tEQ rvalue             
      {
        int *dst = push_pointer(&vec, $2, /* ptr_level= */1);
        // fprintf(file, "AFC %p #%d\n", dst, $4);
        fprintf(file, "COP %p %p\n", dst, $4);
      }
    ;
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


primary:
      tNB                {
            int* ptr = push_value(&vec,getTempVarName());
            fprintf(file,"AFC %p #%i\n",ptr,$1);
            $$=ptr;
        }
    | lvalue             { /* identifier or array */ }
    | tOP rvalue tCP     { $$ = $2;                }
    | tREADSW tOP {
                push_ptr(push_value(&vec,getTempVarName()));
                elevate(&vec);
            } rvalue tCP {
                int* ptr = pop_ptr();
                fprintf(file,"GSW %p %p\n",$4, ptr);
                $$=ptr;
                delevate(&vec);
            }
    ;

unary:
      tMUL unary   %prec USTAR
                    {
        int *p = $2;
        /* generate a temporary to hold the loaded value */
        int *temp = push_pointer(&vec,
                                getTempVarName(),
                                /* ptr_level = original ptr_level–1 */
                                find_ptr_level(&vec, p) - 1
                               );
        fprintf(file, "LRF %p %p\n", temp, p);
        $$ = temp;
    }
    | tESP lvalue    %prec UADDR
                    { 
            /* TODO: FIXME: $2 is an address of the variable; but we want the address‐of operator: */
            /* For a local variable, address = its ptr field (already an address) */
            int *p = $2;
            int *temp = push_pointer(&vec,
                                getTempVarName(),
                                /* ptr_level = original ptr_level–1 */
                                find_ptr_level(&vec, p) + 1
                            );
        fprintf(file, "AFC %p #%d\n", temp, p);
            $$ = temp; 
        }
    | tADD unary     %prec UPLUS
                    {
            $$=$2;
        } 
    | tSUB unary     %prec USUB
                    {
            int* ptr = push_value(&vec,getTempVarName());
            fprintf(file,"AFC %p #0\n",ptr);
            fprintf(file,"SUB %p %p %p\n",ptr,ptr,$2);
            $$=ptr;
        }
    | primary
    ;

mul_expr:
      mul_expr tMUL
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        mul_expr {
            int* ptr = pop_ptr();
            fprintf(file,"MUL %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | mul_expr tDIV
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        unary {
            int* ptr = pop_ptr();
            fprintf(file,"DIV %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | unary
    ;

add_expr:
      add_expr tADD
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        mul_expr {
            int* ptr = pop_ptr();
            fprintf(file,"ADD %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | add_expr tSUB
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        mul_expr {
            int* ptr = pop_ptr();
            fprintf(file,"SUB %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | mul_expr
    ;

rel_expr:
    rel_expr tLE
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        add_expr {
            int* ptr = pop_ptr();
            fprintf(file,"CLE %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | rel_expr tGE
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        add_expr {
            int* ptr = pop_ptr();
            fprintf(file,"CGE %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    |  rel_expr tLT
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        add_expr {
            int* ptr = pop_ptr();
            fprintf(file,"CLT %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | rel_expr tGT
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        add_expr {
            int* ptr = pop_ptr();
            fprintf(file,"CGT %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | rel_expr tCEQ
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        add_expr {
            int* ptr = pop_ptr();
            fprintf(file,"CEQ %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | rel_expr tNEQ
        {
            push_ptr(push_value(&vec,getTempVarName()));
            elevate(&vec);
        }
        add_expr {
            int* ptr = pop_ptr();
            fprintf(file,"CNE %p %p %p\n",ptr,$1,$4);
            $$=ptr;
            delevate(&vec);
        }
    | add_expr
    ;

rvalue:
      rel_expr
    | lvalue tEQ {elevate(&vec);} rvalue {
            delevate(&vec);
            fprintf(file,"COP %p %p\n",$1,$4);
            $$=$1;
        }

    | tMUL lvalue %prec tEQ tEQ {elevate(&vec);} rvalue {
            delevate(&vec);
            fprintf(file,"SRF %p %p\n",$2,$5);
            $$=$2;
        }
    ;
// TODO: *(ptr + 1)
// TODO: 13[ptr]
lvalue:
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


%%

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