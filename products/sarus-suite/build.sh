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

# BUILD DEPENDENCIES
${THIS_DIR}/build_deps.sh

# BUILD
PRODUCT='sarus-suite'
BUILD_OS_NAME='opensuse'
BUILD_OS_VERSION_ID='15.5'
BUILD_OS="${BUILD_OS_NAME}-${BUILD_OS_VERSION_ID}"
VERSION=$(git describe --tags --always)
RELEASE="0.${BUILD_OS_NAME}.${BUILD_OS_VERSION_ID}"
mkdir -p ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
cd ${SRC_DIR}/${BUILD_OS}/${PRODUCT}

function get_artifacts_versions() {
  unset PODMAN_VERSION	
  unset SQUASHFUSE_VERSION	
}

function check_artifacts_versions() {
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


INPUT_FILE="${SRC_DIR}/${BUILD_OS}/${PRODUCT}/input.json"

cat >${INPUT_FILE} <<EOF
{
  "version": "${VERSION}",
  "release": "${RELEASE}",
  "podman_version": "${PODMAN_VERSION}",
  "squashfuse_version": "${SQUASHFUSE_VERSION}"
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
cp ${THIS_DIR}/src/${BUILD_OS_NAME}/build_in_container.sh ./build_in_container.sh

podman run --rm -ti -v ${SRC_DIR}:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION_ID} /tmp/${BUILD_OS}/build_in_container.sh

# INSTALL
OUT_DIR="${ARTIFACTS_DIR}/packages/${BUILD_OS}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/
#mkdir -p ${OUT_DIR}/RPMS/noarch
#mv ${SRC_DIR}/${BUILD_OS}/${PRODUCT}/rpm/RPMS/noarch/*.rpm ${OUT_DIR}/RPMS/noarch/

# CLEAN
#rm -rf ${SRC_DIR}/${BUILD_OS}/${PRODUCT}
