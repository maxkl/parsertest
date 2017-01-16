
#pragma once

#include <stdio.h>
#include <stdbool.h>

int parser_parse_stream(FILE *stream, bool trace);
int parser_parse_file(const char *filename, bool trace);
