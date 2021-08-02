{
  grafanaDashboardFolder:: 'Public',

  grafanaDashboards+:: {
    'alerts3.json': import 'shared/alerts3.jsonnet',
    'kvm-machine-usage3.json': import 'kvm/kvm-machine-usage3.jsonnet',
  },
}
