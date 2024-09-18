local loki = import 'loki-mixin/mixin-ssd.libsonnet';

loki{
  _config+:: {
    tags: [
      "owner:team-atlas",
      "topic:observability",
      "component:loki"
    ],

    per_node_label: 'node',
    per_cluster_label: 'cluster_id',

    operational: {
      memcached: false,
      consul: false,
      bigTable: false,
      dynamo: false,
      gcs: false,
      s3: true,
      azureBlob: true,
      boltDB: false,
    },
  },
}
