# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Fix Alloy mixins tags.

## [3.23.0] - 2024-08-22

### Added

- Added Alloy mixin dashboards

- Added Makefile.custom.mk to group scripts usage
  - Added `make update-mixin` to update mixin dasbhboards
  - Added `make lint-dashboards` to dashboards linting
  - Added `make install-tools` to install required tools

- Added `scripts/update-alloy-mixin.sh` to update the Alloy mixin dashboards

- Added `update-alertmanager-mixin` and `update-kubernetes-mixin` Makefile targets

### Changed

- Updated all dashboars using `decbytes` unit to use `bytes` (IEC units) instead.

### Fixed

- Fix dashboards destination path in `update-monitoring-mixin-dashboards.sh` script

## [3.22.0] - 2024-08-01

### Added

- mimir query stats dashboard

### Changed

- Fixed etcd count dashboard replacing the namespace to expoted_namespace.

### Removed

- Remove Linkerd Control Plane dashboard

## [3.21.0] - 2024-07-03

### Changed

- Get rid of the `app` label in Phoenix dashboards.

## [3.20.0] - 2024-07-01

### Added

- Add "BPF map pressure" graph to "Cilium performance" dashboard.
- Add kube-builder logs in "Kube-Builder Operators" dashboard.

### Changed

- fluentbit dashboard: cluster selection

### Fixed

- Mimir Cost Estimation: fix RAM usage

### Removed

- Removed the dashboard 'Webhook Health'.

## [3.19.0] - 2024-06-13

### Changed

- Make `Certificate Details` dashboard public
- Migrate deprecated angular panels.

## [3.18.0] - 2024-06-12

### Added

- Added missing datasource to all dashboards and panels.

### Removed

- Ger rid the of useless analytics panels.

## [3.17.0] - 2024-06-07

### Added

- Add script to update all mimir dashboards from mixins.

### Changed

- Replace Cluster ID with cluster in dashboard labels.
- remotewrite: improve legends
- remotewrite: add count of agent replicas
- Reviewed labels used in turtles dashboards
- servicemonitors-overview: add info about agent pods

### Fixed

- Add missing datasource to api-security dashboard.
- Add missing datasource to api-performance dashboard and fix tags.
- Add missing datasource to `api-performance` dashboard and fix tags.
- Add missing datasource to `certificate` dashboard and fix tags.
- Lint the capi and capa aggregated-error-logs dashboards to have proper datasource variables.

### Removed

- Remove vintage azure dashboards.

## [3.16.1] - 2024-06-04

### Changed

- Get rid of the `app` label in Atlas dashboards.

## [3.16.0] - 2024-05-30

### Changed

- Move SLO reporting dashboard to be public.

### Fixed

- Add missing data source to atlas dashboards.
- Fix missing provider specific dashboards.
- Fix prometheus-cost-estimation dashboard.
- Update alertmanager-overview dashboard (angular deprecation).
- Update fluentbit dashboard (angular deprecation).
- Update operatorkit dashboard (angular deprecation).
- Update prometheus-overview dashboard (angular deprecation).
- Update prometheus-remote-write dashboard (angular deprecation).

### Removed

- Remove prometheus benchmark dashboard.
- Remove EFK dashboards.
- Removed KVM dashboards.

## [3.15.1] - 2024-05-29

### Fix

- Fix missing ingress slo in slo reporting.

## [3.15.0] - 2024-05-23

### Added

- Add datasource variable to Prometheus dashboard

### Fixed

- Adjust panel positions to fill width and move Mimir related panel under related section

## [3.14.2] - 2024-05-20

### Changed

- ServiceMonitors Overview dashboard: add RAM usage estimation

## [3.14.1] - 2024-05-15

### Changed

- Change "Node utilization" dashboard to use allocatable over capacity, to better reflect the available resources of the nodes.

## [3.14.0] - 2024-05-15

### Fixed

- Fix loki and mimir mixins recording rules
- Fix atlas dashboard tags.
- Fix storage related panes on zot's dashboards
- prometheus: scraping info can now be filtered by cluster
- add some basic linting configuration so we can track down issues in dashboards.

### Added

- ServiceMonitors overview dashboard
- ServiceMonitors details dashboard

## [3.13.0] - 2024-04-24

### Changed

- Change "Worker node utilization" dashboard to "Node utilization", also allowing to analyze data for control plane nodes.

## [3.12.0] - 2024-04-23

### Added

- Add dashboard "Worker node utilization".

## [3.11.4] - 2024-04-17

### Changed

- Updated "In-cluster container registry (Zot)" dashboard to use metric `kubelet_volume_stats_used_bytes` for storage used.

## [3.11.3] - 2024-04-17

### Changed

- Move `node-problem-detector` to be aws only.


### Fixed

- Fix Grafana Cloud service-level dashboard in case we have duplicate clusrer names in different installations.
- Invalid datasource variable name in mimir cost estimate dashboard.

## [3.11.2] - 2024-04-16

