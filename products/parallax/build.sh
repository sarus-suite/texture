#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
TMP_DIR="${SCRIPT_DIR}/tmp"
SRC_DIR="${TMP_DIR}/src"
ARTIFACTS_DIR="${SCRIPT_DIR}/artifacts"
SARUS_SUITE_DIR='sarus-suite'
cd $SCRIPT_DIR

. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg
. ${SCRIPT_DIR}/lib/common.sh

if [ -z "$PARALLAX_VERSION" ]
then
  PARALLAX_VERSION=$(get_github_repo_latest_release containers/conmon)
fi

# BUILD
PRODUCT='parallax'
BUILD_OS_NAME='opensuse'
BUILD_OS_VERSION_ID='15.5'
BUILD_OS="${BUILD_OS_NAME}-${BUILD_OS_VERSION_ID}"
BIN="${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/${PRODUCT}"
mkdir -p ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
cd ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh
podman run --rm -ti -e VERSION=${PARALLAX_VERSION} -v ${SRC_DIR}/${BUILD_OS}/${PRODUCT}:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION_ID} /tmp/build_in_container.sh

# INSTALL
mkdir -p ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin
mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/${PRODUCT}/dist/${PRODUCT} ${BIN}
mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/${PRODUCT}/scripts/${PRODUCT}-mount-program.sh ${BIN}-mount-program.sh

# CLEAN
rm -rf ${SRC_DIR}/${BUILD_OS}
rm -rf ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
