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

* jsonnet: https://github.com/google/jsonnet

`pip install jsonnet`

* grafonnet: https://github.com/grafana/grafonnet-lib

`git clone https://github.com/grafana/grafonnet-lib.git $GOPATH/src/github.com/grafana/grafonnet-lib`

## Update mixins

Upstream dashboards are generated in the
[giantswarm-kubernetes-mixin](https://github.com/giantswarm/giantswarm-kubernetes-mixin)
repository. These are then duplicated into this repository in order to ensure
they are only changed when we want them to be.

To sync the master branch, run this script with no arguments:

```bash
./sync-mixin.sh
```

To sync a different branch, pass the branch name to the script:

```bash
./sync-mixins.sh my-fancy-branch
```