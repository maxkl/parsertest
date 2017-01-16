
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <getopt.h>

#include "parser/driver.h"

static const char *short_options = "ht";
static const struct option long_options[] = {
	{ "help",	no_argument,		NULL,	'h'	},
	{ "trace",	no_argument,		NULL,	't'	},
	{ NULL,		0,					NULL,	0	}
};

void print_help(const char *filename)  {
	printf("Usage: %s [options] <file>\n", filename);
	printf("\n");
	printf("Do something.\n");
	printf("\n");
	printf("Options:\n");
	printf("  -t, --trace               print parser debugging output\n");
	printf("  -h, --help                print this help and exit\n");
	printf("\n");
}

int main(int argc, char **argv) {
	bool help = false;
	char *filename;
	bool trace = false;

	int c;
	while((c = getopt_long(argc, argv, short_options, long_options, NULL)) != -1) {
		switch(c) {
			case 'h':
				help = true;
			case 't':
				trace = true;
				break;
			case '?':
				fprintf(stderr, "Try `%s -h` for more information.\n", argv[0]);
				return 1;
			default:
				abort();
		}
	}

	if(help) {
		print_help(argv[0]);
		return 0;
	}

	int remaining = argc - optind;
	if(remaining == 0) {
		fprintf(stderr, "Error: No input file.\n");
		fprintf(stderr, "Try `%s -h` for more information.\n", argv[0]);
		return 1;
	} else if(remaining > 1) {
		fprintf(stderr, "Error: Too many input files.\n");
		fprintf(stderr, "Try `%s -h` for more information.\n", argv[0]);
		return 1;
	}

	filename = argv[optind];

	int ret;
	if(strcmp(filename, "-") == 0) {
		ret = parser_parse_stream(stdin, trace);
	} else {
		ret = parser_parse_file(filename, trace);
	}
	return ret;
}
