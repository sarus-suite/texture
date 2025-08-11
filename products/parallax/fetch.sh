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

if [ "$ARCH" == "x86_64" ]
then
  GARCH="amd64"
else
  GARCH="$ARCH"
fi

PARALLAX_URL="${PARALLAX_BASE_URL}/v${PARALLAX_VERSION}/parallax-v${PARALLAX_VERSION}-${OS}-${GARCH}"
PARALLAX_MOUNT_PROGRAM_URL="${PARALLAX_BASE_URL}/v${PARALLAX_VERSION}/parallax-mount-program-v${PARALLAX_VERSION}.sh"
mkdir -p ${TMP_DIR}/download
cd ${TMP_DIR}/download
curl -sOL ${PARALLAX_URL}
curl -sOL ${PARALLAX_MOUNT_PROGRAM_URL}

# INSTALL
mkdir -p ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}
cd ${TMP_DIR}/download
mv parallax-v${PARALLAX_VERSION}-${OS}-${GARCH} ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/parallax
mv parallax-mount-program-v${PARALLAX_VERSION}.sh ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/parallax-mount-program.sh
