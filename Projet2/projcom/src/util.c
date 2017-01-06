#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>

int new_var()
{
  static int i=0;
  return i++;
}

int new_label()
{
  static int l=0;
  return l++;
}

struct expr *new_expr() 
{
  return malloc(sizeof(struct expr)); 
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
  asprintf(%s,"%#08llx",u.b);
  return s;
}
