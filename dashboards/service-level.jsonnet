local grafana = import 'grafonnet/grafana.libsonnet';
local stdlib = import 'stdlib.jsonnet';

local burnRateChart(title, queries, threshold) =
  grafana.graphPanel.new(
    title,
    fill=0,
    format='short',
    legend_current=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
    legend_show=true,
    legend_sort='current',
    legend_sortDesc=true,
    legend_values=true,
    min=0,
    shared_tooltip=false,
    thresholds=[],
  )
  .addTargets(
    [grafana.prometheus.target(q.query, legendFormat=q.legend) for q in queries],
  );

stdlib.dashboard(
  'Service Level',
  'service-level',
  ['atlas'],
)

.addTemplates([
    stdlib.variable('pipeline', 'Pipeline', 'label_values(slo_requests, pipeline)', current='stable'),
    stdlib.variable('service', 'Service', 'label_values(slo_requests{pipeline=~"$pipeline"}, service)'),
    stdlib.variable('customer', 'Customer', 'label_values(slo_requests{pipeline=~"$pipeline"}, customer)'),
    stdlib.variable('installation', 'Installation', 'label_values(slo_requests{pipeline=~"$pipeline", customer=~"$customer"}, installation)'),
    stdlib.variable('cluster_id', 'Cluster ID', 'label_values(slo_requests{pipeline=~"$pipeline", installation=~"$installation", customer=~"$customer"}, cluster_id)'),
])

.addPanel(
  grafana.tablePanel.new(
    title='Currently Alerting Services',
    styles=null,    # https://github.com/grafana/grafonnet-lib/issues/240
  )
  .addTarget(
    grafana.prometheus.target(
      'sum(slo_errors_per_request:ratio_rate1h{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"} > 36 * 0.001
      and
      slo_errors_per_request:ratio_rate5m{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"} > 36 * 0.001
      or
      slo_errors_per_request:ratio_rate6h{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"} > 12 * 0.001
      and
      slo_errors_per_request:ratio_rate30m{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"} > 12 * 0.001) by (cluster_id, customer, installation, service)',
      format='table',
      instant=true,
    )
  ) + {
    transformations: [{
      id: "organize",
      options: {
        excludeByName: {
          Time: true,
          Value: true,
        },
        indexByName: {
          "Time": 0,
          "service": 1,
          "customer": 2,
          "installation": 3,
          "cluster_id": 4,
          "Value": 5,
        },
        renameByName: {
          "Value": "",
          "cluster_id": "Cluster ID",
          "customer": "Customer",
          "installation": "Installation",
          "service": "Service",
        }
      }
    }],
  },
  gridPos={x: 0, y: 0, w: 12, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Alert',
    'sum(slo_errors_per_request:ratio_rate1h{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"} > 36 * 0.001
    and
    slo_errors_per_request:ratio_rate5m{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"} > 36 * 0.001
    or
    slo_errors_per_request:ratio_rate6h{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"} > 12 * 0.001
    and
    slo_errors_per_request:ratio_rate30m{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"} > 12 * 0.001) by (service, installation, cluster_id)',
    '{{service}} / {{installation}} / {{cluster_id}}',
    format='none',
  ),
  gridPos={x: 12, y: 0, w: 12, h: 9},
)

.addPanel(
  stdlib.multiSeriesChart(
    'Requests',
    'slo_requests{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"}',
    '{{service}} / {{installation}} / {{cluster_id}}',
    format='none',
  ),
  gridPos={x:0, y: 9, w: 12, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Errors',
    'slo_errors{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"}',
    '{{service}} / {{installation}} / {{cluster_id}}',
    format='none',
  ),
  gridPos={x:12, y: 9, w: 12, h: 9},
)

.addPanel(
  burnRateChart(
    'High Burn Rate',
    [
      {
        query: 'slo_errors_per_request:ratio_rate5m{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"}',
        legend: '{{service}} / {{installation}} / {{cluster_id}} (5m)',
      },
      {
        query: 'slo_errors_per_request:ratio_rate1h{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"}',
        legend: '{{service}} / {{installation}} / {{cluster_id}} (1h)',
      },
      {
        query: 'min(slo_threshold_high{service=~"$service", installation=~"$installation", cluster_id=~"$cluster_id"}) by (service)',
        legend: 'SLO High Threshold - {{service}}',
      }
    ],
    0.036
  )
  .addSeriesOverride({alias: "/.*(5m)/", color: "#8AB8FF"})
  .addSeriesOverride({alias: "/.*(1h)/", color: "#1250B0"})
  .addSeriesOverride({alias: "/.*(SLO High Threshold)/", color: "#E02F44", linewidth: 3}),
  gridPos={x:0, y: 9, w: 12, h: 9},
)
.addPanel(
  burnRateChart(
    'Low Burn Rate',
    [
      {
        query: 'slo_errors_per_request:ratio_rate30m{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"}',
        legend: '{{service}} / {{installation}} / {{cluster_id}} (30m)',
      },
      {
        query: 'slo_errors_per_request:ratio_rate6h{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"}',
        legend: '{{service}} / {{installation}} / {{cluster_id}} (6h)',
      },
      {
        query: 'min(slo_threshold_low{service=~"$service", installation=~"$installation", cluster_id=~"$cluster_id"}) by (service)',
        legend: 'SLO Low Threshold - {{service}}',
      }
    ],
    0.012
  )
  .addSeriesOverride({alias: "/.*(30m)/", color: "#CA95E5"})
  .addSeriesOverride({alias: "/.*(6h)/", color: "#7C2EA3"})
  .addSeriesOverride({alias: "/.*(SLO Low Threshold)/", color: "#E02F44", linewidth: 3}),
  gridPos={x:12, y: 9, w: 12, h: 9},
)
.addPanel(
  grafana.gaugePanel.new(
    'SLO targets',
    min=null,
    max=null,
    pluginVersion='7.5.7',
    reducerFunction='lastNotNull',
    thresholdsMode='percentage',
    unit='percentunit'
  )
  .addThresholds([
    { color: 'red', value: 0 },
    { color: '#EAB839', value: 90 },
    { color: 'green', value: 99 },
  ])
  .addTarget(
    grafana.prometheus.target(
      '1- min(slo_target{pipeline=~"$pipeline", service=~"$service", customer=~"$customer", installation=~"$installation", cluster_id=~"$cluster_id"}) by (service)',
      legendFormat='',
    )
  ),
  gridPos={x:0, y: 27, w: 24, h: 5},
)
