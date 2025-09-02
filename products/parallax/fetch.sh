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

if [ -z "$PARALLAX_VERSION" ]
then
  PARALLAX_VERSION=$(get_github_repo_latest_release "${GITHUB_ORG}/${PRODUCT}")
fi

mkdir -p ${DOWNLOAD_DIR}
cd ${DOWNLOAD_DIR}
github_fetch ${PRODUCT} ${PARALLAX_VERSION} parallax-${PARALLAX_VERSION}-${OS}-${GOARCH} || exit 1
github_fetch ${PRODUCT} ${PARALLAX_VERSION} parallax-mount-program-${PARALLAX_VERSION}.sh || exit 1

# INSTALL
mkdir -p ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin
mv parallax-${PARALLAX_VERSION}-${OS}-${GOARCH} ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/parallax
chmod +x ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/parallax 
mv parallax-mount-program-${PARALLAX_VERSION}.sh ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/parallax-mount-program.sh
chmod +x ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/parallax-mount-program.sh
