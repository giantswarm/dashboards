local grafana = import 'grafonnet/grafana.libsonnet';

local singleSeriesChart(title, query, legend, format='short') =
  grafana.graphPanel.new(
    title,
    fill=0,
    format=format,
    legend_show=false,
    min=0,
  )
  .addTarget(
    grafana.prometheus.target(
      query,
      legendFormat=legend,
    )
  );

local multiSeriesChart(title, query, legend, format='short') =
  grafana.graphPanel.new(
    title,
    fill=0,
    format=format,
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
    legend_show=true,
    legend_sort="current",
    legend_sortDesc=true,
    legend_values=true,
    min=0,
    shared_tooltip=false,
  )
  .addTarget(
    grafana.prometheus.target(
      query,
      legendFormat=legend,
    )
  );

local stackedPercentageChart(title, query, legend) =
  grafana.graphPanel.new(
    title,
    fill=10,
    format='percentunit',
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
    legend_show=true,
    legend_sort="current",
    legend_sortDesc=true,
    legend_values=true,
    max=100,
    min=0,
    percentage=true,
    shared_tooltip=false,
    stack=true,
  )
  .addTarget(
    grafana.prometheus.target(
      query,
      legendFormat=legend,
    )
  );

grafana.dashboard.new(
  'Metrics',
  schemaVersion=16,
  tags=['atlas'],
  time_from='now-7d',
  uid='metrics',
)

.addPanel(
  singleSeriesChart(
    'Number of Time Series In Prometheus (Total)',
    'sum(prometheus_tsdb_head_series)',
    'Time Series',
  ),
  gridPos={x: 0, y: 0, h: 8},
)
.addPanel(
  multiSeriesChart(
    'Number of Time Series In Prometheus (Per Control Plane)',
    'sum(avg(prometheus_tsdb_head_series{customer!=""}) by (customer, cluster_id)) by (cluster_id)',
    '{{cluster_id}}',
  ),
  gridPos={x: 6, y: 0, h: 8}
)
.addPanel(
  multiSeriesChart(
    'Number of Time Series In Prometheus (Per Customer)',
    'sum(avg(prometheus_tsdb_head_series{customer!=""}) by (customer, cluster_id)) by (customer)',
    '{{customer}}',
  ),
  gridPos={x: 12, y: 0, h: 8}
)

.addPanel(
  singleSeriesChart(
    'Memory Usage Of Prometheus (Total)',
    'sum(aggregation:prometheus:memory_usage)',
    'Memory',
    format='decbytes',
  ),
  gridPos={x: 0, y: 8, h: 8},
)
.addPanel(
  multiSeriesChart(
    'Memory Usage Of Prometheus (Per Control Plane)',
    'aggregation:prometheus:memory_usage',
    '{{cluster_id}}',
    format='decbytes',
  ),
  gridPos={x: 6, y: 8, h: 8}
)
.addPanel(
  multiSeriesChart(
    'Percentage Of Node Memory (Per Control Plane)',
    'aggregation:prometheus:memory_percentage',
    '{{cluster_id}}',
    format='percent',
  ),
  gridPos={x: 12, y: 8, h: 8}
)

.addPanel(
  stackedPercentageChart(
    'Percentage Time Series (Per Control Plane)',
    'sum(prometheus_tsdb_head_series{cluster_id!=""}) by (cluster_id) / scalar(sum(prometheus_tsdb_head_series{cluster_id!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 0, y: 16, h: 8}
)
.addPanel(
  stackedPercentageChart(
    'Percentage Time Series (Per Customer)',
    'sum(prometheus_tsdb_head_series{customer!=""}) by (customer) / scalar(sum(prometheus_tsdb_head_series{customer!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 6, y: 16, h: 8}
)
.addPanel(
  stackedPercentageChart(
    'Percentage Memory (Per Control Plane)',
    'sum(aggregation:prometheus:memory_usage{cluster_id!=""}) by (cluster_id) / scalar(sum(aggregation:prometheus:memory_usage{cluster_id!=""}))',
    '{{cluster_id}}',
  ),
  gridPos={x: 12, y: 16, h: 8}
)
