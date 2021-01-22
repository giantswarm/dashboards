local grafana = import 'grafonnet/grafana.libsonnet';
local stdlib = import 'stdlib.jsonnet';

stdlib.dashboard(
  'Metrics',
  'metrics',
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
  stdlib.singleSeriesChart(
    'Number of Time Series In Prometheus (Total)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$management_cluster"})',
    'Time Series',
  ),
  gridPos={x: 0, y: 0, w: 8, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Number of Time Series In Prometheus (Per Management Cluster)',
    'sum(avg(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$management_cluster"}) by (customer, cluster_id)) by (cluster_id)',
    '{{cluster_id}}',
  ),
  gridPos={x: 8, y: 0, w: 8, h: 9}
)
.addPanel(
  stdlib.multiSeriesChart(
    'Number of Time Series In Prometheus (Per Customer)',
    'sum(avg(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$management_cluster"}) by (customer, cluster_id)) by (customer)',
    '{{customer}}',
  ),
  gridPos={x: 16, y: 0, w: 8, h: 9}
)

.addPanel(
  stdlib.singleSeriesChart(
    'Memory Usage Of Prometheus (Total)',
    'sum(aggregation:prometheus:memory_usage{customer=~"$customer", cluster_id=~"$management_cluster"})',
    'Memory',
    format='decbytes',
  ),
  gridPos={x: 0, y: 9, w: 8, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Memory Usage Of Prometheus (Per Management Cluster)',
    'aggregation:prometheus:memory_usage{customer=~"$customer", cluster_id=~"$management_cluster"}',
    '{{cluster_id}}',
    format='decbytes',
  ),
  gridPos={x: 8, y: 9, w: 8, h: 9}
)
.addPanel(
  stdlib.multiSeriesChart(
    'Percentage Of Node Memory (Per Management Cluster)',
    'aggregation:prometheus:memory_percentage{customer=~"$customer", cluster_id=~"$management_cluster"}',
    '{{cluster_id}}',
    format='percent',
  ),
  gridPos={x: 16, y: 9, w: 8, h: 9}
)

.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Time Series (Per Management Cluster)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$management_cluster"}) by (cluster_id) / scalar(sum(prometheus_tsdb_head_series{cluster_id!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 0, y: 18, w: 8, h: 9}
)
.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Time Series (Per Customer)',
    'sum(prometheus_tsdb_head_series{customer=~"$customer", cluster_id=~"$management_cluster"}) by (customer) / scalar(sum(prometheus_tsdb_head_series{customer!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 8, y: 18, w: 8, h: 9}
)
.addPanel(
  stdlib.stackedPercentageChart(
    'Percentage Memory (Per Management Cluster)',
    'sum(aggregation:prometheus:memory_usage{customer=~"$customer", cluster_id=~"$management_cluster"}) by (cluster_id) / scalar(sum(aggregation:prometheus:memory_usage{cluster_id!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 16, y: 18, w: 8, h: 9}
)
