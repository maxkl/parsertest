
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

enum parser_status parse(yyscan_t scanner, bool trace, ast_node_t *root) {
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
	} while(parser->status == PARSER_ACTIVE && token != NULL);
	*root = parser->root;
	enum parser_status status = parser->status;
	free_parser(parser);
	return status;
}

enum parser_status parser_parse_stream(FILE *stream, bool trace, ast_node_t *root) {
	yyscan_t scanner;
	yylex_init(&scanner);
	yyset_in(stream, scanner);
	enum parser_status status = parse(scanner, trace, root);
	yylex_destroy(scanner);
	return status;
}

enum parser_status parser_parse_file(const char *filename, bool trace, ast_node_t *root) {
	FILE *stream = fopen(filename, "r");
	if(!stream) {
		fprintf(stderr, "Unable to open file: %s: %s\n", filename, strerror(errno));
		return -1;
	}

	enum parser_status status = parser_parse_stream(stream, trace, root);

	fclose(stream);

	return status;
}
