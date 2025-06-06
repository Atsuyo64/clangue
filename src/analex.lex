%{
#include "string.h"
#include "stdlib.h"
#ifdef DEBUG_LEX
#define NAME_RET(x)  {printf(" " #x);}
#define VALUE_RET_ID(x) {printf(" " #x "[%s]",yytext);}
#define VALUE_RET_NB(x) {printf(" " #x "[%s]",yytext);}
#else //not DEBUG_LEX
#include "y.tab.h"
#define printf(...) {}
#define NAME_RET(x)  {printf(" " #x); return x;}
#define VALUE_RET_ID(x) {printf(" " #x "[%s]",yytext); yylval.id=strdup(yytext); return x;}
#define VALUE_RET_NB(x) {printf(" " #x "[%s]",yytext); yylval.nb=(int)strtold(yytext,NULL); return x;}
#endif //DEBUG_LEX

%}
%option noyywrap yylineno
D   [0-9]
INT {D}+([eE]{D}+)?|0[xX][0-9a-fA-F]+
OPE [|\^]|"<<"|">>"
TYPE "int"|"const"
NAME [a-zA-Z_][a-zA-Z0-9_]*

%%
"//"[^\n]*                  { }
"/*"([^*]*"*"+[^*/])*[^*]*"*"+"/"   { /* multi line comments */ }
"main"                      NAME_RET(tMAIN)
{INT}                       VALUE_RET_NB(tNB)
"&"                         NAME_RET(tESP)
"<="                        NAME_RET(tLE)
">="                        NAME_RET(tGE)
"<"                         NAME_RET(tLT)
">"                         NAME_RET(tGT)
"=="                        NAME_RET(tCEQ)
"!="                        NAME_RET(tNEQ)
"+"                         NAME_RET(tADD)
"-"                         NAME_RET(tSUB)
"*"                         NAME_RET(tMUL)
"/"                         NAME_RET(tDIV)
{OPE}                       VALUE_RET_ID(tOPE)
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
"for"                       NAME_RET(tFOR)
"void"                      NAME_RET(tVOID)
"printf"                    NAME_RET(tPRINTF)
"read_switch"               NAME_RET(tREADSW)
{TYPE}                      VALUE_RET_ID(tTYPE)
"("                         NAME_RET(tOP)
")"                         NAME_RET(tCP)
{NAME}                      VALUE_RET_ID(tID)
" "                         { }
\t                          { }
\n                          { /*++yylineno;*/ }
.                           { printf(" ERROR[%s]\n",yytext); exit(2); }
%%

#ifndef DEBUG_LEX
#undef printf
#endif
// int main(void) {
// 	yylex();
//     return 0;
// }