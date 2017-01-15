
src_dir := src
out_dir := out

CC := gcc
CFLAGS := -Wall -Wextra -O2
LDFLAGS := -lstdc++

mkdirp = @dir=$(dir $@); [ -d "$$dir" ] || mkdir -p "$$dir"

.PHONY: all
all: $(out_dir)/test

.PHONY: clean
clean:
	rm -rf $(out_dir)

.PHONY: test
test:
	@bats tests.bats

$(out_dir)/test: $(src_dir)/main.cpp $(src_dir)/test-driver.cpp $(src_dir)/test.y.cpp $(src_dir)/test.l.cpp
	$(mkdirp)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(src_dir)/test.y.cpp: $(src_dir)/test.y
	$(mkdirp)
	bison --defines=$(@:.cpp=.hpp) -o $@ $<

$(src_dir)/test.l.cpp: $(src_dir)/test.l
	$(mkdirp)
	flex --header-file=$(@:.cpp=.hpp) -o $@ $<
