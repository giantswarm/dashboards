#!/bin/bash

# Update Loki mixins from upstream
#
# This script is used to update the Loki mixins from the upstream repository.
#
# Usage:
#  ./loki/update.sh from the root of the repository

set -e

BRANCH="main"
MIXIN_URL=https://github.com/grafana/loki/production/loki-mixin@$BRANCH
helmDir="$(pwd)/helm/dashboards/charts/private_dashboards_al/dashboards/shared/private"

set -x
cd loki
rm -rf vendor jsonnetfile.*

jb init
jb install $MIXIN_URL
mixtool generate all mixin.libsonnet

for file in dashboards_out/*; do
  # Process each file here
  echo "$file"
  
  if [[ $(basename "$file") == "loki-canary.json" ]]; then
    # adds missing uid
    jq '.uid = "loki-canary"' "$file" > "$file.out" && mv "$file.out" "$file"
  else
    # adds loki- prefix to uid
    jq '.uid = "loki-" + .uid' "$file" > "$file.out" && mv "$file.out" "$file"
  fi

  ## Needed to fix the log panels as we are using a different label to differentiate loki components
  if [[ $(basename "$file") == "loki-retention.json" ]]; then
    # shellcheck disable=SC2016
    sed -i 's/"{cluster_id=~\\"$cluster\\", job=~\\"($namespace)\/(loki.*|enterprise-logs)-backend\\"}"/"{cluster_id=~\\"$cluster\\", job=~\\"($namespace)\/loki\\", component=\\"backend\\"}"/g' "$file"
  elif [[ $(basename "$file") == "loki-operational.json" ]]; then
    # shellcheck disable=SC2016
    sed -i 's/{cluster_id=\\"$cluster\\", namespace=\\"$namespace\\", job=~\\"($namespace)\/(loki.*|enterprise-logs)-backend\\"} |/{cluster_id=\\"$cluster\\", namespace=\\"$namespace\\", job=~\\"($namespace)\/loki\\", component=\\"backend\\"} |/g' "$file"
    # shellcheck disable=SC2016
    sed -i 's/{cluster_id=\\"$cluster\\", namespace=\\"$namespace\\", job=~\\"($namespace)\/(loki.*|enterprise-logs)-read\\"} |/{cluster_id=\\"$cluster\\", namespace=\\"$namespace\\", job=~\\"($namespace)\/loki\\", component=\\"read\\"} |/g' "$file"
    # shellcheck disable=SC2016
    sed -i 's/{cluster_id=\\"$cluster\\", namespace=\\"$namespace\\", job=~\\"($namespace)\/(loki.*|enterprise-logs)-write\\"} |/{cluster_id=\\"$cluster\\", namespace=\\"$namespace\\", job=~\\"($namespace)\/loki\\", component=\\"write\\"} |/g' "$file"
  fi

  echo "Copying dashboard to $helmDir"
  cp "$file" "$helmDir"

done
