#!/bin/bash

# List dashboards
#
# List dashboards contained in the given folder
#
# $ list-dashboards.sh
# L65Jdq3Zk:Alerts
# ...

# First argument is the folder id
#
# Use list-folders to get folder id.
# Not providing a folder id will show all dashboard accross all folders

curl -sSH "Authorization: Bearer $GRAFANA_API_KEY" "https://giantswarm.grafana.net/api/search?type=dash-db&folderIds=$1" | jq -cr '.[]|(.uid + ":" + .title)'
