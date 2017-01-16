
#include <stdio.h>
#include <stdbool.h>

#include "parser/driver.h"

int main(int argc, char **argv) {
	int ret;
	bool trace = true;
	if(argc > 1) {
		ret = parser_parse_file(argv[1], trace);
	} else {
		ret = parser_parse_stream(stdin, trace);
	}
	return ret;
}
