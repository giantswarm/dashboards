# Dashboards

This project currently contains Giant Swarm public dashboards.

The goal of this repository is to have both public and Grafana Cloud dashboards defined in one place.

## Management cluster's dashboards

The dashboards located under `helm/dashboards` are the dashboards hosted on each management cluster's grafana.
The "public" ones are accessible by the customer, and the "private" ones are only accessible by Giant Swarm employees.

### Sub-charts

Dashboards are organized into **capability-based sub-charts**, each containing dashboards owned by the responsible team:

- [`helm/dashboards/charts/observability`](helm/dashboards/charts/observability) - Observability (Team Atlas)
- [`helm/dashboards/charts/kubernetes`](helm/dashboards/charts/kubernetes) - Kubernetes (Team Tenet)
- [`helm/dashboards/charts/cloud`](helm/dashboards/charts/cloud) - Cloud (Team Phoenix)
- [`helm/dashboards/charts/security`](helm/dashboards/charts/security) - Security (Team Shield)
- [`helm/dashboards/charts/networking`](helm/dashboards/charts/networking) - Networking (Team Cabbage)
- [`helm/dashboards/charts/app_platform`](helm/dashboards/charts/app_platform) - App Platform (Team Honeybadger)

#### Dashboard directory structure

Within each sub-chart, dashboards are placed in a directory hierarchy that determines their Grafana **organization** and **folder**:

```
charts/<capability>/dashboards/<Organization>/<Folder>/<Subfolder>/dashboard.json
```

- `<Organization>` is the Grafana organization name (e.g., `Giant Swarm`, `Shared Org`), used as the `observability.giantswarm.io/organization` annotation.
- `<Folder>/<Subfolder>` is the Grafana folder path (e.g., `Observability/Mimir`), used as the `observability.giantswarm.io/folder` annotation.

Both annotations are **derived automatically** from the filesystem path by the Helm template.

Example:
```
charts/observability/dashboards/
├── Giant Swarm/
│   ├── Observability/Mimir/mimir-overview.json
│   ├── Observability/Loki/loki-overview.json
│   └── Observability/General/datasource-overview.json
└── Shared Org/
    ├── Observability/Mimir/mimir-reads.json
    └── Observability/General/cluster-overview.json
```

#### Provider-specific dashboards

Dashboards that should only be deployed for a specific infrastructure provider go under a `provider/<kind>/` prefix:

```
charts/<capability>/dashboards/provider/<kind>/<Organization>/<Folder>/dashboard.json
```

These are only included when `provider.kind` matches in the Helm values.

### Dashboard format

All dashboards should have proper tags to facilitate their discovery.
To that end, we advise the following tags:
- `owner:team-name`: Team that owns the dashboard
- `component:component_name`: Name of the component this dashboard is about
- `topic:topic`: The topic that this dashboard is about (observability, security, networking, kubernetes, ...)

### Exporting dashboards from Grafana

Dashboards must be committed as a **complete** v1 or v2 Grafana dashboard. See [Exporting dashboards from Grafana](CONTRIBUTING.md#exporting-dashboards-from-grafana) in `CONTRIBUTING.md` for the correct export procedure (use **Export as code**, preferably as a **V2 Resource**) and the common pitfall to avoid (the unimportable "JSON Model" view).

### Linting

Atlas introduced a dashboard linter to ensure some basic dashboard rules are followed (e.g. always have a datasource present) to help with the migration to Mimir. 
This will most likely be moved to CI later but until it is you can run it like this:

```sh
make lint-dashboards
```

If you need help with the tool or its output, please contact @team-atlas.

## Grafana Cloud dashboards

The `grafana-cloud/` directory contains everything related to Giant Swarm's Grafana Cloud instance:

- **`grafana-cloud/sources/`** — Jsonnet sources for dashboards pushed to Grafana Cloud
- **`grafana-cloud/backup/`** — Automated backup of the live Grafana Cloud dashboards (updated monthly by the backup workflow)
- **`grafana-cloud/scripts/`** — Scripts for managing Grafana Cloud dashboards via the Grafana API

### Requirements

* jsonnet: https://github.com/google/jsonnet

`pip install jsonnet`

* grafonnet: https://github.com/grafana/grafonnet-lib

`git clone https://github.com/grafana/grafonnet-lib.git $GOPATH/src/github.com/grafana/grafonnet-lib`

### Building and uploading

To build and upload the Grafana Cloud dashboards:

To make the dashboards, run:
```
./grafana-cloud/scripts/make-dashboards.sh
```

To upload the dashboards, run:
```
./grafana-cloud/scripts/upload-dashboards.sh
```

To upload a dashboard while editing, run:
```
./grafana-cloud/scripts/upload-dashboard.sh metrics.json
```

## Mixins Dashboards

Mixin dashboards are auto-generated from upstream and placed in the team sub-chart that owns the component:

- **Observability components** (Alloy, Loki, Memcached, Mimir, Tempo) → `helm/dashboards/charts/observability/dashboards/Giant Swarm/Observability/<Component>/`
- **Kubernetes** → `helm/dashboards/charts/kubernetes/dashboards/Giant Swarm/Kubernetes/Mixin/`

### Automatic updates

A [monthly GitHub Actions workflow](.github/workflows/update-mixins.yaml) runs on the 1st of each month. It:
1. Fetches the latest `appVersion` from each `giantswarm/*-app` repository
2. Updates the version pin in the corresponding update script
3. Regenerates all mixin dashboards
4. Opens a PR with any changes

### Manual update

To update all mixin dashboards at once:
```sh
make update-mixin
```

Or to update a single component:

| Component | Command |
|-----------|---------|
| Alloy | `make update-alloy-mixin` |
| Kubernetes | `make update-kubernetes-mixin` |
| Loki | `make update-loki-mixin` |
| Memcached | `make update-memcached-mixin` |
| Mimir | `make update-mimir-mixin` |
| Tempo | `make update-tempo-mixin` |

The Kubernetes mixin is sourced from [giantswarm-kubernetes-mixin](https://github.com/giantswarm/giantswarm-kubernetes-mixin). All other mixins are sourced directly from their upstream repositories, pinned to the version matching the deployed app.

## Origins of the dashboards

Some dashboards are crafted by us (Giant Swarm) or forked from public dashboards.

Some dashboards come from mixins, with a few manual updates. They have a `.*-mixin` tag, like `kubernetes-mixin` or `prometheus-mixin`.

Some dashboards are coming from https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/templates/grafana/dashboards-1.14/ like the `prometheus-remote-write` dashboard

Beware when updating them: even though they come from mixins, they may require tweaks to work with our architecture.

The dashboards that don't require tweaks can be automatically updated from pre-generated mixins at https://monitoring.mixins.dev/ with the `update-mixins-monitoring` github workflow.

In the future we should provide documentation and automation to perform clean updates of mixins-based dashboards.

### Specific dashboards

#### Prometheus-overview

Comes from `prometheus-mixins`, with the addition of support for multiple clusters.

#### KEDA

Comes from https://github.com/kedacore/keda/blob/main/config/grafana/keda-dashboard.json

We added multi-cluster support and tags (team owner)

#### Mimir Cardinality

They come from https://github.com/cerndb/grafana-mimir-cardinality-dashboards

## Release of these dashboards

If you want to release changes in this dashboard repository, you only have to create a branch with the name `main#release#minor`. No replacements here, just literally that branch name :) 

The Automation in place will make the necessary changes and create a correctly versioned branch of the code. It will open up a Pull Request you need to check an merge, which will trigger the release and cleanup the temporary `main#release#minor`-branch again. Afterwards the release will automatically get rolled out to all installations. 
