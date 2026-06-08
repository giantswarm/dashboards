##@ Dashboards

.PHONY: install-tools lint-dashboards sync-kafka-dashboards update-alloy-mixin update-kubernetes-mixin update-memcached-mixin update-mimir-mixin update-tempo-mixin update-mixin-versions

SHELL:=/bin/bash -O globstar

dashboards = helm/dashboards/dashboards/**/*.json helm/dashboards/charts/**/*.json

install-tools: ## Install dependencies tools
	./scripts/install-tools.sh

update-alloy-mixin: install-tools ## Update Alloy mixin dashboards
	./mixins/alloy/update.sh

update-kubernetes-mixin: ## Update Kubernetes mixin dashboards
	./scripts/sync-kube-mixin.sh

update-mimir-mixin: install-tools ## Update Mimir mixin dashboards
	./mixins/mimir/update.sh

update-loki-mixin: install-tools ## Update Loki mixin dashboards
	./mixins/loki/update.sh

update-tempo-mixin: install-tools ## Update Tempo mixin dashboards
	./mixins/tempo/update.sh

update-memcached-mixin: install-tools ## Update Memcached mixin dashboards
	./mixins/memcached/update.sh

sync-kafka-dashboards: ## Sync Strimzi/Kafka dashboards from the giantswarm strimzi-kafka-operator fork
	./scripts/sync-kafka-dashboards.sh

update-mixin-versions: ## Fetch app versions from giantswarm/*-app repos and update version pins in update scripts
	./scripts/update-mixin-versions.sh

update-mixin: update-mixin-versions update-alloy-mixin update-kubernetes-mixin update-memcached-mixin update-mimir-mixin update-loki-mixin update-tempo-mixin ## Update all mixins dashboards (fetches latest app versions first)

lint-dashboards: install-tools ## Run dashboard-linter for all dashboards in the helm/dashboards directory
		./scripts/lint-dashboards.sh
