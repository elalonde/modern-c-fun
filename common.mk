BUILD_DIR = build
BIN_TARGET = $(BUILD_DIR)/$(BIN)
SRC_DIR = src
SRCS = $(SRC_DIR)/$(BIN).c
OBJS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRCS))
LANG_STD := -std=c99 -pedantic
CWARNINGS = -Wall -Wextra -Wshadow -Wconversion -Wsign-conversion \
	    -Wstrict-prototypes -Wmissing-prototypes -Wvla -Wcast-align \
	    -Wformat=2 -Wnull-dereference -Wundef
CFLAGS = -O0 -g3 -fno-omit-frame-pointer -fsanitize=address,undefined \
	 -fno-sanitize-recover=all
CC = gcc
LD = ld
LDFLAGS =

ifeq ($(WERROR), 1)
CWARNINGS := $(CWARNINGS) -Werror
endif

.PHONY: debug hardened analyze clean

$(info BIN  = [$(BIN)])
$(info SRCS = [$(SRCS)])
$(info OBJS = [$(OBJS)])
debug: $(BIN_TARGET)

hardened:

analyze:

test:
clean:
	rm -rf build

$(BIN_TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(CWARNINGS) $(OBJS) -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(CWARNINGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@
