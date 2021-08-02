local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

dashboard.new(
  'KVM Machine Usage 3',
  uid='kvm-machine-usage3',
  schemaVersion=16,
  tags=['kvm'],
)
