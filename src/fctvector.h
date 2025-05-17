#pragma once

typedef struct {
    char *name;
    int address; // starting addr
    int param_count;
} function_entry;

typedef struct {
    function_entry *entries;
    int size;
    int capacity;
} function_table;

function_table *newFunctionTable();
void ft_add(function_table *ft, char *name, int address, int param_count);
function_entry *ft_get(function_table *ft, char *name);