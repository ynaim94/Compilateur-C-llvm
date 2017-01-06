%{
#define _GNU_SOURCE
#include <stdio.h>
#include "assert.h" 
#include "string.h"

#include "type.h"
#include "hash.h"
#include "expression.h"
#include "statement.h"


  char *last_name;
  
  extern int yylineno;
  int yylex ();
  int yyerror ();
  %}

%token <string> IDENTIFIER <doubl> CONSTANTD <integer> CONSTANTI
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN DIV_ASSIGN
%token SHL_ASSIGN SHR_ASSIGN
%token REM_ASSIGN
%token REM SHL SHR
%token AND OR
%token TYPE_NAME
%token INT DOUBLE VOID
%token IF ELSE WHILE RETURN FOR DO
%type <t> declarator  parameter_declaration
%type <pl> parameter_list
%type <expr> primary_expression postfix_expression argument_expression_list unary_expression unary_operator multiplicative_expression additive_expression expression conditional_expression logical_or_expression logical_and_expression shift_expression comparison_expression 
%type <stat>  statement compound_statement jump_statement iteration_statement selection_statement expression_statement statement_list
%start program 
%type <string> assignment_operator
%union {
  char *string;
  int integer;
  double doubl;
  struct Type* t;
  struct Type ** pl;
  struct Expr* expr;
  struct Stat* stat;
}
%%

conditional_expression
: logical_or_expression
{
  $$ = $1;

  //  $$->type =new_type(INTEGER);
}
;

logical_or_expression
: logical_and_expression
{
  $$ = $1;
}
| logical_or_expression OR logical_and_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  asprintf(&code,"%%x%d=or i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  char *code2 = malloc(strlen(code) + strlen($3->code) + strlen($1->code)+1);
  strcpy(code2,$1->code);
  strcat(code2,$3->code);
  strcat(code2,code);
  $$->type = new_type(INTEGER);
  $$->code = code2;
  free(code);
}
;

logical_and_expression
: comparison_expression
{
  $$ = $1;
}
| logical_and_expression AND comparison_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  asprintf(&code,"%%x%d=or i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  char *code2 = malloc(strlen(code) + strlen($3->code) + strlen($1->code)+1);
  strcpy(code2,$1->code);
  strcat(code2,$3->code);
  strcat(code2,code);
  $$->type = new_type(INTEGER);
  $$->code = code2;
  free(code);
} 

;


shift_expression
: additive_expression
{
  $$ = $1;
}
| shift_expression SHL additive_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  asprintf(&code,"%%x%d=shl i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  char *code2 = malloc(strlen(code) + strlen($3->code) + strlen($1->code)+1);
  strcpy(code2,$1->code);
  strcat(code2,$3->code);
  strcat(code2,code);
  $$->type = new_type(INTEGER);
  $$->code = code2;
  free(code);
}

| shift_expression SHR additive_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  asprintf(&code,"%%x%d=lshr i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  char *code2 = malloc(strlen(code) + strlen($3->code) + strlen($1->code)+1);
  strcpy(code2,$1->code);
  strcat(code2,$3->code);
  strcat(code2,code);
  $$->type = new_type(INTEGER);
  $$->code = code2;
  free(code);
}
;


primary_expression 
: IDENTIFIER
{
  int lvl;
  assert((lvl = intab($1))); //teste si $1 a bien été déclaré
  key_t k = {$1,last_function,intab($1)}; 
  symbol_t sym = findtab(k);
  $$ = new_expr();
  $$->var = sym.var;
  $$->type = new_type(sym.type->type);
  $$->code = "";
}

| CONSTANTI
{
  $$ = new_expr();
  $$->var = new_var();
  $$->type = new_type(INTEGER);
  char *code;
  asprintf(&code,"%%x%d=add i32 0,%d\n", *$$->var,$1);
  $$->code=code;
}

| CONSTANTD
{
  $$ = new_expr();
  $$->var = new_var();
  $$->type = new_type(DOUBLE);
  char *code;
  asprintf(&code,"%%x%d=add double %s,%s\n",*$$->var,double_to_hex_str(0),double_to_hex_str($1));
  $$->code=code;
}

| '(' expression ')'
{
  $$ = $2;
}

| IDENTIFIER '(' ')'
{
  key_t k = {$1,"\0", 0};
  symbol_t sym = findtab(k);
  assert((!(strcmp(sym.name,k.name))));
  assert ((sym.type->type == FUNCTION) && (sym.type->f->nbParam == 0));
  $$ = new_expr();
  $$->var = new_var();
  $$->type = new_type(sym.type->type);
  //char *code;
  $$->code = ""; //a faire : appel de fonction

}

