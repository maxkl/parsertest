
%include {
	#include <stdio.h>
	#include <stdlib.h>
	#include <assert.h>

	#include "token.h"
	#include "parser_public.h"
}

%token_type { token_t }

%syntax_error {
	fprintf(stderr, "Syntax error!\n");
}

%parse_accept {
	printf("Parsing complete.\n");
}

%parse_failure {
	fprintf(stderr, "Parsing failed.\n");
}

%stack_overflow {
	fprintf(stderr, "Parser stack overflow.\n");
}

%token_destructor {
	free_token($$);
}

%left COMMA.
%right ASSIGN ADD_ASSIGN SUBTRACT_ASSIGN MULTIPLY_ASSIGN DIVIDE_ASSIGN
	MODULO_ASSIGN BIT_AND_ASSIGN BIT_OR_ASSIGN BIT_XOR_ASSIGN SHIFT_LEFT_ASSIGN
	SHIFT_RIGHT_ASSIGN.
%left OR.
%left AND.
%left BIT_OR.
%left BIT_XOR.
%left BIT_AND.
%left EQUAL NOT_EQUAL.
%left LESS GREATER LESS_EQUAL GREATER_EQUAL.
%left SHIFT_LEFT SHIFT_RIGHT.
%left PLUS MINUS.
%left MULTIPLY DIVIDE MODULO.
%right UNARY_MINUS UNARY_PLUS NOT.
%nonassoc LBRACKET LPAREN.

start ::= program.

program ::= toplevel_statement.
program ::= program toplevel_statement.

toplevel_statement ::= function.

function ::= type IDENTIFIER LPAREN parameter_list RPAREN LBRACE statements RBRACE.
function ::= type IDENTIFIER LPAREN RPAREN LBRACE statements RBRACE.

type ::= type_name.
type ::= type_name LBRACKET RBRACKET.

type_name ::= VOID.
type_name ::= INT.
type_name ::= FLOAT.
type_name ::= BOOL.
type_name ::= CHAR.
type_name ::= STRING.

parameter_list ::= parameter.
parameter_list ::= parameter_list COMMA parameter.

parameter ::= type IDENTIFIER.

statements ::= .
statements ::= statements statement.

statement ::= expression_statement.
statement ::= var_decl_statement.
statement ::= return_statement.

expression_statement ::= expression SEMICOLON.

var_decl_statement ::= type var_decl_list SEMICOLON.

var_decl_list ::= var_decl.
var_decl_list ::= var_decl_list COMMA var_decl.

var_decl ::= IDENTIFIER.
var_decl ::= IDENTIFIER ASSIGN expression.

return_statement ::= RETURN expression SEMICOLON.

expression ::= LPAREN expression RPAREN.
expression ::= STRING_LITERAL.
expression ::= INT_LITERAL.
expression ::= CHAR_LITERAL.
expression ::= IDENTIFIER.
expression ::= expression LBRACKET expression RBRACKET.
expression ::= expression LPAREN RPAREN.
expression ::= expression LPAREN expression_list RPAREN.
expression ::= MINUS expression. [UNARY_MINUS]
expression ::= PLUS expression. [UNARY_PLUS]
expression ::= NOT expression. [NOT]
expression ::= expression PLUS expression.
expression ::= expression MINUS expression.
expression ::= expression MULTIPLY expression.
expression ::= expression DIVIDE expression.
expression ::= expression MODULO expression.
expression ::= expression SHIFT_LEFT expression.
expression ::= expression SHIFT_RIGHT expression.
expression ::= expression BIT_AND expression.
expression ::= expression BIT_XOR expression.
expression ::= expression BIT_OR expression.
expression ::= expression AND expression.
expression ::= expression OR expression.
expression ::= expression LESS expression.
expression ::= expression GREATER expression.
expression ::= expression LESS_EQUAL expression.
expression ::= expression GREATER_EQUAL expression.
expression ::= expression EQUAL expression.
expression ::= expression NOT_EQUAL expression.
expression ::= expression ASSIGN expression.
expression ::= expression ADD_ASSIGN expression.
expression ::= expression SUBTRACT_ASSIGN expression.
expression ::= expression MULTIPLY_ASSIGN expression.
expression ::= expression DIVIDE_ASSIGN expression.
expression ::= expression MODULO_ASSIGN expression.
expression ::= expression BIT_AND_ASSIGN expression.
expression ::= expression BIT_OR_ASSIGN expression.
expression ::= expression BIT_XOR_ASSIGN expression.
expression ::= expression SHIFT_LEFT_ASSIGN expression.
expression ::= expression SHIFT_RIGHT_ASSIGN expression.

expression_list ::= expression.
expression_list ::= expression_list COMMA expression.

%code {
	parser_t create_parser() {
		return ParseAlloc(malloc);
	}

	void parser_trace(FILE *stream, const char *prefix) {
#ifndef NDEBUG
		ParseTrace(stream, prefix);
#endif
	}

	void free_parser(parser_t p) {
		ParseFree(p, free);
	}

	void parser_parse(parser_t p, token_t t) {
		if(t == NULL) {
			Parse(p, 0, NULL);
		} else {
			Parse(p, t->type, t);
		}
	}
}
