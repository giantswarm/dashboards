# installation-dashboards-e3

This is an experiment with structuring dashboards with a bit less repetition.

This is similar to [installation-dashboards-e2](../installation-dashboards-e2/)
but instead of repeating this structure:

``` jsonnet
{
  grafanaDashboardFolder:: 'Public',
  grafanaDashboards+:: {
    'filename.json': {}
  }
}
```

in each dashboard file, we only use it in `dashboards.jsonnet` and then each
dashboard file can just define the dashboard contents, e.g.:

``` jsonnet
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

dashboard.new(
  ...
)
```

The advantage is less repetition as mentioned, the downside is that it diverges
from upstream conventions, and it's not possible to generate individual
dashboards. Instead you have to call `grr` with the index file:

``` sh
mkdir output
grr export installation-dashboards-e3/dashboards.jsonnet output/e3
```
