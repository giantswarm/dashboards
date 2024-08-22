##@ Dashboards

.PHONY: install-tools update-mimir-mixin update-alloy-mixin lint-dashboards

SHELL:=/bin/bash -O globstar

dashboards = helm/dashboards/dashboards/**/*.json helm/dashboards/charts/**/*.json

install-tools: ## Install dependencies tools
	./scripts/install-tools.sh

update-mimir-mixin: install-tools ## Update Mimir mixin dashboards
	./mimir/update.sh

update-alloy-mixin: install-tools ## Update Alloy mixin dashboards
	./scripts/update-alloy-mixin.sh

update-mixin: update-mimir-mixin update-alloy-mixin ## Update all mixins dashboards

lint-dashboards: install-tools ## Run dashboard-linter for all dashboards in the helm/dashboards directory
		@for file in $(dashboards); do \
			echo "------ Linting $$file"; \
			dashboard-linter lint -c linter/config.yaml $$file; \
		done
		@echo "------ Linted $(shell echo $(dashboards) | wc -w) dashboards"
