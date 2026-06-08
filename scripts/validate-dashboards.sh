#!/bin/bash
# This script does some sanity checks on dashboards:
# - Check for owner tag presence
# - Match owners against list of team names retrieved from https://github.com/giantswarm/github
# - Check for uid presence
#
# It won't change any files, and does not require any extra argument. Just run it from the root of the repository, then check its logs and return value.
#
# The list of problem dashboards is printed between BEGIN_DASHBOARD_PROBLEMS /
# END_DASHBOARD_PROBLEMS markers so CI can extract a concise summary.
set -eu

# List of files to exclude
excludes=( "values.schema.json" )
excludes_string="$(IFS="|"; echo "${excludes[*]}")"

# Find valid team names
# In CI, set GH_TOKEN to a token with read access to the private giantswarm/github
# repo; locally we default to SSH.
if [ -n "${GH_TOKEN:-}" ]; then
  github_repo="https://x-access-token:${GH_TOKEN}@github.com/giantswarm/github.git"
else
  github_repo="git@github.com:giantswarm/github.git"
fi
github_repo_directory="$(mktemp -d -t validate-dashboards.XXXXXXXXXX)"
trap 'rm -rf "$github_repo_directory"' EXIT
git clone --depth 1 "$github_repo" "$github_repo_directory"
cd "$github_repo_directory"
mapfile teams < <(find repositories -name 'team*.yaml' -printf '%f\n' | cut -d. -f1)
cd -
printf "Found %d teams:\n" "${#teams[@]}"
printf " - %s" "${teams[@]}"

# Check all dashboards
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
    # Dashboards come in two schemas. The "v2" schema (apiVersion
    # dashboard.grafana.app/v2*) nests tags under .spec and the uid under
    # .metadata; the classic schema keeps them at the top level.
    apiVersion=$(jq -r '.apiVersion // empty' "$dashboardFile" 2>/dev/null)
    if [[ "$apiVersion" == dashboard.grafana.app/v2* ]]; then
        tagsPath='.spec.tags'
        uidPath='.metadata.uid'
    else
        tagsPath='.tags'
        uidPath='.uid'
    fi

    # Find owner tag
    if owners=$(jq -r "${tagsPath}[]?|select(.|test(\"^owner:\"))" "$dashboardFile" 2>/dev/null); then
      if [ -z "$owners" ]; then
          record "Owner tag missing"
          continue
      fi
      # Check all owner tags found
      invalid_owner=()
      for owner in $owners; do
        team="${owner#owner:}"
        # Check if owner tag matches a team name
        if [[ ! "${teams[*]}" =~ ${team} ]]; then
            invalid_owner+=("$team")
        fi
      done
      if [ "${#invalid_owner[@]}" -ne 0 ]; then
          record "Owner team(s) invalid: ${team[*]}"
          continue
      fi
    else
      record "Error parsing"
      continue
    fi

    # Check uid
    uid=$(jq -r "${uidPath}|strings" "$dashboardFile")
    if [ -z "$uid" ]; then
        record "Missing uid"
        continue
    fi

    printf "%-${log_length}s %s\n" "OK" "$dashboardFile"
done < <(find helm/dashboards/ -name "*.json" | grep -vE "$excludes_string")

if [ "$failures" -gt 0 ]; then
    echo "BEGIN_DASHBOARD_PROBLEMS"
    printf '%s\n' "${problems[@]}"
    echo "END_DASHBOARD_PROBLEMS"
    exit 1
fi
