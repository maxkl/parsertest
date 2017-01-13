%{
	#include <stdio.h>
	#include <stdlib.h>

	#include "test.y.h"

	char *string_contents(char *, size_t);
	char char_value(char *, size_t);
%}

%option noinput
%option nounput

%x COMMENT

%%

"/*"						{ BEGIN(COMMENT); }
<COMMENT>"*/"				{ BEGIN(INITIAL); }
<COMMENT>\n
<COMMENT>.
"//".*

"<<"						{ return SHIFT_LEFT; }
">>"						{ return SHIFT_RIGHT; }
"&&"						{ return AND; }
"||"						{ return OR; }
"<="						{ return LESS_OR_EQUAL; }
">="						{ return GREATER_OR_EQUAL; }
"=="						{ return EQUAL; }
"!="						{ return NOT_EQUAL; }
"+="						{ return PLUS_EQUAL; }
"-="						{ return MINUS_EQUAL; }
"*="						{ return MULTIPLY_EQUAL; }
"/="						{ return DIVIDE_EQUAL; }
"%="						{ return MODULO_EQUAL; }
"&="						{ return BIT_AND_EQUAL; }
"^="						{ return BIT_XOR_EQUAL; }
"|="						{ return BIT_OR_EQUAL; }
"<<="						{ return SHIFT_LEFT_EQUAL; }
">>="						{ return SHIFT_RIGHT_EQUAL; }
[!\-+*/%&^|<>=;,(){}\[\]]	{ return yytext[0]; }

void						{ return VOID; }
int							{ return INT; }
float						{ return FLOAT; }
bool						{ return BOOL; }
char						{ return CHAR; }
array						{ return ARRAY; }
string						{ return STRING; }
return						{ return RETURN; }

[a-zA-Z_][a-zA-Z_0-9]*		{ yylval.sval = strdup(yytext); return IDENTIFIER; }

[0-9]+						{ yylval.ival = atoi(yytext); return INT_LITERAL; }
\"(\\.|[^\\"])*\"			{ yylval.sval = string_contents(yytext, yyleng); return STRING_LITERAL; }
\'(\\.|[^\\'])\'			{ yylval.cval = char_value(yytext, yyleng); return CHAR_LITERAL; }

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