### Fixed

- Fix `Mimir / writes resources` disk usage related graphs.

## [3.11.1] - 2024-04-16

### Changed

- Improved many details on the dashboard "In-cluster container registry (Zot)".
- Change `net-exporter` dashboard ownership from turtles to cabbage.
- Change `cluster-total.json` dashboard ownership from turtles to cabbage.
- Change `namespace-by-pod.json` dashboard ownership from turtles to cabbage.
- Change `namespace-by-workload.json` dashboard ownership from turtles to cabbage.
- Change `pod-total.json` dashboard ownership from turtles to cabbage.
- Change `workload-total.json` dashboard ownership from turtles to cabbage.
- Update "Ingress NGINX Controller Connection Distribution" dashboard file to schema version 39.
- Update "Giant Swarm / Kubernetes Persistent Volumes" dashboard file to replace old graph panels with new time series panels.
- Update "Security: Falco Dashboard" dashboard file to replace old graph panel with new time series panel, old table with new table panel.

### Fixed

- Fix `Mimir / Reads resources` Disk usage graphs.

### Removed

- Remove "Microstorage" dashboard.

## [3.11.0] - 2024-04-11

### Added

-  Add a CAPA aggregated error logs dashboard.

## [3.10.4] - 2024-04-10

### Fixed

- Fixes "All Dex requests" panel showing "No data" by increasing query interval to 2m.

## [3.10.3] - 2024-04-10

### Changed

- Remove `app` and `namespace` labels from the prometheus - remotewrite's nginx graphs.

### Fixed

- Fix cpu throttling panel in prometheus dashboard

## [3.10.2] - 2024-04-10

### Fixed

- Fix and update Flux Control Plane dashboard in various ways.

### Changed

- The private Zot dashboard is updated because of a namespace change, and some minor fixes are applied.

## [3.10.1] - 2024-04-08

### Fixed

- Fix Mimir / Compactor / Overview dashboard.

## [3.10.0] - 2024-04-03

### Added

- Add private dashboard about in-cluster container image registry (Zot)

### Fixed

- Fix `Mimir / Overview resources` dashboard

## [3.9.0] - 2024-03-27

### Added

- Add dashboard for loki-canary (private for now)

### Changed

- Migrate panels from graph to timeseries in DNS dashboard.
- Add promxy cpu and memory graphs to prometheus cost dashboard.
- Add promxy cpu and memory graphs to mimir cost dashboard.

## [3.8.5] - 2024-03-26

### Added

- Add public Cilium performance dashboard.

### Fixed

- Fix all dashboards that were only supporting only role=master to now support role=~control-plane|master.
- Fix Mimir - Prometheus cost dashboard to compare over real data (not missing on data from old prometheus instances)

## [3.8.4] - 2024-03-11

### Added

- Add mimir overview mixins dashboard.

## [3.8.3] - 2024-03-11

### Added

- Add mimir mixins dashboard for compactor.

## [3.8.2] - 2024-03-07

### Added

- Add mimir mixins dashboard for ruler.

## [3.8.1] - 2024-03-05

### Added

- Add mimir mixins dashboards for read.

## [3.8.0] - 2024-02-29

### Added

- Add mimir mixins dashboards for write.

### Changed

- Change `managed-apps-efk-stack-app` dashboard owner to Atlas.
- Updated `k8s-resources-node` dashboard.

## [3.7.1] - 2024-02-27

### Fixed

- Fix Prometheus - Mimir Cost Comparison dashboard.
- Moved Dashboards from deprecated ludacris team to turtles team tags.
- Removed Dashboards with deprecated data sources.

## [3.7.0] - 2024-01-31

### Added

- Create `Policy Enforcement (PSS) Status` workload cluster compliance overview dashboard.
- Add first draft of the SLA reporting dashboard.

### Fixed

- Fix query in API server dashboard for CAPI clusters

## [3.6.2] - 2024-01-18

### Fixed

- Fix name and query for API server dashboard

## [3.6.1] - 2024-01-18

### Changed

- Fixed API server dashboard and made it public

## [3.6.0] - 2024-01-15

### Added

- Kube-Builder operators dashboard
- Add Linkerd Control Plane dashboard

## Changed

- Better description and small spacing fixes in etcd-backup dashboard

## [3.5.0] - 2023-11-24

### Changed

- Loki Operational dashboard improvements:
  - Added a `Backend Path` panel
  - Added `disk usage` to Write and Backend path panel
  - Added `total pods` to Write, Read and Backend panels

### Fixed

- Loki cost estimation: update legends to name tenants

## [3.4.2] - 2023-11-21

### Changed

- Add three stat panels to "Container images from docker.io" dashboard

## [3.4.1] - 2023-11-20

### Fixed

- Fix queries in "Container images from docker.io" dashboard to use the `image_spec` label instead of `image`.

## [3.4.0] - 2023-11-20

### Added

- Public dashboard: Container images from docker.io

