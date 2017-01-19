
#include <stdlib.h>
#include <stdio.h>

#include "ast.h"

const char *ast_node_type_names[] = {
	"AST_PROGRAM",
	"AST_FUNCTION",
	"AST_PARAMETER_LIST",
	"AST_PARAMETER",
	"AST_STATEMENTS",
	"AST_DECLARATION",
	"AST_DECLARATOR_LIST",
	"AST_DECLARATOR",
	"AST_RETURN",
	"AST_STRING_LITERAL",
	"AST_INT_LITERAL",
	"AST_CHAR_LITERAL",
	"AST_IDENTIFIER",
	"AST_FUNCTION_CALL",
	"AST_UNOP_EXPR",
	"AST_BINOP_EXPR",
	"AST_COMP_EXPR",
	"AST_ASSIGN_EXPR",
	"AST_EXPR_LIST"
};

const char *ast_type_names[] = {
	"void",
	"int",
	"float",
	"bool",
	"char",
	"string"
};

const char *ast_unop_symbols[] = {
	"-",
	"+",
	"!"
};

const char *ast_binop_symbols[] = {
	"+",
	"-",
	"*",
	"/",
	"%",
	"<<",
	">>",
	"&",
	"|",
	"^",
	"&&",
	"||"
};

const char *ast_comp_symbols[] = {
	"<",
	">",
	"<=",
	">=",
	"==",
	"!="
};

ast_node_t create_ast_node(ast_node_type_t type, size_t child_count, ...) {
	ast_node_t node = malloc(sizeof(*node));
	if(node) {
		node->type = type;
		node->child_count = child_count;
		if(child_count > 0) {
			node->children = malloc(sizeof(*node->children) * child_count);
			if(node->children) {
				va_list children;
				va_start(children, child_count);
				for(size_t i = 0; i < child_count; i++) {
					node->children[i] = va_arg(children, ast_node_t);
				}
				va_end(children);
			}
		} else {
			node->children = NULL;
		}
	}
	return node;
}

void add_ast_node(ast_node_t node, ast_node_t child) {
	node->child_count++;
	ast_node_t *new_children = realloc(node->children, sizeof(*node->children) * node->child_count);
	if(new_children) {
		node->children = new_children;
		node->children[node->child_count - 1] = child;
	} else {
		fprintf(stderr, "Failed to allocate memory for AST node children\n");
	}
}

void copy_ast_children(ast_node_t from, ast_node_t to) {
	for(size_t i = 0; i < from->child_count; i++) {
		add_ast_node(to, from->children[i]);
	}
}

void free_ast_node(ast_node_t node, bool recursive) {
	if(recursive) {
		for(size_t i = 0; i < node->child_count; i++) {
			free_ast_node(node->children[i], true);
		}
	}
	if(node->child_count > 0) {
		free(node->children);
	}
	switch(node->type) {
		case AST_FUNCTION:
			free(node->function.name);
			free_ast_node(node->function.parameter_list, true);
			break;
		case AST_PARAMETER:
			free(node->parameter.name);
			break;
		case AST_DECLARATOR:
			free(node->declarator.name);
			break;
		case AST_STRING_LITERAL:
			free(node->string_literal.value);
			break;
		case AST_IDENTIFIER:
			free(node->identifier.name);
			break;
		case AST_FUNCTION_CALL:
			free(node->function_call.name);
			break;
		default:
			break;
	}
	free(node);
}

void print_ast_node_indented(ast_node_t node, unsigned indent_level) {
	printf("%*s%s: ", indent_level * 2, "", ast_node_type_names[node->type]);
	switch(node->type) {
		case AST_FUNCTION:
			printf("%s %s(", ast_type_names[node->function.type], node->function.name);
			ast_node_t params = node->function.parameter_list;
			ast_node_t param;
			for(size_t i = 0; i < params->child_count; i++) {
				param = params->children[i];
				printf("%s %s", ast_type_names[param->parameter.type], param->parameter.name);
				if(i < params->child_count - 1) {
					printf(", ");
				}
			}
			printf(")");
			break;
		case AST_DECLARATION:
			printf("%s", ast_type_names[node->declaration.type]);
			break;
		case AST_DECLARATOR:
			printf("%s", node->declarator.name);
			break;
		case AST_STRING_LITERAL:
			printf("\"%s\"", node->string_literal.value);
			break;
		case AST_INT_LITERAL:
			printf("%i", node->int_literal.value);
			break;
		case AST_CHAR_LITERAL:
			printf("'%c'", node->char_literal.value);
			break;
		case AST_IDENTIFIER:
			printf("%s", node->identifier.name);
			break;
		case AST_FUNCTION_CALL:
			printf("%s", node->function_call.name);
			break;
		case AST_UNOP_EXPR:
			printf("%s", ast_unop_symbols[node->unop.op]);
			break;
		case AST_BINOP_EXPR:
			printf("%s", ast_binop_symbols[node->binop.op]);
			break;
		case AST_COMP_EXPR:
			printf("%s", ast_comp_symbols[node->comp.op]);
			break;
		default:
			break;
	}
	printf("\n");
	for(size_t i = 0; i < node->child_count; i++) {
		print_ast_node_indented(node->children[i], indent_level + 1);
	}
}

void print_ast_node(ast_node_t node) {
	print_ast_node_indented(node, 0);
}
