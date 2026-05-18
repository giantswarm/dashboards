#!/bin/bash
#
# Sync Strimzi/Kafka Grafana dashboards from the main branch of the
# giantswarm strimzi-kafka-operator fork.
#
# Source: https://github.com/giantswarm/strimzi-kafka-operator
#         helm/strimzi-kafka-operator/files/grafana-dashboards/
#
# Usage:
#   ./scripts/sync-kafka-dashboards.sh
#
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
DEST_DIR="$SCRIPT_DIR/../helm/dashboards/charts/team_atlas/dashboards/Shared Org/Kafka"

echo "====> Syncing Strimzi dashboards from giantswarm/strimzi-kafka-operator@main"

mkdir -p "$DEST_DIR"
curl -sSfL "https://api.github.com/repos/giantswarm/strimzi-kafka-operator/contents/helm/strimzi-kafka-operator/files/grafana-dashboards?ref=main" \
    | jq -r '.[] | select(.type=="file" and (.name | endswith(".json"))) | "\(.name)\t\(.download_url)"' \
    | while IFS=$'\t' read -r name url; do
        echo "  Downloading $name"
        curl -sSfL "$url" -o "$DEST_DIR/$name"
      done

echo "Dashboards synced to $DEST_DIR. Review the diff and commit."
