
#pragma once

#include <stdio.h>
#include <stdbool.h>

#include "ast.h"

enum parser_status {
	PARSER_ACTIVE = -1,
	PARSER_OK = 0,
	PARSER_FAILED,
	PARSER_FAILED_SYNTAX_ERROR,
	PARSER_FAILED_STACK_OVERFLOW
};

enum parser_status parser_parse_stream(FILE *stream, bool trace, ast_node_t *root);
enum parser_status parser_parse_file(const char *filename, bool trace, ast_node_t *root);
