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

if [ -z "$CONMON_VERSION" ]
then
  CONMON_VERSION=$(get_github_repo_latest_release containers/conmon)
fi

# BUILD
SRC_DIR="${BUILD_DIR}/${PRODUCT}/src"
BIN="${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin/${PRODUCT}"

mkdir -p ${SRC_DIR}
cd ${SRC_DIR}
cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh
podman run --rm -ti -e CONMON_VERSION=${CONMON_VERSION} -v ${SRC_DIR}:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION} /tmp/build_in_container.sh

# INSTALL
mkdir -p ${USERSPACE_DIR}/${SARUS_SUITE_DIR}/bin
mv ${SRC_DIR}/conmon/bin/conmon ${BIN}

# BUILD RPM
if [ ! -f ${BIN} ]
then
  echo "ERROR: cannot build ${PRODUCT}"
  exit 1
fi

function get_artifacts_versions() {
  unset CONMON_VERSION
  CONMON_VERSION=$(${BIN} --version | awk '/conmon version /{print $NF}')
  GIT_COMMIT=$(${BIN} --version | awk '/commit: /{print $NF}')
}

function check_artifacts_versions() {
  if [ -z "${CONMON_VERSION}" ]
  then
    echo "Error: Cannot find \$CONMON_VERSION, fetch crun in advance."
    return 1
  fi
}
get_artifacts_versions
check_artifacts_versions || exit 1

mkdir -p ${SRC_DIR}/rpmbuild
cd ${SRC_DIR}/rpmbuild

VERSION=${CONMON_VERSION}
RELEASE="0.${BUILD_OS_NAME}.${BUILD_OS_VERSION}"
INPUT_FILE="${SRC_DIR}/rpmbuild/input.json"

cat >${INPUT_FILE} <<EOF
{
  "product": "${PRODUCT}",
  "version": "${VERSION}",
  "release": "${RELEASE}",
  "bindir": "/opt/${SARUS_SUITE_DIR}/bin",
  "bin": "/tmp/${PRODUCT}"
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

cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_rpm_in_container.sh ./build_rpm_in_container.sh
cp ${BIN} ./${PRODUCT}

podman run --rm -ti -e PRODUCT=${PRODUCT} -v ${SRC_DIR}/rpmbuild:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION} /tmp/build_rpm_in_container.sh

# INSTALL RPM
OUT_DIR="${PACKAGES_DIR}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/rpmbuild/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/rpmbuild/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/

# CLEAN
rm -rf ${SRC_DIR}
