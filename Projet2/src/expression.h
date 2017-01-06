#ifndef EXPRESSION_H
#define EXPRESSION_H

#include "type.h"

struct Expr{
  int* var; //liste de variable
  int length;;
  char *code;
  struct Type* type;
};

int* new_var();

int new_label();
struct Type *new_type(enum EnumType type );

int concat_var(int **dest, int* ldest, int *v2,int l2);

struct Expr *new_expr();

char *double_to_hex_str(double d);

#endif //EXPRESSION_H
