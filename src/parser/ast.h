
#pragma once

#include <stdbool.h>
#include <stdarg.h>

enum ast_node_type {
	AST_PROGRAM = 0,
	AST_FUNCTION,
	AST_PARAMETER_LIST,
	AST_PARAMETER,
	AST_STATEMENTS,
	AST_DECLARATION,
	AST_DECLARATOR_LIST,
	AST_DECLARATOR,
	AST_RETURN,
	AST_STRING_LITERAL,
	AST_INT_LITERAL,
	AST_CHAR_LITERAL,
	AST_IDENTIFIER,
	AST_FUNCTION_CALL,
	AST_UNOP_EXPR,
	AST_BINOP_EXPR,
	AST_COMP_EXPR,
	AST_ASSIGN_EXPR,
	AST_EXPR_LIST
};
typedef enum ast_node_type ast_node_type_t;

extern const char *ast_node_type_names[];

enum ast_type {
	AST_TYPE_VOID = 0,
	AST_TYPE_INT,
	AST_TYPE_FLOAT,
	AST_TYPE_BOOL,
	AST_TYPE_CHAR,
	AST_TYPE_STRING
};

extern const char *ast_type_names[];

enum ast_unop_op {
	AST_UNOP_MINUS = 0,
	AST_UNOP_PLUS,
	AST_UNOP_NOT
};

extern const char *ast_unop_symbols[];

enum ast_binop_op {
	AST_BINOP_ADD = 0,
	AST_BINOP_SUBTRACT,
	AST_BINOP_MULTIPLY,
	AST_BINOP_DIVIDE,
	AST_BINOP_MODULO,
	AST_BINOP_SHIFT_LEFT,
	AST_BINOP_SHIFT_RIGHT,
	AST_BINOP_BIT_AND,
	AST_BINOP_BIT_OR,
	AST_BINOP_BIT_XOR,
	AST_BINOP_AND,
	AST_BINOP_OR
};

extern const char *ast_binop_symbols[];

enum ast_comp_op {
	AST_COMP_LESS = 0,
	AST_COMP_GREATER,
	AST_COMP_LESS_EQUAL,
	AST_COMP_GREATER_EQUAL,
	AST_COMP_EQUAL,
	AST_COMP_NOT_EQUAL
};

extern const char *ast_comp_symbols[];

struct ast_node;
typedef struct ast_node *ast_node_t;
struct ast_node {
	ast_node_type_t type;
	union {
		struct { enum ast_type type; char *name; ast_node_t parameter_list; } function;
		struct { enum ast_type type; char *name; } parameter;
		struct { enum ast_type type; } declaration;
		struct { char *name; } declarator;
		struct { char *value; } string_literal;
		struct { int value; } int_literal;
		struct { char value; } char_literal;
		struct { char *name; } identifier;
		struct { char *name; } function_call;
		struct { enum ast_unop_op op; } unop;
		struct { enum ast_binop_op op; } binop;
		struct { enum ast_comp_op op; } comp;

	};
	size_t child_count;
	ast_node_t *children;
};

ast_node_t create_ast_node(ast_node_type_t type, size_t child_count, ...);
void add_ast_node(ast_node_t node, ast_node_t child);
void copy_ast_children(ast_node_t from, ast_node_t to);
void free_ast_node(ast_node_t node, bool recursive);
void print_ast_node(ast_node_t node);
