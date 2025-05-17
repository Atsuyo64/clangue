#include "fctvector.h"
#include <stdlib.h>
#include <string.h>
#include "assert.h"

#define DEBUG_VEC

#ifdef DEBUG_VEC
#include <stdio.h>
#endif // DEBUG_VEC


void doubleVecSize(fct_vector *vec)
{
    unsigned newcapa = vec->capacity * 2;
    fct_cell *ptr = malloc(newcapa * sizeof(fct_cell));
    if (vec->capacity != 0)
    {
        memcpy(ptr, vec->cells, vec->size * sizeof(fct_cell));
        free(vec->cells);
    }
    vec->capacity = newcapa;
    vec->cells = ptr;
}

static int *sp = (int *)4;

#define INIT_VEC_CAPA 128

fct_vector newFctVector()
{
    fct_vector v = {malloc(INIT_VEC_CAPA * sizeof(fct_cell)), INIT_VEC_CAPA, 0, 0};
    return v;
}
int *fctAdd(fct_vector *vec, char *ID)
{
    assert(ID != NULL && strlen(ID) > 0 && "ID VIDE !");
    if (vec->size == vec->capacity)
        doubleVecSize(vec);

    char *ptr = malloc(256);
    strncpy(ptr, ID, 255);
    fct_cell data = {ptr, sp++};
    vec->cells[vec->size++] = data;
    return data.ptr;
}

fct_cell *findFct(fct_vector *v, char *id)
{
    for (int i = v->size - 1; i >= 0; --i)
    {
        if (strcmp(id, v->cells[i].id) == 0)
        {
            return v->cells + i;
        }
    }
    return NULL;
}

static int *ptr_stack[256];
static int index_ptr_stack = 0;
void push_fct_ptr(int *ptr)
{
    if (index_ptr_stack >= 256)
    {
        fprintf(stderr, "fct ptr stack out of memory !\n");
        exit(1);
    }
    ptr_stack[index_ptr_stack++] = ptr;
}
int *pop_fct_ptr()
{
    if (index_ptr_stack <= 0)
    {
        fprintf(stderr, "trying to pop an empty fct ptr stack\n");
        exit(1);
    }
    return ptr_stack[--index_ptr_stack];
}