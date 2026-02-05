#!/bin/bash

# Lint dashboards using the config.yaml
#
# Usage:
#  ./linter/lint-dashboards.sh

set -euo pipefail

# Dashboard directory
DASHBOARDS_DIRECTORY=./helm/dashboards

listDashboards () {
    # find all dashboards ".json" files and values.schema.json files
    find "$DASHBOARDS_DIRECTORY" -type f -name \*.json \
        | grep -v 'values.schema.json'
}

main() {
    local returncode=0

    # Investigation section
    ########################

    # Retrieve list of opsrecipes
    mapfile -t dashboards < <(listDashboards)

    for dashboard in "${dashboards[@]}"; do
        echo "-------"
        echo "Linting \"$dashboard\""
        dashboard-linter lint -c linter/config.yaml "$dashboard"
    done

    return "$returncode"
}

main "$@"
