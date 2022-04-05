#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

TMPDIR="./tmp"
MIXIN_REPO="git@github.com:giantswarm/giantswarm-kubernetes-mixin.git"
# clone a branch if provided
BRANCH=${1:-""}

# make a temporary dir to work in
mkdir ${TMPDIR}

if [ -z "${BRANCH}" ]; then
    # clone the mixins repo
    echo -e "\nCloning master branch:\n"
    git clone ${MIXIN_REPO} ${TMPDIR}/mixins
else
    # clone the mixins repo branch
    echo -e "\nCloning branch '${BRANCH}':\n"
    git clone -b ${BRANCH} --single-branch ${MIXIN_REPO} ${TMPDIR}/mixins
fi

# get the current commit of the mixin repo
cd ${TMPDIR}/mixins
MIXIN_VER=$(git rev-parse HEAD)
cd - > /dev/null

# copy over the dashboards to the helm chart
cp -a ${TMPDIR}/mixins/files/dashboards/* helm/dashboards/dashboards/mixin/

echo -e "\nSynced mixin repo at commit: ${MIXIN_VER}\n"

# tidy up
rm -rf ${TMPDIR}
