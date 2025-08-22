#!/bin/bash
# 
# Fetch the binary, just build a rpm.
#

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
TMP_DIR="${SCRIPT_DIR}/tmp"
SRC_DIR="${TMP_DIR}/src"
ARTIFACTS_DIR="${SCRIPT_DIR}/artifacts"
SARUS_SUITE_DIR='sarus-suite'
BASE_URL="https://github.com/containers/crun/releases/download"
cd $SCRIPT_DIR

. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg
. ${SCRIPT_DIR}/lib/common.sh

#BUILD DEPENDENCIES
build_venv_j2cli

# BUILD
PRODUCT='crun'
BUILD_OS_NAME='opensuse'
BUILD_OS_VERSION_ID='15.5'
BUILD_OS="${BUILD_OS_NAME}-${BUILD_OS_VERSION_ID}"
BIN="${ARTIFACTS_DIR}/${SARUS_SUITE_DIR}/bin/${PRODUCT}"
mkdir -p ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
cd ${SRC_DIR}/${BUILD_OS}/${PRODUCT}

if [ "$ARCH" == "x86_64" ]
then
  GARCH="amd64"
else
  GARCH="$ARCH"
fi

if [ ! -f ${BIN} ]
then
  ${THIS_DIR}/fetch.sh
  RC=$?
  if [ $RC -ne 0 ]
  then 
    echo "ERROR: cannot fetch ${PRODUCT} - RC:$RC"
    exit 1
  fi
fi

function get_artifacts_versions() {
  unset CRUN_VERSION
  CRUN_VERSION=$(${BIN} --version | awk '/crun version /{print $NF}')
  GIT_COMMIT=$(${BIN} --version | awk '/commit: /{print $NF}')
}

function check_artifacts_versions() {
  if [ -z "${CRUN_VERSION}" ]
  then
    echo "Error: Cannot find \$CRUN_VERSION, fetch crun in advance."
    return 1
  fi
}
get_artifacts_versions
check_artifacts_versions || exit 1

VERSION=${CRUN_VERSION}
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

# INSTALL
OUT_DIR="${ARTIFACTS_DIR}/packages/${BUILD_OS}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/

# CLEAN
rm -rf ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
