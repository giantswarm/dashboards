JB := go run github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb

# Make Go ignore the `vendor/` dir as it is a jsonnet-bundler dir
export GOFLAGS = -mod=mod


vendor: ## Fetch Jsonnet dependencies
	$(JB) install
