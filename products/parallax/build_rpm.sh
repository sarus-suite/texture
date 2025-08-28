#!/bin/bash
# 
# Fetch the binary, just build a rpm.
#

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

mkdir -p ${SRC_DIR}
cd ${SRC_DIR}

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

function check_artifacts_versions() {
  if [ -z "${PARALLAX_VERSION}" ]
  then
    # setting the latest release
    # TODO: FIX IT after https://github.com/sarus-suite/parallax/issues/22
    REPO="sarus-suite/${PRODUCT}"
    PARALLAX_VERSION=$(get_github_repo_latest_release ${REPO})
    if [ -z "${PARALLAX_VERSION}" ]
    then
      echo "Error: Cannot find \$PARALLAX_VERSION."
      return 1
    fi
  fi
}
#get_artifacts_versions
check_artifacts_versions || exit 1

mkdir -p ${SRC_DIR}/rpmbuild
cd ${SRC_DIR}/rpmbuild

VERSION=${PARALLAX_VERSION}
RELEASE="0.${BUILD_OS_NAME}.${BUILD_OS_VERSION}"
INPUT_FILE="${SRC_DIR}/rpmbuild/input.json"

cat >${INPUT_FILE} <<EOF
{
  "product": "${PRODUCT}",
  "version": "${VERSION}",
  "release": "${RELEASE}",
  "bindir": "/opt/${SARUS_SUITE_DIR}/bin",
  "srcdir": "/tmp"
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
cp ${BIN}-mount-program.sh ./${PRODUCT}-mount-program.sh

podman run --rm -ti -e PRODUCT=${PRODUCT} -v ${SRC_DIR}/rpmbuild:/tmp docker.io/${BUILD_OS_NAME}/leap:${BUILD_OS_VERSION} /tmp/build_rpm_in_container.sh

# INSTALL
OUT_DIR="${PACKAGES_DIR}"
mkdir -p ${OUT_DIR}/SRPMS
mv ${SRC_DIR}/rpmbuild/rpm/SRPMS/*.rpm ${OUT_DIR}/SRPMS/
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${SRC_DIR}/rpmbuild/rpm/RPMS/${ARCH}/*.rpm ${OUT_DIR}/RPMS/${ARCH}/

# CLEAN
rm -rf ${SRC_DIR}
