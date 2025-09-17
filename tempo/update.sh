#!/bin/bash

# Update Tempo mixin dashboards
#
# This script updates the Tempo mixin dashboards from the upstream repository.
#
# Usage:
#   ./update.sh

set -eu

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
TOOLS_DIR="$SCRIPT_DIR/../tools"
TMPDIR="$(mktemp -d -t giantswarm-dashboards-XXXXXX)"
trap 'rm -rf $TMPDIR' EXIT

helm_dir="$SCRIPT_DIR/../helm/dashboards/charts/private_dashboards_mz/dashboards/shared/private"

set -x
cd tempo
rm -rf vendor jsonnetfile.* dashboards_out

"$TOOLS_DIR/jb" init
"$TOOLS_DIR/jb" install https://github.com/grafana/tempo/operations/tempo-mixin@main
mixtool generate dashboards mixin.libsonnet -d "$TMPDIR/dashboards"
{ set +x; } 2>/dev/null

tags="$(cat "$SCRIPT_DIR/tags.json")"
for file in "$TMPDIR/dashboards"/*.json; do
	filename=$(basename "$file")
	
	# Skip the backendwork dashboard
	if [[ "$filename" == "tempo-backendwork.json" ]]; then
		echo "Skipping $file (backendwork dashboard not needed)"
		continue
	fi
	
  # Skip the block-builder dashboard as this component is used it our chart (this is the replacement for the compactor)
	if [[ "$filename" == "tempo-block-builder.json" ]]; then
		echo "Skipping $file (block-builder dashboard not needed)"
		continue
	fi

	echo "$file"

	# Fix rollout progress title
	if [[ "$filename" == "tempo-rollout-progress.json" ]]; then
		jq '.title = "Tempo / Rollout progress"' "$file" > "$file.out" && mv "$file.out" "$file"
	fi
	
	# Fix operational title
	if [[ "$filename" == "tempo-operational.json" ]]; then
		jq '.title = "Tempo / Operational"' "$file" > "$file.out" && mv "$file.out" "$file"
	fi

	# Remove Gateway row from tempo-reads dashboard
	if [[ "$filename" == "tempo-reads.json" ]]; then
		jq '.rows |= .[1:]' "$file" > "$file.out" && mv "$file.out" "$file"
	fi

	# Remove Gateway and Envoy Proxy rows from tempo-writes dashboard
	if [[ "$filename" == "tempo-writes.json" ]]; then
		jq '.rows |= .[3:]' "$file" > "$file.out" && mv "$file.out" "$file"
	fi

	# Add tags
	"$TOOLS_DIR/yq" '.tags += '"$tags"'' -i "$file"

	# Generate UID from title if UID is missing or empty
	current_uid=$(jq -r '.uid // ""' "$file")
	if [[ -z "$current_uid" || "$current_uid" == "null" ]]; then
		# Extract title and convert to lowercase, replace spaces/slashes with hyphens
		title=$(jq -r '.title' "$file")
		new_uid=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
		jq --arg uid "$new_uid" '.uid = $uid' "$file" > "$file.out" && mv "$file.out" "$file"
	else
		# Add tempo- prefix to existing uid
		jq '.uid = "tempo-" + .uid' "$file" > "$file.out" && mv "$file.out" "$file"
	fi

	# Copy to helm directory
	cp "$file" "$helm_dir"
done
