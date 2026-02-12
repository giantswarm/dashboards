(import 'memcached-mixin/mixin.libsonnet') + {
  _config+:: {
    // tags not included (yet)
    tags: [
      'owner:team-atlas',
      'topic:observability',
      'component:loki',
    ],
    clusterLabel: 'cluster_id',
  },
}