## [3.3.0] - 2023-11-09

### Added

- Add Nginx admission controller dashboard.
- Add Node Problem Detector dashboard.

## [3.2.4] - 2023-11-06

### Added

- Add KEDA dashboard.

## [3.2.3] - 2023-10-26

### Fixed

- Fix `Kubernetes Events & Resources Count` dashboard.

## [3.2.2] - 2023-10-20

### Changed

- Added rate limit graphs to cilium

## [3.2.1] - 2023-10-19

### fixed

- Fixed nginx panel in remote-writes dashboard

## [3.2.0] - 2023-10-19

### Changed

- Prometheus remote-writes: add nginx stats

## [3.1.0] - 2023-10-13

### Changed

- prometheus remote-writes: filter on URL

## [3.0.0] - 2023-10-11

### Changed

- Update Loki Cost Estimation dashboard.
- [BREAKING] Split the chart in sub-chart to get around chart size limitation - all values are moved to a `global` section.

## [2.47.0] - 2023-10-11

### Changed

- Update Loki Cost Estimation dashboard.

## [2.46.0] - 2023-10-09

### Fixed

- Prometheus dashboard: fix node RAM

### Added

- Add custom dashboards documentation link into home panel.
- Loki dashboards from mixins

### Changed

- Cilium: migrate to Timeseries and change rate timeframe.

## [2.45.0] - 2023-09-21

### Changed

- Improve DNS logs with filtering options.

### Fixed

- Alerts dashboard: show alerts with missing fields

## [2.44.0] - 2023-09-19

### Changed

- Alerts dashboard:
  - new filters: team, severity, alertname
  - removed "inhibitions" graph as it was not reliable
  - changed visualization for alerts from graph to timeline
  - added a table listing alerts that have previously fired
  - minor changes to global stat numbers

## [2.43.0] - 2023-09-19

### Added

- Add internal links between all Prometheus Dashboards.

## [2.42.0] - 2023-08-31

### Changed

- DNS Dashboard: add logs panel for CoreDNS
- Kong Connection Distribution: Make public

## [2.41.0] - 2023-08-30

### Changed

- Prometheus dashboard: logs panel and restart logs annotation

## [2.40.0] - 2023-08-24

### Added

- Added dashboard showing AWS Load Balancer Controller errors
- Added Karpenter dashboard

## [2.39.0] - 2023-08-22

### Changed

- Align owner tags in Grafana cloud dashboards to format `owner:TEAM-NAME`.

## [2.38.0] - 2023-08-21

### Fixed

- Added promtail to cpu & memory graphs

## [2.37.0] - 2023-08-18

### Fixed

- Fixed issues from `Loki Cost Estimate` dashboard
- Fixed cluster id in `Cilium Metrics` dashboard

### Changed

- Update Kyverno health dashboard to be compatible with Kyverno 1.10.
- Add modified "Kong (official)" dashboard
- Update Kong-Connection-Distribution dashboard to work with new kong-app versions

## [2.36.0] - 2023-07-27

### Added

- Add `External DNS` dashboard.
- Add Cache panes to DNS dashboard.

## [2.35.0] - 2023-07-13

### Changed

