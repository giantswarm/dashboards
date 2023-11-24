# Intro

Dashboards were grabbed from https://github.com/grafana/loki/tree/main/production/loki-mixin-compiled-ssd/dashboards / tag: `helm-loki-5.26.0`
then tuned to fit our metrics.

## Changes

Most of the changes were these:

* Add cluster_id variable for filtering
  add:
  ```
            {
               "datasource": "$datasource",
               "hide": 0,
               "includeAll": false,
               "label": "Kube cluster",
               "multi": false,
               "name": "cluster_id",
               "options": [ ],
               "query": "label_values(loki_build_info, cluster_id)",
               "refresh": 1,
               "regex": "",
               "sort": 2,
               "tagValuesQuery": "",
               "tags": [ ],
               "tagsQuery": "",
               "type": "query",
               "useTags": false
            },
  ```
* update all `"expr":` statements with `cluster_id=\"$cluster_id\", ` (except metrics from recording rules for now)
* change UID
* non-loki metrics: remove `cluster` filtering
* Logs: update job name, and add `component` filtering
* loki-deletion logs: add `loki_datasource` datasource:
    ```
            {
               "hide": 0,
               "label": null,
               "name": "loki_datasource",
               "options": [ ],
               "query": "loki",
               "refresh": 1,
               "regex": "",
               "type": "datasource"
            },
    ```

## Notes on specific files:
* loki-chunks.json - ok
* loki-deletion.json - ok
* loki-logs - ok
* loki-mixin-recording-rules - requires `loki_ruler_wal_.*` metrics, which we don't have.
* loki-operational - ok
* loki-read - ok - no boltdb-shipper data, because it's in `write`
* loki-read-resources - ok, but no disk data (because not sts?)
* loki-writes - ok
* loki-writes-resources - ok, but no disk data

## Diffs

Generating diffs, for future reference
```
LOKI_GIT="/home/herve/github/loki"
DASHBOARDS="/home/herve/github/giantswarm/dashboards/helm/dashboards/dashboards/shared/private"
mkdir -p diffs
for dashboard in "$LOKI_GIT"/production/loki-mixin-compiled-ssd/dashboards/*.json; do diff "$dashboard" "$DASHBOARDS"/"$(basename "$dashboard")" > diffs/"$(basename "$dashboard")".diff; done
```

# Extra changes

There's been some extra changes done interactively with Grafana UI.

## Loki Overview

* Added a `Backend Path` panel
* Added `disk usage` to Write and Backend path panel
* Added `total pods` to Write, Read and Backend panels
