#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
PRODUCT=$(basename ${THIS_DIR})
SARUS_SUITE_DIR='sarus-suite'
cd $SCRIPT_DIR

. lib/common.sh
check_build_os || exit 1
create_tmp_folders

DOWNLOAD_DIR="${TMP_DIR}/download"
GITHUB_ORG=$(get_github_org ${PRODUCT}) || exit 1

if [ -z "$CRUN_VERSION" ]
then
  CRUN_VERSION=$(get_github_repo_latest_release "${GITHUB_ORG}/${PRODUCT}")
fi

mkdir -p ${DOWNLOAD_DIR}
cd ${DOWNLOAD_DIR}
github_fetch ${PRODUCT} ${CRUN_VERSION} crun-${CRUN_VERSION}-linux-${GOARCH} || exit 1

# INSTALL
mkdir -p ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin
mv ${DOWNLOAD_DIR}/crun-${CRUN_VERSION}-linux-${GOARCH} ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/crun
chmod +x ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/crun
