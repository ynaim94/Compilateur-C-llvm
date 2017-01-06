#include<stdlib.h>
#include<stdio.h>
#include "type.h"


struct Type* create_symbol_function(const struct Type last_type, struct Type** param_list){
    struct Type *s = malloc (sizeof(struct Type));
    s->type = 0;
    s->f = malloc (sizeof(struct Function));
    s->f->param_type = param_list;
    s->f->return_type = last_type;
    s->f->nbParam = nb_parameter;
    return s;
}

struct Type* create_symbol(const struct Type last_type){
  struct Type *s = malloc (sizeof(struct Type));
  s->type = last_type.type;
  return s;
}

struct Type** param_append(struct Type** list_param, struct Type* param){
  if (list_param == NULL){
    struct Type **list = malloc (sizeof(struct Type*));
    *list = param;
    return list;
  }
  list_param = realloc (list_param, nb_parameter*sizeof(struct Type*));
  list_param[nb_parameter-1] = param;
  return list_param;
}
