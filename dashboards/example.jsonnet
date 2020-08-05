local grafana = import 'grafonnet/grafana.libsonnet';

grafana.dashboard.new(
  'Grafonnet Example',
  uid='grafonnet-example',
  tags=['example'],
  schemaVersion=16,
)
.addPanel(
  grafana.graphPanel.new(
    'Prometheus Head Series',
    format='short',
    fill=0,
    min=0,
    legend_values=true,
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
  )
  .addTarget(
    grafana.prometheus.target(
      'prometheus_tsdb_head_series',
      datasource='Cortex',
    )
  ), gridPos={
    x: 0,
    y: 0,
    w: 24,
    h: 24,
  }
)
