#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
PRODUCT=$(basename ${THIS_DIR})
SARUS_SUITE_DIR='sarus-suite'
cd $SCRIPT_DIR

. lib/common.sh
check_build_os || exit 1
create_tmp_folders

. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg

if [ "$ARCH" == "x86_64" ]
then
  GARCH="amd64"
else
  GARCH="$ARCH"
fi

DOWNLOAD_DIR="${TMP_DIR}/download"
REPO="containers/crun"
BASE_URL="https://github.com/${REPO}/releases/download"

if [ -z "$CRUN_VERSION" ]
then
  CRUN_VERSION=$(get_github_repo_latest_release ${REPO})
fi

CRUN_URL="${BASE_URL}/${CRUN_VERSION}/crun-${CRUN_VERSION}-linux-${GARCH}"
mkdir -p ${DOWNLOAD_DIR}
cd ${DOWNLOAD_DIR}
curl -sOL ${CRUN_URL}

# INSTALL
mkdir -p ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin
mv ${DOWNLOAD_DIR}/crun-${CRUN_VERSION}-linux-${GARCH} ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/crun
chmod +x ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/crun
