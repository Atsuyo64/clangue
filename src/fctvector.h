#pragma once

typedef struct
{
    char *id;
    int *ptr;
} fct_cell;

typedef struct
{
    fct_cell *cells;
    unsigned capacity;
    unsigned size;
} fct_vector;

fct_vector newFctVector();
int* fctAdd(fct_vector *vec, char* ID);
fct_cell *findFct(fct_vector *v, char *id);

void push_fct_ptr(int* ptr);
int* pop_fct_ptr();