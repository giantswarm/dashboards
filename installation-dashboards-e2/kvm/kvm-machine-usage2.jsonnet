local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

{
  grafanaDashboardFolder:: 'shared',
  grafanaDashboards+:: {
    'kvm-machine-usage2.json': dashboard.new(
      'KVM Machine Usage 3',
      uid='kvm-machine-usage2',
      schemaVersion=16,
      tags=['alerts'],
    )
  },
}
