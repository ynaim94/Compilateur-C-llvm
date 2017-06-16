
#ifndef STATEMENT_H
#define STATEMENT_H

#define EMPTY_STAT -1

#include "type.h"



struct Stat{
  int* var; //liste de variable
  char *code;
};



struct Stat *new_stat();

struct Stat* empty_stat();

#endif //STATEMENT_H
