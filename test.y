/* Reverse polish notation calculator */

%{
	#include <stdio.h>
	#include <math.h>
	int yylex();
	void yyerror(char const *);
%}

%glr-parser
%define parse.error verbose
%define api.value.type {double}
%token NUM
%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'

%% /* Grammer rules and actions follow */

input:
	%empty
|	input line
;

line:
	'\n'
|	exp '\n'			{ printf("\t%.10g\n", $1);	}
|	error '\n'			{ yyerrok;					}
;

exp:
	NUM					{ $$ = $1;					}
|	exp '+' exp			{ $$ = $1 + $3;				}
|	exp '-' exp			{ $$ = $1 - $3;				}
|	exp '*' exp			{ $$ = $1 * $3;				}
|	exp '/' exp			{ $$ = $1 / $3;				}
|	'-' exp %prec NEG	{ $$ = -$2;					}
|	exp '^' exp			{ $$ = pow($1, $3);			}
|	'(' exp ')'			{ $$ = $2;					}
;

%%

#include <ctype.h>

int yylex() {
	int c;

	/* Skip white space.  */
	while ((c = getchar ()) == ' ' || c == '\t')
		;

	/* Process numbers.  */
	if(c == '.' || isdigit (c)) {
		ungetc(c, stdin);
		scanf("%lf", &yylval);
		return NUM;
	}

	/* Return end-of-input.  */
	if(c == EOF)
		return 0;

	/* Return a single char.  */
	return c;
}

int main() {
	return yyparse();
}

#include <stdio.h>

/* Called by yyparse on error.  */
void yyerror (char const *s) {
	fprintf(stderr, "%s\n", s);
}
