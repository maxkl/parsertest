%{
	#include <stdio.h>
	#include <stdlib.h>

	#include "parser.h"
	#include "token.h"
	#include "lexer_header.h"

	char *string_contents(char *, size_t);
	char char_value(char *, size_t);
%}

%option reentrant
%option warn nodefault noyywrap
%option noinput nounput

%x COMMENT

%%

"/*"						{ BEGIN(COMMENT); }
<COMMENT>"*/"				{ BEGIN(INITIAL); }
<COMMENT>\n
<COMMENT>.
"//".*

"!"							{ return create_token(NOT); }
"-"							{ return create_token(MINUS); }
"+"							{ return create_token(PLUS); }
"*"							{ return create_token(MULTIPLY); }
"/"							{ return create_token(DIVIDE); }
"%"							{ return create_token(MODULO); }
"&"							{ return create_token(BIT_AND); }
"^"							{ return create_token(BIT_XOR); }
"|"							{ return create_token(BIT_OR); }
"<"							{ return create_token(LESS); }
">"							{ return create_token(GREATER); }
"="							{ return create_token(ASSIGN); }
";"							{ return create_token(SEMICOLON); }
","							{ return create_token(COMMA); }
"("							{ return create_token(LPAREN); }
")"							{ return create_token(RPAREN); }
"{"							{ return create_token(LBRACE); }
"}"							{ return create_token(RBRACE); }
"<<"						{ return create_token(SHIFT_LEFT); }
">>"						{ return create_token(SHIFT_RIGHT); }
"&&"						{ return create_token(AND); }
"||"						{ return create_token(OR); }
"<="						{ return create_token(LESS_EQUAL); }
">="						{ return create_token(GREATER_EQUAL); }
"=="						{ return create_token(EQUAL); }
"!="						{ return create_token(NOT_EQUAL); }

void						{ return create_token(VOID); }
int							{ return create_token(INT); }
float						{ return create_token(FLOAT); }
bool						{ return create_token(BOOL); }
char						{ return create_token(CHAR); }
string						{ return create_token(STRING); }
return						{ return create_token(RETURN); }

[a-zA-Z_][a-zA-Z_0-9]*		{ return create_token_string(IDENTIFIER, strdup(yytext)); }

[0-9]+						{ return create_token_int(INT_LITERAL, atoi(yytext)); }
\"(\\.|[^\\"])*\"			{ return create_token_string(STRING_LITERAL, string_contents(yytext, yyleng)); }
\'(\\.|[^\\'])\'			{ return create_token_char(CHAR_LITERAL, char_value(yytext, yyleng)); }

[[:space:]]+				// Ignore

.							{ fprintf(stderr, "Invalid input: %s\n", yytext); exit(-1); }

%%

char *string_contents(char *literal, size_t len) {
	size_t inner_len = len - 2;
	char *str = malloc(inner_len + 1);
	if(str) {
		strncpy(str, &literal[1], inner_len);
		str[inner_len] = '\0';
	}
	return str;
}

char char_value(char *source, size_t len) {
	if(len == 3) {
		return source[1];
	} else if(len == 4 && source[1] == '\\') {
		return source[2];
	} else {
		fprintf(stderr, "Invalid character literal: %s\n", source);
		exit(-1);
	}
}
