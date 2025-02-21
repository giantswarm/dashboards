#!/bin/bash
# This script does some sanity checks on dashboards:
# - Check for owner tag presence
# - Match owners against list of team names retrieved from https://github.com/giantswarm/github
# - Check for uid presence
#
# It won't change any files, and does not require any extra argument. Just run it from the root of the repository, then check its logs and return value.
set -eu

# List of files to exclude
excludes=( "values.schema.json" "home.json" )
excludes_string="$(IFS="|"; echo "${excludes[*]}")"

# Find valid team names
github_repo="https://github.com/giantswarm/github.git"
github_repo_directory="$(mktemp -d -t validate-dashboards.XXXXXXXXXX)"
trap 'rm -rf "$github_repo_directory"' EXIT
git clone --depth 1 "$github_repo" "$github_repo_directory"
cd "$github_repo_directory"
mapfile teams < <(find repositories -name '*.yaml' -printf '%f\n' | cut -d. -f1)
cd -
echo "Found ${#teams[@]} teams:" ${teams[*]}

# Check all dashboards
failures=0
log_length=19
exec 5< <(find helm/dashboards/ -name "*.json" | grep -vE "$excludes_string")
while read -ru 5 f; do
    # Find owner tag
    if owners=$(jq -r '.tags[]?|select(.|test("^owner:"))' "$f" 2>/dev/null); then
      if [ -z "$owners" ]; then
          printf "%-${log_length}s %s\n" "Owner tag missing" "$f"
          failures=$((failures+1))
          continue
      fi
      # Check all owner tags found
      for owner in $owners; do
        team="${owner#owner:}"
        # Check if owner tag matches a team name
        if [[ ! "${teams[*]}" =~ ${team} ]]; then
            printf "%-${log_length}s %s\n" "Owner team invalid" "$f"
            failures=$((failures+1))
            continue
        fi
      done
    else
      printf "%-${log_length}s %s\n" "Error parsing" "$f"
      failures=$((failures+1))
      continue
    fi

    # Check uid
    uid=$(jq -r '.uid|strings' "$f")
    if [ -z "$uid" ]; then
        printf "%-${log_length}s %s\n" "Missing uid" "$f"
        failures=$((failures+1))
        continue
    fi

    printf "%-${log_length}s %s\n" "OK" "$f"
done
exec 5<&-

test $failures -gt 0 && exit 1
