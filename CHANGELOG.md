# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.9.0] - 2022-05-18

### Added

- Add new dashboard 'Webhook Health'.

## Changed

- Fixes and updates to `grafana` dashboard.

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

[Unreleased]: https://github.com/giantswarm/dashboards/compare/v2.9.0...HEAD
[2.9.0]: https://github.com/giantswarm/dashboards/compare/v2.7.0...v2.9.0
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
