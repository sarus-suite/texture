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
VERSION=$(git describe --tags --always | tr '-' '_')
RELEASE="0.${BUILD_OS_NAME}.${BUILD_OS_VERSION}"

function get_artifacts_versions() {
  unset CONMON_VERSION	
  unset CRUN_VERSION	
  unset PARALLAX_VERSION	
  unset PODMAN_VERSION	
  unset SQUASHFUSE_VERSION 
  CONMON_VERSION=$(ls ${PACKAGES_DIR}/RPMS/${ARCH}/ | sed -n "s/^conmon-\([[:digit:]].*\).$ARCH.rpm$/\1/p")
  CRUN_VERSION=$(ls ${PACKAGES_DIR}/RPMS/${ARCH}/ | sed -n "s/^crun-\([[:digit:]].*\).$ARCH.rpm$/\1/p")
  PODMAN_VERSION=$(ls ${PACKAGES_DIR}/RPMS/${ARCH}/ | sed -n "s/^podman-\([[:digit:]].*\).$ARCH.rpm$/\1/p")
  PARALLAX_VERSION=$(ls ${PACKAGES_DIR}/RPMS/${ARCH}/ | sed -n "s/^parallax-\(v[[:digit:]].*\).$ARCH.rpm$/\1/p")
  PODMAN_VERSION=$(ls ${PACKAGES_DIR}/RPMS/${ARCH}/ | sed -n "s/^podman-\([[:digit:]].*\).$ARCH.rpm$/\1/p")
  SQUASHFUSE_VERSION=$(ls ${PACKAGES_DIR}/RPMS/${ARCH}/ | sed -n "s/^squashfuse-\([[:digit:]].*\).$ARCH.rpm$/\1/p")
}

function check_artifacts_versions() {
  if [ -z "${CONMON_VERSION}" ]
  then
    echo "Error: Cannot find \$CONMON_VERSION, build conmon in advance."
    return 1
  fi
  if [ -z "${CRUN_VERSION}" ]
  then
    echo "Error: Cannot find \$CRUN_VERSION, build crun in advance."
    return 1
  fi
  if [ -z "${PARALLAX_VERSION}" ]
  then
    echo "Error: Cannot find \$PARALLAX_VERSION, build parallax in advance."
    return 1
  fi
  if [ -z "${PODMAN_VERSION}" ]
  then
    echo "Error: Cannot find \$PODMAN_VERSION, build podman in advance."
    return 1
  fi
  if [ -z "${SQUASHFUSE_VERSION}" ]
  then
    echo "Error: Cannot find \$SQUASHFUSE_VERSION, build squashfuse in advance."
    return 1
  fi
}
get_artifacts_versions
check_artifacts_versions || exit 1

mkdir -p ${SRC_DIR}/rpmbuild
cd ${SRC_DIR}/rpmbuild

INPUT_FILE="${SRC_DIR}/rpmbuild/input.json"

GIT_TAG="$(git describe --exact-match --tags 2>/dev/null)"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
GIT_COMMIT="$(git rev-parse HEAD)"

cat >${INPUT_FILE} <<EOF
{
  "version": "${VERSION}",
  "release": "${RELEASE}",
  "conmon_version": "${CONMON_VERSION}",
  "crun_version": "${CRUN_VERSION}",
  "parallax_version": "${PARALLAX_VERSION}",
  "podman_version": "${PODMAN_VERSION}",
  "squashfuse_version": "${SQUASHFUSE_VERSION}",
  "git_tag": "${GIT_TAG}",
  "git_branch": "${GIT_BRANCH}",
  "git_commit": "${GIT_COMMIT}"
}
EOF

CUSTOM_FILE="${SRC_DIR}/rpmbuild/custom.py"
cat >${CUSTOM_FILE} <<EOF
def j2_environment_params():
    return dict(
        # Remove whitespace around blocks
        trim_blocks=True,
        lstrip_blocks=True
    )
EOF

j2cli --customize ${CUSTOM_FILE} -f json ${THIS_DIR}/src/${BUILD_OS_NAME}/${PRODUCT}.spec.j2 ${INPUT_FILE} > ${SRC_DIR}/rpmbuild/${PRODUCT}.spec
j2cli --customize ${CUSTOM_FILE} -f json ${THIS_DIR}/src/sarus_env.j2 ${INPUT_FILE} > ${SRC_DIR}/rpmbuild/sarus_env
j2cli --customize ${CUSTOM_FILE} -f json ${THIS_DIR}/src/sarusmgr.j2 ${INPUT_FILE} > ${SRC_DIR}/rpmbuild/sarusmgr
j2cli --customize ${CUSTOM_FILE} -f json ${THIS_DIR}/src/setup.j2 ${INPUT_FILE} > ${SRC_DIR}/rpmbuild/setup

cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/j2 ./
cp -a ${THIS_DIR}/src/templates ./
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh

podman run --rm -ti -e PRODUCT=${PRODUCT} -v ${SRC_DIR}/rpmbuild:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION} /tmp/build_in_container.sh

# INSTALL
OUT_DIR="${PACKAGES_DIR}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/rpmbuild/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/rpmbuild/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/

#mkdir -p ${OUT_DIR}/RPMS/noarch
#mv ${SRC_DIR}/rpmbuild/rpm/RPMS/noarch/*.rpm ${OUT_DIR}/RPMS/noarch/

OUT_DIR="${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin"
mkdir -p ${OUT_DIR}
cp ${SRC_DIR}/rpmbuild/j2 ${OUT_DIR}/
cp ${SRC_DIR}/rpmbuild/sarusmgr ${OUT_DIR}/

OUT_DIR="${USERSPACE_DIR}/${SARUS_SUITE_DIR}/lib"
mkdir -p ${OUT_DIR}
cp ${SRC_DIR}/rpmbuild/sarus_env ${OUT_DIR}/

OUT_DIR="${USERSPACE_DIR}/${SARUS_SUITE_DIR}/lib/templates"
mkdir -p ${OUT_DIR}
cp ${SRC_DIR}/rpmbuild/templates/containers.conf.base.j2 ${OUT_DIR}/
cp ${SRC_DIR}/rpmbuild/templates/containers.conf.hpc.j2 ${OUT_DIR}/
cp ${SRC_DIR}/rpmbuild/templates/storage.conf.base.j2 ${OUT_DIR}/

# BUNDLE artifacts
OUT_DIR="${SCRIPT_DIR}/tmp/artifacts"
mkdir -p ${OUT_DIR}
cp ${SRC_DIR}/rpmbuild/setup ${OUT_DIR}/

cd ${USERSPACE_DIR}
tar czf ${OUT_DIR}/${PRODUCT}-${BUILD_OS}-${ARCH}-userspace.tar.gz ./

cd ${PACKAGES_DIR}/RPMS
tar czf ${OUT_DIR}/${PRODUCT}-${BUILD_OS}-${ARCH}-packages.tar.gz --transform 's/^\./sarus-suite/' ./

# CLEAN
rm -rf ${SRC_DIR}
