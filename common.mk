BUILD_ROOT = ../build
BIN_ROOT = $(BUILD_ROOT)/$(BIN)
BUILD_DIR = $(BIN_ROOT)/$(TARGET)
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
DEPFLAGS = -MMD -MP
CC = gcc
LD = ld
LDFLAGS =

ifeq ($(WERROR), 1)
CWARNINGS := $(CWARNINGS) -Werror
endif

ifeq ($(MAKECMDGOALS),)
TARGET=debug
else
TARGET=$(MAKECMDGOALS)
endif

hardened: CFLAGS = -O2 -g -D_FORTIFY_SOURCE=3  -fstack-protector-strong \
	-fstack-clash-protection -fcf-protection=full \
	-Wl,-z,relro,-z,now -Wl,-z,noexecstack

analyze: CFLAGS = -O2 -fanalyzer

.PHONY: debug hardened analyze clean spotless

#$(info BIN  = [$(BIN)])
#$(info SRCS = [$(SRCS)])
#$(info OBJS = [$(OBJS)])

debug: $(BIN_TARGET)

hardened: $(BIN_TARGET)

analyze: $(BIN_TARGET)

clean:
	rm -rf --one-file-system --preserve-root $(BIN_ROOT)

spotless:
	rm -rf --one-file-system --preserve-root $(BUILD_ROOT)


$(BIN_TARGET): $(OBJS)
	$(CC) $(LANG_STD) $(CFLAGS) $(CWARNINGS) $(OBJS) -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(LANG_STD) $(CFLAGS) $(DEPFLAGS) $(CWARNINGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@
