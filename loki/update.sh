#!/bin/bash

# Update Loki mixins from upstream
#
# This script is used to update the Loki mixins from the upstream repository.
#
# Usage:
#  ./loki/update.sh from the root of the repository

set -e

BRANCH="main"
BRANCH="fix-cluster-id-label-in-mixins"
MIXIN_URL=https://github.com/grafana/loki/production/loki-mixin@$BRANCH
MIXIN_URL=https://github.com/QuentinBisson/loki-upstream/production/loki-mixin@$BRANCH
helmDir="$(pwd)/helm/dashboards/charts/private_dashboards_al/dashboards/shared/private"

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

  echo "Copying dashboard to $helmDir"
  cp "$file" "$helmDir"
done
