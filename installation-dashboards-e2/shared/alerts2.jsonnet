local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

{
  grafanaDashboardFolder:: 'shared',
  grafanaDashboards+:: {
    'alerts2.json': dashboard.new(
      'Alerts2',
      uid='alerts2',
      schemaVersion=16,
      tags=['alerts'],
    )
  },
}
