#!/bin/bash

# Update memcached mixins from upstream
#
# This script is used to update the memcached mixins from the upstream repository.
#
# Usage:
#  ./scripts/update.sh from the root of the repository

set -e

BRANCH="master"
MIXIN_URL=https://github.com/grafana/jsonnet-libs/memcached-mixin@$BRANCH
helmDir="$(pwd)/helm/dashboards/charts/private_dashboards_mz/dashboards/shared/private"

set -x
mkdir -p memcached
cd memcached
rm -rf vendor jsonnetfile.* dashboards_out

jb init
jb install $MIXIN_URL
mixtool generate all mixin.libsonnet

dashboard_file="dashboards_out/memcached-overview.json"
# Set a human-readable uid for the dashboard
jq '.uid = "memcached-overview"' "$dashboard_file" > "$dashboard_file.out" && mv "$dashboard_file.out" "$dashboard_file"
# Set tags
jq '.tags = ["owner:team-atlas", "topic:observability", "mixin"]' "$dashboard_file" > "$dashboard_file.out" && mv "$dashboard_file.out" "$dashboard_file"
# Update refresh interval
jq '.refresh = "5m"' "$dashboard_file" > "$dashboard_file.out" && mv "$dashboard_file.out" "$dashboard_file"

echo "Copying dashboard to $helmDir"
cp "$dashboard_file" "$helmDir"
