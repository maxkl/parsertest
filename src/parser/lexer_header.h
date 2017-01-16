
#pragma once

#include "token.h"

typedef void *yyscan_t;

#define YY_DECL token_t yylex(yyscan_t yyscanner)
#define yyterminate() return NULL

YY_DECL;
