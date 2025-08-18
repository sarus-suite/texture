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

if [ -z "$SQUASHFUSE_VERSION" ]
then
  SQUASHFUSE_VERSION=$(get_github_repo_latest_release vasi/squashfuse)
fi

# BUILD
BUILD_OS_NAME='opensuse'
BUILD_OS_VERSION_ID='15.5'
BUILD_OS="${BUILD_OS_NAME}-${BUILD_OS_VERSION_ID}"
mkdir -p ${SRC_DIR}/${BUILD_OS}
cd ${SRC_DIR}/${BUILD_OS}
cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/squashfuse.spec ./squashfuse.spec
podman run --rm -ti -e SQUASHFUSE_VERSION=${SQUASHFUSE_VERSION} -v ${SRC_DIR}:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION_ID} /tmp/${BUILD_OS}/build_in_container.sh

# INSTALL
#mkdir -p ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin
#mv ${SRC_DIR}/${BUILD_OS}/conmon/bin/conmon ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/conmon

# CLEAN
#rm -rf ${SRC_DIR}/${BUILD_OS}
