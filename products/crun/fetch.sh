#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
TMP_DIR="${SCRIPT_DIR}/tmp"
SRC_DIR="${TMP_DIR}/src"
ARTIFACTS_DIR="${SCRIPT_DIR}/artifacts"
SARUS_SUITE_DIR='sarus-suite'
BASE_URL="https://github.com/containers/crun/releases/download"
cd $SCRIPT_DIR

. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg
. ${SCRIPT_DIR}/lib/common.sh

if [ "$ARCH" == "x86_64" ]
then
  GARCH="amd64"
else
  GARCH="$ARCH"
fi

if [ -z "$CRUN_VERSION" ]
then
  CRUN_VERSION=$(get_github_repo_latest_release containers/crun)
fi

CRUN_URL="${BASE_URL}/${CRUN_VERSION}/crun-${CRUN_VERSION}-linux-${GARCH}"
mkdir -p ${TMP_DIR}/download
cd ${TMP_DIR}/download
curl -sOL ${CRUN_URL}

# INSTALL
mkdir -p ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin
cd ${TMP_DIR}/download
mv crun-${CRUN_VERSION}-linux-${GARCH} ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/crun
chmod +x ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/crun
