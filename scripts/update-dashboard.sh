#!/bin/bash

# Update dashboard
#
# Upload the given file as new dashboard version
# A version notes is added during upload

# First argument is the dashboard file
#
# This file contains the dashboard data, this can be retrieved via the UI or with get-dashboard.

set -e

OUTPUT=$(mktemp --tmpdir curl.XXXXXXXXXX)
INPUT=$(mktemp --tmpdir dashboard.XXXXXXXXXX)
trap "rm -rf $INPUT $OUTPUT" EXIT

jq '.message="update by giantswarm/dashboards"' $1 > $INPUT
HTTP_CODE=$(curl --output "$OUTPUT" --write '%{http_code}' --silent --show-error --request POST --data @$INPUT --header "Content-Type: application/json" --header "Authorization: Bearer $GRAFANA_API_KEY" https://giantswarm.grafana.net/api/dashboards/db)
if [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]] ; then
	echo -n "HTTP $HTTP_CODE "
	cat "$OUTPUT"
	exit 1
fi
