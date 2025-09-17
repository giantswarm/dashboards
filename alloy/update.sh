#!/bin/bash

# Update Alloy mixin dashboards
#
# This script updates the Alloy mixin dashboards from the upstream repository.
#
# Usage:
#   ./update.sh

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
mixtool generate dashboards mixin.libsonnet -d "$TMPDIR/dashboards"
{ set +x; } 2>/dev/null

tags="$(cat "$SCRIPT_DIR"/tags.json)"
for file in "$TMPDIR/dashboards"/*.json; do
	echo "$file"
	(
		set -x
		"$TOOLS_DIR"/yq '.tags += '"$tags"'' -i "$file"
	)
done

# Fix alloy-logs specific issues
sed -i 's/{,/{/g' "$TMPDIR"/dashboards/alloy-logs.json
sed -i 's/job/scrape_job/g' "$TMPDIR"/dashboards/alloy-logs.json

# Fix cluster selector on all dashboards
sed -i 's/cluster=/cluster_id=/g' "$TMPDIR"/dashboards/*.json
sed -i 's/\(.*label_values(.*cluster\)\().*\)/\1_id\2/g' "$TMPDIR"/dashboards/*.json

set -x
mv "$TMPDIR/dashboards"/*.json "$helm_dir"
