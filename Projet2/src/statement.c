#include "statement.h"

#include <stdlib.h>


struct Stat *  new_stat(){

  return malloc (sizeof(struct Stat));

}

struct Stat* empty_stat(){
  struct Stat* s = malloc (sizeof(struct Stat));
  s->var = malloc (sizeof(int));
  *s->var = EMPTY_STAT; 
  return s;
}

