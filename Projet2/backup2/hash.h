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
  char *var;
} symbol_t;


int hachage(key_t k);

symbol_t findtab(key_t k);

void addtab(key_t k, struct Type *type);

void init();

void printtab();

#endif //HASH_H
