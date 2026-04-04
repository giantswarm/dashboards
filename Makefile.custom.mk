##@ Dashboards

.PHONY: install-tools lint-dashboards update-alloy-mixin update-kubernetes-mixin update-memcached-mixin update-mimir-mixin update-tempo-mixin

SHELL:=/bin/bash -O globstar

dashboards = helm/dashboards/dashboards/**/*.json helm/dashboards/charts/**/*.json

# Install dependencies tools
install-tools:
	./scripts/install-tools.sh

# Update Alloy mixin dashboards
update-alloy-mixin: install-tools
	./mixins/alloy/update.sh

# Update Kubernetes mixin dashboards
update-kubernetes-mixin:
	./scripts/sync-kube-mixin.sh

# Update Memcached mixin dashboards
update-memcached-mixin: install-tools
	./memcached/update.sh

# Update Mimir mixin dashboards
update-mimir-mixin: install-tools
	./mixins/mimir/update.sh

# Update Loki mixin dashboards
update-loki-mixin: install-tools
	./mixins/loki/update.sh

# Update Tempo mixin dashboards
update-tempo-mixin: install-tools
	./mixins/tempo/update.sh

# Update Memcached mixin dashboards
update-memcached-mixin: install-tools
	./mixins/memcached/update.sh

# Update all mixins dashboards
update-mixin: update-alloy-mixin update-kubernetes-mixin update-memcached-mixin update-mimir-mixin update-loki-mixin update-tempo-mixin

# Run dashboard-linter for all dashboards in the helm/dashboards directory
lint-dashboards: install-tools
		@for file in $(dashboards); do \
			echo "------ Linting $$file"; \
			dashboard-linter lint -c scripts/lint-config.yaml $$file; \
		done
		@echo "------ Linted $(shell echo $(dashboards) | wc -w) dashboards"
