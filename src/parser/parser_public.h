
#pragma once

#include <stdbool.h>

#include "token.h"
#include "ast.h"

struct parser {
	void *parser;
	ast_node_t root;
};
typedef struct parser *parser_t;

parser_t create_parser();
void parser_trace(FILE *stream, char *prefix);
void free_parser(parser_t parser);
void parser_parse(parser_t parser, token_t token);
