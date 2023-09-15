local grafana = import 'grafonnet/grafana.libsonnet';
local stdlib = import 'stdlib.jsonnet';

stdlib.dashboard(
  'Metrics',
  'metrics',
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
  grafana.statPanel.new(
    title='Number of Time Series In Prometheus (Total)',
    transparent=true,
    reducerFunction='lastNotNull',
  )
  .addThreshold(
    {
      color: 'super-light-orange',
      value: 0,
    }
  )
  .addTarget(
    grafana.prometheus.target(
      expr='sum(prometheus_tsdb_head_series{customer=~"$customer", installation=~"$management_cluster"})',
      legendFormat='Time Series',
    )
  ),
  gridPos={x: 0, y: 0, w: 8, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Number of Time Series In Prometheus (Per Installation)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", installation=~"$management_cluster"}) by (installation)',
    '{{installation}}',
  ),
  gridPos={x: 8, y: 0, w: 8, h: 9}
)
.addPanel(
  stdlib.multiSeriesChart(
    'Number of Time Series In Prometheus (Per Customer)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", installation=~"$management_cluster"}) by (customer)',
    '{{customer}}',
  ),
  gridPos={x: 16, y: 0, w: 8, h: 9}
)

.addPanel(
  stdlib.multiSeriesChart(
    'Number of Time Series In Prometheus (Per Cluster)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", installation=~"$management_cluster", cluster_id=~".*"}) by (cluster_id)',
    '{{cluster_id}}',
  ),
  gridPos={x: 0, y: 9, w: 8, h: 9}
)
.addPanel(
  stdlib.multiSeriesChart(
    'Memory Usage Of Prometheus (Per Cluster)',
    'aggregation:prometheus:memory_usage{customer=~"$customer", installation=~"$management_cluster", cluster_id=~".*"}',
    '{{installation}} - {{cluster_id}}',
    format='decbytes',
  ),
  gridPos={x: 8, y: 9, w: 8, h: 9}
)
.addPanel(
  stdlib.multiSeriesChart(
    'Percentage Of Node Memory (Per Cluster)',
    'aggregation:prometheus:memory_percentage{customer=~"$customer", installation=~"$management_cluster", cluster_id=~".*"}',
    '{{installation}} - {{cluster_id}}',
    format='percent',
  ),
  gridPos={x: 16, y: 9, w: 8, h: 9}
)

.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Time Series (Per Installation)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", installation=~"$management_cluster"}) by (installation) / scalar(sum(prometheus_tsdb_head_series{installation!=""}))',
    '{{installation}}',
  ),
  gridPos={x: 0, y: 18, w: 8, h: 9}
)
.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Time Series (Per Customer)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", installation=~"$management_cluster"}) by (customer) / scalar(sum(prometheus_tsdb_head_series{customer!=""}))',
    '{{installation}}',
  ),
  gridPos={x: 8, y: 18, w: 8, h: 9}
)
.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Memory (Per Installation)',
    'sum(aggregation:prometheus:memory_usage{customer=~"$customer", installation=~"$management_cluster"}) by (installation) / scalar(sum(aggregation:prometheus:memory_usage{installation!=""}))',
    '{{installation}}',
  ),
  gridPos={x: 16, y: 18, w: 8, h: 9}
)
