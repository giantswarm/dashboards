#!/bin/bash

# Update Alloy mixin dashboards
#
# This script updates the Alloy mixin dashboards from the upstream repository.
#
# Usage:
#   ./update-alloy-mixin.sh

set -eu

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE}") && pwd -P)
TOOLS_DIR="$SCRIPT_DIR/../tools"
TMPDIR="$(mktemp -d -t giantswarm-dashboards-XXXXXX)"
trap "rm -rf $TMPDIR" EXIT

alloy_mixin_dir="$TMPDIR/alloy/operations/alloy-mixin"
helm_dir="$SCRIPT_DIR/../helm/dashboards/charts/private_dashboards_al/dashboards/shared/private"

set -x
git clone https://github.com/grafana/alloy.git --depth 1 "$TMPDIR/alloy"
cd "$alloy_mixin_dir"
"$TOOLS_DIR/jb" install
mixtool generate dashboards mixin.libsonnet -d "$helm_dir"
