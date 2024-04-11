local loki = import 'loki-mixin/mixin-ssd.libsonnet';

loki{
  _config+:: {
    tags: [
      "owner:team-atlas",
      "topic:observability",
      "component:loki"
    ],

    per_cluster_label: 'cluster_id',

    canary+: {
      enabled: true,
    },
  },
}
