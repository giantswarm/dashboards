local grafana = import 'grafonnet/grafana.libsonnet';
local stdlib = import 'stdlib.jsonnet';

stdlib.dashboard(
  'Grafana Analytics',
  'grafana-analytics',
  ['atlas'],
  time_from='now-7d',
)

.addTemplate(
  stdlib.variable('customer', 'Customer', 'label_values(prometheus_tsdb_head_series, customer)')
)
.addTemplate(
  stdlib.variable('management_cluster', 'Management Cluster', 'label_values(prometheus_tsdb_head_series{customer=~"$customer"}, installation)')
)

.addPanel(
  stdlib.multiSeriesChart(
    'Sessions by Dashboards',
    'sum by (dashboard_name) (sum_over_time(aggregation:grafana_analytics_sessions_total{customer=~"$customer", installation=~"$management_cluster"}[$__interval]))',
    '{{dashboard_name}}',
  ),
  gridPos={x: 0, y: 0, w: 12, h: 12}
)
.addPanel(
  stdlib.multiSeriesChart(
    'Sessions by Installation',
    'sum by (installation) (sum_over_time(aggregation:grafana_analytics_sessions_total{customer=~"$customer", installation=~"$management_cluster"}[$__interval]))',
    '{{installation}}',
  ),
  gridPos={x: 12, y: 0, w: 12, h: 12}
)
