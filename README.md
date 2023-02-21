# Dashboards

This project currently contains Giant Swarm public dashboards.

The goal of this repository is to have both public and Grafana Cloud dashboards defined in one place and in the same format.

## Management cluster's dashboards

The dashboards located under `helm/dashboards` are the dashboards hosted on each management cluster's grafana.
The "public" ones are accessible by the customer, and the "private" ones are only accessible by Giant Swarm employees.
Those dashboards are currently in JSON and will eventually be replaced to jsonnet format.

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

## Requirements

* jsonnet: https://github.com/google/jsonnet

`pip install jsonnet`

* grafonnet: https://github.com/grafana/grafonnet-lib

`git clone https://github.com/grafana/grafonnet-lib.git $GOPATH/src/github.com/grafana/grafonnet-lib`

### Mixins

To Update the `kubernetes-mixin` dashboards:

* Follow the instructions in [giantswarm-kubernetes-mixin](https://github.com/giantswarm/giantswarm-kubernetes-mixin)
* Run `./scripts/sync-mixins.sh (?my-fancy-branch-or-tag)` to updated the `helm/dashboards/dashboards/mixin` folder.

## Origins of the dashboards

Some dashboards are crafted by us (Giant Swarm) or forked from public dashboards.

Some dashboards come from mixins, with a few manual updates. They have a `.*-mixin` tag, like `kubernetes-mixin` or `prometheus-mixin`.

Beware when updating them: even though they come from mixins, they may require tweaks to work with our architecture.

The dashboards that don't require tweaks can be automatically updated from pre-generated mixins at https://monitoring.mixins.dev/ with the `update-mixins-monitoring` github workflow.

In the future we should provide documentation and automation to perform clean updates of mixins-based dashboards.
