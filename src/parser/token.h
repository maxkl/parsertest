
#pragma once

enum token_data_type {
	TYPE_NONE,
	TYPE_INT,
	TYPE_CHAR,
	TYPE_STRING
};

struct token {
	int type;
	enum token_data_type data_type;
	union {
		int int_data;
		char char_data;
		char *string_data;
	};
};
typedef struct token *token_t;

token_t create_token(int type);
token_t create_token_int(int, int);
token_t create_token_char(int, char);
token_t create_token_string(int, char *);

void free_token(token_t token);
