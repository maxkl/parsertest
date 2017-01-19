
%include {
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <assert.h>

	#include "token.h"
	#include "parser_public.h"
}

%token_type { token_t }
%extra_argument { parser_t parser }
%default_type { ast_node_t }

%syntax_error {
	parser->status = PARSER_FAILED_SYNTAX_ERROR;
}

%parse_accept {
	parser->status = PARSER_OK;
}

%parse_failure {
	parser->status = PARSER_FAILED;
}

%stack_overflow {
	parser->status = PARSER_FAILED_STACK_OVERFLOW;
}

%token_destructor {
	free_token($$);
}

%default_destructor {
	free_ast_node($$, false);
}

%left COMMA.
%right ASSIGN.
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

start ::= program(A). { parser->root = A; }

program(R) ::= toplevel_statement(A). { R = create_ast_node(AST_PROGRAM, 1, A); }
program(R) ::= program(A) toplevel_statement(B). { R = A; add_ast_node(R, B); }

toplevel_statement(R) ::= function(A). { R = A; }

function(R) ::= type(A) IDENTIFIER(B) LPAREN parameter_list(C) RPAREN LBRACE statements(D) RBRACE. {
	R = create_ast_node(AST_FUNCTION, 0);
	R->function.type = A;
	R->function.name = strdup(B->string_data);
	R->function.parameter_list = C;
	for(size_t i = 0; i < D->child_count; i++) {
		add_ast_node(R, D->children[i]);
	}
	free_token(B);
	free_ast_node(D, false);
}

%type type { enum ast_type }
%destructor type {}
type(R) ::= VOID. { R = AST_TYPE_VOID; }
type(R) ::= INT. { R = AST_TYPE_INT; }
type(R) ::= FLOAT. { R = AST_TYPE_FLOAT; }
type(R) ::= BOOL. { R = AST_TYPE_BOOL; }
type(R) ::= CHAR. { R = AST_TYPE_CHAR; }
type(R) ::= STRING. { R = AST_TYPE_STRING; }

parameter_list(R) ::= . { R = create_ast_node(AST_PARAMETER_LIST, 0); }
parameter_list(R) ::= parameter_list_not_empty(A). { R = A; }

parameter_list_not_empty(R) ::= parameter(A). { R = create_ast_node(AST_PARAMETER_LIST, 1, A); }
parameter_list_not_empty(R) ::= parameter_list_not_empty(A) COMMA parameter(B). { R = A; add_ast_node(R, B); }

parameter(R) ::= type(A) IDENTIFIER(B). { R = create_ast_node(AST_PARAMETER, 0); R->parameter.type = A; R->parameter.name = strdup(B->string_data); free_token(B); }

statements(R) ::= . { R = create_ast_node(AST_STATEMENTS, 0); }
statements(R) ::= statements(A) statement(B). { R = A; add_ast_node(R, B); }

statement(R) ::= expression_statement(A). { R = A; }
statement(R) ::= var_decl_statement(A). { R = A; }
statement(R) ::= return_statement(A). { R = A; }

expression_statement(R) ::= expression(A) SEMICOLON. { R = A; }

var_decl_statement(R) ::= type(A) var_decl_list(B) SEMICOLON. {
	R = create_ast_node(AST_DECLARATION, 0);
	R->declaration.type = A;
	copy_ast_children(B, R);
	free_ast_node(B, false);
}

var_decl_list(R) ::= var_decl(A). { R = create_ast_node(AST_DECLARATOR_LIST, 1, A); }
var_decl_list(R) ::= var_decl_list(A) COMMA var_decl(B). { R = A; add_ast_node(R, B); }

var_decl(R) ::= IDENTIFIER(A). { R = create_ast_node(AST_DECLARATOR, 0); R->declarator.name = strdup(A->string_data); free_token(A); }
var_decl(R) ::= IDENTIFIER(A) ASSIGN expression(B). { R = create_ast_node(AST_DECLARATOR, 1, B); R->declarator.name = strdup(A->string_data); free_token(A); }

return_statement(R) ::= RETURN expression(A) SEMICOLON. { R = create_ast_node(AST_RETURN, 1, A); }

