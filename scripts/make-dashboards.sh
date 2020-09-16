#!/bin/bash

set -eu

DASHBOARD_DIRECTORY="./dashboards"
OUTPUT_DIRECTORY="./output"

echo "Cleaning output directory"
rm -rf ./$OUTPUT_DIRECTORY && mkdir ./$OUTPUT_DIRECTORY

for dashboard in $DASHBOARD_DIRECTORY/*; do
    dashboard=$(basename $dashboard)
    dashboard=${dashboard%.*}

    if [ "$dashboard" = "stdlib" ]; then
        continue
    fi

    echo "Making dashboard $dashboard.jsonnet"

    jsonnet \
        --jpath ~/go/src/github.com/grafana/grafonnet-lib/ \
        $DASHBOARD_DIRECTORY/$dashboard.jsonnet > $OUTPUT_DIRECTORY/$dashboard.json
done

echo "Made all dashboards"
