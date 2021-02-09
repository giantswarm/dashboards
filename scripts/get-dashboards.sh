#!/bin/bash

# Get all dashboards from given folder
#
# Retrive all dashboards from given folder, as json and store them
#
# $ get-dashboards.sh 0 test
# L65Jdq3Zk:Alerts
# ...
# $ ls test
# L65Jdq3Zk.json
# ...

# First argument is folder id
#
# see list-dashboards.sh

# Second argument is folder output
#
# see get-dashboard.sh

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"

$script_path/list-dashboards.sh $1 | while read d; do
	uid=$(echo -n "$d" | cut -d: -f1)
	echo "$d"
	$script_path/get-dashboard.sh $uid $2
done
