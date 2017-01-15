%skeleton "lalr1.cc"
%require "3.0.4"
%define parse.trace
%define parse.error verbose
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define parser_class_name {test_parser}

%code requires {
	class test_driver;
}

%param {test_driver &driver}
%locations
%initial-action { @$.begin.filename = @$.end.filename = &driver.filename; }

%code {
	#include "test-driver.hpp"
}

%printer { yyoutput << $$; } <*>;

%token END 0 "end of file"
%token VOID "void"
%token INT "int"
%token FLOAT "float"
%token BOOL "bool"
%token CHAR "char"
%token STRING "string"
%token RETURN "return"
%token <std::string> IDENTIFIER "identifier"
%token <int> INT_LITERAL "integer literal"
%token <char> CHAR_LITERAL "character literal"
%token <std::string> STRING_LITERAL "string literal"
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
%token NOT "!"
%token MINUS "-"
%token PLUS "+"
%token MULTIPLY "*"
%token DIVIDE "/"
%token MODULO "%"
%token BIT_AND "&"
%token BIT_XOR "^"
%token BIT_OR "|"
%token LESS "<"
%token GREATER ">"
%token ASSIGN "="
%token SEMICOLON ";"
%token COMMA ","
%token PARENTHESIS_OPEN "("
%token PARENTHESIS_CLOSE ")"
%token BRACE_OPEN "{"
%token BRACE_CLOSE "}"
%token BRACKET_OPEN "["
%token BRACKET_CLOSE "]"
%left ","
%right "=" "+=" "-=" "*=" "/=" "%=" "&=" "|=" "^=" "<<=" ">>="
%left "||"
%left "&&"
%left "|"
%left "^"
%left "&"
%left "==" "!="
%left "<" ">" "<=" ">="
%left "<<" ">>"
%left "+" "-"
%left "*" "/" "%"
%right UNARY_MINUS UNARY_PLUS NOT
%precedence "[" "("

%%

%start program;
program:
		%empty
	|	program toplevel_statement
	;

toplevel_statement:
		function
	;

function:
		type IDENTIFIER "(" parameter_list ")" "{" statements "}"
	;

type:
		type_name
	|	type_name "[" "]"
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
	|	parameter_list_notempty "," parameter
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
		expression ";"
	;

var_decl_statement:
		type var_decl_list ";"
	;

var_decl_list:
		var_decl
	|	var_decl_list "," var_decl
	;

var_decl:
		IDENTIFIER
	|	IDENTIFIER "=" expression
	;

return_statement:
		RETURN expression ";"
	;

expression:
		STRING_LITERAL
	|	INT_LITERAL
	|	CHAR_LITERAL
	|	IDENTIFIER
	|	expression "[" expression "]"
	|	expression "(" expression_list ")"
	|	"-" expression %prec UNARY_MINUS
	|	"+" expression %prec UNARY_PLUS
	|	"!" expression %prec NOT
	|	expression "+" expression
	|	expression "-" expression
	|	expression "*" expression
	|	expression "/" expression
	|	expression "%" expression
	|	expression "<<" expression
	|	expression ">>" expression
	|	expression "&" expression
	|	expression "^" expression
	|	expression "|" expression
	|	expression "&&" expression
	|	expression "||" expression
	|	expression "<" expression
	|	expression ">" expression
	|	expression "<=" expression
	|	expression ">=" expression
	|	expression "==" expression
	|	expression "!=" expression
	|	expression "=" expression
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
	|	"(" expression ")"
	;

expression_list:
		%empty
	|	expression_list_notempty
	;

expression_list_notempty:
		expression
	|	expression_list_notempty "," expression
	;

%%

void yy::test_parser::error(const location_type &loc, const std::string &message) {
	driver.error(loc, message);
}
