# Dashboards

This project currently contains Giant Swarm public dashboards.

The goal of this repository is to have both public and cortex dashboards defined in one place and in the same format.

## Management cluster's dashboards

The dashboards located under `helm/dashboards` are the dashboards hosted on each management cluster's grafana and are accessible by the customer.
Those dashboards are currently in JSON and will eventually be replaced to jsonnet format.

## Cortex dashboards

The dashboards located under `dashboards` are the dashboards hosted on Giant Swarm's Cortex.

To build and upload the Cortex Dashboards hosted in Grafana Cloud, here is what you need to do:

To make the dashboards, run:
```
./scripts/make-dashboards.sh
```

To upload the dashboards, run:
```
./scripts/upload-dashboards.sh
```

To upload a dashboard while editing, run:
```
./scripts/upload-dashboard.sh metrics.json
```

## Requirements

Makefile will take care of pulling in requirements as needed, we use [tool
dependency
tracking](https://github.com/golang/go/wiki/Modules#how-can-i-track-tool-dependencies-for-a-module)
technique so all Go dependencies are defined in `tools.go` and `go.mod`. Jsonnet
dependencies are pulled using [jsonnet-bundler][cgh-jbjb] which populates the
`vendor/` directory according to dependencies defined in `jsonnetfile.json`
file. All in all, that means you only need Go on the host machine, everything
else will be fetched automatically.

For completeness, the list of tools used:

* [Jsonnet](https://github.com/google/go-jsonnet)

* [jsonnet-bundler][cgh-jbjb]

* [Grafonnet](https://github.com/grafana/grafonnet-lib)

## Hacking

`make vendor` triggers [jsonnet-bundler][cgh-jbjb] to populate `vendor/`
directory with Jsonnet libraries as defined in `jsonnetfile.json`. This usually
isn't updated unless dependencies change, but can be done manually by just
deleting the directory and re-running `make vendor`.

One side-effect of using a `vendor/` directory is that Go tooling has to be told
to ignore it (usually when it exists Go tools assume `-mod=vendor` option and
try to use the directory but as it's not used for Go deps this causes problems),
which can be done with `GOLAGS="-mod=mod"` environment variable.

The Makefile already does this so all Go tools that run from make are fine, but
when running any commands outside (like below) remember to run `export
GOLAGS="-mod=mod"` first.

### Adding a new Jsonnet dependency

Use `jb install repo/path`, e.g.:

``` sh
go run github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb install github.com/grafana/grafonnet-lib/grafonnet
```

[cgh-jbjb]: https://github.com/jsonnet-bundler/jsonnet-bundler
