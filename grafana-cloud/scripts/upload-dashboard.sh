#!/bin/bash

set -eu

GRAFANA_URL="https://giantswarm.grafana.net"
FOLDER_ID="31"  # Playground folder
OUTPUT_DIRECTORY="./output"

if [ -z "$GRAFANA_API_KEY" ]; then
    echo "Grafana API key not set"
    exit 1
fi

filename=$1
dashboard_data=$(cat $OUTPUT_DIRECTORY/"$filename")

curl \
    --header "Authorization: Bearer $GRAFANA_API_KEY" \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data "{\"dashboard\": $dashboard_data, \"folderId\": $FOLDER_ID, \"overwrite\": true}" \
    $GRAFANA_URL/api/dashboards/db
echo

echo "Uploaded dashboard"
