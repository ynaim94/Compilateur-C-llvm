#include "expression_symbols.h"

#include <stdlib.h>

struct expression_symbol* create_expression_symbol_int(int n)
{
  struct expression_symbol *s = malloc(sizeof(struct expression_symbol));
  s->t = ENTIER;
  s->v.n = n;
  return s;
}

struct expression_symbol* create_expression_symbol_float(float f)
{
  struct expression_symbol *s = malloc(sizeof(struct expression_symbol));
  s->t = FLOTTANT;
  s->v.f = f;
  return s;
}
