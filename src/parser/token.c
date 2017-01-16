
#include <stdlib.h>
#include <stdio.h>

#include "token.h"

token_t create_token(int type) {
	struct token *token = malloc(sizeof(*token));
	if(token) {
		token->type = type;
		token->data_type = TYPE_NONE;
	}
	return token;
}

#define CREATE_TOKEN_FN(NAME, TYPECONST, TYPE) token_t create_token_ ## NAME (int type, TYPE data) { \
		token_t t = create_token(type); \
		if(t) { \
			t->data_type = TYPECONST; \
			t-> NAME ## _data = data; \
		} \
		return t; \
	}

CREATE_TOKEN_FN(int, TYPE_INT, int);
CREATE_TOKEN_FN(char, TYPE_CHAR, char);
CREATE_TOKEN_FN(string, TYPE_STRING, char *);

void free_token(token_t token) {
	switch(token->data_type) {
		case TYPE_STRING:
			free(token->string_data);
			break;
		default:
			break; // make gcc happy
	}
	free(token);
}
