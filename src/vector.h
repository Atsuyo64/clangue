#pragma once

typedef enum TYPE {
    CONST,
    INT,
    //FUNC,
} TYPE;

typedef struct
{
    char *id;
    unsigned height;
    int *ptr;
    TYPE type;
    int ptr_level;
} cell;

typedef struct
{
    cell *cells;
    unsigned capacity;
    unsigned size;
    unsigned max_height;
} vector;

vector newVector();
int* push_value(vector *vec, char* ID);
void elevate(vector *vec);
void delevate(vector *vec);
cell *find(vector *v, char *id);
TYPE str2type(char* str);

void push_ptr(int* ptr);
int* pop_ptr();