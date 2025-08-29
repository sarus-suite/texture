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
REPO="sarus-suite/parallax"
PARALLAX_BASE_URL="https://github.com/${REPO}/releases/download"

if [ -z "$PARALLAX_VERSION" ]
then
  PARALLAX_VERSION=$(get_github_repo_latest_release ${REPO})
fi

PARALLAX_URL="${PARALLAX_BASE_URL}/${PARALLAX_VERSION}/parallax-${PARALLAX_VERSION}-${OS}-${GARCH}"
PARALLAX_MOUNT_PROGRAM_URL="${PARALLAX_BASE_URL}/${PARALLAX_VERSION}/parallax-mount-program-${PARALLAX_VERSION}.sh"
mkdir -p ${DOWNLOAD_DIR}
cd ${DOWNLOAD_DIR}
curl -sOL ${PARALLAX_URL}
curl -sOL ${PARALLAX_MOUNT_PROGRAM_URL}

# INSTALL
mkdir -p ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin
mv parallax-${PARALLAX_VERSION}-${OS}-${GARCH} ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/parallax
chmod +x ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/parallax 
mv parallax-mount-program-${PARALLAX_VERSION}.sh ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/parallax-mount-program.sh
chmod +x ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/parallax-mount-program.sh
