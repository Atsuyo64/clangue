#pragma once

typedef struct {
    char *name;
    // int address; // starting addr not used
    int param_count;
} function_entry;

typedef struct {
    function_entry *entries;
    int size;
    int capacity;
} function_table;

function_table *newFunctionTable();
void ft_add(function_table *ft, char *name, int param_count);
function_entry *ft_get(function_table *ft, char *name);
char* getFctName(char* name);