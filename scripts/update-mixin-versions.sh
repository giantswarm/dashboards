#!/bin/bash

# Update mixin version references from giantswarm app Chart.yaml files.
#
# For each mixin component, fetches the appVersion from the corresponding
# giantswarm/*-app repository and updates the version pin in the local
# update script.
#
# Usage:
#   ./scripts/update-mixin-versions.sh

set -eu

SCRIPT_DIR="$(readlink -f "$(dirname "$0")")"
ROOT_DIR="$SCRIPT_DIR/.."
TOOLS_DIR="$ROOT_DIR/tools"

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI not installed."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Error: gh not authenticated. Run: gh auth login"
  exit 1
fi

if [[ ! -x "$TOOLS_DIR/yq" ]]; then
  echo "Error: yq not found in $TOOLS_DIR. Run: make install-tools"
  exit 1
fi

get_app_version() {
  local app="$1"
  local chart_name="$2"
  gh api "repos/giantswarm/${app}/contents/helm/${chart_name}/Chart.yaml" \
    --jq '.content' | base64 --decode | "$TOOLS_DIR/yq" '.appVersion'
}

update_tempo() {
  local version
  version="$(get_app_version "tempo-app" "tempo")"
  # Strip patch: "2.10.2" → "release-v2.10"
  local minor="${version%.*}"
  local ref="release-v${minor}"
  echo "Tempo: appVersion=${version} → ${ref}"
  sed -i "s|^BRANCHREF=.*|BRANCHREF=\"${ref}\"|" "$ROOT_DIR/mixins/tempo/update.sh"
}

update_mimir() {
  local version
  version="$(get_app_version "mimir-app" "mimir")"
  # Use full tag: "2.17.6" → "mimir-2.17.6"
  local ref="mimir-${version}"
  echo "Mimir: appVersion=${version} → ${ref}"
  sed -i "s|^BRANCH=.*|BRANCH=\"${ref}\"|" "$ROOT_DIR/mixins/mimir/update.sh"
}

update_loki() {
  local version
  version="$(get_app_version "loki-app" "loki")"
  # Strip patch: "3.6.5" → "release-3.6.x"
  local minor="${version%.*}"
  local ref="release-${minor}.x"
  echo "Loki: appVersion=${version} → ${ref}"
  sed -i "s|^BRANCH=.*|BRANCH=\"${ref}\"|" "$ROOT_DIR/mixins/loki/update.sh"
}

update_alloy() {
  local version
  version="$(get_app_version "alloy-app" "alloy")"
  # Use full tag as-is: "v1.15.0"
  local ref="${version}"
  echo "Alloy: appVersion=${version} → ${ref}"
  sed -i "s|^ALLOY_VERSION=.*|ALLOY_VERSION=\"${ref}\"|" "$ROOT_DIR/mixins/alloy/update.sh"
}

update_tempo
update_mimir
update_loki
update_alloy

echo "Done. Run 'make update-mixin' to regenerate dashboards."
