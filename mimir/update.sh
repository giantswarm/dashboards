#!/bin/bash

# Update Mimir mixins from upstream
#
# This script is used to update the Mimir mixins from the upstream repository.
#
# Usage:
#  ./mimir/update.sh from the root of the repository

set -e

BRANCH="main"
MIXIN_URL=https://github.com/grafana/mimir/operations/mimir-mixin@$BRANCH
helmDir="$(pwd)/helm/dashboards/charts/private_dashboards_mz/dashboards/shared/private"

cd mimir
rm -rf vendor jsonnetfile.*

jb init
jb install $MIXIN_URL
mixtool generate dashboards mixin.libsonnet --directory=dashboards_out

for file in dashboards_out/*; do
  # Process each file here
  echo "$file"
  
  echo "Copying dashboard to $helmDir"
  cp "$file" "$helmDir"
done
