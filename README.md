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



### Mixin

To Update `kubernetes-mixin` dashboards:

* After Checking a suitable release in the [upstream](https://github.com/kubernetes-monitoring/kubernetes-mixin#releases) and updating [mixins.rules](https://github.com/giantswarm/prometheus-rules/blob/master/helm/prometheus-rules/templates/recording-rules/kubernetes-mixins.rules.yml)

* follow those [instructions](https://github.com/kubernetes-monitoring/kubernetes-mixin#generate-config-files)

* Copy the content of `dashboards_out/` to `helm/dashboards/dashboards/mixin` and overwrite dashboards with same name.

* Adjust labels in the dashboards

```
cluster=                   =>  cluster_id=

job="apiserver"            =>  app="kubernetes"

job="cadvisor"             =>  app="cadvisor"

job="kube-state-metrics"   =>  app="kube-state-metrics"

job="kube-scheduler"       =>  app="kube-scheduler"

job="node-exporter"        =>  app="node-exporter"

job="kubelet"              =>  app="kubelet"
```

Don't forget to change labelvalues grafana function as follow:

```
label_values(up{app=\"cadvisor\"}, cluster)   =>  label_values(up{app=\"cadvisor\"}, cluster_id)
```
