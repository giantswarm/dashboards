#!/bin/bash

### This script is used to copy dashboards
## from https://github.com/giantswarm/giantswarm-kubernetes-mixin.git
## However, This repo is not the upstream.
## it's used to Customizing upstream Grafana Dashboards and generating
## proper Giant Swarm dashboards.
## Generated via https://github.com/kubernetes-monitoring/kubernetes-mixin
###

set -o errexit
set -o nounset
set -o pipefail

unneeded_dashboards=(
    k8s-resources-windows-cluster.json
    k8s-resources-windows-namespace.json
    k8s-resources-windows-pod.json
    k8s-windows-cluster-rsrc-use.json
    k8s-windows-node-rsrc-use.json
    proxy.json
    )

public_dashboards=(
    apiserver.json
    )

function tune_dashboard {
    dashboardFile="$1"
    # Extra tuning

    # Latest mixins use SLO instead of classic metrics in several places
    # but we dropped these SLO metrics
    sed -i 's/apiserver_request_sli_duration_seconds/apiserver_request_duration_seconds/g' "$dashboardFile"

    # Dashboard ownership.
    case $(basename "${dashboardFile}") in
        cluster-total.json|namespace-by-pod.json|namespace-by-workload.json|pod-total.json|workload-total.json)
            sed -i 's/"owner:team-.*"/"owner:team-cabbage"/g' "${dashboardFile}"
            ;;
    esac
}


# make a temporary dir to work in
TMPDIR=$(mktemp -d -t 'tmp.XXXXXXXXXX')
trap 'rm -f $TMPDIR' EXIT
MIXIN_REPO="git@github.com:giantswarm/giantswarm-kubernetes-mixin.git"
# clone a branch of tag if provided
BRANCH=${1:-""}

if [ -z "${BRANCH}" ]; then
    # clone the mixins repo
    echo -e "\nCloning master branch:\n"
    git clone --single-branch "${MIXIN_REPO}" "${TMPDIR}"/mixins
else
    # clone the mixins repo branch or tag
    echo -e "\nCloning branch or tag '${BRANCH}':\n"
    git clone --branch "${BRANCH}" --single-branch "${MIXIN_REPO}" "${TMPDIR}"/mixins
fi

# get the current commit of the mixin repo
cd "${TMPDIR}"/mixins
MIXIN_VER=$(git rev-parse HEAD)
cd - > /dev/null

# Remove unneeded dashboards
for dashboard in "${unneeded_dashboards[@]}"; do
    rm -f "${TMPDIR}"/mixins/files/dashboards/"${dashboard}"
done

# Tune dashboards as needed
while read -r file; do
    tune_dashboard "$file"
done < <(find "$TMPDIR" -type f -name \*.json)

# Move public dashboards to the publec dashboards folder
for dashboard in "${public_dashboards[@]}"; do
    mv "${TMPDIR}"/mixins/files/dashboards/"${dashboard}" helm/dashboards/charts/public_dashboards/dashboards/shared/public/
done

# Move remaining (private) dashboards to the helm chart
mv "${TMPDIR}"/mixins/files/dashboards/* helm/dashboards/dashboards/mixin/

echo -e "\nSynced mixin repo at commit: ${MIXIN_VER}\n"

# tidy up
rm -rf "${TMPDIR}"
