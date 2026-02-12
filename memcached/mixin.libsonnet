(import 'memcached-mixin/mixin.libsonnet') + {
  _config+:: {
    // tags not included (yet)
    tags: [
      'owner:team-atlas',
      'topic:observability',
      'mixin',
    ],
    clusterLabel: 'cluster_id',
  },
}
