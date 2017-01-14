
src_dir := src
out_dir := out

CC := gcc
CFLAGS := -Wall -Wextra -O2
LDFLAGS := -lfl

mkdirp = @dir=$(dir $@); [ -d "$$dir" ] || mkdir -p "$$dir"

.PHONY: all
all: $(out_dir)/test

.PHONY: clean
clean:
	rm -rf $(out_dir)

.PHONY: test
test:
	@bats tests.bats

$(out_dir)/test: $(out_dir)/test.y.c $(out_dir)/test.l.c
	$(mkdirp)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(out_dir)/test.y.c: $(src_dir)/test.y
	$(mkdirp)
	bison --defines=$(@:.c=.h) -o $@ $<

$(out_dir)/test.l.c: $(src_dir)/test.l
	$(mkdirp)
	flex --header-file=$(@:.c=.h) -o $@ $<
