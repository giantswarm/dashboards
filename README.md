# Dashboards

This project currently contains Giant Swarm public dashboards.

The goal of this repository is to have both public and Grafana Cloud dashboards defined in one place.

## Management cluster's dashboards

The dashboards located under `helm/dashboards` are the dashboards hosted on each management cluster's grafana.
The "public" ones are accessible by the customer, and the "private" ones are only accessible by Giant Swarm employees.

### Sub-charts

This chart is divided in 4 different charts, to get around helm charts size limitations:
- `helm/dashboards/charts/public_dashboards/` for public dashboards.
- `helm/dashboards/charts/private_dashboards_al/` for private dashboards starting with letters A to L.
- `helm/dashboards/charts/private_dashboards_mz/` for private dashboards starting with letters M to Z.
- `helm/dashboards/` for other dashboards.

### Dashboard format

All dashboards should have proper tags to facilitate their discovery.
To that end, we advise the following tags:
- `owner:team-name`: Team that owns the dashboard
- `component:component_name`: Name of the component this dashboard is about
- `topic:topic`: The topic that this dashboard is about (observability, security, networking, kubernetes, ...)

### Linting

Atlas introduced a dashboard linter to ensure some basic dashboard rules are followed (e.g. always have a datasource present) to help with the migration to Mimir. 
This will most likely be moved to CI later but until it is you can run it like this:

```sh
make lint-dashboards
```

If you need help with the tool or its output, please contact @team-atlas.

## Grafana Cloud dashboards

The dashboards located under `dashboards` are the dashboards hosted on Giant Swarm's Grafana Cloud.

To build and upload the Grafana Cloud dashboards, here is what you need to do:

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


## Mixins Dashboards

### Requirements

* jsonnet: https://github.com/google/jsonnet

`pip install jsonnet`

* grafonnet: https://github.com/grafana/grafonnet-lib

`git clone https://github.com/grafana/grafonnet-lib.git $GOPATH/src/github.com/grafana/grafonnet-lib`

### Update 

* To Update the `kubernetes-mixin` dashboards:

  * Follow the instructions in [giantswarm-kubernetes-mixin](https://github.com/giantswarm/giantswarm-kubernetes-mixin)
  * Run `./scripts/sync-kube-mixin.sh (?my-fancy-branch-or-tag)` to update the `helm/dashboards/dashboards/mixin` folder.

* To Update the `alertmanager-monitoring-mixins` dashboards:

  * The Github Action `update-monitoring-mixins` runs automatically every month and it creates a PR to update the dashboard.
  * Or you can run the action named `update-monitoring-mixins` manually.

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
