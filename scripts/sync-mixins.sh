#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

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

# copy over the dashboards to the helm chart
cp -a "${TMPDIR}"/mixins/files/dashboards/* helm/dashboards/dashboards/mixin/

echo -e "\nSynced mixin repo at commit: ${MIXIN_VER}\n"

# tidy up
rm -rf "${TMPDIR}"
