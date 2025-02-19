%{
#include "y.tab.h"

#ifdef DEBUG_LEX
#define NAME_RET(x)  {printf(" " #x);}
#define VALUE_RET(x) {printf(" " #x "[%s]",yytext);}
#else //not DEBUG_LEX
#define NAME_RET(x)  {printf(" " #x); return x;}
#define VALUE_RET(x) {printf(" " #x "[%s]",yytext); return x;}
#endif //DEBUG_LEX
%}

%option noyywrap
D   [0-9]
INT {D}+("e"{D}+)?
OPE [+\-*/"<<"">>"&|\^]
TYPE "int"|"const"
NAME [a-zA-Z][a-zA-Z0-9_]*


%%
{INT}           VALUE_RET(tNB)
"="             printf(" tEQ");
"{"             printf(" tOB");
"}"             printf(" tCB");
";"             printf(" tSEM");
","             printf(" tCOMMA");
{OPE}           printf(" tOPE[%s]",yytext);
while           printf(" tWHILE");
void            printf(" tVOID");
{TYPE}          printf(" t[%s]",yytext);
"("             NAME_RET(tOP);
")"             printf(" tCP");
{NAME}          printf(" tID[%s]", yytext);
"//"[^\n]*      printf(" tCOMM[%s]",yytext+2);
"/*".*"*/"      printf(" tCOMM[%s]",yytext);
" "             { }
\t              { }
\n              { }
.               { printf(" ERROR\n"); exit(2); }

%%

// int main(void) {
// 	yylex();
//     return 0;
// }