#!/bin/bash

set -eu

DASHBOARD_LINTER_VERSION="eb2bc3ba25e3f0ae816b45ed3d05700002f76871"
MIXTOOL_VERSION="448a81c91e517aa4259e7d3e039c19fed9771864"

JB_VERSION="v0.6.0"
JB_BIN="jb"

YQ_VERSION="v4.44.3"
YQ_BIN="yq"

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE}") && pwd -P)
TOOLS_DIR="$SCRIPT_DIR/../tools"
OS=$(go env GOOS)
ARCH=$(go env GOARCH)
TMPDIR="$(mktemp -d -t giantswarm-dashboards-XXXXXX)"
trap "rm -rf $TMPDIR" EXIT

install_tool() {
    # Sometimes the archive might contain a folder tree. Use this as a path prefix relative to the root of the
    # extraction folder to point to the actual binary or pass it as empty string if the binary is directly downloaded.
    local binaryPath=$1 ; shift
    local binary=$1 ; shift
    local version=$1 ; shift
    local url=$1 ; shift

    local short_path="${TOOLS_DIR}/${binary}"
    local long_path="${short_path}-${version}"

    file=$(basename "${url}")

    if [[ ! -f "${long_path}" ]]; then
        echo "---> Installing ${binary} ${version}"
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

go_install() {
				url="$1"
				binary=$(basename "$url")
				version="$2"

				if ! command -v "$binary" &>/dev/null; then
								echo "---> Installing $binary"
								go install "$1@$version"
				fi
}

main() {
				command -v go &>/dev/null || { echo "go is required but not installed"; exit 1; }

                mkdir -p "${TOOLS_DIR}"
				install_tool "" "${JB_BIN}" "${JB_VERSION}" "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/${JB_VERSION}/jb-${OS}-${ARCH}"
				install_tool "" "${YQ_BIN}" "${YQ_VERSION}" "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${OS}_${ARCH}"

				go_install "github.com/monitoring-mixins/mixtool/cmd/mixtool" "$MIXTOOL_VERSION"
				go_install "github.com/grafana/dashboard-linter" "$DASHBOARD_LINTER_VERSION"
}

main "$@"
