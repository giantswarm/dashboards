#!/bin/bash

set -eu

GRAFANA_URL="https://giantswarm.grafana.net"
FOLDER_ID="40"  # Official folder
OUTPUT_DIRECTORY="./output"

if [ -z "$GRAFANA_API_KEY" ]; then
    echo "Grafana API key not set"
    exit 1
fi

echo "Removing all existing dashboards in managed folder"

uids=$(curl -Ss \
    --header "Authorization: Bearer $GRAFANA_API_KEY" \
    $GRAFANA_URL/api/search?folderIds=$FOLDER_ID \ |
    jq --compact-output --raw-output '.[].uid')

for uid in $uids; do
    curl \
        --header "Authorization: Bearer $GRAFANA_API_KEY" \
        --request "DELETE" \
        $GRAFANA_URL/api/dashboards/uid/"$uid"
    echo
done

echo "Uploading all dashboards"

for dashboard in "$OUTPUT_DIRECTORY"/*; do
    dashboard=$(basename "$dashboard")
    dashboard=${dashboard%.*}

    dashboard_data=$(cat "$OUTPUT_DIRECTORY"/"$dashboard".json)

    curl \
        --header "Authorization: Bearer $GRAFANA_API_KEY" \
        --header "Content-Type: application/json" \
        --request "POST" \
        --data "{\"dashboard\": $dashboard_data, \"folderId\": $FOLDER_ID, \"overwrite\": true}" \
        $GRAFANA_URL/api/dashboards/db
    echo

    echo "Uploaded dashboard $dashboard"
done
