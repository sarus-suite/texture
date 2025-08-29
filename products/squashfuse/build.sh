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

#BUILD
SRC_DIR="${BUILD_DIR}/${PRODUCT}/src"
REPO="vasi/squashfuse"

if [ -z "$SQUASHFUSE_VERSION" ]
then
  SQUASHFUSE_VERSION=$(get_github_repo_latest_release ${REPO})
fi

mkdir -p ${SRC_DIR}/rpmbuild
cd ${SRC_DIR}/rpmbuild
cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/squashfuse.spec ./squashfuse.spec
podman run --rm -ti -e SQUASHFUSE_VERSION=${SQUASHFUSE_VERSION} -v ${SRC_DIR}/rpmbuild:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION} /tmp/build_in_container.sh

# INSTALL
OUT_DIR="${PACKAGES_DIR}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/rpmbuild/${PRODUCT}/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/rpmbuild/${PRODUCT}/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/
#mkdir -p ${OUT_DIR}/RPMS/noarch
#mv ${SRC_DIR}/rpmbuild/rpm/RPMS/noarch/*.rpm ${OUT_DIR}/RPMS/noarch/

# CLEAN
rm -rf ${SRC_DIR}
