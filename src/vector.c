#include "vector.h"
#include <stdlib.h>
#include <string.h>
#include "assert.h"

#define DEBUG_VEC

#ifdef DEBUG_VEC
#include <stdio.h>
#endif // DEBUG_VEC

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

void doubleVecSize(vector *vec)
{
    unsigned newcapa = vec->capacity * 2;
    cell *ptr = malloc(newcapa * sizeof(cell));
    if (vec->capacity != 0)
    {
        memcpy(ptr, vec->cells, vec->size * sizeof(cell));
        free(vec->cells);
    }
    vec->capacity = newcapa;
    vec->cells = ptr;
}

static int *sp = (int *)4;

#define INIT_VEC_CAPA 128

vector newVector()
{
    vector v = {malloc(INIT_VEC_CAPA * sizeof(cell)), INIT_VEC_CAPA, 0, 0};
    return v;
}
int *push_value(vector *vec, char *ID)
{
#ifdef DEBUG_VEC_SIZE
    fprintf(stderr, "vec(%i/%i) id %s (%i) pushed", vec->size + 1, vec->capacity, ID, vec->max_height);
#endif // DEBUG_VEC
    assert(ID != NULL && strlen(ID) > 0 && "ID VIDE !");
    if (vec->size == vec->capacity)
        doubleVecSize(vec);

    char *ptr = malloc(256);
    strncpy(ptr, ID, 255);
#ifdef DEBUG_VEC
    fprintf(stderr, "Pushing %s (%p) -> %p\n", ptr, ptr, sp);
#endif // DEBUG_VEC
    cell data = {ptr, vec->max_height, sp++, INT, 0}; //0 means pointer level is 0
    vec->cells[vec->size++] = data;
    return data.ptr;
}

int *push_pointer(vector *vec, char *ID, unsigned int level)
{
#ifdef DEBUG_VEC_SIZE
    fprintf(stderr, "vec(%i/%i) id %s (%i) pushed", vec->size + 1, vec->capacity, ID, vec->max_height);
#endif // DEBUG_VEC
    assert(ID != NULL && strlen(ID) > 0 && "ID VIDE !");
    if (vec->size == vec->capacity)
        doubleVecSize(vec);

    char *ptr = malloc(256);
    strncpy(ptr, ID, 255);
#ifdef DEBUG_VEC
    fprintf(stderr, "Pushing_ptr %s* (%p) -> %p (lvl:%d)\n", ptr, ptr, sp, level);
#endif // DEBUG_VEC
    cell data = {ptr, vec->max_height, sp++, INT, level};
    vec->cells[vec->size++] = data;
    return data.ptr;
}

void elevate(vector *vec)
{
    vec->max_height++;
}
void delevate(vector *vec)
{
    unsigned new_height = vec->max_height - 1;
    vec->max_height = new_height;
#ifdef DEBUG_VEC
    fprintf(stderr, "Delevating, nh:%i {\n", new_height);
#endif
    for (int i = 0; i < vec->size; ++i)
    {
        if (vec->cells[i].height > new_height)
        {
            for (int j = i; j < vec->size; ++j)
            {
#ifdef DEBUG_VEC
                fprintf(stderr, "\t\e[31mh:%i, ptr:%p (%s)\e[0m\n", vec->cells[j].height, vec->cells[j].id, vec->cells[j].id);
#endif
                free(vec->cells[j].id);
            }
            sp -= vec->size - i;
            vec->size = i;
#ifdef DEBUG_VEC
            fprintf(stderr, "}\n");
#endif
            return;
        }
        else
        {
#ifdef DEBUG_VEC
            fprintf(stderr, "\t\e[36mh:%i, ptr:%p (%s)\e[0m\n", vec->cells[i].height, vec->cells[i].id, vec->cells[i].id);
#endif
        }
    }
#ifdef DEBUG_VEC
    fprintf(stderr, "}\n");
#endif
}

cell *find(vector *v, char *id)
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

cell *find_by_ptdr(vector *v, int *ptdr)
{
    for (int i = v->size - 1; i >= 0; --i)
    {
        if (ptdr == v->cells[i].ptr)
        {
            return v->cells + i;
        }
    }
    return NULL;
}

int find_ptr_level(vector *v,int *ptr) {
  cell *c = find_by_ptdr(v, ptr);
  return c ? c->ptr_level : 0;
}

TYPE str2type(char *str)
{
    if (strncmp(str, "int", 3) == 0)
    {
        return INT;
    }
    else if (strncmp(str, "const", 4) == 0)
    {
        return CONST;
    }
    else
    {
        fprintf(stderr, "Unknown type : %s\nExiting...", str);
        exit(1);
    }
}

static int *ptr_stack[256];
static int index_ptr_stack = 0;
void push_ptr(int *ptr)
{
    if (index_ptr_stack >= 256)
    {
        fprintf(stderr, "ptr stack out of memory !\n");
        exit(1);
    }
    ptr_stack[index_ptr_stack++] = ptr;
}
int *pop_ptr()
{
    if (index_ptr_stack <= 0)
    {
        fprintf(stderr, "trying to pop an empty ptr stack\n");
        exit(1);
    }
    return ptr_stack[--index_ptr_stack];
}