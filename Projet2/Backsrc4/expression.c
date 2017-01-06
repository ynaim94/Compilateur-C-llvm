#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>

#include "expression.h"

int* new_var()
{
  static int i=0;
  int* a = malloc (sizeof(int));
  *a = i++;
  return a;
}

int new_label()
{
  static int l=0;
  return l++;
}

struct Expr *new_expr() 
{
  return malloc(sizeof(struct Expr)); 
}

struct Type* new_type(enum EnumType type ){
  struct Type* t = malloc (sizeof (struct Type));
  t->type = type;
  return t;
}

char *double_to_hex_str(double d)
{
  char *s =NULL;
  union 
  {
    double a;
    long long int b;
  } u;
  u.a = d;
  asprintf(&s,"%#08llx",u.b);
  return s;
}

int concat_var(int *dest, int *ldest, int *v2,int l2){

  dest = realloc (dest,(l2+*ldest)*sizeof(int));
  if (dest == NULL)
    return 0;
  int i ;
  for (i = 0 ; i < l2; i++){
    dest[*ldest + i] = v2[i];
  }
  *ldest +=l2; 
  return 1;
}
