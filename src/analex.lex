%{
#ifdef DEBUG_LEX
#define NAME_RET(x)  {printf(" " #x);}
#define VALUE_RET(x) {printf(" " #x "[%s]",yytext);}
#else //not DEBUG_LEX
#include "y.tab.h"
#define NAME_RET(x)  {printf(" " #x); return x;}
#define VALUE_RET(x) {printf(" " #x "[%s]",yytext); return x;}
#endif //DEBUG_LEX

//TODO: "==""<="">=""!="
%}

%option noyywrap
D   [0-9]
INT [\-\+]?{D}+("e"{D}+)?
OPE [+\-*/&|\^<>]|"=="|"<="|">="|"!="|"<<"|">>"
TYPE "int"|"const"
NAME [a-zA-Z_][a-zA-Z0-9_]*

%%
"//"[^\n]*                  { }
"/*"(.|\n|\t)*"*/"                  { }
"main"                      NAME_RET(tMAIN)
{INT}                       VALUE_RET(tNB)
{OPE}                       VALUE_RET(tOPE)
"="                         NAME_RET(tEQ)
"{"                         NAME_RET(tOB)
"}"                         NAME_RET(tCB)
"["                         NAME_RET(tOSB)
"]"                         NAME_RET(tCSB)
";"                         NAME_RET(tSEM)
","                         NAME_RET(tCOMMA)
"if"                        NAME_RET(tIF)
"else"                      NAME_RET(tELSE)
"while"                     NAME_RET(tWHILE)
"void"                      NAME_RET(tVOID)
{TYPE}                      VALUE_RET(tTYPE)
"("                         NAME_RET(tOP)
")"                         NAME_RET(tCP)
{NAME}                      VALUE_RET(tID)
" "                         { }
\t                          { }
\n                          { }
.                           { printf(" ERROR[%s]\n",yytext); exit(2); }
%%

// int main(void) {
// 	yylex();
//     return 0;
// }