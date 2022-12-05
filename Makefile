# Add environment variables
ifeq ($(shell test -e '.env' && echo -n yes), yes)
    include .env
endif

# docker-compose or docker compose
ifneq (, $(shell which docker-compose))
DC = docker-compose
else
DC = docker compose
endif

# Manual definition
ifndef APP_PORT
override APP_PORT = 8000
endif

ifndef APP_HOST
override APP_HOST = 127.0.0.1
endif

# Contrants
SRC_FOLDER = service
TEST = poetry run python -m pytest --verbosity=2 --showlocals --log-level=DEBUG
CODE = $(SRC_FOLDER) tests

THIS_FILE := $(lastword $(MAKEFILE_LIST))
.PHONY: env help build up start down destroy stop restart logs logs-api ps login-timescale login-api db-shell

# YA-inspired
env:  ## Create .env template
	@$(eval SHELL:=/bin/bash)
	@cp .env.example .env

lint:  ##@Code Check code with pylint
	poetry run python3 -m pylint $(CODE)

format:  ## Reformat with isort and black
	poetry run python3 -m isort $(CODE)
	poetry run python3 -m black $(CODE)

migrate:  ## Do migrations in db
	cd $(APPLICATION_NAME)/db && alembic upgrade $(args)

test:  ## Test application with pytest
	make db && $(TEST)

test-cov:  ## Test with coverate
	make db && $(TEST) --cov=$(APPLICATION_NAME) --cov-report html --cov-fail-under=70

clean:  ## Clean directory from garbage files
	rm -fr *.egg-info dist


# RUVDS-inspired 
help:
	@make -pRrq  -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
build:
	$(DC) -f docker-compose.yml build $(c)
up:
	$(DC) -f docker-compose.yml up -d $(c)
start:
	$(DC) -f docker-compose.yml start $(c)
down:
	$(DC) -f docker-compose.yml down $(c)
destroy:
	$(DC) -f docker-compose.yml down -v $(c)
stop:
	$(DC) -f docker-compose.yml stop $(c)
restart:
	$(DC) -f docker-compose.yml stop $(c)
	$(DC) -f docker-compose.yml up -d $(c)
logs:
	$(DC) -f docker-compose.yml logs --tail=100 -f $(c)
logs-api:
	$(DC) -f docker-compose.yml logs --tail=100 -f api
ps:
	$(DC) -f docker-compose.yml ps
login-timescale:
	$(DC) -f docker-compose.yml exec timescale /bin/bash
login-api:
	$(DC) -f docker-compose.yml exec api /bin/bash
db-shell:
	$(DC) -f docker-compose.yml exec timescale psql -Upostgres