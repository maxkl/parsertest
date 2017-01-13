%{
	#include <stdio.h>
	#include <stdlib.h>

	int yylex();
	FILE *yyin;

	void yyerror(const char *);
%}

%glr-parser
%define parse.error verbose

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
%token ARRAY "array"
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

%%

program:
		%empty
	|	program toplevel_statement
	;

toplevel_statement:
		function
	;

function:
		type IDENTIFIER '(' arglist ')' '{' statements '}'
	;

type:
		VOID
	|	INT
	|	FLOAT
	|	BOOL
	|	CHAR
	|	ARRAY
	|	STRING
	;

arglist:
		%empty
	|	arglist_notempty
	;

arglist_notempty:
		arg
	|	arglist_notempty ',' arg
	;

arg:
		type IDENTIFIER
	;

statements:
		%empty
	|	statements statement
	;

statement:
		return_statement
	|	expression_statement
	;

expression_statement:
		expression ';'
	;

return_statement:
		RETURN expression ';'
	;

expression:
		STRING_LITERAL
	|	INT_LITERAL
	|	CHAR_LITERAL
	|	IDENTIFIER
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

%%

int main(int argc, char **argv) {
	if(argc > 1) {
		FILE *f = fopen(argv[1], "r");
		if(!f) {
			perror("Unable to open source file");
			exit(-1);
		}

		yyin = f;
	}

	return yyparse();
}

void yyerror (char const *s) {
	fprintf(stderr, "%s\n", s);
}
