
#pragma once

#include <string>

#include "test.y.hpp"

#define YY_DECL yy::test_parser::symbol_type yylex(test_driver &driver)

YY_DECL;

class test_driver {
public:
	test_driver();
	virtual ~test_driver();

	void scan_begin();
	void scan_end();
	bool trace_scanning;

	int parse(const std::string &);
	std::string filename;
	bool trace_parsing;

	void error(const yy::location &, const std::string &);
	void error(const std::string &);
};
