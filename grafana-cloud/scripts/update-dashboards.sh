#!/bin/bash

# Update multiple dashboards
#
# Upload all dashboards found in the given directory

# First argument is folder input
#
# This folder holds one file for each dashboard in the same form as get-dashboard result.

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"

ls $1 | while read f; do
	d=$(cat "$1/$f" |jq -r '.dashboard.uid + ":" + .dashboard.title')
	echo "$d"
	$script_path/update-dashboard.sh "$1/$f"
done
