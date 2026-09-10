BUILD_DIR = ../build/$(BIN)
BIN_TARGET = $(BUILD_DIR)/$(BIN)
SRC_DIR = .
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

hardened: CFLAGS = -O2 -g -D_FORTIFY_SOURCE=3  -fstack-protector-strong \
	-fstack-clash-protection -fcf-protection=full \
	-Wl,-z,relro,-z,now -Wl,-z,noexecstack

analyze: CFLAGS = -O2 -fanalyzer

.PHONY: debug hardened analyze clean

$(info BIN  = [$(BIN)])
$(info SRCS = [$(SRCS)])
$(info OBJS = [$(OBJS)])

debug: $(BIN_TARGET)

hardened: $(BIN_TARGET)

analyze: | $(BIN_TARGET)
	clang-tidy $(SRCS)

test:
clean:
	rm -rf ../build/$(BIN)

$(BIN_TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(CWARNINGS) $(OBJS) -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(CWARNINGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@
