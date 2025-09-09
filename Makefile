#
# Tasks to build rulesets, bundle js functions, and generate documentation
# for Italian OpenAPI Guidelines Spectral rules
#
#
.PHONY: all clean rules docs help prepare_dir
.DEFAULT_GOAL := help

RULESET_VERSION ?= 0.1

UID := $(shell id -u)
GID := $(shell id -g)

RULE_FILES := spectral.yml spectral-full.yml spectral-security.yml spectral-generic.yml spectral-modi.yml spectral-new-profile.yml
RULESET_DIR := rulesets
FUNCTIONS_DIR := $(RULESET_DIR)/functions

# Docker base command
DOCKER_BASE := docker run --rm \
	--user $(UID):$(GID) \
	-v "$(CURDIR)":/app \
	-w /app

# Python command with venv
PYTHON_VENV_CMD := sh -c "python -m venv /tmp/venv; source /tmp/venv/bin/activate; pip install -r requirements.txt && python builder.py"

help:
	@echo "Available targets:"
	@echo "  all              - Build all rulesets and documentation"
	@echo "  clean            - Remove generated files"
	@echo "  rules            - Build all ruleset files"
	@echo "  docs             - Generate documentation"
	@echo "  spectral.yml     - Build basic Italian Guidelines ruleset"
	@echo "  spectral-*.yml   - Build specific ruleset variants"

all: clean rules docs

clean:
	@echo "Cleaning generated files..."
	rm -rf $(RULESET_DIR)

rules: prepare_dir spectral.yml spectral-generic.yml spectral-security.yml spectral-full.yml spectral-modi.yml spectral-new-profile.yml

prepare_dir: clean
	@echo "Creating directories..."
	mkdir -p $(RULESET_DIR)
	mkdir -p $(FUNCTIONS_DIR)

spectral.yml: $(wildcard ./rules/*.yml) | prepare_dir
	@echo "Building $@..."
	$(DOCKER_BASE) \
		-e RULES_FOLDERS=rules/ \
		-e RULESET_NAME="Italian Guidelines Full" \
		-e RULESET_VERSION=$(RULESET_VERSION) \
		-e RULESET_FILE_NAME=$(RULESET_DIR)/$@ \
		-e TEMPLATE_FILE=rules/rules-template.yml.template \
		python:3.11-alpine \
		$(PYTHON_VENV_CMD)

spectral-generic.yml: $(wildcard ./rules/*.yml) | prepare_dir
	@echo "Building $@..."
	$(DOCKER_BASE) \
		-e RULES_FOLDERS=rules/ \
		-e RULESET_NAME="Best Practices Only" \
		-e RULESET_VERSION=$(RULESET_VERSION) \
		-e RULESET_FILE_NAME=$(RULESET_DIR)/$@ \
		-e TEMPLATE_FILE=rules/rules-template.yml.template \
		-e CONFIG_FILE=override/spectral-generic-override.yml \
		python:3.11-alpine \
		$(PYTHON_VENV_CMD)

spectral-security.yml: $(wildcard ./rules/*.yml) $(wildcard ./security/*.yml) | prepare_dir
	@echo "Building $@..."
	$(DOCKER_BASE) \
		-e RULES_FOLDERS=security/ \
		-e RULESET_NAME="Extra Security Checks" \
		-e RULESET_VERSION=$(RULESET_VERSION) \
		-e RULESET_FILE_NAME=$(RULESET_DIR)/$@ \
		-e TEMPLATE_FILE=rules/rules-template.yml.template \
		python:3.11-alpine \
		$(PYTHON_VENV_CMD)
	@echo "Copying security functions..."
	cp security/functions/* $(FUNCTIONS_DIR)/

spectral-full.yml: $(wildcard ./rules/*.yml) $(wildcard ./security/*.yml) | prepare_dir
	@echo "Building $@..."
	$(DOCKER_BASE) \
		-e RULES_FOLDERS=rules/,security/ \
		-e RULESET_NAME="Italian Guidelines Full + Extra Security Checks" \
		-e RULESET_VERSION=$(RULESET_VERSION) \
		-e RULESET_FILE_NAME=$(RULESET_DIR)/$@ \
		-e TEMPLATE_FILE=rules/rules-template.yml.template \
		python:3.11-alpine \
		$(PYTHON_VENV_CMD)

spectral-modi.yml: $(wildcard ./rules/*.yml) | prepare_dir
	@echo "Building $@..."
	$(DOCKER_BASE) \
		-e RULES_FOLDERS=rules/ \
		-e RULESET_NAME="Italian Guidelines" \
		-e RULESET_VERSION=$(RULESET_VERSION) \
		-e RULESET_FILE_NAME=$(RULESET_DIR)/$@ \
		-e TEMPLATE_FILE=rules/rules-template.yml.template \
		-e CONFIG_FILE=override/spectral-modi-override.yml \
		python:3.11-alpine \
		$(PYTHON_VENV_CMD)

spectral-new-profile.yml: $(wildcard ./rules/*.yml ./new-rules/*.yml ./security/*) | prepare_dir
	@echo "Building $@..."
	$(DOCKER_BASE) \
		-e RULES_FOLDERS=rules/,security/,new-rules/ \
		-e RULESET_NAME="Italian Guidelines Pro" \
		-e RULESET_VERSION=$(RULESET_VERSION) \
		-e RULESET_FILE_NAME=$(RULESET_DIR)/$@ \
		-e TEMPLATE_FILE=rules/rules-template.yml.template \
		-e CONFIG_FILE=override/spectral-new-profile-override.yml \
		python:3.11-alpine \
		$(PYTHON_VENV_CMD)
	@echo "Copying security functions..."
	cp security/functions/* $(FUNCTIONS_DIR)/

docs: rules
	@echo "Generating documentation..."
	docker run --rm \
		--user $(UID):$(GID) \
		-v "$(CURDIR)":/app \
		-w /app/docs-generator \
		python:3.11-alpine \
		sh -c 'python -m venv /tmp/venv && \
		source /tmp/venv/bin/activate && \
		pip install -r requirements.txt && \
		for file in /app/rulesets/*.yml; do \
			echo "Processing $$file..." && \
			python generator.py --file "$$file" --out "/app/rulesets"; \
		done'