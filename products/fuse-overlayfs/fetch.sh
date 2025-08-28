#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
TMP_DIR="${SCRIPT_DIR}/tmp"
SRC_DIR="${TMP_DIR}/src"
ARTIFACTS_DIR="${SCRIPT_DIR}/artifacts"
SARUS_SUITE_DIR='sarus-suite'
BASE_URL="https://github.com/containers/fuse-overlayfs/releases/download"
cd $SCRIPT_DIR

. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg
. ${SCRIPT_DIR}/lib/common.sh

if [ -z "$FUSEOVERLAYFS_VERSION" ]
then
  FUSEOVERLAYFS_VERSION=$(get_github_repo_latest_release containers/fuse-overlayfs)
fi

FUSEOVERLAYFS_URL="${BASE_URL}/${FUSEOVERLAYFS_VERSION}/fuse-overlayfs-${ARCH}"
mkdir -p ${TMP_DIR}/download
cd ${TMP_DIR}/download
curl -sOL ${FUSEOVERLAYFS_URL}

# INSTALL
mkdir -p ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin
cd ${TMP_DIR}/download
mv fuse-overlayfs-${ARCH} ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/fuse-overlayfs
chmod +x ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/fuse-overlayfs
