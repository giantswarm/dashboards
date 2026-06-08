#!/bin/bash

# Lint dashboards using the config.yaml
#
# Usage:
#  ./scripts/lint-dashboards.sh
#
# Lints every dashboard and reports ALL failures (it does not stop at the first
# one). Exits non-zero if any dashboard has lint issues. The list of problem
# dashboards is also printed between BEGIN_DASHBOARD_PROBLEMS / END_DASHBOARD_PROBLEMS
# markers so CI can extract a concise summary.

set -euo pipefail

# Dashboard directory
DASHBOARDS_DIRECTORY=./helm/dashboards

listDashboards () {
    # find all dashboards ".json" files, excluding values.schema.json files
    find "$DASHBOARDS_DIRECTORY" -type f -name \*.json \
        | grep -v 'values.schema.json'
}

main() {
    local returncode=0
    local problems=()

    mapfile -t dashboards < <(listDashboards)

    for dashboard in "${dashboards[@]}"; do
        if ! output=$(dashboard-linter lint --strict -c scripts/lint-config.yaml "$dashboard" 2>&1); then
            returncode=1
            echo "------ FAIL: $dashboard"
            echo "$output"
            # Extract the actual findings -- the marked error/warning lines and any
            # parse Error, but not the rule-description preamble nor the generic
            # "there were linting errors" trailer.
            findings=$(printf '%s\n' "$output" \
                | grep -E '^(\[(❌|⚠️)\]|Error: )' \
                | grep -vF 'there were linting errors, please see previous output')
            problems+=("- \`${dashboard#./}\`:")
            while IFS= read -r finding; do
                [ -n "$finding" ] && problems+=("  - ${finding}")
            done <<< "$findings"
        fi
    done

    if [ "${#problems[@]}" -gt 0 ]; then
        echo "BEGIN_DASHBOARD_PROBLEMS"
        printf '%s\n' "${problems[@]}"
        echo "END_DASHBOARD_PROBLEMS"
    else
        echo "All ${#dashboards[@]} dashboards passed linting."
    fi

    return "$returncode"
}

main "$@"
