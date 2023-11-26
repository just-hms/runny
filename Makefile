# Define your compiler and flags
CC := gcc
CFLAGS :=

# Define build directory
BUILD_DIR := build

# List your source files
SRC := $(shell find pkg -name '*.c' ! -name '*_test.c')
MAIN_SRC := cmd/main.c
TEST_SRC := /tmp/test.c

# Define corresponding object files in the build directory
OBJ := $(SRC:%.c=$(BUILD_DIR)/%.o)
MAIN_OBJ := $(MAIN_SRC:%.c=$(BUILD_DIR)/%.o)
TEST_OBJ := $(TEST_SRC:%.c=$(BUILD_DIR)/%.o)

# Default target
all: test build run

# Test target
test: $(BUILD_DIR)/test
	@$(BUILD_DIR)/test

# Rule to generate test.c and compile it into an object file
$(BUILD_DIR)/test: $(OBJ) $(TEST_OBJ)
	@$(CC) $(CFLAGS) -o $@ $^

$(TEST_OBJ): $(TEST_SRC)
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

# Rule to run test.sh and generate test.c
$(TEST_SRC):
	@./test.sh > $(TEST_SRC)

# Build target
build: $(BUILD_DIR)/main

$(BUILD_DIR)/main: $(OBJ) $(MAIN_OBJ)
	@$(CC) $(CFLAGS) -o $@ $^

# Run target
run: $(BUILD_DIR)/main
	@$(BUILD_DIR)/main

# General rule for object files
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

# Clean target to remove generated files
clean:
	@rm -rf $(BUILD_DIR) $(TEST_SRC)

.PHONY: all test build run clean