expression(R) ::= LPAREN expression(A) RPAREN. { R = A; }
expression(R) ::= STRING_LITERAL(A). { R = create_ast_node(AST_STRING_LITERAL, 0); R->string_literal.value = strdup(A->string_data); free_token(A); }
expression(R) ::= INT_LITERAL(A). { R = create_ast_node(AST_INT_LITERAL, 0); R->int_literal.value = A->int_data; free_token(A); }
expression(R) ::= CHAR_LITERAL(A). { R = create_ast_node(AST_CHAR_LITERAL, 0); R->char_literal.value = A->char_data; free_token(A); }
expression(R) ::= IDENTIFIER(A). { R = create_ast_node(AST_IDENTIFIER, 0); R->identifier.name = strdup(A->string_data); free_token(A); }
expression(R) ::= IDENTIFIER(A) LPAREN expression_list(B) RPAREN. {
	R = create_ast_node(AST_FUNCTION_CALL, 0);
	R->function_call.name = strdup(A->string_data);
	copy_ast_children(B, R);
	free_token(A);
	free_ast_node(B, false);
}
expression(R) ::= MINUS expression(A). [UNARY_MINUS] { R = create_ast_node(AST_UNOP_EXPR, 1, A); R->unop.op = AST_UNOP_MINUS; }
expression(R) ::= PLUS expression(A). [UNARY_PLUS] { R = create_ast_node(AST_UNOP_EXPR, 1, A); R->unop.op = AST_UNOP_PLUS; }
expression(R) ::= NOT expression(A). [NOT] { R = create_ast_node(AST_UNOP_EXPR, 1, A); R->unop.op = AST_UNOP_NOT; }
expression(R) ::= expression(A) PLUS expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_ADD; }
expression(R) ::= expression(A) MINUS expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_SUBTRACT; }
expression(R) ::= expression(A) MULTIPLY expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_MULTIPLY; }
expression(R) ::= expression(A) DIVIDE expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_DIVIDE; }
expression(R) ::= expression(A) MODULO expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_MODULO; }
expression(R) ::= expression(A) SHIFT_LEFT expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_SHIFT_LEFT; }
expression(R) ::= expression(A) SHIFT_RIGHT expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_SHIFT_RIGHT; }
expression(R) ::= expression(A) BIT_AND expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_BIT_AND; }
expression(R) ::= expression(A) BIT_XOR expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_BIT_XOR; }
expression(R) ::= expression(A) BIT_OR expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_BIT_OR; }
expression(R) ::= expression(A) AND expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_AND; }
expression(R) ::= expression(A) OR expression(B). { R = create_ast_node(AST_BINOP_EXPR, 2, A, B); R->binop.op = AST_BINOP_OR; }
expression(R) ::= expression(A) LESS expression(B). { R = create_ast_node(AST_COMP_EXPR, 2, A, B); R->comp.op = AST_COMP_LESS; }
expression(R) ::= expression(A) GREATER expression(B). { R = create_ast_node(AST_COMP_EXPR, 2, A, B); R->comp.op = AST_COMP_GREATER; }
expression(R) ::= expression(A) LESS_EQUAL expression(B). { R = create_ast_node(AST_COMP_EXPR, 2, A, B); R->comp.op = AST_COMP_LESS_EQUAL; }
expression(R) ::= expression(A) GREATER_EQUAL expression(B). { R = create_ast_node(AST_COMP_EXPR, 2, A, B); R->comp.op = AST_COMP_GREATER_EQUAL; }
expression(R) ::= expression(A) EQUAL expression(B). { R = create_ast_node(AST_COMP_EXPR, 2, A, B); R->comp.op = AST_COMP_EQUAL; }
expression(R) ::= expression(A) NOT_EQUAL expression(B). { R = create_ast_node(AST_COMP_EXPR, 2, A, B); R->comp.op = AST_COMP_NOT_EQUAL; }
expression(R) ::= expression(A) ASSIGN expression(B). { R = create_ast_node(AST_ASSIGN_EXPR, 2, A, B); }

expression_list(R) ::= . { R = create_ast_node(AST_EXPR_LIST, 0); }
expression_list(R) ::= expression_list_not_empty(A). { R = A; }

expression_list_not_empty(R) ::= expression(A). { R = create_ast_node(AST_EXPR_LIST, 1, A); }
expression_list_not_empty(R) ::= expression_list_not_empty(A) COMMA expression(B). { R = A; add_ast_node(R, B); }

%code {
	parser_t create_parser() {
		parser_t parser = malloc(sizeof(*parser));
		if(parser) {
			parser->status = PARSER_ACTIVE;
			parser->parser = ParseAlloc(malloc);
			parser->root = NULL;
		}
		return parser;
	}

	void parser_trace(FILE *stream, char *prefix) {
#ifndef NDEBUG
		ParseTrace(stream, prefix);
#endif
	}

	void free_parser(parser_t parser) {
		ParseFree(parser->parser, free);
		free(parser);
	}

	void parser_parse(parser_t parser, token_t t) {
		if(t == NULL) {
			Parse(parser->parser, 0, NULL, parser);
		} else {
			Parse(parser->parser, t->type, t, parser);
		}
	}
}
