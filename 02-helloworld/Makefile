# Assembly program Makefile
ASM = nasm
ASMFLAGS = -f elf64
LINKER = ld
TARGET = main
BINARY = helloworld
SRCDIR = src
OBJDIR = obj
BINDIR = bin

# Source and object files
SRCFILE = $(SRCDIR)/$(TARGET).asm
OBJFILE = $(OBJDIR)/$(TARGET).o
BINFILE = $(BINDIR)/$(BINARY)

# Default target
all: $(BINFILE)

# Create directories if they don't exist
$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

# Compile assembly source to object file
$(OBJFILE): $(SRCFILE) | $(OBJDIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Link object file to create executable
$(BINFILE): $(OBJFILE) | $(BINDIR)
	$(LINKER) $< -o $@

# Run the program
run: $(BINFILE)
	./$(BINFILE)

# Clean up generated files
clean:
	rm -rf $(OBJDIR) $(BINDIR)

# Debug version with symbols
debug: ASMFLAGS += -g -F dwarf
debug: $(BINFILE)

# Phony targets
.PHONY: all run clean debug