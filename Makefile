#
# Tasks set to build ruleset, bundle js, test and deploy
#
#

UID=$(shell id -u)
GID=$(shell id -g)

RULE_FILES := spectral.yml spectral-full.yml spectral-security.yml spectral-generic.yml spectral-modi.yml
RULESET_DIR := rulesets
FUNCTIONS_DIR:= $(RULESET_DIR)/functions

all: clean rules

clean:
	rm -rf $(RULESET_DIR)
	rm -rf $(FUNCTIONS_DIR)

rules: prepare_dir spectral.yml spectral-generic.yml spectral-security.yml spectral-full.yml spectral-modi.yml

prepare_dir: clean
	mkdir -p $(RULESET_DIR)
	mkdir -p $(FUNCTIONS_DIR)

spectral.yml: $(wildcard ./rules/*.yml)
	docker run --rm\
		--user  ${UID}:${GID} \
		-v "$(CURDIR)":/app\
		-w /app\
		-e RULES_FOLDERS=rules/\
		-e RULESET_NAME=$(RULESET_DIR)/$@\
		-e TEMPLATE_FILE=rules/rules-template.yml.template\
		python:3.11-alpine\
		sh -c "python -m venv /tmp/venv; source /tmp/venv/bin/activate; pip install -r requirements.txt && python builder.py"

spectral-generic.yml: $(wildcard ./rules/*.yml)
	docker run --rm\
		--user  ${UID}:${GID} \
		-v "$(CURDIR)":/app\
		-w /app\
		-e RULES_FOLDERS=rules/\
		-e RULESET_NAME=$(RULESET_DIR)/$@\
		-e TEMPLATE_FILE=rules/rules-template.yml.template\
		-e CONFIG_FILE=override/spectral-generic-override.yml\
		python:3.11-alpine\
		sh -c "python -m venv /tmp/venv; source /tmp/venv/bin/activate; pip install -r requirements.txt && python builder.py"

spectral-security.yml: $(wildcard ./rules/*.yml) $(wildcard ./security/*.yml)
	docker run --rm\
		--user  ${UID}:${GID} \
		-v "$(CURDIR)":/app\
		-w /app\
		-e RULES_FOLDERS=security/\
		-e RULESET_NAME=$(RULESET_DIR)/$@\
		-e TEMPLATE_FILE=rules/rules-template.yml.template\
		python:3.11-alpine\
		sh -c "python -m venv /tmp/venv; source /tmp/venv/bin/activate; pip install -r requirements.txt && python builder.py"
	cp security/functions/* $(FUNCTIONS_DIR)/

spectral-full.yml: spectral.yml spectral-security.yml
	docker run --rm\
		--user ${UID}:${GID} \
		-v "$(CURDIR)":/app\
		-w /app\
		-e RULES_FOLDERS=rules/,security/\
		-e RULESET_NAME=$(RULESET_DIR)/$@\
		-e TEMPLATE_FILE=rules/rules-template.yml.template\
		python:3.11-alpine\
		sh -c "python -m venv /tmp/venv; source /tmp/venv/bin/activate; pip install -r requirements.txt && python builder.py"

spectral-modi.yml: $(wildcard ./rules/*.yml)
	docker run --rm\
		--user ${UID}:${GID} \
		-v "$(CURDIR)":/app\
		-w /app\
		-e RULES_FOLDERS=rules/\
		-e RULESET_NAME=$(RULESET_DIR)/$@\
		-e TEMPLATE_FILE=rules/rules-template.yml.template\
		-e CONFIG_FILE=override/spectral-modi-override.yml\
		python:3.11-alpine\
		sh -c "python -m venv /tmp/venv; source /tmp/venv/bin/activate; pip install -r requirements.txt && python builder.py"
