#!/bin/bash

# Get a single dashboard
#
# Retrieve a dashboard as json and optionally stores it
#
# $ get-dashboard.sh xIIDfwMMk test
# $ ls test
# xIIDfwMMk.json

# First argument is dashboard uid
#
# Use list-dashboards to get dashboard uid

# Second argument is folder output
#
# e.g. bob becomes bob/UID.json
# otherwise stdout is used

set -e

OUTPUT=/dev/stdout

TMP=$(mktemp --tmpdir curl.XXXXXXXXXX)
trap "rm -rf $TMP" EXIT

HTTP_CODE=$(curl --output "$TMP" --write '%{http_code}' --silent --show-error --header "Authorization: Bearer $GRAFANA_API_KEY" https://giantswarm.grafana.net/api/dashboards/uid/$1)
if [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]] ; then
	echo $HTTP_CODE
	cat "$TMP"
	exit 1
fi

if [ -n "$2" ]; then
	mkdir -p "$2"
	OUTPUT="$2/$1.json"
fi

cat "$TMP" > "$OUTPUT"
