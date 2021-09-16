GRR := go run github.com/grafana/grizzly/cmd/grr
JB := go run github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
JSONNET := go run github.com/google/go-jsonnet/cmd/jsonnet
YQ := go run github.com/mikefarah/yq/v4

OUTDIR := output

# Make Go ignore the `vendor/` dir as it is a jsonnet-bundler dir
export GOFLAGS = -mod=mod

# Grafana Cloud
GCSRCDIR := dashboards
GCOUTDIR := $(OUTDIR)/gc
GC_DASHBOARDS_SRC := $(wildcard $(GCSRCDIR)/*.jsonnet)
GC_DASHBOARDS_OUT := $(addprefix $(GCOUTDIR)/,$(GC_DASHBOARDS_SRC:.jsonnet=.yaml))
GCPREVIEW_EXPIRE ?= 600

.PHONY: clean deps gc-apply gc-diff gc-resources

clean: ## Clean (delete) all outputs
	rm -rf $(OUTDIR)

vendor: ## Fetch Jsonnet dependencies
	$(JB) install

# main target for Grafana Cloud resources, will cause all resources to be
# generated through dependencies (vendor so we have Jsonnet libs, and
# GC_DASHBOARDS_OUT depends on all dashboard resource YAML files)
gc-resources: vendor $(GC_DASHBOARDS_OUT) ## Grafana Cloud resources

# target that shows a diff between locally generated resources and the state on
# Grafana Cloud
gc-diff: $(GC_DASHBOARDS_OUT) | gc-resources
	for resource in $^; do \
		$(GRR) diff "$${resource}"; \
	done

# target that applies (uploads) the generated resources to Grafana Cloud
gc-apply: $(GC_DASHBOARDS_OUT) | gc-resources
	for resource in $^; do \
		$(GRR) apply "$${resource}"; \
	done

# target that uses a dashboard snapshot to generate a "preview" dashboard
# Used to preview changes to generated dashboards before applying them.
gc-preview: $(GC_DASHBOARDS_OUT) | gc-resources
	for resource in $^; do \
		$(GRR) preview --expires $(GCPREVIEW_EXPIRE) "$${resource}"; \
	done

# a rule that tells make how to produce a YAML files in GCOUTDIR from a source
# Jsonnet files
$(GCOUTDIR)/%.yaml: %.jsonnet
	@mkdir -p $(dir $@)
	$(JSONNET) --jpath vendor $< | $(YQ) eval --prettyPrint '.' - > $@
