#ifndef HASH_H
#define HASH_H

#include "type.h"


typedef struct{
  char *name;
  char *function;
  int level;
} key_t;

typedef struct {
  char *name;
  struct Type *type;
  char *code;
  int *var;
  char* last_function;
  int level;
} symbol_t;


int hachage(key_t k);

symbol_t findtab(key_t k);

void addtab(key_t k, struct Type *type);

void init();

void printtab();

int intab(char *name);

#endif //HASH_H
