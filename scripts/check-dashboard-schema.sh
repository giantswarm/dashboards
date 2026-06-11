#!/bin/bash
# This script enforces that every dashboard uses a schema Grafana can import:
# either the classic "v1" schema or the "v2" schema (apiVersion
# dashboard.grafana.app/v2*).
#
# It specifically rejects the "JSON model" shown in a dashboard's
# Settings -> JSON model view: that is the v2 *spec* with the
# apiVersion/kind/metadata/spec envelope stripped off (top-level .elements and
# .layout but no .apiVersion and no .schemaVersion). Grafana cannot import that
# form, so committing it is almost always a mistake.
#
# It won't change any files and takes no arguments. Run it from the root of the
# repository, then check its logs and return value.
#
# The list of problem dashboards is printed between BEGIN_DASHBOARD_PROBLEMS /
# END_DASHBOARD_PROBLEMS markers so CI can extract a concise summary.
set -eu

# List of files to exclude
excludes=( "values.schema.json" )
excludes_string="$(IFS="|"; echo "${excludes[*]}")"

failures=0
problems=()
log_length=19

# Record a problem: print a log line and remember it for the summary.
record() {
    local msg="$1"
    printf "%-${log_length}s %s\n" "$msg" "$dashboardFile"
    problems+=("- \`${dashboardFile#./}\`: ${msg}")
    failures=$((failures+1))
}

# NOTE: a process substitution (not a pipe) is used so that the loop runs in the
# current shell and the "failures" counter survives the loop.
while read -r dashboardFile; do
    # Must be valid JSON before we can classify it.
    if ! schema=$(jq -r '
        if (.apiVersion // "" | startswith("dashboard.grafana.app/v2")) then
            (if (.spec | type) == "object" then "v2" else "v2-no-spec" end)
        elif (.schemaVersion | type) == "number" then
            "v1"
        elif (.elements | type) == "object" then
            "json-model"
        else
            "unknown"
        end' "$dashboardFile" 2>/dev/null); then
        record "Invalid JSON"
        continue
    fi

    case "$schema" in
        v1|v2)
            printf "%-${log_length}s %s (%s)\n" "OK" "$dashboardFile" "$schema"
            ;;
        json-model)
            record "Unwrapped v2 'JSON model' (export the full v2 dashboard, not Settings -> JSON model)"
            ;;
        v2-no-spec)
            record "v2 apiVersion but missing .spec envelope"
            ;;
        *)
            record "Unrecognized schema (neither v1 nor v2)"
            ;;
    esac
done < <(find helm/dashboards/ -name "*.json" | grep -vE "$excludes_string")

if [ "$failures" -gt 0 ]; then
    echo "BEGIN_DASHBOARD_PROBLEMS"
    printf '%s\n' "${problems[@]}"
    echo "END_DASHBOARD_PROBLEMS"
    exit 1
fi
