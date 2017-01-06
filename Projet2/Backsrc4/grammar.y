%{
#define _GNU_SOURCE
#include <stdio.h>
#include "assert.h" 
#include "string.h"

#include "type.h"
#include "hash.h"
#include "expression.h"


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
%type <expr> primary_expression postfix_expression argument_expression_list unary_expression unary_operator multiplicative_expression additive_expression expression
%start program
%union {
  char *string;
  int integer;
  double doubl;
  struct Type* t;
  struct Type ** pl;
  struct Expr* expr;
}
%%

conditional_expression
: logical_or_expression
;

logical_or_expression
: logical_and_expression
| logical_or_expression OR logical_and_expression
;

logical_and_expression
: comparison_expression
| logical_and_expression AND comparison_expression
;


shift_expression
: additive_expression
| shift_expression SHL additive_expression
| shift_expression SHR additive_expression
;


primary_expression 
: IDENTIFIER
{
  int lvl;
  assert((lvl = intab($1))); //teste si $1 a bien été déclaré
  key_t k = {$1,last_function,intab($1)}; 
  symbol_t sym = findtab(k);
  $$ = new_expr();
  $$->var = new_var();
  $$->type = new_type(sym.type->type);
  $$->code = " ";
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
  $$->code = " "; //a faire

}

| IDENTIFIER '(' argument_expression_list ')'
{
  key_t k = {$1,"\0", 0};
  symbol_t sym = findtab(k);
  assert((!(strcmp(sym.name,k.name))));
  printf("%s , %d == %d\n",$1,sym.type->f->nbParam, $3->length);
  assert ((sym.type->type == FUNCTION) && (sym.type->f->nbParam == $3->length));
  $$ = new_expr();
  $$->var = new_var();
  $$->type = new_type(sym.type->type);
  $$->code = " ";
}
;

postfix_expression
: primary_expression
{
  $$ = $1;
}
| postfix_expression INC_OP
{
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
  $$->length = 1;
}
| argument_expression_list ',' expression
{/*
   char *code = malloc (strlen($1->code) + strlen($3->code) +2);
   strcpy(code, $1->code);
   strcat(code,",");
   strcat(code, $3->code);
   $$->code = code;
   assert((concat_var($$->var,&($$->length), $3->var,1)));
   assert((concat_var($$->var,&($$->length), $1->var,$1->length)));
 */
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
  $$->var = new_var();
  char *code;
  if (($1->type->type == INTEGER) && ($3->type->type == INTEGER)){
    asprintf(&code,"%%x%d=mul i32 %%x%d,%d\n", *$$->var,*$1->var,*$3->var);
  }
  /*else {
    int nv = *(new_var());
    if ($1->type->type == INTEGER){
    asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fmul double %%x%d,%d\n", nv,*$1->var , *$3->var,nv,-1);
    }
    else
    if ($3->type->type == INTEGER){
    asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d=fmul double %%x%d,%d\n", nv,*$3->var , *$1->var,nv,-1);
    }
    else {
    //int nv2 = (*new_var());
    //asprintf(&code,"%%x%d = sitofp i32 %%x%d to double\n%%x%d = sitofp i32 %%x%d to double\n%%x%d=fmul double %%x%d,%d\n", nv,*$3->var, nv2,*$1->var, *$1->var,nv,-1);
    asprintf(&code,"%%x%d=fmul double %%x%d,%d\n", *$$->var,*$1->var,*$3->var);
    }
    }
  
    //  char *code2 = malloc(strlen(code) + strlen($3->code) +strlen($1->code) +1);
    //  strcpy(code2,$3->code);
    //strcat(code2,$1->code);
    //strcat(code2,code);
    //$$->code = code2;
    //free(code);*/
}
| multiplicative_expression '/' unary_expression
| multiplicative_expression REM unary_expression
;

additive_expression
: multiplicative_expression
| additive_expression '+' multiplicative_expression
| additive_expression '-' multiplicative_expression
;

comparison_expression
: shift_expression
| comparison_expression '<' shift_expression
| comparison_expression '>' shift_expression
| comparison_expression LE_OP shift_expression
| comparison_expression GE_OP shift_expression
| comparison_expression EQ_OP shift_expression
| comparison_expression NE_OP shift_expression
;

expression
: unary_expression assignment_operator conditional_expression
| conditional_expression
;

assignment_operator
: '=' 
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
niv ++;
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
| expression_statement
| selection_statement
| iteration_statement
| jump_statement
;

compound_statement
: left-brace right-brace
| left-brace statement_list right-brace
| left-brace declaration_list statement_list right-brace
| left-brace declaration_list right-brace
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
| statement_list statement
;

expression_statement
: ';'
| expression ';'
;

selection_statement
: IF '(' expression ')' statement
| IF '(' expression ')' statement ELSE statement
| FOR '(' expression ';' expression ';' expression ')' statement
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
last_function =" ";
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
