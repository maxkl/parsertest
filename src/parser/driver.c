
#include <stdlib.h>

#include "driver.h"
#include "token.h"
#include "parser_public.h"
#include "lexer_header.h"
#include "lexer.h"

void print_token(token_t token) {
	if(token == NULL) {
		fprintf(stderr, "TOKEN: EOF\n");
	} else {
		fprintf(stderr, "TOKEN: %i, ", token->type);
		switch(token->data_type) {
			case TYPE_NONE:
				fprintf(stderr, "none");
				break;
			case TYPE_INT:
				fprintf(stderr, "int, %i", token->int_data);
				break;
			case TYPE_CHAR:
				fprintf(stderr, "char, %i=%c", token->char_data, token->char_data);
				break;
			case TYPE_STRING:
				fprintf(stderr, "string, %s", token->string_data);
				break;
		}
		fprintf(stderr, "\n");
	}
}

int parse(yyscan_t scanner, bool trace) {
	parser_t parser = create_parser();
	if(trace) {
		parser_trace(stderr, "PARSER: ");
	}
	token_t token;
	do {
		token = yylex(scanner);
		if(trace) {
			print_token(token);
		}
		parser_parse(parser, token);
	} while(token != NULL);
	free_parser(parser);
	return 0;
}

int parser_parse_stream(FILE *stream, bool trace) {
	yyscan_t scanner;
	yylex_init(&scanner);
	yyset_in(stream, scanner);
	int ret = parse(scanner, trace);
	yylex_destroy(scanner);
	return ret;
}

int parser_parse_file(const char *filename, bool trace) {
	FILE *stream = fopen(filename, "r");
	if(!stream) {
		fprintf(stderr, "Unable to open file: %s: %s\n", filename, strerror(errno));
		return -1;
	}

	int ret = parser_parse_stream(stream, trace);

	fclose(stream);

	return ret;
}
