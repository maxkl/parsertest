
# Directory names
src_dir := src
out_dir := out

CC := gcc
CFLAGS := -Wall -Wextra -O2
LDFLAGS :=

LEMON := tools/lemon/lemon

# Targets that don't need dependency files (.d) (e.g. clean)
# This allows us to only include them when they're actually needed
# so we are not building unnecessary stuff
no-dep-targets = clean test

# Helper macros
# Recursively create the directory for the current target
# Usage: $(mkdirp)
mkdirp = @dir=$(dir $@); [ -d "$$dir" ] || mkdir -p "$$dir"

.PHONY: all
all: $(out_dir)/test

.PHONY: clean
clean:
	rm -rf $(out_dir)
	rm -f $(LEMON) $(addprefix $(src_dir)/parser/,lexer.c lexer.h parser.c parser.h parser.out)

.PHONY: test
test:
	bats tests.bats

objs := parser/parser.o parser/lexer.o parser/token.o parser/driver.o main.o
libs :=

# Prepend the output directory to all object file paths
objs := $(addprefix $(out_dir)/,$(objs))

$(LEMON): $(dir $(LEMON))lemon.c
	gcc -Wall -Wextra -O2 -o $@ $^

$(out_dir)/test: $(objs)
	$(mkdirp)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(libs) $(objs)

# Build a .c file to an object
# Also generates a corresponding .d file for faster building
%.o: %.c
$(out_dir)/%.o: $(src_dir)/%.c $(out_dir)/%.d
	$(mkdirp)
	$(CC) -MT $@ -MMD -MP -MF $(out_dir)/$*.Td $(CFLAGS) -o $@ -c $<
	mv -f $(out_dir)/$*.Td $(out_dir)/$*.d

$(src_dir)/%.c $(src_dir)/%.h: $(src_dir)/%.y $(LEMON)
	$(LEMON) $<

$(src_dir)/%.c $(src_dir)/%.h: $(src_dir)/%.l
	flex --header-file=$(src_dir)/$*.h -o $(src_dir)/$*.c $<

$(out_dir)/%.d: ;
# Mark the dependency files as precious, so they won't get deleted when
# make is interrupted (we are using intermediary files (.Td))
.PRECIOUS: $(out_dir)/%.d $(src_dir)/%.c

# Include .d files only if needed
# This is rather complicated as make does not have proper a
# proper logical or function
no-deps :=
# Include if no targets given
ifneq ($(MAKECMDGOALS),)
# Don't include if only no-dep targets are given
ifeq ($(filter-out $(no-dep-targets),$(MAKECMDGOALS)),)
no-deps := 1
endif
endif
# Only include if no-deps is not set
ifeq ($(no-deps),)
# For every .o file include a .d file
-include $(objs:.o,.d)
endif
