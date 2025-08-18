#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
TMP_DIR="${SCRIPT_DIR}/tmp"
SRC_DIR="${TMP_DIR}/src"
ARTIFACTS_DIR="${SCRIPT_DIR}/artifacts"
cd $SCRIPT_DIR

. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg
. ${SCRIPT_DIR}/lib/common.sh

if [ -z "$PODMAN_VERSION" ]
then
  PODMAN_VERSION=$(get_github_repo_latest_release containers/podman)
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
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/podman.spec ./podman.spec
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/podman.conf ./podman.conf
podman run --rm -ti -e PODMAN_VERSION=${PODMAN_VERSION} -v ${SRC_DIR}:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION_ID} /tmp/${BUILD_OS}/build_in_container.sh

# EXTRACT RPMS
OUT_DIR="${ARTIFACTS_DIR}/packages/${BUILD_OS}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/${BUILD_OS}/podman/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/${BUILD_OS}/podman/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/
mkdir -p ${OUT_DIR}/RPMS/noarch
mv ${SRC_DIR}/${BUILD_OS}/podman/rpm/RPMS/noarch/*.rpm ${OUT_DIR}/RPMS/noarch/

