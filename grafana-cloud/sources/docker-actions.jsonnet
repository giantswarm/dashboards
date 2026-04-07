local grafana = import 'grafonnet/grafana.libsonnet';
local stdlib = import 'stdlib.jsonnet';

stdlib.dashboard(
  'Docker Actions',
  'docker-actions',
  ['owner:team-honeybadger'],
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
    'Number of Docker Pulls (Total)',
    'sum(aggregation:docker:action_count{customer=~"$customer", installation=~"$management_cluster", action="pull"})',
    'Pulls',
  ),
  gridPos={x: 0, y: 0, w: 12, h: 9},
)
.addPanel(
  stdlib.singleSeriesChart(
    'Rate of Docker Pulls (Total)',
    'sum(rate(aggregation:docker:action_count{customer=~"$customer", installation=~"$management_cluster", action="pull"}[24h]))',
    'Pulls',
  ),
  gridPos={x: 12, y: 0, w: 12, h: 9},
)

.addPanel(
  stdlib.multiSeriesChart(
    'Number of Docker Pulls Per Customer',
    'sum(aggregation:docker:action_count{customer=~"$customer", installation=~"$management_cluster", action="pull"}) by (customer)',
    '{{customer}}',
  ),
  gridPos={x: 0, y: 9, w: 8, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Number of Docker Pulls Per Installation',
    'sum(aggregation:docker:action_count{customer=~"$customer", installation=~"$management_cluster", action="pull"}) by (installation)',
    '{{installation}}',
  ),
  gridPos={x: 8, y: 9, w: 8, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Number of Docker Pulls Per Cluster',
    'aggregation:docker:action_count{customer=~"$customer", installation=~"$management_cluster", action="pull"}',
    '{{installation}} - {{cluster_id}}',
  ),
  gridPos={x: 16, y: 9, w: 8, h: 9},
)

.addPanel(
  stdlib.multiSeriesChart(
    'Average Number of Docker Pulls Per Node',
    'sum(aggregation:docker:action_count{customer=~"$customer", installation=~"$management_cluster", action="pull"}) by (installation, cluster_id) / sum(aggregation:kubernetes:node_total{customer=~"$customer", installation=~"$management_cluster"}) by (installation, cluster_id)',
    '{{installation}} - {{cluster_id}}',
  ),
  gridPos={x: 0, y: 9, w: 8, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Average Rate of Docker Pulls Per Node',
    'sum(rate(aggregation:docker:action_count{customer=~"$customer", installation=~"$management_cluster", action="pull"}[24h])) by (installation, cluster_id) / sum(aggregation:kubernetes:node_total{customer=~"$customer", installation=~"$management_cluster"}) by (installation, cluster_id)',
    '{{installation}} - {{cluster_id}}',
  ),
  gridPos={x: 8, y: 9, w: 8, h: 9},
)
