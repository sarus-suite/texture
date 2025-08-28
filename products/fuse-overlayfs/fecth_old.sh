#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
TMP_DIR="${SCRIPT_DIR}/tmp"
SRC_DIR="${TMP_DIR}/src"
ARTIFACTS_DIR="${SCRIPT_DIR}/artifacts"
SARUS_SUITE_DIR='sarus-suite'
BASE_URL="https://download.opensuse.org/distribution/leap"
cd $SCRIPT_DIR

. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg
. ${SCRIPT_DIR}/lib/common.sh


PRODUCT='fuse-overlayfs'
BUILD_OS_NAME='opensuse'
BUILD_OS_VERSION_ID='15.5'
BUILD_OS="${BUILD_OS_NAME}-${BUILD_OS_VERSION_ID}"

if [ -n "${FUSEOVERLAYFS_VERSION}" ]
then
  VERSION_FILTER="${FUSEOVERLAYFS_VERSION}"
else
  VERSION_FILTER='[[:digit:]]'
fi

#https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/fuse-overlayfs-1.1.2-3.9.1.x86_64.rpm
FUSEOVERLAYFS_RPM=$(curl -sL ${BASE_URL}/${BUILD_OS_VERSION_ID}/repo/oss/${ARCH} | grep 'class="name"' | grep -E "fuse-overlayfs-${VERSION_FILTER}" | sed 's/^.*<a [^>]*>\([^<]*\)<.*$/\1/' | tail -n 1)

FUSEOVERLAYFS_VERSION=$(basename ${FUSEOVERLAYFS_RPM} | awk -F- '{print $3}')

URL="${BASE_URL}/${BUILD_OS_VERSION_ID}/repo/oss/${ARCH}/${FUSEOVERLAYFS_RPM}"
mkdir -p ${TMP_DIR}/download/${BUILD_OS}/${ARCH}
cd ${TMP_DIR}/download/${BUILD_OS}/${ARCH}
curl -sOL ${URL}

# INSTALL
OUT_DIR="${ARTIFACTS_DIR}/packages/${BUILD_OS}"
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${TMP_DIR}/download/${BUILD_OS}/${ARCH}/fuse-overlayfs-*.${ARCH}.rpm ${OUT_DIR}/RPMS/${ARCH}/

# EXTRACT userspace binary
mkdir -p ${TMP_DIR}/${BUILD_OS}/${ARCH}/${PRODUCT}
cd ${TMP_DIR}/${BUILD_OS}/${ARCH}/${PRODUCT}
rpm2cpio ${OUT_DIR}/RPMS/${ARCH}/fuse-overlayfs-*.${ARCH}.rpm | cpio -imdv 2>/dev/null

OUT_DIR="${ARTIFACTS_DIR}/userspace/${BUILD_OS}/${ARCH}/${SARUS_SUITE_DIR}"
mkdir -p ${OUT_DIR}/bin
mv ${TMP_DIR}/${BUILD_OS}/${ARCH}/${PRODUCT}/usr/bin/fuse-overlayfs ${OUT_DIR}/bin/

# CLEAN
rm -rf ${TMP_DIR}/${BUILD_OS}/${ARCH}/${PRODUCT}
