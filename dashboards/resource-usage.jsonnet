local grafana = import 'grafonnet/grafana.libsonnet';
local stdlib = import 'stdlib.jsonnet';

stdlib.dashboard(
  'Resource Usage REMIX',
  'resource-usage',
  ['atlas'],
  time_from='now-1M',
)

.addTemplates([
  stdlib.variable('pipeline', 'Pipeline', 'label_values(aggregation:node:cpu_cores_total, pipeline)', current='stable'),
  stdlib.variable('provider', 'Provider', 'label_values(aggregation:node:cpu_cores_total, provider)'),
  stdlib.variable('customer', 'Customer', 'label_values(aggregation:node:cpu_cores_total, customer)'),
  stdlib.variable('installation', 'Installation', 'label_values(aggregation:node:cpu_cores_total, installation)'),
])

.addPanel(
  stdlib.singleSeriesChart(
    'Usage Packs',
    'ceil(
      (
        (
          sum(
            aggregation:node:memory_memtotal_bytes_total{
              cluster_type="tenant_cluster",
              pipeline=~"$pipeline",
              provider=~"$provider",
              customer=~"$customer",
              installation=~"$installation",
            }
          )
          OR
          on() vector(0)
        )
        /
        274877766206    // 256GB (how? show calculation)
      )
      >
      (
        (
          sum(
            aggregation:node:cpu_cores_total{
              cluster_type="tenant_cluster",
              pipeline=~"$pipeline",
              provider=~"$provider",
              customer=~"$customer",
              installation=~"$installation",
            }
          )
          OR
          on() vector(0)
        )
        /
        64
      )
      or
      (
        (
          sum(
            aggregation:node:cpu_cores_total{
              cluster_type="tenant_cluster",
              pipeline=~"$pipeline",
              provider=~"$provider",
              customer=~"$customer",
              installation=~"$installation",
            }
          )
          OR
          on() vector(0)
        )
        /
        64
      )
    )',
    'Usage Packs',
  ),
  gridPos={x: 0, y: 0, w: 12, h: 9},
)
.addPanel(
  stdlib.multiSeriesChart(
    'Usage Packs By Region',
    'sum(
      aggregation:node:memory_memtotal_bytes_total{
        cluster_type="tenant_cluster",
        pipeline=~"$pipeline",
        provider=~"$provider",
        customer=~"$customer",
        installation=~"$installation"
      }
      /
      274877766206
    ) by (region)
    >
    sum(
      aggregation:node:cpu_cores_total{
        cluster_type="tenant_cluster",
        pipeline=~"$pipeline",
        provider=~"$provider",
        customer=~"$customer",
        installation=~"$installation"
      }
      /
      64
    ) by (region)
    or
    sum(
      aggregation:node:cpu_cores_total{
        cluster_type="tenant_cluster",
        pipeline=~"$pipeline",
        provider=~"$provider",
        customer=~"$customer",
        installation=~"$installation"
      }
      /
      64
    ) by (region)',
    '{{region}}',
  ),
  gridPos={x: 12, y: 0, w: 12, h: 9}
)