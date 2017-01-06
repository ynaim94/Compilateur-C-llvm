%{
#include <stdio.h>
#include "type.h"
#include "hash.h"
#include "assert.h" 
#include "string.h"
  char *last_name;
  
  extern int yylineno;
  int yylex ();
  int yyerror ();
  %}

%token <string> IDENTIFIER <doubl> CONSTANTF <integer> CONSTANTI
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN DIV_ASSIGN
%token SHL_ASSIGN SHR_ASSIGN
%token REM_ASSIGN
%token REM SHL SHR
%token AND OR
%token TYPE_NAME
%token INT FLOAT VOID
%token IF ELSE WHILE RETURN FOR DO
%type <t> declarator  parameter_declaration
%type <pl> parameter_list
%start program
%union {
  char *string;
  int integer;
  float doubl;
  struct Type* t;
  struct Type ** pl;
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
| CONSTANTI 
| CONSTANTF 
| '(' expression ')'
| IDENTIFIER '(' ')' 
| IDENTIFIER '(' argument_expression_list ')' 
;

postfix_expression
: primary_expression
| postfix_expression INC_OP
| postfix_expression DEC_OP
;

argument_expression_list
: expression
| argument_expression_list ',' expression
;

unary_expression
: postfix_expression
| INC_OP unary_expression
| DEC_OP unary_expression
| unary_operator unary_expression
;

unary_operator
: '-'
;

multiplicative_expression
: unary_expression
| multiplicative_expression '*' unary_expression
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
: VOID {last_type.type = VOIDD; printf("niv %d \n", niv);}
| INT {last_type.type = INTEGER;printf("niv %d \n", niv);}
| FLOAT {last_type.type = DOUBLE;printf("niv %d \n", niv);}
;

declarator
: IDENTIFIER
{
  
  // printf("niv %d Identifier %d name %s level %d last_name %s actual function %s\n",niv ,last_type.type,$1,level,last_name,last_function);
  $$ = create_symbol(last_type);
  if ((!(strcmp(last_name,""))) && (level == 0)){
    last_name = $1;
  }
  else{
    if (level ==0){
      key_t k = {$1,last_name,level};
      addtab(k,$$);
    }
    else{
      key_t k = {$1,last_function,level};
      addtab(k,$$);
    }
  }
    /*else {
    last_function = $1;
    assert(0);
  }
  key_t k = {$1,last_function,level};
  addtab(k, $$);*/
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
  key_t k = {last_name,last_function,level};
  addtab(k, $$);
  last_function =last_name;
  last_name ="";
  printf("niv %d declarator(p) %d\n", niv,$1->type);
}

| declarator '(' ')'
{
  niv ++;
  $1 = create_symbol_function(*($$), NULL);
  free($$);
  $$ = $1;
  key_t k = {last_name,last_function,level};
  addtab(k, $$);
  last_name ="";
  printf("niv %d declarator(p) %d\n", niv,$1->type);

  /*  $$ = create_symbol_function(last_type, NULL);
  $1 = $$;
  printf("niv %d declarator() %d\n", niv,last_type.type = FUNCTION);
   last_type.type = FUNCTION;*/
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
