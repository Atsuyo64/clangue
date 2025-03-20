#include "utils.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MAX_VAR_NAM_SIZE 256
#define MAX_WHILE_DEPTH 256

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

char* closeWhile() {
    if (whileDepth == 0) {
        fprintf(stderr, "ERROR: IMPOSSIBLE TO CLOSE NON EXISTENT WHILE\n");
        exit(1);
    }   
    char* endFlagName = getCurrentWhileStartFlag();
    whileCnt--;
    return endFlagName;
}

char* getCurrentWhileStartFlag()
{
    if (whileDepth == 0) {
        fprintf(stderr, "ERROR: CAN'T GET WSF, NOT IN A WHILE LOOP\n");
        exit(1);
    }
    strcpy(whileName, "__WSF"); // while flag start
    char whileNameNumber[MAX_VAR_NAM_SIZE - 5];
    sprintf(whileNameNumber, "%d", whileStack[whileDepth - 1]);
    strcat(whileName, whileNameNumber);
    tmpCnt++;
    return whileName;
}

char* getCurrentWhileEndFlag()
{
    if (whileDepth == 0) {
        fprintf(stderr, "ERROR: CAN'T GET WeF, NOT IN A WHILE LOOP\n");
        exit(1);
    }
    strcpy(whileName, "__WEF"); // while flag end
    char whileNameNumber[MAX_VAR_NAM_SIZE - 5];
    sprintf(whileNameNumber, "%d", whileStack[whileDepth - 1]);
    strcat(whileName, whileNameNumber);
    tmpCnt++;
    return whileName;
}