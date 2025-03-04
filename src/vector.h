#pragma once

typedef struct
{
    char* id;
    unsigned height;
} cell;

typedef struct
{
    cell* cells;
    unsigned capacity;
    unsigned size;
    unsigned max_height;
} vector;

vector newVector();
void push(vector* vec,cell data);
void elevate(vector* vec);
void delevate(vector* vec);