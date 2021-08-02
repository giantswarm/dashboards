# installation-dashboards-e2

This is an experiment with structuring dashboards using the _mixins_
conventions described in

- grizzly docs: https://github.com/grafana/grizzly#grafana-dashboard-example
- kubernetes mixins docs: https://github.com/monitoring-mixins/docs

and implemented in https://github.com/kubernetes-monitoring/kubernetes-mixin

The way this works is that each dashboard jsonnet file is structured in a way
that adds that dashboard into a hidden `grafanaDashboards` object keyed by
dashboard filename.

All dashboards are then combined together in
[dashboards.jsonnet](./dashboards.jsonnet) file which simply imports each
dashboard.

This is a format that [grizzly](https://github.com/grafana/grizzly) expects
and the advantage is that a single dashboard can be generated with

``` sh
mkdir output
grr export installation-dashboards-e2/kvm/kvm-machine-usage2.jsonnet output/e2
```

and all dashboards can be generated with:

``` sh
mkdir output
grr export installation-dashboards-e2/dashboards.jsonnet output/e2
```
