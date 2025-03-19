#include "utils.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MAX_VAR_NAM_SIZE 256

static int tmpCnt = 0;
static char tmpName[MAX_VAR_NAM_SIZE];

char* getTempName()
{
    //memset(&tmpName[0], 0, MAX_VAR_NAM_SIZE);
    strcpy(tmpName, "__TMP");
    char tmpNameNumber[MAX_VAR_NAM_SIZE - 5];
    sprintf(tmpNameNumber, "%d", tmpCnt);
    strcat(tmpName, tmpNameNumber);
    tmpCnt++;
    return tmpName;
}