#include "src/vector.h"
#include <stdlib.h>
#include <string.h>

#define DEBUG_VEC

#ifdef DEBUG_VEC
#include <stdio.h>
#endif //DEBUG_VEC


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

// FIXME: why no c++ ? (à tester)

void doubleVecSize(vector* vec) {
    unsigned newcapa = vec->capacity * 2;
    cell* ptr = malloc(newcapa*sizeof(cell));
    if(vec->capacity != 0) {
        memcpy(ptr,vec->cells,vec->size*sizeof(cell));
        free(vec->cells);
    }
    vec->capacity = newcapa;
    vec->cells = ptr;
}

#define INIT_VEC_CAPA 128

vector newVector(){
    vector v = {malloc(INIT_VEC_CAPA*sizeof(cell)),INIT_VEC_CAPA,0,0};
    return v;
}
void push(vector* vec,cell data){
#ifdef DEBUG_VEC
    printf("vec(%i/%i) id %s (%i) pushed\n",vec->size+1,vec->capacity,data.id,vec->max_height);
#endif // DEBUG_VEC
    if (vec->size == vec->capacity)
        doubleVecSize(vec);
    vec->cells[vec->size++] = data;
}

void elevate(vector* vec) 
{
    vec->max_height++;
}
void delevate(vector* vec)
{
    unsigned new_height = vec->max_height - 1;
    vec->max_height = new_height;
    for(int i = 0;i<vec->capacity;++i) {
        if (vec->cells[i].height > new_height) {
            vec->size = i;
            return;
        }
    }
}

// void setVectorSize(void** data, unsigned* currentSize, unsigned newSize,char copy)
// {
//     if(*currentSize>=newSize) return;
//     unsigned newSize_ = *currentSize*2;
//     while(newSize_<newSize) newSize_*=2;
//     void* tmp = malloc(newSize_);
//     if(copy) memcpy(tmp,*data,*currentSize);
//     *currentSize=newSize_;
//     free(*data);
//     *data=tmp;
// }


cell* find(vector* v,char* id) {
    for(int i=v->size-1;i>=0;--i) {
        if (strcmp(id,v->cells[i].id)==0) {
            return v->cells + i;
        }
    }
    return NULL;
}