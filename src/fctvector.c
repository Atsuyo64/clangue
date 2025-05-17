#include "fctvector.h"
#include <stdlib.h>
#include <string.h>
#include "assert.h"
#include <stdio.h>

#define DEBUG_VEC

#ifdef DEBUG_VEC
#endif // DEBUG_VEC


static int *sp = (int *)4;

#define INITIAL_FUNC_CAPACITY 16
#define MAX_FCT_NAM_SIZE 256

static char fctName[MAX_FCT_NAM_SIZE];
function_table *newFunctionTable() {
    function_table *ft = malloc(sizeof(function_table));
    ft->entries = malloc(sizeof(function_entry) * INITIAL_FUNC_CAPACITY);
    ft->size = 0;
    ft->capacity = INITIAL_FUNC_CAPACITY;
    return ft;
}

char* getFctName(char* name) {
    strcpy(fctName, "__FCT_");
    strcat(fctName, name);
    return fctName;
}

void ft_add(function_table *ft, char *name, int param_count) {
    if (ft->size >= ft->capacity) {
        ft->capacity *= 2;
        ft->entries = realloc(ft->entries, sizeof(function_entry) * ft->capacity);
    }

    ft->entries[ft->size].name = strdup(getFctName(name));
    ft->entries[ft->size].param_count = param_count;
    ft->size++;
}

function_entry *ft_get(function_table *ft, char *name) {
    for (int i = 0; i < ft->size; ++i) {
        if (strcmp(ft->entries[i].name, name) == 0) {
            return &ft->entries[i];
        }
    }
    return NULL;
}
