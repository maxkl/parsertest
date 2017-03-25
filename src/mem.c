
#include <stdio.h>

#include "mem.h"

void *xmalloc(size_t size) {
	void *ptr = malloc(size);
	if(ptr == NULL) {
		fprintf(stderr, "Out of memory (malloc)\n");
		fflush(stderr);
		abort();
	}
	return ptr;
}

void *xrealloc(void *ptr, size_t size) {
	ptr = realloc(ptr, size);
	if(ptr == NULL) {
		fprintf(stderr, "Out of memory (realloc)\n");
		fflush(stderr);
		abort();
	}
	return ptr;
}
