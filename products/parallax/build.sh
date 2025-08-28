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

# BUILD
SRC_DIR="${BUILD_DIR}/${PRODUCT}/src"
BIN="${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/${PRODUCT}"
REPO="sarus-suite/${PRODUCT}"

if [ -z "$PARALLAX_VERSION" ]
then
  PARALLAX_VERSION=$(get_github_repo_latest_release ${REPO})
fi

mkdir -p ${SRC_DIR}
cd ${SRC_DIR}
cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh
podman run --rm -ti -e VERSION=${PARALLAX_VERSION} -v ${SRC_DIR}:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION} /tmp/build_in_container.sh

# INSTALL
mkdir -p ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin
mv ${SRC_DIR}/${PRODUCT}/dist/${PRODUCT} ${BIN}
mv ${SRC_DIR}/${PRODUCT}/scripts/${PRODUCT}-mount-program.sh ${BIN}-mount-program.sh

# CLEAN
rm -rf ${SRC_DIR}
