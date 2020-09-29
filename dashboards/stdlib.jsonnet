local grafana = import 'grafonnet/grafana.libsonnet';

{
  dashboard(title, uid, tags, time_from='now-1h', refresh='1m', graphTooltip='shared_crosshair')::
    grafana.dashboard.new(
      title,
      graphTooltip=graphTooltip,
      schemaVersion=16,
      tags=tags,
      timezone='utc',
      time_from=time_from,
      refresh=refresh,
      uid=uid,
    ),

  singleSeriesChart(title, query, legend, format='short')::
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
    ),

  multiSeriesChart(title, query, legend, format='short')::
    grafana.graphPanel.new(
      title,
      fill=0,
      format=format,
      legend_current=true,
      legend_alignAsTable=true,
      legend_rightSide=true,
      legend_show=true,
      legend_sort='current',
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
    ),

  stackedPercentageChart(title, query, legend)::
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
    ),

  variable(name, label, query, current='null')::
    grafana.template.new(
      allValues='.*',
      current=current,
      datasource='Cortex',
      includeAll=true,
      label=label,
      name=name,
      query=query,
      refresh='load',
      sort='1',
    ),
}