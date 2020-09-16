local grafana = import 'grafonnet/grafana.libsonnet';
local stdlib = import 'stdlib.jsonnet';

grafana.dashboard.new(
  'Metrics',
  schemaVersion=16,
  tags=['atlas'],
  time_from='now-7d',
  uid='metrics',
)

.addTemplate(
  stdlib.variable('customer', 'Customer', 'label_values(prometheus_tsdb_head_series, customer)')
)
.addTemplate(
  stdlib.variable('control_plane', 'Control Plane', 'label_values(prometheus_tsdb_head_series{customer=~"$customer"}, installation)')
)

.addPanel(
  stdlib.singleSeriesChart(
    'Number of Time Series In Prometheus (Total)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$control_plane"})',
    'Time Series',
  ),
  gridPos={x: 0, y: 0, h: 8},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Number of Time Series In Prometheus (Per Control Plane)',
    'sum(avg(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$control_plane"}) by (customer, cluster_id)) by (cluster_id)',
    '{{cluster_id}}',
  ),
  gridPos={x: 6, y: 0, h: 8}
)
.addPanel(
  stdlib.multiSeriesChart(
    'Number of Time Series In Prometheus (Per Customer)',
    'sum(avg(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$control_plane"}) by (customer, cluster_id)) by (customer)',
    '{{customer}}',
  ),
  gridPos={x: 12, y: 0, h: 8}
)

.addPanel(
  stdlib.singleSeriesChart(
    'Memory Usage Of Prometheus (Total)',
    'sum(aggregation:prometheus:memory_usage{customer=~"$customer", cluster_id=~"$control_plane"})',
    'Memory',
    format='decbytes',
  ),
  gridPos={x: 0, y: 8, h: 8},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Memory Usage Of Prometheus (Per Control Plane)',
    'aggregation:prometheus:memory_usage{customer=~"$customer", cluster_id=~"$control_plane"}',
    '{{cluster_id}}',
    format='decbytes',
  ),
  gridPos={x: 6, y: 8, h: 8}
)
.addPanel(
  stdlib.multiSeriesChart(
    'Percentage Of Node Memory (Per Control Plane)',
    'aggregation:prometheus:memory_percentage{customer=~"$customer", cluster_id=~"$control_plane"}',
    '{{cluster_id}}',
    format='percent',
  ),
  gridPos={x: 12, y: 8, h: 8}
)

.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Time Series (Per Control Plane)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$control_plane"}) by (cluster_id) / scalar(sum(prometheus_tsdb_head_series{cluster_id!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 0, y: 16, h: 8}
)
.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Time Series (Per Customer)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$control_plane"}) by (customer) / scalar(sum(prometheus_tsdb_head_series{customer!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 6, y: 16, h: 8}
)
.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Memory (Per Control Plane)',
    'sum(aggregation:prometheus:memory_usage{customer=~"$customer", cluster_id=~"$control_plane"}) by (cluster_id) / scalar(sum(aggregation:prometheus:memory_usage{cluster_id!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 12, y: 16, h: 8}
)
