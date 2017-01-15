%{
	#include <stdio.h>
	#include <stdlib.h>

	#include "test-driver.hpp"
	#include "test.y.hpp"

	using yy::test_parser;

	static yy::location loc;
%}

%option warn debug
%option nodefault noyywrap batch
%option noinput nounput

%x COMMENT

%{
	#define YY_USER_ACTION loc.columns(yyleng);
%}

%%

%{
	loc.step();
%}

"/*"						{ BEGIN(COMMENT); }
<COMMENT>"*/"				{ BEGIN(INITIAL); }
<COMMENT>\n
<COMMENT>.
"//".*

"<<"						{ return test_parser::make_SHIFT_LEFT(loc); }
">>"						{ return test_parser::make_SHIFT_RIGHT(loc); }
"&&"						{ return test_parser::make_AND(loc); }
"||"						{ return test_parser::make_OR(loc); }
"<="						{ return test_parser::make_LESS_OR_EQUAL(loc); }
">="						{ return test_parser::make_GREATER_OR_EQUAL(loc); }
"=="						{ return test_parser::make_EQUAL(loc); }
"!="						{ return test_parser::make_NOT_EQUAL(loc); }
"+="						{ return test_parser::make_PLUS_EQUAL(loc); }
"-="						{ return test_parser::make_MINUS_EQUAL(loc); }
"*="						{ return test_parser::make_MULTIPLY_EQUAL(loc); }
"/="						{ return test_parser::make_DIVIDE_EQUAL(loc); }
"%="						{ return test_parser::make_MODULO_EQUAL(loc); }
"&="						{ return test_parser::make_BIT_AND_EQUAL(loc); }
"^="						{ return test_parser::make_BIT_XOR_EQUAL(loc); }
"|="						{ return test_parser::make_BIT_OR_EQUAL(loc); }
"<<="						{ return test_parser::make_SHIFT_LEFT_EQUAL(loc); }
">>="						{ return test_parser::make_SHIFT_RIGHT_EQUAL(loc); }
"!"							{ return test_parser::make_NOT(loc); }
"-"							{ return test_parser::make_MINUS(loc); }
"+"							{ return test_parser::make_PLUS(loc); }
"*"							{ return test_parser::make_MULTIPLY(loc); }
"/"							{ return test_parser::make_DIVIDE(loc); }
"%"							{ return test_parser::make_MODULO(loc); }
"&"							{ return test_parser::make_BIT_AND(loc); }
"^"							{ return test_parser::make_BIT_XOR(loc); }
"|"							{ return test_parser::make_BIT_OR(loc); }
"<"							{ return test_parser::make_LESS(loc); }
">"							{ return test_parser::make_GREATER(loc); }
"="							{ return test_parser::make_ASSIGN(loc); }
";"							{ return test_parser::make_SEMICOLON(loc); }
","							{ return test_parser::make_COMMA(loc); }
"("							{ return test_parser::make_PARENTHESIS_OPEN(loc); }
")"							{ return test_parser::make_PARENTHESIS_CLOSE(loc); }
"{"							{ return test_parser::make_BRACE_OPEN(loc); }
"}"							{ return test_parser::make_BRACE_CLOSE(loc); }
"["							{ return test_parser::make_BRACKET_OPEN(loc); }
"]"							{ return test_parser::make_BRACKET_CLOSE(loc); }

void						{ return test_parser::make_VOID(loc); }
int							{ return test_parser::make_INT(loc); }
float						{ return test_parser::make_FLOAT(loc); }
bool						{ return test_parser::make_BOOL(loc); }
char						{ return test_parser::make_CHAR(loc); }
string						{ return test_parser::make_STRING(loc); }
return						{ return test_parser::make_RETURN(loc); }

[a-zA-Z_][a-zA-Z_0-9]*		{ return test_parser::make_IDENTIFIER(yytext, loc); }

[0-9]+						{ return test_parser::make_INT_LITERAL(atoi(yytext), loc); }
\"(\\.|[^\\"])*\"			{ return test_parser::make_STRING_LITERAL(yytext, loc); }
\'(\\.|[^\\'])\'			{ return test_parser::make_CHAR_LITERAL(yytext[0], loc); }

[\n]+						{ loc.lines(yyleng); loc.step(); }
[[:space:]]+				{ loc.step(); }

<<EOF>>						{ return test_parser::make_END(loc); }

.							{ fprintf(stderr, "Invalid input: %s\n", yytext); exit(-1); }

%%

void test_driver::scan_begin() {
	yy_flex_debug = trace_scanning;
	if(filename.empty()) {
		yyin = stdin;
	} else {
		FILE *f = fopen(filename.c_str(), "r");
		if(!f) {
			perror("Unable to open source file");
			exit(-1);
		}

		yyin = f;
	}
}

void test_driver::scan_end() {
	if(yyin != stdin) {
		fclose(yyin);
	}
}
