#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
TMP_DIR="${SCRIPT_DIR}/tmp"
SRC_DIR="${TMP_DIR}/src"
ARTIFACTS_DIR="${SCRIPT_DIR}/artifacts"
SARUS_SUITE_DIR='sarus-suite'
PARALLAX_BASE_URL="https://github.com/sarus-suite/parallax/releases/download"
cd $SCRIPT_DIR

# FETCH
. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg
. ${SCRIPT_DIR}/lib/common.sh

if [ "$ARCH" == "x86_64" ]
then
  GARCH="amd64"
else
  GARCH="$ARCH"
fi

if [ -z "$PARALLAX_VERSION" ]
then
  PARALLAX_VERSION=$(get_github_repo_latest_release sarus-suite/parallax)
fi

PARALLAX_URL="${PARALLAX_BASE_URL}/${PARALLAX_VERSION}/parallax-${PARALLAX_VERSION}-${OS}-${GARCH}"
PARALLAX_MOUNT_PROGRAM_URL="${PARALLAX_BASE_URL}/${PARALLAX_VERSION}/parallax-mount-program-${PARALLAX_VERSION}.sh"
mkdir -p ${TMP_DIR}/download
cd ${TMP_DIR}/download
curl -sOL ${PARALLAX_URL}
curl -sOL ${PARALLAX_MOUNT_PROGRAM_URL}

# INSTALL
mkdir -p ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin
cd ${TMP_DIR}/download
mv parallax-${PARALLAX_VERSION}-${OS}-${GARCH} ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/parallax
chmod +x ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/parallax 
mv parallax-mount-program-${PARALLAX_VERSION}.sh ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/parallax-mount-program.sh
chmod +x ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/parallax-mount-program.sh
