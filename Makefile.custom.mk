##@ Dashboards

.PHONY: install-tools lint-dashboards update-alertmanager-mixin update-alloy-mixin update-kubernetes-mixin update-mimir-mixin

SHELL:=/bin/bash -O globstar

dashboards = helm/dashboards/dashboards/**/*.json helm/dashboards/charts/**/*.json

install-tools: ## Install dependencies tools
	./scripts/install-tools.sh

update-alertmanager-mixin: ## Update Alertmanager mixin dashboards
	./scripts/update-monitoring-mixin-dashboards.sh

update-alloy-mixin: install-tools ## Update Alloy mixin dashboards
	./scripts/update-alloy-mixin.sh

update-kubernetes-mixin: ## Update Kubernetes mixin dashboards
	./scripts/sync-kube-mixin.sh

update-mimir-mixin: install-tools ## Update Mimir mixin dashboards
	./mimir/update.sh

update-mixin: update-alertmanager-mixin update-alloy-mixin update-kubernetes-mixin update-mimir-mixin ## Update all mixins dashboards

lint-dashboards: install-tools ## Run dashboard-linter for all dashboards in the helm/dashboards directory
		@for file in $(dashboards); do \
			echo "------ Linting $$file"; \
			dashboard-linter lint -c linter/config.yaml $$file; \
		done
		@echo "------ Linted $(shell echo $(dashboards) | wc -w) dashboards"
