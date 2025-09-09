#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
PRODUCT=$(basename ${THIS_DIR})
SARUS_SUITE_DIR='sarus-suite'
cd $SCRIPT_DIR

. lib/common.sh
check_build_os || exit 1
check_build_container_image || exit 1
create_tmp_folders

# BUILD
SRC_DIR="${BUILD_DIR}/${PRODUCT}/src"
BIN="${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/${PRODUCT}"
GITHUB_ORG=$(get_github_org ${PRODUCT}) || exit 1

if [ -z "$GIT_TAG" ] && [ -z "${GIT_COMMIT}" ] && [ -z "${GIT_BRANCH}" ] && [ -z "$PODMAN_VERSION" ]
then
  GIT_TAG=$(get_github_repo_latest_release "${GITHUB_ORG}/${PRODUCT}")
  PODMAN_VERSION=${GIT_TAG}
elif [ -n "$PODMAN_VERSION" ]
then
  GIT_TAG="${PODMAN_VERSION}"
  unset GIT_BRANCH
  unset GIT_COMMIT   
fi

mkdir -p ${SRC_DIR}/rpmbuild
cd ${SRC_DIR}/rpmbuild
github_fetch_sources ${PRODUCT}

cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/podman.spec ./${PRODUCT}/rpm/podman.spec
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/podman.conf ./${PRODUCT}/rpm/podman.conf
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build.packages ./
#podman run --rm -ti -e PRODUCT=${PRODUCT} -v ${SRC_DIR}/rpmbuild:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION} /tmp/build_in_container.sh
podman run --rm -ti -e PRODUCT=${PRODUCT} -v ${SRC_DIR}/rpmbuild:/tmp ${BUILD_IMAGE_NAME} /tmp/build_in_container.sh

# EXTRACT RPMS
OUT_DIR="${PACKAGES_DIR}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/rpmbuild/${PRODUCT}/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/rpmbuild/${PRODUCT}/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/
mkdir -p ${OUT_DIR}/RPMS/noarch
mv ${SRC_DIR}/rpmbuild/${PRODUCT}/rpm/RPMS/noarch/*.rpm ${OUT_DIR}/RPMS/noarch/

# SAVE binary for userspace
OUT_DIR="${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin"
mkdir -p ${OUT_DIR}
cp ${SRC_DIR}/rpmbuild/${PRODUCT}/rpm/BUILD/podman-*/bin/podman ${BIN}

# CLEAN
rm -rf ${SRC_DIR}
