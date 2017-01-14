%{
	#include <stdio.h>
	#include <stdlib.h>

	typedef void *yyscan_t;

	#include "test.y.h"
	#include "test.l.h"

	void yyerror(yyscan_t *, const char *);
%}

%glr-parser
%define api.pure
%define parse.error verbose
%lex-param {yyscan_t scanner}
%parse-param {yyscan_t scanner}

%union {
	int ival;
	char cval;
	char *sval;
}

%token END 0 "end of file"
%token VOID "void"
%token INT "int"
%token FLOAT "float"
%token BOOL "bool"
%token CHAR "char"
%token STRING "string"
%token RETURN "return"
%token <sval> IDENTIFIER "identifier"
%token <ival> INT_LITERAL "integer literal"
%token <cval> CHAR_LITERAL "character literal"
%token <sval> STRING_LITERAL "string literal"
%token SHIFT_LEFT "<<"
%token SHIFT_RIGHT ">>"
%token AND "&&"
%token OR "||"
%token LESS_OR_EQUAL "<="
%token GREATER_OR_EQUAL ">="
%token EQUAL "=="
%token NOT_EQUAL "!="
%token PLUS_EQUAL "+="
%token MINUS_EQUAL "-="
%token MULTIPLY_EQUAL "*="
%token DIVIDE_EQUAL "/="
%token MODULO_EQUAL "%="
%token BIT_AND_EQUAL "&="
%token BIT_XOR_EQUAL "^="
%token BIT_OR_EQUAL "|="
%token SHIFT_LEFT_EQUAL "<<="
%token SHIFT_RIGHT_EQUAL ">>="
%left '=' "+=" "-=" "*=" "/=" "%=" "&=" "|=" "^=" "<<=" ">>="
%left "||"
%left "&&"
%left '|'
%left '^'
%left '&'
%left "==" "!="
%left '<' '>' "<=" ">="
%left "<<" ">>"
%left '+' '-'
%left '*' '/' '%'
%precedence UNARY_MINUS UNARY_PLUS NOT
%precedence '[' ']' '(' ')'

%%

program:
		%empty
	|	program toplevel_statement
	;

toplevel_statement:
		function
	;

function:
		type IDENTIFIER '(' parameter_list ')' '{' statements '}'
	;

type:
		type_name
	|	type_name '[' ']'
	;

type_name:
		VOID
	|	INT
	|	FLOAT
	|	BOOL
	|	CHAR
	|	STRING
	;

parameter_list:
		%empty
	|	parameter_list_notempty
	;

parameter_list_notempty:
		parameter
	|	parameter_list_notempty ',' parameter
	;

parameter:
		type IDENTIFIER
	;

statements:
		%empty
	|	statements statement
	;

statement:
		expression_statement
	|	var_decl_statement
	|	return_statement
	;

expression_statement:
		expression ';'
	;

var_decl_statement:
		type var_decl_list ';'
	;

var_decl_list:
		var_decl
	|	var_decl_list ',' var_decl
	;

var_decl:
		IDENTIFIER
	|	IDENTIFIER '=' expression
	;

return_statement:
		RETURN expression ';'
	;

expression:
		STRING_LITERAL
	|	INT_LITERAL
	|	CHAR_LITERAL
	|	IDENTIFIER
	|	expression '[' expression ']'
	|	expression '(' expression_list ')'
	|	'-' expression %prec UNARY_MINUS
	|	'+' expression %prec UNARY_PLUS
	|	'!' expression %prec NOT
	|	expression '+' expression
	|	expression '-' expression
	|	expression '*' expression
	|	expression '/' expression
	|	expression '%' expression
	|	expression "<<" expression
	|	expression ">>" expression
	|	expression '&' expression
	|	expression '^' expression
	|	expression '|' expression
	|	expression "&&" expression
	|	expression "||" expression
	|	expression '<' expression
	|	expression '>' expression
	|	expression "<=" expression
	|	expression ">=" expression
	|	expression "==" expression
	|	expression "!=" expression
	|	expression '=' expression
	|	expression "+=" expression
	|	expression "-=" expression
	|	expression "*=" expression
	|	expression "/=" expression
	|	expression "%=" expression
	|	expression "&=" expression
	|	expression "|=" expression
	|	expression "^=" expression
	|	expression "<<=" expression
	|	expression ">>=" expression
	|	'(' expression ')'
	;

expression_list:
		%empty
	|	expression_list_notempty
	;

expression_list_notempty:
		expression
	|	expression_list_notempty ',' expression
	;

%%

int main(int argc, char **argv) {
	yyscan_t scanner;

	FILE *stream;
	if(argc > 1) {
		FILE *f = fopen(argv[1], "r");
		if(!f) {
			perror("Unable to open source file");
			exit(-1);
		}

		stream = f;
	} else {
		stream = stdin;
	}

	yylex_init(&scanner);
	yyset_in(stream, scanner);

	int ret = yyparse(scanner);

	yylex_destroy(scanner);

	return ret;
}

void yyerror (yyscan_t *scanner, char const *s) {
	fprintf(stderr, "%s\n", s);
}
