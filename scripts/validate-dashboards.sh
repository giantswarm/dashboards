#!/bin/bash

set -eu

# List of files to exclude
excludes=( "values.schema.json" "home.json" )
exculde_string=$(IFS="|"; echo "${excludes[*]}")

# Find valid team names
github_repo="https://github.com/giantswarm/github.git"
github_repo_directory="$(mktemp -d -t validate-dashboards.XXXXXXXXXX)"
trap 'rm -rf "$github_repo_directory"' EXIT
git clone --depth 1 "$github_repo" "$github_repo_directory"
pushd "$github_repo_directory" > /dev/null || exit 1
mapfile teams < <(find repositories -name '*.yaml' -printf '%f\n' | cut -d. -f1)
popd > /dev/null || exit 1
echo "Found ${#teams[@]} teams:" ${teams[*]}

# Check all dashboards
failures=0
exec 5< <(find helm/dashboards/ -name "*.json" | grep -vE "$exculde_string")
while read -ru 5 f; do
    # Find owner tag
    if owners=$(jq -r '.tags[]?|select(.|test("^owner:"))' "$f" 2>/dev/null); then
      if [ -z "$owners" ]; then
          echo "Owner tag missing  $f"
          failures=$((failures+1))
          continue
      fi
      # Check all owner tags found
      for owner in $owners; do
        team="${owner#owner:}"
        # Check if owner tag matches a team name
        if [[ ! "${teams[*]}" =~ ${team} ]]; then
            echo "Owner team invalid $f"
            failures=$((failures+1))
            continue
        fi
      done
    else
      echo "Error parsing      $f"
      failures=$((failures+1))
      continue
    fi

    # Check uid
    uid=$(jq -r '.uid|strings' "$f")
    if [ -z "$uid" ]; then
        echo "Missing uid        $f"
        failures=$((failures+1))
        continue
    fi

    echo "OK                 $f"
done
exec 5<&-

test $failures -gt 0 && exit 1
