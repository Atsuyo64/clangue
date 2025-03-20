#pragma once

char* getTempVarName();

char* openWhile();
char* endWhile();
char* getCurrentWhileStartFlag();
char* getCurrentWhileEndFlag();

void openIf();
char* endIf();
char* getCurrentIfElseFlag();
char* getCurrentIfEndFlag();