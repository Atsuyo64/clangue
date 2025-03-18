#pragma once

typedef enum TYPE {
    CONST,
    INT,
    FUNC,
} TYPE;

typedef struct
{
    char *id;
    unsigned height;
    int *ptr;
    TYPE type;
} cell;

typedef struct
{
    cell *cells;
    unsigned capacity;
    unsigned size;
    unsigned max_height;
} vector;

vector newVector();
void push(vector *vec, cell data);
void elevate(vector *vec);
void delevate(vector *vec);
cell *find(vector *v, char *id);
