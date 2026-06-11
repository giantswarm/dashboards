.PHONY: install-tools lint-dashboards check-dashboard-schema update-all-dashboards update-alloy-mixin update-kafka-dashboardsn update-kubernetes-mixin update-loki-mixi update-memcached-mixin update-mimir-mixin update-tempo-mixin update-mixin-versions

SHELL:=/bin/bash -O globstar

dashboards = helm/dashboards/dashboards/**/*.json helm/dashboards/charts/**/*.json

##@ Tools

install-tools: ## Install dependencies tools
	./scripts/install-tools.sh

##@ Dashboards update

update-all-dashboards: update-mixin update-kafka-dashboards ## Update all dashboards (mixins and Kafka)

update-all-mixin: update-mixin-versions update-alloy-mixin update-kubernetes-mixin update-loki-mixin update-memcached-mixin update-mimir-mixin update-tempo-mixin ## Update all mixins dashboards (fetches latest app versions first)

update-alloy-mixin: install-tools ## Update Alloy mixin dashboards
	./mixins/alloy/update.sh

update-kafka-dashboards: ## Update Strimzi/Kafka dashboards from the giantswarm strimzi-kafka-operator fork
	./scripts/update-kafka-dashboards.sh

update-kubernetes-mixin: ## Update Kubernetes mixin dashboards
	./scripts/update-kube-mixin.sh

update-loki-mixin: install-tools ## Update Loki mixin dashboards
	./mixins/loki/update.sh

update-memcached-mixin: install-tools ## Update Memcached mixin dashboards
	./mixins/memcached/update.sh

update-mimir-mixin: install-tools ## Update Mimir mixin dashboards
	./mixins/mimir/update.sh

update-tempo-mixin: install-tools ## Update Tempo mixin dashboards
	./mixins/tempo/update.sh

update-mixin-versions: ## Fetch app versions from giantswarm/*-app repos and update version pins in update scripts
	./scripts/update-mixin-versions.sh

lint-dashboards: install-tools ## Run dashboard-linter for all dashboards in the helm/dashboards directory
		./scripts/lint-dashboards.sh

check-dashboard-schema: ## Fail if any dashboard is neither v1 nor v2 (rejects the unwrapped "JSON model")
		./scripts/check-dashboard-schema.sh
