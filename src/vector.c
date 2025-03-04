#include "src/vector.h"
#include <stdlib.h>

/*
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
*/

// FIXME: why no c++ ? (authorised, à tester)

void doubleVecSize(vector* vec) {
    unsigned newcapa = vec->capacity * 2;
    cell* ptr = malloc(newcapa*sizeof(cell));
    memcpy(ptr,vec->cells,vec->size*sizeof(cell));
    vec->capacity = newcapa;
}

vector newVector(){
    return {.cells = NULL,.capacity = 0,.size = 0,.max_height = 0};
}
void push(vector* vec,cell data){
    if (vec->size == vec->capacity)
        doubleVecSize(vec);
}
void elevate(vector* vec);
void delevate(vector* vec);




void setVectorSize(void** data, unsigned* currentSize, unsigned newSize,bool copy)
{
    if(*currentSize>=newSize) return;
    unsigned newSize_ = *currentSize*2;
    while(newSize_<newSize) newSize_*=2;
    void* tmp = malloc(newSize_);
    if(copy) memcpy(tmp,*data,*currentSize);
    *currentSize=newSize_;
    free(*data);
    *data=tmp;
}