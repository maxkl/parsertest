
#pragma once

#include <stdio.h>
#include <stdbool.h>

#include "ast.h"

int parser_parse_stream(FILE *stream, bool trace, ast_node_t *root);
int parser_parse_file(const char *filename, bool trace, ast_node_t *root);