| IDENTIFIER '(' argument_expression_list ')'
{
  key_t k = {$1,"\0", 0};
  symbol_t sym = findtab(k);
  assert((!(strcmp(sym.name,k.name))));
  //printf("%s , %d == %d\n",$1,sym.type->f->nbParam, $3->length); //debug
  assert ((sym.type->type == FUNCTION) && (sym.type->f->nbParam == $3->length));
  $$ = new_expr();
  $$->var = new_var();
  $$->type = new_type(sym.type->type);
  //char *code;
  $$->code = ""; //a faire : appel de fonction 
}
;

postfix_expression
: primary_expression
{
  $$ = $1;
}
| postfix_expression INC_OP
{
  $$->var = $1->var;
  char *code;
  if ($1->type->type == INTEGER){
    asprintf(&code,"%%x%d=add i32 %%x%d,%d\n", *$1->var,*$1->var,1);
  }
  else {
    asprintf(&code,"%%x%d=add double %%x%d,%d\n", *$1->var,*$1->var,1);
  }
  char *code2 = malloc(strlen(code) + strlen($1->code) +1);
  strcpy(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}

| postfix_expression DEC_OP

{
  $$->var = $1->var;
  char *code;
  if ($1->type->type == INTEGER)
    asprintf(&code,"%%x%d=sub i32 %%x%d,%d\n", *$1->var,*$1->var,1);
  else
    asprintf(&code,"%%x%d=sub double %%x%d,%d\n", *$1->var,*$1->var,1);
  char *code2 = malloc(strlen(code) + strlen($1->code) +1);
  strcpy(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}

;

argument_expression_list
: expression
{
  $$ = $1;
  //  $$->length = 1;
  // printf("var expr %d\n",*$$->var);
}
| argument_expression_list ',' expression
{
  //  static int i = 0;
  //printf("static int : %d\n",i++);
  char *code = malloc (strlen($1->code) + strlen($3->code) +1);
  strcpy(code, $1->code);
  strcat(code, $3->code);
  $$->code = code;
  concat_var(&($$->var),&($$->length), $3->var,1);
  /* int j;
  printf("length = %d\n",$1->length);
  for (j = 0; j < $1->length; j++){
    printf("v[%d] = %d \n", j,$1->var[j]);
    }*/
  concat_var(&($$->var),&($$->length), $1->var,$1->length);
  $$->length =  $1->length + $3->length;
}
;

unary_expression
: postfix_expression
{
  $$ = $1;
}
| INC_OP unary_expression
{
  $$ = $2;
  char *code;
  if ($2->type->type == INTEGER){
    asprintf(&code,"%%x%d=add i32 %%x%d,%d\n", *$2->var,*$2->var,1);
  }
  else {
    asprintf(&code,"%%x%d=add double %%x%d,%d\n", *$2->var,*$2->var,1);
  }
  char *code2 = malloc(strlen(code) + strlen($2->code) +1);
  strcpy(code2,$2->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}
| DEC_OP unary_expression
{
  $$ = $2;
  char *code;
  if ($2->type->type == INTEGER){
    asprintf(&code,"%%x%d=add i32 %%x%d,%d\n", *$2->var,*$2->var,1);
  }
  else {
    asprintf(&code,"%%x%d=add double %%x%d,%d\n", *$2->var,*$2->var,1);
  }
  char *code2 = malloc(strlen(code) + strlen($2->code) +1);
  strcpy(code2,$2->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}
| unary_operator unary_expression
{
  $$ = $1;
  char *code;
  if ($2->type->type == INTEGER){
    asprintf(&code,"%%x%d=mul i32 %%x%d,%d\n", *$2->var,*$2->var,-1);
  }
  else {
    asprintf(&code,"%%x%d=fmul double %%x%d,%d\n", *$2->var,*$2->var,-1);
  }
  char *code2 = malloc(strlen(code) + strlen($2->code) +1);
  strcpy(code2,$2->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}
;

unary_operator
: '-'
;

multiplicative_expression
: unary_expression
{
  $$ = $1;
}
| multiplicative_expression '*' unary_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=mul i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    $$->type = new_type(INTEGER);
  }
  else {
    int nv = *(new_var());
    if ($1->type->type == INTEGER){
      asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fmul double %%x%d,%%x%d\n", nv,*$1->var , *$$->var,nv,*$3->var);
      	$$->type = new_type(DOUBL);
    }
    else
      if ($3->type->type == INTEGER){
	asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fmul double %%x%d,%%x%d\n", nv,*$3->var , *$$->var,*$1->var,nv);
	$$->type = new_type(DOUBL);
      }
      else {
	asprintf(&code,"%%x%d=fmul double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
      }
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;

  free(code);
}

| multiplicative_expression '/' unary_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=div i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    $$->type = new_type(INTEGER);
  }
  else {
    int nv = *(new_var());
    if ($1->type->type == INTEGER){
      asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fdiv double %%x%d,%%x%d\n", nv,*$1->var , *$$->var,nv,*$3->var);
      $$->type = new_type(DOUBL);
    }
    else
      if ($3->type->type == INTEGER){
	asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fdiv double %%x%d,%%x%d\n", nv,*$3->var , *$$->var,*$1->var,nv);
	$$->type = new_type(DOUBL);
      }
      else {
	asprintf(&code,"%%x%d=fdiv double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
	$$->type = new_type(DOUBL);
      }
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}

| multiplicative_expression REM unary_expression
{
  assert(($1->type->type == INTEGER) && ($3->type->type == INTEGER));
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  asprintf(&code,"%%x%d=srem i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->type = new_type(INTEGER);
  $$->code = code2;
  free(code);
}
;

additive_expression
: multiplicative_expression
{
  $$ = $1;
}
| additive_expression '+' multiplicative_expression
{
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=add i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    $$->type = new_type(INTEGER);
  }
  else {
    int nv = *(new_var());
    if ($1->type->type == INTEGER){
      asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fadd double %%x%d,%%x%d\n", nv,*$1->var , *$$->var,nv,*$3->var);
      $$->type = new_type(DOUBL);
    }
    else
      if ($3->type->type == INTEGER){
	asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fadd double %%x%d,%%x%d\n", nv,*$3->var , *$$->var,*$1->var,nv);
	$$->type = new_type(DOUBL);
      }
      else {
	asprintf(&code,"%%x%d=fadd double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
	$$->type = new_type(DOUBL);
      }
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}
| additive_expression '-' multiplicative_expression
{
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=sub i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    $$->type = new_type(INTEGER);
  }
  else {
    int nv = *(new_var());
    if ($1->type->type == INTEGER){
      asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fsub double %%x%d,%%x%d\n", nv,*$1->var , *$$->var,nv,*$3->var);
      $$->type = new_type(DOUBL);
    }
    else
      if ($3->type->type == INTEGER){
	asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fsub double %%x%d,%%x%d\n", nv,*$3->var , *$$->var,*$1->var,nv);
	$$->type = new_type(DOUBL);
      }
      else {
	asprintf(&code,"%%x%d=fsub double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
	$$->type = new_type(DOUBL);
      }
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}
;

comparison_expression
: shift_expression
{
  $$ = $1;

}
| comparison_expression '<' shift_expression

{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=slt i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  }
  else {
    if (($1->type->type == DOUBL)&& ($3->type->type == DOUBL)){
      asprintf(&code,"%%x%d=slt double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    }
    else
      printf("erreur :%%x%d et %%x%d sont de type différent\n",*$1->var,*$3->var);
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);

}

| comparison_expression '>' shift_expression

{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=sgt i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  }
  else {
    if (($1->type->type == DOUBL)&& ($3->type->type == DOUBL)){
      asprintf(&code,"%%x%d=sgt double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    }
    else
      printf("erreur :%%x%d et %%x%d sont de type différent\n",*$1->var,*$3->var);
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}

| comparison_expression LE_OP shift_expression

{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=sle i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  }
  else {
    if (($1->type->type == DOUBL)&& ($3->type->type == DOUBL)){
      asprintf(&code,"%%x%d=sle double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    }
    else
      printf("erreur :%%x%d et %%x%d sont de type différent\n",*$1->var,*$3->var);
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}

| comparison_expression GE_OP shift_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=sge i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  }
  else {
    if (($1->type->type == DOUBL)&& ($3->type->type == DOUBL)){
      asprintf(&code,"%%x%d=sge double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    }
    else
      printf("erreur :%%x%d et %%x%d sont de type différent\n",*$1->var,*$3->var);
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}

| comparison_expression EQ_OP shift_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=eq i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  }
  else {
    if (($1->type->type == DOUBL)&& ($3->type->type == DOUBL)){
      asprintf(&code,"%%x%d=eq double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    }
    else
      printf("erreur :%%x%d et %%x%d sont de type différent\n",*$1->var,*$3->var);
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}
| comparison_expression NE_OP shift_expression
{
  $$ = new_expr();
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=ne i32 %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
  }
  else {
    if (($1->type->type == DOUBL)&& ($3->type->type == DOUBL)){
      asprintf(&code,"%%x%d=ne double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
    }
    else
      printf("erreur :%%x%d et %%x%d sont de type différent\n",*$1->var,*$3->var);
  }
  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
  strcpy(code2,$3->code);
  strcat(code2,$1->code);
  strcat(code2,code);
  $$->code = code2;
  free(code);
}
;

expression//
: unary_expression assignment_operator conditional_expression
{
  //  printf("type: $1:%d $3:%d\n", $1->type->type,$3->type->type);
  if (!(strcmp($2, "="))){
      char *code;
      if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
	asprintf(&code,"%%x%d=add i32 %%x%d,%%x%d\n", *$1->var,*$3->var,0);
      }
      else {
	if (($1->type->type == DOUBL)&& ($3->type->type == DOUBL)){
	  asprintf(&code,"%%x%d=fadd double %%x%d,%%x%d\n", *$$->var,*$1->var,*$3->var);
	}
	else{
	  int nv = *new_var();
	  if (($1->type->type == INTEGER)){
	      printf("Warning: %%x%d et %%x%d sont de type différent\n",*$1->var,*$3->var);
	      asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fsub double %%x%d,%%x%d\n", nv,*$1->var , *$$->var,nv,*$3->var);
	    }
	  else {
	    printf("Warning: %%x%d et %%x%d sont de type différent\n",*$1->var,*$3->var);
	    asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fsub double %%x%d,%%x%d\n", nv,*$3->var , *$$->var,*$1->var,nv);
	  }
	}

      }
      char *codeeq;
      $$->var=new_var();
      asprintf(&codeeq,"%%x%d=add i32 %%x%d,%%x%d\n", *$$->var,*$1->var,0);
      char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +strlen(codeeq) +1);
      strcpy(code2,$3->code);
      strcat(code2,$1->code);
      strcat(code2,code);
      strcat(code2,codeeq);
      $$->code = code2;
      //  printf("%s", $$->code);
      $$->length = 1;
      //    free(code);
  }
}

| conditional_expression
{
  $$ = $1;
  $$->length = 1;
  
}
;

assignment_operator
: '='
{
  $$ = "=";
}
| MUL_ASSIGN
| DIV_ASSIGN
| REM_ASSIGN
| SHL_ASSIGN
| SHR_ASSIGN
| ADD_ASSIGN
| SUB_ASSIGN
;

declaration
: type_name declarator_list ';'
;

declarator_list
: declarator                         
| declarator_list ',' declarator
{
  
}
;

type_name
: VOID {last_type.type = VOIDD;}
| INT {last_type.type = INTEGER;}
| DOUBLE {last_type.type = DOUBL;}
;

declarator
: IDENTIFIER
{
  $$ = create_symbol(last_type);
  if ((!(strcmp(last_name,""))) && (level == 0)){
    last_name = $1;
  }
  else{
    if (level ==0){
      key_t k = {$1,last_name,level+1};
      addtab(k,$$);
    }
    else{
      key_t k = {$1,last_function,level};
      addtab(k,$$);
    }
  }
  
  //  char *code;
}

| '(' declarator ')'
{
  $$ = create_symbol(last_type);
}

| declarator '(' parameter_list ')'
{
  niv ++;
  $1 = create_symbol_function(*($$), $3);
  free($$);
  $$ = $1;
  key_t k = {last_name,"\0",level};
  addtab(k, $$);
  last_function =last_name;
  last_name ="";
  nb_parameter = 0;
}

| declarator '(' ')'
{
  assert(level == 0);
  niv ++;
  $1 = create_symbol_function(*($$), NULL);
  free($$);
  $$ = $1;
  key_t k = {last_name,"\0",level};
  addtab(k, $$);
  last_name ="";
} 
;

parameter_list
: parameter_declaration  {nb_parameter++; $$ = param_append(NULL,$1);} 
| parameter_list ',' parameter_declaration {nb_parameter++; $$ = param_append ($1, $3);}
;

parameter_declaration
: type_name declarator {$$ = create_symbol(last_type);}
;

statement
: compound_statement 
{
  $$ = $1;
}
| expression_statement
{
  $$ = $1;
}
| selection_statement
{
  $$ = $1;
}
| iteration_statement
{
  $$ = $1;
}
| jump_statement
{
  $$ = $1;
}
;

compound_statement
: left-brace right-brace
{
  $$ = empty_stat();
}
| left-brace statement_list right-brace
{
  /*$$ = $2;
  $$->var = new_var();
  char *code;
  asprintf(&code, "label l%d\n", *$$->var);
  char *code2 = malloc (strlen($2->code) + strlen(code) +1);
  strcpy(code2, code);
  strcat(code2, $2->code);
  $$->code = code2;*/
}
| left-brace declaration_list statement_list right-brace
{
  /* int i;
  char *code;
  char *code2;
  for (i =0 ; i < SIZE; i++){
    if((hachtab[i].level == level) && (!(strcmp(hachtab[i].function == last_function)))){
      asprint (&code ,"
	       code2 = realloc (code2,strlen (code2) + strlen(code));
		       free(code);
		       }
		       }*/
  /*$$->var = new_var();
  char *code;
  asprintf(&code,"label l%d\n",*$$->var);
  char *code2 = malloc (strlen ($3->code)+strlen(code)+1);
  strcpy(code2,$3->code);
  strcat(code2,code);
  $$->code = code2;*/
}
| left-brace declaration_list right-brace
{
  //$$ = empty_stat();
  
}
;

left-brace
:'{' {level ++;}
;

right-brace
:'}' {level --;}
;

declaration_list
: declaration
| declaration_list declaration
;

statement_list
: statement
{
  $$ = $1;
}

| statement_list statement
{
  $$ = new_stat();
  $$->var = new_var();
  if (*$1->var != EMPTY_STAT)
    if (*$2->var != EMPTY_STAT)
  char *code = malloc ( strlen ($1->code) + strlen($2->code) +1);
  strcpy(code,$1->code);
  strcat(code,$2->code);
  $$->code = code;
}
;

expression_statement
: ';'
| expression ';'
;

selection_statement
: IF '(' expression ')' statement
{
  /*if (*$5->var != -1){
    char *code;
    asprintf(&code,"br il %%x%d, label %%l%d\n", *$3->var,*$5->var);
    char *code2 = malloc (strlen($3->code) + strlen($5->code) +1 );
    strcpy(code2, $3->code);
    strcat(code2, code);
    strcat(code2, $5->code);
    $$->code = code2;
    }*/
}
  
| IF '(' expression ')' statement ELSE statement
{
  /* if (*$5->var != -1){
    if (*$7->var != -1){
      char *code;
      asprintf(&code,"br il %%x%d, label %%l%d, label %%l%d\n", *$3->var,*$5->var,*$7->var);
      char *code2 = malloc (strlen($3->code) + strlen($5->code) + strlen($7->code)+1 );
      strcpy(code2, $3->code);
      strcat(code2, code);
      strcat(code2, $5->code);
      strcat(code2, $7->code);
      $$->code = code2;
    }
    }*/
}
| FOR '(' expression ';' expression ';' expression ')' statement
{
  /*
    $3->code
    l3:
    statement_list
    $7->code
    br $5->var , l3
   */
  
}
| FOR '(' expression ';' expression ';'            ')' statement
| FOR '(' expression ';'            ';' expression ')' statement
| FOR '(' expression ';'            ';'            ')' statement
| FOR '('            ';' expression ';' expression ')' statement
| FOR '('            ';' expression ';'            ')' statement
| FOR '('            ';'            ';' expression ')' statement
| FOR '('            ';'            ';'            ')' statement
;

iteration_statement
: WHILE '(' expression ')' statement
| DO statement WHILE '(' expression  ')'
;

jump_statement
: RETURN ';'
| RETURN expression ';'
;

program
: external_declaration
| program external_declaration
;

external_declaration
: function_definition
| declaration
;

function_definition
: type_name declarator compound_statement
{
  
}
;

%%
#include <stdio.h>
#include <string.h>

extern char yytext[];
extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;

int yyerror (char *s) {
  fflush (stdout);
  fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
  return 0;
}


int main (int argc, char *argv[]) {
  niv = 0; //debugg
  nb_parameter = 0;
  level = 0;
  init();
  last_function ="";
  last_name="";
  FILE *input = NULL;
  if (argc==2) {
    input = fopen (argv[1], "r");
    file_name = strdup (argv[1]);
    if (input) {
      yyin = input;
    }
    else {
      fprintf (stderr, "%s: Could not open %s\n", *argv, argv[1]);
      return 1;
    }
  }
  else {
    fprintf (stderr, "%s: error: no input file\n", *argv);
    return 1;
  }
  yyparse ();
  printtab();
  free (file_name);
  return 0;
}
