#!/bin/bash

# Update multiple dashboards
#
# Upload all dashboards found in the given directory

# First argument is folder input
#
# This folder holds one file for each dashboard in the same form as get-dashboard result.

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"

find "$1" | while read -r f; do
	d=$(jq -r '.dashboard.uid + ":" + .dashboard.title' "$1/$f")
	echo "$d"
	"$script_path"/update-dashboard.sh "$1/$f"
done
