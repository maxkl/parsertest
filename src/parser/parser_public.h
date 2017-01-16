
#pragma once

#include <stdbool.h>

#include "token.h"

typedef void *parser_t;

parser_t create_parser();
void parser_trace(FILE *stream, const char *prefix);
void free_parser(parser_t parser);
void parser_parse(parser_t parser, token_t token);
