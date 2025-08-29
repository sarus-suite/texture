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

DOWNLOAD_DIR="${TMP_DIR}/download"
REPO="containers/${PRODUCT}"
BASE_URL="https://github.com/${REPO}/releases/download"

if [ -z "$FUSEOVERLAYFS_VERSION" ]
then
  FUSEOVERLAYFS_VERSION=$(get_github_repo_latest_release ${REPO})
fi

FUSEOVERLAYFS_URL="${BASE_URL}/${FUSEOVERLAYFS_VERSION}/fuse-overlayfs-${ARCH}"
mkdir -p ${DOWNLOAD_DIR}
cd ${DOWNLOAD_DIR}
curl -sOL ${FUSEOVERLAYFS_URL}

# INSTALL
mkdir -p ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin
mv fuse-overlayfs-${ARCH} ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/fuse-overlayfs
chmod +x ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/fuse-overlayfs
