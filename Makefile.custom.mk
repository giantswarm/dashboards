##@ Dashboards

.PHONY: install-tools lint-dashboards update-alloy-mixin update-kubernetes-mixin update-mimir-mixin update-tempo-mixin

SHELL:=/bin/bash -O globstar

dashboards = helm/dashboards/dashboards/**/*.json helm/dashboards/charts/**/*.json

# Install dependencies tools
install-tools:
	./scripts/install-tools.sh

# Update Alloy mixin dashboards
update-alloy-mixin: install-tools
	./alloy/update.sh

# Update Kubernetes mixin dashboards
update-kubernetes-mixin:
	./scripts/sync-kube-mixin.sh

# Update Mimir mixin dashboards
update-mimir-mixin: install-tools
	./mimir/update.sh

# Update Loki mixin dashboards
update-loki-mixin: install-tools
	./loki/update.sh

# Update Tempo mixin dashboards
update-tempo-mixin: install-tools
	./tempo/update.sh

# Update all mixins dashboards
update-mixin: update-alloy-mixin update-kubernetes-mixin update-mimir-mixin update-loki-mixin update-tempo-mixin

# Run dashboard-linter for all dashboards in the helm/dashboards directory
lint-dashboards: install-tools
		@for file in $(dashboards); do \
			echo "------ Linting $$file"; \
			dashboard-linter lint -c linter/config.yaml $$file; \
		done
		@echo "------ Linted $(shell echo $(dashboards) | wc -w) dashboards"
