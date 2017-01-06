%{
    #include <stdio.h>
    extern int yylineno;
    int yylex ();
    int yyerror ();

%}

%token <string> IDENTIFIER 
%token <d> CONSTANTD
%token <n> CONSTANTI
%type <e> PRIMARY_EXPRESSION
%type <e> POSTFIX_EXPRESSION
%type <e> ARGUMENT_EXPRESSION_LIST
%type <e> UNARY_EXPRESSION
%type <e> UNARY_OPERATOR
%type <e> MULTIPLICATIVE_EXPRESSION
%type <e> ADDITIVE_EXPRESSION
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN DIV_ASSIGN
%token SHL_ASSIGN SHR_ASSIGN
%token REM_ASSIGN
%token REM SHL SHR
%token AND OR
%token TYPE_NAME
%token INT DOUBLE VOID
%token IF ELSE WHILE RETURN FOR DO
%start program
%union {
  double d;
  int n;
  struct expr *e;
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
: IDENTIFIER {printf("ID: %s \n", $1);}
| CONSTANTI {
  $$=new_expr();
  $$->var=new_var();
  $$->type=new_type(INT_T); //don't have
  char *code;
  asprintf(&code,"%%x%d=add i32 0,%d\n", $$->var,$1);
  $$->code=code;
}

| CONSTANTD {
  $$=new_expr();
  $$->var=new_ver();
  $$->type=new_type(DOUBLE_T); //don't have
  char *code;
  asprintf(&code,"%%x%d=add double %s,%s\n",$$->var,double_to_hex_str(0),double_to_hex_str(1));
  $$->code=code;
}

| '(' expression ')'
| IDENTIFIER '(' ')' {printf("ID: %s \n", $1);}
| IDENTIFIER '(' argument_expression_list ')' {printf("ID: %s \n", $1);}
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
: VOID
| INT
| DOUBLE
;

declarator
: IDENTIFIER {printf("ID: %s \n", $1);}
| '(' declarator ')'
| declarator '(' parameter_list ')'
| declarator '(' ')'
;

parameter_list
: parameter_declaration
| parameter_list ',' parameter_declaration
;

parameter_declaration
: type_name declarator
;

statement
: compound_statement
| expression_statement
| selection_statement
| iteration_statement
| jump_statement
;

compound_statement
: '{' '}'
| '{' statement_list '}'
| '{' declaration_list statement_list '}'
| '{' declaration_list '}'
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
| DO statement WHILE '(' expression ')'
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
    free (file_name);
    return 0;
}
