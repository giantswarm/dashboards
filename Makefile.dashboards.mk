GRR := go run github.com/grafana/grizzly/cmd/grr
JB := go run github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
JSONNET := go run github.com/google/go-jsonnet/cmd/jsonnet
YQ := go run github.com/mikefarah/yq/v4

OUTDIR := output

# Make Go ignore the `vendor/` dir as it is a jsonnet-bundler dir
export GOFLAGS = -mod=mod

# Grafana Cloud
GCSRCDIR := dashboards
GCOUTDIR := $(OUTDIR)/gc/dashboards
GCDASHBOARDS := $(addprefix $(GCOUTDIR)/, grafana-analytics.yaml)
GCPREVIEW_EXPIRE ?= 600

.PHONY: clean deps gc-apply gc-diff gc-resources

clean: ## Clean (delete) all outputs
	rm -rf $(OUTDIR)

vendor: ## Fetch Jsonnet dependencies
	$(JB) install

# main target for Grafana Cloud resources, will cause all resources to be
# generated through dependencies (vendor so we have Jsonnet libs, and
# GCDASHBOARDS depends on all dashboard resource YAML files)
gc-resources: vendor $(GCDASHBOARDS) ## Grafana Cloud resources

# target that shows a diff between locally generated resources and the state on
# Grafana Cloud
gc-diff: $(GCDASHBOARDS) | gc-resources
	for resource in $^; do \
		$(GRR) diff "$${resource}"; \
	done

# target that applies (uploads) the generated resources to Grafana Cloud
gc-apply: $(GCDASHBOARDS) | gc-resources
	for resource in $^; do \
		$(GRR) apply "$${resource}"; \
	done

# target that uses a dashboard snapshot to generate a "preview" dashboard
# Used to preview changes to generated dashboards before applying them.
gc-preview: $(GCDASHBOARDS) | gc-resources
	for resource in $^; do \
		$(GRR) preview --expires $(GCPREVIEW_EXPIRE) "$${resource}"; \
	done

# dashboard YAML files depend on the output directory but as an order-only
# dependency (i.e. it needs to be done before the dashboards but updating itit
# should not trigger rebuilds)
$(GCDASHBOARDS): | $(GCOUTDIR)

$(GCOUTDIR):
	mkdir -p $@

# a rule that tells make how to produce a YAML file in GCOUTDIR from a source
# Jsonnet filie in GCSRCDIR
$(GCOUTDIR)/%.yaml: $(GCSRCDIR)/%.jsonnet
	$(JSONNET) --jpath vendor $< | $(YQ) eval --prettyPrint '.' - > $@
