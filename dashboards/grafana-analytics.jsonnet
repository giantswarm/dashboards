local grafana = import 'grafonnet/grafana.libsonnet';
local stdlib = import 'stdlib.jsonnet';

stdlib.dashboard(
  'Grafana Analytics',
  'grafana-analytics',
  ['owner:team-atlas'],
  time_from='now-7d',
)

.addTemplate(
  stdlib.variable('customer', 'Customer', 'label_values(prometheus_tsdb_head_series, customer)')
)
.addTemplate(
  stdlib.variable('management_cluster', 'Management Cluster', 'label_values(prometheus_tsdb_head_series{customer=~"$customer"}, installation)')
)

.addPanel(
  grafana.text.new(
    title='Notes',
    content='This dashboard reports Grafana dashboard sessions.\n\nTo generate some activity, head over to and installation Grafana dashboard.\n\nIt may take around a minute for activity to begin to show.',
    mode='markdown',
  ),
  gridPos={'x':0, 'y':0, 'w':24, 'h': 4}
)

.addPanel(
  grafana.graphPanel.new(
    title='Sessions by Dashboards',
    bars=true,
    fill=1,
    lines=false,
    maxDataPoints=40,
    pointradius=2,
    format='short',
    min=0,
  ).addTarget(
    grafana.prometheus.target(
      'sum by (dashboard_name) (sum_over_time(aggregation:grafana_analytics_sessions_total{customer=~"$customer", installation=~"$management_cluster"}[$__interval]))',
      legendFormat='{{dashboard_name}}',
    )
  ),
  gridPos={x: 0, y: 4, w: 12, h: 12}
)

.addPanel(
  grafana.graphPanel.new(
    title='Sessions by Installation',
    bars=true,
    fill=1,
    lines=false,
    maxDataPoints=40,
    pointradius=2,
    format='short',
    min=0,
  ).addTarget(
    grafana.prometheus.target(
      'sum by (installation) (sum_over_time(aggregation:grafana_analytics_sessions_total{customer=~"$customer", installation=~"$management_cluster"}[$__interval]))',
      legendFormat='{{installation}}',
    )
  ),
  gridPos={x: 12, y: 4, w: 12, h: 12}
)
