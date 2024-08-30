#!/bin/bash

### This script is used to copy dashboards
## from Monitoring Mixins website repo.
## https://monitoring.mixins.dev/
## the repo behind this website is located:
## https://github.com/monitoring-mixins/website
## We copy certain dashboards from this repo:
## alertmanager


set -e

TMPDIR="$(mktemp -d)"
trap "rm -rf $TMPDIR" EXIT


main() {

  apps=("alertmanager")

  ## clone the repo
  git clone https://github.com/monitoring-mixins/website.git --depth 1 "$TMPDIR"/monitoring-mixins

  ## Copy and overwrite
  for app in "${apps[@]}"; do
      echo "copying $app dashboard"
      cp "$TMPDIR"/monitoring-mixins/assets/"$app"/dashboards/* ./helm/dashboards/charts/public_dashboards/dashboards/shared/public/
  done

  echo "------- Update Changelog"
  gst="$(git status --short)"
  if [[ "$gst" != "" ]]; then
      echo "$gst"
      echo_changes > "$TMPDIR"/tmp_changes
      sed -i '/^## \[Unreleased\]/r '"$TMPDIR"'/tmp_changes' CHANGELOG.md
      echo_warning_customupdates
  fi

}


echo_changes() {
  echo ""
  echo "### Changed"
  echo ""
  echo "- Monitoring Dashboard Updated"
  echo "\`\`\`"
  git status --short
  echo "\`\`\`"
}

echo_warning_customupdates() {
  echo ""
  echo "### Warning"
  echo ""
  echo "These dashboards have custom updates, please review the changes"
  echo "and make sure you didn't lose these custom updates."
  echo ""
  echo "known custom changes:"
  echo "- alertmanager: select specific integration"
  echo "- alertmanager: show logs"
  echo ""
}

main "$@"
