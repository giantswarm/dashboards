#!/bin/bash

# List folders
#
# Folders are used to group dashboards
#
# $ list-folders.sh
# {"id":40,"uid":"bm_2ocRGz","title":"Official"}
# ...

curl -sSH "Authorization: Bearer $GRAFANA_API_KEY" https://giantswarm.grafana.net/api/folders | jq -cr '.[]'
