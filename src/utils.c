#include "utils.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MAX_VAR_NAM_SIZE 256
#define MAX_WHILE_DEPTH 256
#define MAX_IF_DEPTH 256

/* ################# TEMP VARS ################# */

static int tmpCnt = 0;
static char tmpName[MAX_VAR_NAM_SIZE];

char* getTempVarName()
{
    //memset(&tmpName[0], 0, MAX_VAR_NAM_SIZE);
    strcpy(tmpName, "__TMP");
    char tmpNameNumber[MAX_VAR_NAM_SIZE - 5];
    sprintf(tmpNameNumber, "%d", tmpCnt);
    strcat(tmpName, tmpNameNumber);
    tmpCnt++;
    return tmpName;
}

/* ################# WHILE STACK ################# */

static int whileCnt = 0;
static int whileDepth = 0;
static int whileStack[MAX_WHILE_DEPTH] = {};
static char whileName[MAX_VAR_NAM_SIZE];

char* openWhile() {
    if (whileDepth >= MAX_WHILE_DEPTH) {
        fprintf(stderr, "ERROR: WHILE STACK TOO HIGH.\n");
        exit(1);
    }   
    whileStack[whileDepth++] = whileCnt++;
    return getCurrentWhileStartFlag();
}

char* endWhile() {
    if (whileDepth == 0) {
        fprintf(stderr, "ERROR: IMPOSSIBLE TO CLOSE NON EXISTENT WHILE\n");
        exit(1);
    }   
    char* endFlagName = getCurrentWhileStartFlag();
    whileDepth--;
    return endFlagName;
}

char* getCurrentWhileStartFlag()
{
    if (whileDepth == 0) {
        fprintf(stderr, "ERROR: CAN'T GET WSF:, NOT IN A WHILE LOOP\n");
        exit(1);
    }
    strcpy(whileName, "__WSF"); // while start: flag
    char whileNameNumber[MAX_VAR_NAM_SIZE - 5];
    sprintf(whileNameNumber, "%d", whileStack[whileDepth - 1]);
    strcat(whileName, whileNameNumber);
    tmpCnt++;
    return whileName;
}

char* getCurrentWhileEndFlag()
{
    if (whileDepth == 0) {
        fprintf(stderr, "ERROR: CAN'T GET WEF:, NOT IN A WHILE LOOP\n");
        exit(1);
    }
    strcpy(whileName, "__WEF"); // while end: flag
    char whileNameNumber[MAX_VAR_NAM_SIZE - 5];
    sprintf(whileNameNumber, "%d", whileStack[whileDepth - 1]);
    strcat(whileName, whileNameNumber);
    tmpCnt++;
    return whileName;
}

/* ################# IF STACK ################# */

static int ifCnt = 0;
static int ifDepth = 0;
static int ifStack[MAX_IF_DEPTH] = {};
static char ifName[MAX_VAR_NAM_SIZE];

void openIf() {
    if (ifDepth >= MAX_IF_DEPTH) {
        fprintf(stderr, "ERROR: IF STACK TOO HIGH.\n");
        exit(1);
    }   
    ifStack[ifDepth++] = ifCnt++;
}

char* endIf() {
    if (ifDepth == 0) {
        fprintf(stderr, "ERROR: IMPOSSIBLE TO CLOSE NON EXISTENT IF\n");
        exit(1);
    }   
    char* endFlagName = getCurrentIfEndFlag();
    ifDepth--;
    return endFlagName;
}

char* getCurrentIfElseFlag()
{
    if (ifDepth == 0) {
        fprintf(stderr, "ERROR: CAN'T GET ILF:, NOT IN A IF CONDITION\n");
        exit(1);
    }
    strcpy(ifName, "__ILF"); // if eLse: flag
    char ifNameNumber[MAX_VAR_NAM_SIZE - 5];
    sprintf(ifNameNumber, "%d", ifStack[ifDepth - 1]);
    strcat(ifName, ifNameNumber);
    tmpCnt++;
    return ifName;
}

char* getCurrentIfEndFlag()
{
    if (ifDepth == 0) {
        fprintf(stderr, "ERROR: CAN'T GET INF:, NOT IN A IF CONDITION\n");
        exit(1);
    }
    strcpy(ifName, "__INF"); // if eNd: flag
    char ifNameNumber[MAX_VAR_NAM_SIZE - 5];
    sprintf(ifNameNumber, "%d", ifStack[ifDepth - 1]);
    strcat(ifName, ifNameNumber);
    tmpCnt++;
    return ifName;
}