#!/bin/bash

### This script is used to copy dashboards
## from Monitoring Mixins website repo.
## https://monitoring.mixins.dev/
## the repo behind this website is located:
## https://github.com/monitoring-mixins/website
## We copy certain dashboards from this repo:
## alertmanager


set -e

GRIZZLY_VERSION="0.4.3"
GRIZZLY_BIN="grr"

JB_VERSION="0.5.1"
JB_BIN="jb"

YQ_VERSION="4.44.3"
YQ_BIN="yq"

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE}") && pwd -P)
OS=$(go env GOOS)
ARCH=$(go env GOARCH)
TMPDIR="$(mktemp -d -t giantswarm-dashboards-XXXXXX)"
#trap "rm -rf $TMPDIR" EXIT
echo $TMPDIR

function install_tool() {
    # Sometimes the archive might contain a folder tree. Use this as a path prefix relative to the root of the
    # extraction folder to point to the actual binary or pass it as empty string if the binary is directly downloaded.
    local binaryPath=$1 ; shift
    local binary=$1 ; shift
    local version=$1 ; shift
    local url=$1 ; shift

    local short_path="${SCRIPT_DIR}/${binary}"
    local long_path="${short_path}-v${version}"

    file=$(basename "${url}")

    if [[ ! -f "${long_path}" ]]; then
        echo "---> Installing ${binary} v${version}"
        set -x
        curl -fsL  -o "${TMPDIR}/${file}" "${url}"
        { set +x; } 2>/dev/null
        if [[ "${file}" == *.tar.gz ]]; then
            set -x
            tar xf "${TMPDIR}/${file}" -C "${TMPDIR}" --strip-components 1
            { set +x; } 2>/dev/null
        elif [[ "${file}" == *.zip ]]; then
            set -x
            unzip -qo "${TMPDIR}/${file}" -d "${TMPDIR}"
            { set +x; } 2>/dev/null
        else
            set -x
            mv "${TMPDIR}/${file}" "${TMPDIR}/${binary}"
            { set +x; } 2>/dev/null
        fi
        set -x
        chmod +x "${TMPDIR}/${binaryPath}${binary}"
        mv "${TMPDIR}/${binaryPath}${binary}" "${long_path}"
        { set +x; } 2>/dev/null
        base_long="$(basename "${long_path}")"
        set -x
        ln -fs "${base_long}" "${short_path}"
        { set +x; } 2>/dev/null
    fi
}

update_monitoring-mixins() {

  apps=("alertmanager")

  ## clone the repo
  git clone https://github.com/monitoring-mixins/website.git --depth 1 "$TMPDIR/monitoring-mixins"

  ## Copy and overwrite
  for app in "${apps[@]}"; do
      echo "copying $app dashboard"
      cp "$TMPDIR"/monitoring-mixins/assets/"$app"/dashboards/* ./helm/dashboards/dashboards/shared/public/
  done
}

update_alloy-mixins() {
  ## clone the repo
  git clone https://github.com/grafana/alloy.git --depth 1 "$TMPDIR/alloy"

  alloy_mixin_dir="$TMPDIR/alloy/operations/alloy-mixin"

  (
    cd "$alloy_mixin_dir"
    "$SCRIPT_DIR/$JB_BIN" install
    "$SCRIPT_DIR/$GRIZZLY_BIN" export grizzly/dashboards.jsonnet ./destination
  )

  for file in $(ls -1 "$alloy_mixin_dir/destination/Dashboard/"*.yaml); do
    filename="$(cat "$file" | "$SCRIPT_DIR/$YQ_BIN" .spec.title | tr -dc '[:alnum:] \n\r' | tr '[:upper:]' '[:lower:]' | tr '[:space:]' '_')"
    cat "$file" | "$SCRIPT_DIR/$YQ_BIN" --output-format json .spec > "./helm/dashboards/dashboards/$filename.json"
  done
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

main() {
  install_tool "" "${GRIZZLY_BIN}" "${GRIZZLY_VERSION}" "https://github.com/grafana/grizzly/releases/download/v0.4.3/grr-${OS}-${ARCH}"
  install_tool "" "${JB_BIN}" "${JB_VERSION}" "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v${JB_VERSION}/jb-${OS}-${ARCH}"
  install_tool "" "${YQ_BIN}" "${YQ_VERSION}" "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${OS}_${ARCH}"

  #update_monitoring-mixins
  update_alloy-mixins

  echo "------- Update Changelog"
  gst="$(git status --short)"
  if [[ "$gst" != "" ]]; then
      echo "$gst"
      echo_changes > "$TMPDIR"/tmp_changes
      sed -i '/^## \[Unreleased\]/r '"$TMPDIR"'/tmp_changes' CHANGELOG.md
  fi
}

main "$@"
