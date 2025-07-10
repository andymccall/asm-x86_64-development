# Top-level Makefile for all assembly projects

# Automatically find all project directories that contain a Makefile
PROJECTS := $(patsubst %/Makefile,%,$(wildcard */Makefile))

# Default target - build all projects
all: $(PROJECTS)

# Build individual projects
$(PROJECTS):
	@echo "Building $@..."
	@$(MAKE) -C $@

# Clean all projects
clean:
	@echo "Cleaning all projects..."
	@for project in $(PROJECTS); do \
		echo "Cleaning $$project..."; \
		$(MAKE) -C $$project clean; \
	done

# Clean individual projects
clean-%:
	@echo "Cleaning $*..."
	@$(MAKE) -C $* clean

# Run all projects
run: $(PROJECTS)
	@echo "Running all projects..."
	@for project in $(PROJECTS); do \
		echo "Running $$project..."; \
		$(MAKE) -C $$project run; \
		echo ""; \
	done

# Run individual projects
run-%:
	@echo "Running $*..."
	@$(MAKE) -C $* run

# Debug build for all projects
debug:
	@echo "Building all projects in debug mode..."
	@for project in $(PROJECTS); do \
		echo "Debug building $$project..."; \
		$(MAKE) -C $$project debug; \
	done

# Debug build for individual projects
debug-%:
	@echo "Debug building $*..."
	@$(MAKE) -C $* debug

# List all discovered projects
list:
	@echo "Discovered projects: $(PROJECTS)"

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Build all projects"
	@echo "  clean        - Clean all projects"
	@echo "  run          - Run all projects"
	@echo "  debug        - Debug build all projects"
	@echo "  list         - List all discovered projects"
	@echo "  <project>    - Build specific project (e.g., make 01-hellochar)"
	@echo "  clean-<project> - Clean specific project (e.g., make clean-01-hellochar)"
	@echo "  run-<project>   - Run specific project (e.g., make run-01-hellochar)"
	@echo "  debug-<project> - Debug build specific project (e.g., make debug-01-hellochar)"
	@echo ""
	@echo "Discovered projects: $(PROJECTS)"

# Phony targets
.PHONY: all clean run debug help list $(PROJECTS)