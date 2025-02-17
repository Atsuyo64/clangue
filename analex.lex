%option noyywrap
D   [0-9]
INT {D}+("e"{D}+)?
OPE [+\-*/"<<"">>"&|\^]
TYPE "int"|"const"
NAME [a-zA-Z][a-zA-Z0-9_]*


%%
{INT}            printf(" tNB[%s]", yytext);
"="             printf(" tEQ");
"{"             printf(" tOB");
"}"             printf(" tCB");
";"             printf(" tSEM");
","             printf(" tCOMMA");
{OPE}           printf(" tOPE[%s]",yytext);
while           printf(" tWHILE");
void            printf(" tVOID");
{TYPE}          printf(" t[%s]",yytext);
"("             printf(" tOP");
")"             printf(" tCP");
{NAME}          printf(" tID[%s]", yytext);
"//"[^\n]*       printf(" tCOMM[%s]",yytext+2);
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