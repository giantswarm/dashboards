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

``` sh
make gc-resources
```

To see a diff of what's changed comparing to what's in Grafana Cloud:

``` sh
make gc-diff
```

To upload the dashboards, run:

``` sh
make gc-apply
```

To preview a dashboard while editing, run:

``` sh
make gc-preview
```

This figures out which dashboards have changed locally and uploads them as
[snapshots][cgr-dglhas] that expire after 10 minutes (by default, can be set
with `make gc-preview GCPREVIEW_EXPIRE=X` where `X` is time in seconds) and are
automatically cleaned up.

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

* [Grizzly][cgh-grgr]

* [Grafonnet][cgh-grgl]

* [jsonnet-libs][cgh-grjl]

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

### Using Grafana Cloud targets

[Grizzly][cgh-grgr] needs to have two env variables set to work:

* `GRAFANA_URL` set to the root URL of your tenant in [Grafana Cloud][cgr-pc]
* `GRAFANA_TOKEN` set to an API token to authenticate with the above, can be
  created in the cloud portal, see [Create a Grafana Cloud API key][cgr-dgcrcak]

Note that grizzly's `pull` and `push` commands also operate on
`PrometheusRuleGroup` and `SyntheticMonitoringCheck` resources which need
additional variables defined for Cortex and Synthetic Monitoring products, if
using them you can use

``` sh
GOFLAGS=-mod=mod go run github.com/grafana/grizzly/cmd/grr pull -d tmp/dashboards-pulled --target 'DashboardFolder/*' --target 'Dashboard/*' --target 'Datasource/*'
```

to limit to only pulling Grafana resources.

For dashboards to work with [Grizzly][cgh-grgr] they need to be formatted as
Kubernetes-style resources that `grr` tool expects. Regular
[Grafonnet][cgh-grgl] dashboards can be converted using [jsonnet-libs][cgh-grjl]
library, and this is hooked in to our [stdlib](./dashboards/stdlib.jsonnet)
helper so in the dashboard `.jsonnet` file it's sufficient to call:

``` jsonnet
.toResource()
```

as the last thing in the file.

[cgh-grgr]: https://github.com/grafana/grizzly
[cgh-grgl]: https://github.com/grafana/grafonnet-lib
[cgh-grjl]: https://github.com/grafana/jsonnet-libs
[cgh-jbjb]: https://github.com/jsonnet-bundler/jsonnet-bundler
[cgr-dgcrcak]: https://grafana.com/docs/grafana-cloud/reference/create-api-key/
[cgr-dglhas]: https://grafana.com/docs/grafana/latest/http_api/snapshot/
[cgr-pc]: https://grafana.com/products/cloud/
