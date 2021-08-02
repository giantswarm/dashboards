local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

dashboard.new(
  'Alerts3',
  uid='alerts3',
  schemaVersion=16,
  tags=['alerts'],
)
