
#include <stdlib.h>

#include "driver.h"
#include "token.h"
#include "parser_public.h"
#include "lexer_header.h"
#include "lexer.h"

void print_token(token_t token) {
	if(token == NULL) {
		printf("TOKEN: EOF\n");
	} else {
		printf("TOKEN: %i, ", token->type);
		switch(token->data_type) {
			case TYPE_NONE:
				printf("none");
				break;
			case TYPE_INT:
				printf("int, %i", token->int_data);
				break;
			case TYPE_CHAR:
				printf("char, %i=%c", token->char_data, token->char_data);
				break;
			case TYPE_STRING:
				printf("string, %s", token->string_data);
				break;
		}
		printf("\n");
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
		print_token(token);
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
		perror("Unable to open source file");
		return -1;
	}

	int ret = parser_parse_stream(stream, trace);

	fclose(stream);

	return ret;
}
