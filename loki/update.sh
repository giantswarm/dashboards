#!/bin/bash

# Update Loki mixins from upstream
#

set -e

TAG="helm-loki-5.47.2"

tmpDir="$(mktemp -d)"

git clone --depth 1 --single-branch -b "$TAG" --no-tags -q git@github.com:grafana/loki.git "$tmpDir"

ls -l "$tmpDir"/production/loki-mixin-compiled-ssd/dashboards

rm -rf ./output
mkdir -p ./output

for file in "$tmpDir"/production/loki-mixin-compiled-ssd/dashboards/*; do
  # Process each file here
  echo "$file"
  
  # replaces cluster with cluster_id in queries and  expr, then adds loki- prefix to uid
  jq '.uid = "loki-" + .uid | .templating.list[].query |= gsub(", cluster\\)"; ", cluster_id)") | .templating.list[].query |= gsub("cluster=~\\\"\\$cluster\\\""; "cluster_id=~\"$cluster_id\"") | .templating.list[].query |= gsub("cluster=\\\"\\$cluster\\\""; "cluster_id=\"$cluster_id\"") | .rows[].panels[].targets[].expr |= gsub("cluster=~\\\"\\$cluster\\\""; "cluster_id=~\"$cluster_id\"") | .rows[].panels[].targets[].expr |= gsub("cluster=\\\"\\$cluster\\\""; "cluster_id=\"$cluster_id\"") | .tags |= ["owner:team-atlas", "topic:observability", "component:loki"] | .links[].tags |= ["owner:team-atlas", "topic:observability", "component:loki"]' "$file" > "./output/$(basename "$file")"

done

cp ./output/* helm/dashboards/charts/private_dashboards_al/dashboards/shared/private


