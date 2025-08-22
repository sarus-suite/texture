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

# BUILD Dependencies
build_venv_j2cli

if [ -z "$CONMON_VERSION" ]
then
  CONMON_VERSION=$(get_github_repo_latest_release containers/conmon)
fi

# BUILD
PRODUCT='conmon'
BUILD_OS_NAME='opensuse'
BUILD_OS_VERSION_ID='15.5'
BUILD_OS="${BUILD_OS_NAME}-${BUILD_OS_VERSION_ID}"
BIN="${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/${PRODUCT}"
mkdir -p ${SRC_DIR}/${BUILD_OS}
cd ${SRC_DIR}/${BUILD_OS}
cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh
podman run --rm -ti -e CONMON_VERSION=${CONMON_VERSION} -v ${SRC_DIR}:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION_ID} /tmp/${BUILD_OS}/build_in_container.sh

# INSTALL
mkdir -p ${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin
mv ${SRC_DIR}/${BUILD_OS}/conmon/bin/conmon ${BIN}

# BUILD RPM
mkdir -p ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
cd ${SRC_DIR}/${BUILD_OS}/${PRODUCT}

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

VERSION=${CONMON_VERSION}
RELEASE="0.${BUILD_OS_NAME}.${BUILD_OS_VERSION_ID}"
INPUT_FILE="${SRC_DIR}/${BUILD_OS}/${PRODUCT}/input.json"

cat >${INPUT_FILE} <<EOF
{
  "product": "${PRODUCT}",
  "version": "${VERSION}",
  "release": "${RELEASE}",
  "bindir": "/opt/${SARUS_SUITE_DIR}/bin",
  "bin": "/tmp/${PRODUCT}"
}
EOF

CUSTOM_FILE="${SRC_DIR}/${BUILD_OS}/${PRODUCT}/custom.py"
cat >${CUSTOM_FILE} <<EOF
def j2_environment_params():
    return dict(
        # Remove whitespace around blocks
        trim_blocks=True,
        lstrip_blocks=True
    )
EOF

source ${TMP_DIR}/venv/bin/activate
j2 --customize ${CUSTOM_FILE} -f json ${THIS_DIR}/src/${BUILD_OS_NAME}/${PRODUCT}.spec.j2 ${INPUT_FILE} > ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/${PRODUCT}.spec
deactivate

cp ${SCRIPT_DIR}/etc/release.cfg ./release.cfg
cp ${SCRIPT_DIR}/etc/system.cfg ./system.cfg
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_rpm_in_container.sh ./build_rpm_in_container.sh
cp ${BIN} ./${PRODUCT}

podman run --rm -ti -e PRODUCT=${PRODUCT} -v ${SRC_DIR}/${BUILD_OS}/${PRODUCT}:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION_ID} /tmp/build_rpm_in_container.sh

# INSTALL RPM
OUT_DIR="${ARTIFACTS_DIR}/packages/${BUILD_OS}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/

# CLEAN
rm -rf ${SRC_DIR}/${BUILD_OS}
rm -rf ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