- Dashboards: Rename `nginx-ingress-controller` to `ingress-nginx`. ([#331](https://github.com/giantswarm/dashboards/pull/331))
- Allow filtering by DNS zone in the `DNS` dashboard.

## [2.34.0] - 2023-07-12

### Changed

- Add MC data into DNS dashboard.

## [2.33.0] - 2023-07-11

### Changed

- Add per-node brakedown of latency in DNS dashboard.

## [2.32.1] - 2023-07-11

### Fixed

- Set correct filter in DNS Latency graph for node-local DNS cache.

## [2.32.0] - 2023-07-10

### Changed

- Improved the DNS dashboard in order to be quicker and richer, especially considering node-local DNS cache and coredns as separate components.

## [2.31.2] - 2023-07-10

### Fixed

- Fix broken panels in `DNS` dashboard.

## [2.31.1] - 2023-06-28

### Removed

- Remove broken managed app sli dashboard.

## [2.31.0] - 2023-06-23

### Added

- Add `CAPI Overview` dashboard.
- Add `Mimir Cost Estimate` dashboard.
- Add `Prometheus - Mimir Comparative` dashboard.
- Add `Kyverno Health` dashboard.

## [2.30.0] - 2023-06-20

### Changed

- Update team label of dashboards related to bigmac components.

## [2.29.0] - 2023-06-13

### Changed

- Update "Persistent Volume Usage" dashboard.

## [2.28.4] - 2023-06-06

### Added

- Add Helm charts to Flux cluster dashboard.
- Add `Prometheus Cost Estimate` dashboard.

### Removed

- Stop pushing to `openstack-app-collection`.

## [2.28.3] - 2023-05-04

### Fixed

- Make `Nodes Overview` dashboard work for Workload Clusters and assign to team phoenix.

### Changed

- Adjusted the ENA dashboard to have an overview of the data across time

## [2.28.2] - 2023-05-03

### Changed

- added link from prometheus to prometheus/availability dashboard
- added link from prometheus/availability to prometheus dashboard

## [2.28.1] - 2023-05-02

### Fixed

- prometheus availability over period

## [2.28.0] - 2023-04-20

### Added

- Add Loki cost estimation dashboard

### Changed

- rework of requests vs usage to use the same metrics as kube-mixins and change filtering options
- requests vs usage dashboard made public

## [2.27.0] - 2023-04-17

###  Changed

- Move cilium dashboard to public dashboards.

## [2.26.0] - 2023-04-06

### Changed

- Add AWS ENA Performance
- Updated team labels for team-rocket
- Add graph in Node Overview to identify emptydir growth
- Update kube-mixins to 0.12
- Added Etcd health for monitoring the Etcd key space status
- Adjusted the K8s Api Perfomance master nodes memory dashoboard and using `node_memory_MemAvailable_bytes` instead of `node_memory_MemFree_bytes`

## [2.25.0] - 2023-03-24

### Added

- Prometheus availability dashboard

### Changed

- Small improvements for Prometheus dashboard

## [2.24.1] - 2023-03-09

### Changed

- Change the name of metric `ETCD Backend Quota Low Space` to `ETCD Keyspace usage`.

## [2.24.0] - 2023-03-03

### Added

- Prometheus - opsrecipe dashboard
- Prometheus Overview dashboards - from prometheus-mixins
- Add `ETCD Backend Quota Low Space` to K8s API Performance Dashboard.

### Changed

- Make main prometheus dashboard public

## [2.23.0] - 2023-02-28

### Changed

- Monitoring Dashboard Updated
```
?? helm/dashboards/dashboards/shared/public/alertmanager-overview.json
```

### Added

- Alertmanager / Overview Dashboard

### Changed

- Prometheus dashboard improvements: available node resources, scraped metrics info and rules info.

## [2.22.0] - 2023-02-23

### Changed

- Prometheus dashboard improvements: add volume usage, add memory and cpu limits.
- README updates
- Update cimg/go Docker tag from v1.20.0 to v1.20.1
- Move prometheus-remote-write dashboard to public

## [2.21.0] - 2023-02-20

### Changed

- updates of Prometheus dashboard
- updates of Pod request vs usage dashboard

### Fixed

- Datasource for kong-config-reload dashboard

### Removed

- What is presumed to be a debug matcher from upstream

## [2.20.0] - 2023-01-18

### Added

- Add private dashboard for External Secrets.

## [2.19.3] - 2023-01-12

### Fixed

- Fix hardcoded interval in the DNS dashboard.

## [2.19.2] - 2023-01-11

### Changed

- Fix efk-stack-app dashboard

## [2.19.1] - 2023-01-10

### Changed

- Add dashboards to gcp.

## [2.19.0] - 2023-01-05

### Added

- Add official kong ingress controller dashboard rev 2 from https://grafana.com/grafana/dashboards/15662-kong-ingress-controller/
- TESTING guidelines

### Changed

- Added uid for some dashboards when missing (etcd, managed-apps-efk-stack-app, management-cluster-kubernetes, microstorage, prometheus-remote-write, workload-cluster-kubernetes)

## [2.18.0] - 2022-11-22

### Changed

- Add namespace to the Flux reconciliation duration graph.

### Added

- Add user metrics for API audit logs.
- Add private dashboard for Crossplane.

## [2.17.0] - 2022-10-20

### Added

- Add dashboard to display Cilium agents' metrics.

### Changed

- Make `API Audit` dashboard work with management clusters.
- Move nginx Ingress Controller to public dashboards

## [2.16.0] - 2022-09-12

### Added

- Add NGINX Ingress Controller Connection Distribution dashboard.
- Add Kong Connection Distribution dashboard.

## [2.15.0] - 2022-09-06

### Changed

- Use `app` label instead of `service` label to identify metrics in `dex` dashboard.

### Added

- Add new dashboard for CertificateRequests

### Changed

- Add variable `app` and upgrade panel types for the "NGINX Ingress controller" dashboard.
- Metrics dashboard: replace Prometheus total memory with time series per cluster
- Metrics dashboard: change Prometheus total time series to stat panel type

## [2.14.0] - 2022-08-12

### Added

- operatorkit dashboard

### Changed

- Deprecated cert-operator dashboard, superceded by operatorkit dashboard

## [2.13.3] - 2022-07-27

### Changed

- Certificates expiration details file name

## [2.13.2] - 2022-07-27

### Added

- Certificates expiration details

## [2.13.1] - 2022-07-26

### Added

- Webhooks performance dashboard

## [2.13.0] - 2022-07-18

### Changed

- Move ownership of dashboards from Celestial and Firecracker to Phoenix.
- Set Team Shield as owner of Falco and Starboard dashboards.
- Split the "Rate of API requests" chart by instance in the "K8s API performance" private dashboard.

## [2.12.1] - 2022-06-29

### Fixed

- Fix datasource using UID.

## [2.12.0] - 2022-06-13

### Added

- Add sync mixin scripts.
- Add Organization filter to shared and AWS public dashboards.

## [2.11.2] - 2022-05-31

### Fixed

- Yet another fix for the Fairness and Priority charts in the `K8s API Performance` dashboard.

## [2.11.1] - 2022-05-30

### Fixed

- Fixed query for the Fairness and Priority charts in the `K8s API Performance` dashboard.

## [2.11.0] - 2022-05-30

### Changed

- Add Fairness and Priority charts in the `K8s API Performance` dashboard.

## [2.10.0] - 2022-05-26

### Changed

- Updated mixin dashboards

## [2.9.2] - 2022-05-26

### Added

- Add etcd response times histogram.

### Changed

- Improve `Etcd k8s events and resources` dashboard
- Fix KVM usage dashboard

## [2.9.1] - 2022-05-23

### Added

- Update `etcd-k8s-resources-count` to `etcd-k8s-events-and-resources-count`


## [2.9.0] - 2022-05-18

### Added

- Add dashboard for Fluentbit.

## [2.8.0] - 2022-05-17


### Added

- Add new dashboard 'Webhook Health'.
- Add dashboard for Fluentbit.

## Changed

- Fixes and updates to `grafana` dashboard.
- Improve `K8s API performance` dashboard.

## [2.7.0] - 2022-05-12

### Changed

- Improve `K8s API performance` dashboard.

## [2.6.0] - 2022-05-10

### Changed

- Improve `K8s API performance` dashboard.

## [2.5.0] - 2022-05-09

### Changed

- Improve `K8s API performance` dashboard.

## [2.4.2] - 2022-05-05

### Fixed

- Fix query in `K8s API performance` dashboard to make it more reliable.

## [2.4.1] - 2022-05-05

### Fixed

- Only display master nodes metrics in `K8s API performance` dashboard.

## [2.4.0] - 2022-05-04

### Added

- Add new dashboard 'K8s API performance'.

## [2.3.0] - 2022-04-28

### Changed

- Make DNS dasbhoard public.

## [2.2.0] - 2022-04-21

### Changed

- Improved DNS dashboard to visualize data about node-local DNS cache.

## [2.1.1] - 2022-04-19

### Changed

- Make `kube-proxy` dashboard UX compliant.
- Fix `ceph-cluster` dashboard datasource.

## [2.1.0] - 2022-04-05

### Changed

- Split each dashboards into specific configmaps
- Make mixin dashboard private

## [2.0.0] - 2022-04-04

### Added

- Add all dashboards from g8s-grafana.
- Add grafana sidecar annotation to all configmaps.
- Add a dashboard for `ceph cluster usage in KVM`.

## [1.11.0] - 2022-03-29

### Added

- Add a dashboard for `kube-proxy`.

## [1.10.2] - 2022-03-18

### Fixed

- Fix query in `AWS Cluster Status` dashboard.

## [1.10.1] - 2022-02-28

### Fixed

- Fix `kube_node_status_capacity_` metrics.

## [1.10.0] - 2022-02-23

### Added

- Add support for arbitrary providers instead of hardcoding dashboard settings per provider.

## [1.9.1] - 2022-01-20

### Changed

- Dex dashboard:
  - Add new panel to show requests with more details.
  - Exclude health check requests (handler `/healthz`) from the successful requests graph.

## [1.9.0] - 2022-01-13

### Added

- Add a new dashboard showing success and error responses for SSO via `dex`.

## [1.8.1] - 2021-12-02

### Fixed

- Fix metrics dashboard showing incorrect values for number of time series per installation and customer.

## [1.8.0] - 2021-12-01

### Deleted

- Delete Azure Load Balancer Backend Nodes dashboard.

## [1.7.0] - 2021-11-24

### Added

- Add new dashboard to visualize API audit metrics

## [1.6.0] - 2021-11-09

### Added

- Add FluxCD dashboards.

## [1.5.1] - 2021-10-20

### Changed

- Update description and icon

## [1.5.0] - 2021-09-17

### Added

- Add AWS Cluster Status Dashboard
- Add Managed Apps dashboard.

## [1.4.0] - 2021-09-06

### Added

- Add Grafana Analytics dashboard.
- Add Azure Load Balancer Instances dashboard.

## [1.3.0] - 2021-08-18

### Added

- Added macropower-analytics-panel to public dashboards.

## [1.2.0] - 2021-08-13

### Changed

- Migrate to configuration management.
- Update `architect-orb` to v4.0.0.

## [1.1.0] - 2021-08-05

### Added

- Add KVM Resource Usage dashboard link to the home page for KVM only.
- Allow templating in dashboards.

## [1.0.5] - 2021-07-27

- Several updates to the KVM Resource Usage dashboard:
  - Change graph (old) to Grafana 8 time series panels
  - Change graphs for CPUs and memory left from absolute numbers to percentage

## [1.0.4] - 2021-07-26

- Moved KVM dashboard to a provider dedicated folder.

## [0.1.3] - 2021-07-23

### Added

- New dashboard to expose KVM information, helping with capacity planning and observability.

### Fixed

- Updated the link to the source repo of the Prometheus rules and alerts in the Alerts dashboard.

## [0.1.2] - 2021-06-29

### Changed

- Update the Nodes Overview dashboard to use Grafana 8 time series instead of graph panels.
- Update the Alerts dashboard to use Grafana 8 time series instead of graph panels.
- Update Home dashboard to only show release notes related to dashboards.

### Fixed

- A typo in the alerts dashboard.

## [0.1.1] - 2021-06-25

### Fixed

- Fix CI build

## [0.1.0] - 2021-06-25

### Added

- Add public grafana dashboards.


[Unreleased]: https://github.com/giantswarm/dashboards/compare/v3.23.0...HEAD
[3.23.0]: https://github.com/giantswarm/dashboards/compare/v3.22.0...v3.23.0
[3.22.0]: https://github.com/giantswarm/dashboards/compare/v3.21.0...v3.22.0
[3.21.0]: https://github.com/giantswarm/dashboards/compare/v3.20.0...v3.21.0
[3.20.0]: https://github.com/giantswarm/dashboards/compare/v3.19.0...v3.20.0
[3.19.0]: https://github.com/giantswarm/dashboards/compare/v3.18.0...v3.19.0
[3.18.0]: https://github.com/giantswarm/dashboards/compare/v3.17.0...v3.18.0
[3.17.0]: https://github.com/giantswarm/dashboards/compare/v3.16.1...v3.17.0
[3.16.1]: https://github.com/giantswarm/dashboards/compare/v3.16.0...v3.16.1
[3.16.0]: https://github.com/giantswarm/dashboards/compare/v3.15.1...v3.16.0
[3.15.1]: https://github.com/giantswarm/dashboards/compare/v3.15.0...v3.15.1
[3.15.0]: https://github.com/giantswarm/dashboards/compare/v3.14.2...v3.15.0
[3.14.2]: https://github.com/giantswarm/dashboards/compare/v3.14.1...v3.14.2
[3.14.1]: https://github.com/giantswarm/dashboards/compare/v3.14.0...v3.14.1
[3.14.0]: https://github.com/giantswarm/dashboards/compare/v3.13.0...v3.14.0
[3.13.0]: https://github.com/giantswarm/dashboards/compare/v3.12.0...v3.13.0
[3.12.0]: https://github.com/giantswarm/dashboards/compare/v3.11.4...v3.12.0
[3.11.4]: https://github.com/giantswarm/dashboards/compare/v3.11.3...v3.11.4
[3.11.3]: https://github.com/giantswarm/dashboards/compare/v3.11.2...v3.11.3
[3.11.2]: https://github.com/giantswarm/dashboards/compare/v3.11.1...v3.11.2
[3.11.1]: https://github.com/giantswarm/dashboards/compare/v3.11.0...v3.11.1
[3.11.0]: https://github.com/giantswarm/dashboards/compare/v3.10.4...v3.11.0
[3.10.4]: https://github.com/giantswarm/dashboards/compare/v3.10.3...v3.10.4
[3.10.3]: https://github.com/giantswarm/dashboards/compare/v3.10.2...v3.10.3
[3.10.2]: https://github.com/giantswarm/dashboards/compare/v3.10.1...v3.10.2
[3.10.1]: https://github.com/giantswarm/dashboards/compare/v3.10.0...v3.10.1
[3.10.0]: https://github.com/giantswarm/dashboards/compare/v3.9.0...v3.10.0
[3.9.0]: https://github.com/giantswarm/dashboards/compare/v3.8.5...v3.9.0
[3.8.5]: https://github.com/giantswarm/dashboards/compare/v3.8.4...v3.8.5
[3.8.4]: https://github.com/giantswarm/dashboards/compare/v3.8.3...v3.8.4
[3.8.3]: https://github.com/giantswarm/dashboards/compare/v3.8.2...v3.8.3
[3.8.2]: https://github.com/giantswarm/dashboards/compare/v3.8.1...v3.8.2
[3.8.1]: https://github.com/giantswarm/dashboards/compare/v3.8.0...v3.8.1
[3.8.0]: https://github.com/giantswarm/dashboards/compare/v3.7.1...v3.8.0
[3.7.1]: https://github.com/giantswarm/dashboards/compare/v3.7.0...v3.7.1
[3.7.0]: https://github.com/giantswarm/dashboards/compare/v3.6.2...v3.7.0
[3.6.2]: https://github.com/giantswarm/dashboards/compare/v3.6.1...v3.6.2
[3.6.1]: https://github.com/giantswarm/dashboards/compare/v3.6.0...v3.6.1
[3.6.0]: https://github.com/giantswarm/dashboards/compare/v3.5.0...v3.6.0
[3.5.0]: https://github.com/giantswarm/dashboards/compare/v3.4.2...v3.5.0
[3.4.2]: https://github.com/giantswarm/dashboards/compare/v3.4.1...v3.4.2
[3.4.1]: https://github.com/giantswarm/dashboards/compare/v3.4.0...v3.4.1
[3.4.0]: https://github.com/giantswarm/dashboards/compare/v3.3.0...v3.4.0
[3.3.0]: https://github.com/giantswarm/dashboards/compare/v3.2.4...v3.3.0
[3.2.4]: https://github.com/giantswarm/dashboards/compare/v3.2.3...v3.2.4
[3.2.3]: https://github.com/giantswarm/dashboards/compare/v3.2.2...v3.2.3
[3.2.2]: https://github.com/giantswarm/dashboards/compare/v3.2.1...v3.2.2
[3.2.1]: https://github.com/giantswarm/dashboards/compare/v3.2.0...v3.2.1
[3.2.0]: https://github.com/giantswarm/dashboards/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/giantswarm/dashboards/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/giantswarm/dashboards/compare/v2.47.0...v3.0.0
[2.47.0]: https://github.com/giantswarm/dashboards/compare/v2.46.0...v2.47.0
[2.46.0]: https://github.com/giantswarm/dashboards/compare/v2.45.0...v2.46.0
[2.45.0]: https://github.com/giantswarm/dashboards/compare/v2.44.0...v2.45.0
[2.44.0]: https://github.com/giantswarm/dashboards/compare/v2.43.0...v2.44.0
[2.43.0]: https://github.com/giantswarm/dashboards/compare/v2.42.0...v2.43.0
[2.42.0]: https://github.com/giantswarm/dashboards/compare/v2.41.0...v2.42.0
[2.41.0]: https://github.com/giantswarm/dashboards/compare/v2.40.0...v2.41.0
[2.40.0]: https://github.com/giantswarm/dashboards/compare/v2.39.0...v2.40.0
[2.39.0]: https://github.com/giantswarm/dashboards/compare/v2.38.0...v2.39.0
[2.38.0]: https://github.com/giantswarm/dashboards/compare/v2.37.0...v2.38.0
[2.37.0]: https://github.com/giantswarm/dashboards/compare/v2.36.0...v2.37.0
[2.36.0]: https://github.com/giantswarm/dashboards/compare/v2.35.0...v2.36.0
[2.35.0]: https://github.com/giantswarm/dashboards/compare/v2.34.0...v2.35.0
[2.34.0]: https://github.com/giantswarm/dashboards/compare/v2.33.0...v2.34.0
[2.33.0]: https://github.com/giantswarm/dashboards/compare/v2.32.1...v2.33.0
[2.32.1]: https://github.com/giantswarm/dashboards/compare/v2.32.0...v2.32.1
[2.32.0]: https://github.com/giantswarm/dashboards/compare/v2.31.2...v2.32.0
[2.31.2]: https://github.com/giantswarm/dashboards/compare/v2.31.1...v2.31.2
[2.31.1]: https://github.com/giantswarm/dashboards/compare/v2.31.0...v2.31.1
[2.31.0]: https://github.com/giantswarm/dashboards/compare/v2.30.0...v2.31.0
[2.30.0]: https://github.com/giantswarm/dashboards/compare/v2.29.0...v2.30.0
[2.29.0]: https://github.com/giantswarm/dashboards/compare/v2.28.4...v2.29.0
[2.28.4]: https://github.com/giantswarm/dashboards/compare/v2.28.3...v2.28.4
[2.28.3]: https://github.com/giantswarm/dashboards/compare/v2.28.2...v2.28.3
[2.28.2]: https://github.com/giantswarm/dashboards/compare/v2.28.1...v2.28.2
[2.28.1]: https://github.com/giantswarm/dashboards/compare/v2.28.0...v2.28.1
[2.28.0]: https://github.com/giantswarm/dashboards/compare/v2.27.0...v2.28.0
[2.27.0]: https://github.com/giantswarm/dashboards/compare/v2.26.0...v2.27.0
[2.26.0]: https://github.com/giantswarm/dashboards/compare/v2.25.0...v2.26.0
[2.25.0]: https://github.com/giantswarm/dashboards/compare/v2.24.1...v2.25.0
[2.24.1]: https://github.com/giantswarm/dashboards/compare/v2.24.0...v2.24.1
[2.24.0]: https://github.com/giantswarm/dashboards/compare/v2.23.0...v2.24.0
[2.23.0]: https://github.com/giantswarm/dashboards/compare/v2.22.0...v2.23.0
[2.22.0]: https://github.com/giantswarm/dashboards/compare/v2.21.0...v2.22.0
[2.21.0]: https://github.com/giantswarm/dashboards/compare/v2.20.0...v2.21.0
[2.20.0]: https://github.com/giantswarm/dashboards/compare/v2.19.3...v2.20.0
[2.19.3]: https://github.com/giantswarm/dashboards/compare/v2.19.2...v2.19.3
[2.19.2]: https://github.com/giantswarm/dashboards/compare/v2.19.1...v2.19.2
[2.19.1]: https://github.com/giantswarm/dashboards/compare/v2.19.0...v2.19.1
[2.19.0]: https://github.com/giantswarm/dashboards/compare/v2.18.0...v2.19.0
[2.18.0]: https://github.com/giantswarm/dashboards/compare/v2.17.0...v2.18.0
[2.17.0]: https://github.com/giantswarm/dashboards/compare/v2.16.0...v2.17.0
[2.16.0]: https://github.com/giantswarm/dashboards/compare/v2.15.0...v2.16.0
[2.15.0]: https://github.com/giantswarm/dashboards/compare/v2.14.0...v2.15.0
[2.14.0]: https://github.com/giantswarm/dashboards/compare/v2.13.3...v2.14.0
[2.13.3]: https://github.com/giantswarm/dashboards/compare/v2.13.2...v2.13.3
[2.13.2]: https://github.com/giantswarm/dashboards/compare/v2.13.1...v2.13.2
[2.13.1]: https://github.com/giantswarm/dashboards/compare/v2.13.0...v2.13.1
[2.13.0]: https://github.com/giantswarm/dashboards/compare/v2.12.1...v2.13.0
[2.12.1]: https://github.com/giantswarm/dashboards/compare/v2.12.0...v2.12.1
[2.12.0]: https://github.com/giantswarm/dashboards/compare/v2.11.2...v2.12.0
[2.11.2]: https://github.com/giantswarm/dashboards/compare/v2.11.1...v2.11.2
[2.11.1]: https://github.com/giantswarm/dashboards/compare/v2.11.0...v2.11.1
[2.11.0]: https://github.com/giantswarm/dashboards/compare/v2.10.0...v2.11.0
[2.10.0]: https://github.com/giantswarm/dashboards/compare/v2.9.2...v2.10.0
[2.9.2]: https://github.com/giantswarm/dashboards/compare/v2.9.1...v2.9.2
[2.9.1]: https://github.com/giantswarm/dashboards/compare/v2.9.0...v2.9.1
[2.9.0]: https://github.com/giantswarm/dashboards/compare/v2.8.0...v2.9.0
[2.8.0]: https://github.com/giantswarm/dashboards/compare/v2.7.0...v2.8.0
[2.7.0]: https://github.com/giantswarm/dashboards/compare/v2.6.0...v2.7.0
[2.6.0]: https://github.com/giantswarm/dashboards/compare/v2.5.0...v2.6.0
[2.5.0]: https://github.com/giantswarm/dashboards/compare/v2.4.2...v2.5.0
[2.4.2]: https://github.com/giantswarm/dashboards/compare/v2.4.1...v2.4.2
[2.4.1]: https://github.com/giantswarm/dashboards/compare/v2.4.0...v2.4.1
[2.4.0]: https://github.com/giantswarm/dashboards/compare/v2.3.0...v2.4.0
[2.3.0]: https://github.com/giantswarm/dashboards/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/giantswarm/dashboards/compare/v2.1.1...v2.2.0
[2.1.1]: https://github.com/giantswarm/dashboards/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/giantswarm/dashboards/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/giantswarm/dashboards/compare/v1.11.0...v2.0.0
[1.11.0]: https://github.com/giantswarm/dashboards/compare/v1.10.2...v1.11.0
[1.10.2]: https://github.com/giantswarm/dashboards/compare/v1.10.1...v1.10.2
[1.10.1]: https://github.com/giantswarm/dashboards/compare/v1.10.0...v1.10.1
[1.10.0]: https://github.com/giantswarm/dashboards/compare/v1.9.1...v1.10.0
[1.9.1]: https://github.com/giantswarm/dashboards/compare/v1.9.0...v1.9.1
[1.9.0]: https://github.com/giantswarm/dashboards/compare/v1.8.1...v1.9.0
[1.8.1]: https://github.com/giantswarm/dashboards/compare/v1.8.0...v1.8.1
[1.8.0]: https://github.com/giantswarm/dashboards/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/giantswarm/dashboards/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/giantswarm/dashboards/compare/v1.5.1...v1.6.0
[1.5.1]: https://github.com/giantswarm/dashboards/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/giantswarm/dashboards/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/giantswarm/dashboards/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/giantswarm/dashboards/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/giantswarm/dashboards/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/giantswarm/dashboards/compare/v1.0.5...v1.1.0
[1.0.5]: https://github.com/giantswarm/dashboards/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/giantswarm/dashboards/compare/v0.1.3...v1.0.4
[0.1.3]: https://github.com/giantswarm/dashboards/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/giantswarm/dashboards/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/giantswarm/dashboards/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/dashboards/releases/tag/v0.1.0
