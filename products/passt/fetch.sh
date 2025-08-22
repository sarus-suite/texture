#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
TMP_DIR="${SCRIPT_DIR}/tmp"
SRC_DIR="${TMP_DIR}/src"
ARTIFACTS_DIR="${SCRIPT_DIR}/artifacts"
SARUS_SUITE_DIR='sarus-suite'
BASE_URL="https://download.opensuse.org/repositories/Virtualization:/containers/"
cd $SCRIPT_DIR

. ${SCRIPT_DIR}/etc/release.cfg
. ${SCRIPT_DIR}/etc/system.cfg
. ${SCRIPT_DIR}/lib/common.sh


PRODUCT='passt'
BUILD_OS_NAME='opensuse'
BUILD_OS_VERSION_ID='15.5'
BUILD_OS="${BUILD_OS_NAME}-${BUILD_OS_VERSION_ID}"

if [ -n "${PASST_VERSION}" ]
then
  VERSION_FILTER="${PASST_VERSION}"
else
  VERSION_FILTER='[[:digit:]]'
fi

PASST_RPM=$(curl -sL ${BASE_URL}/${BUILD_OS_VERSION_ID}/${ARCH} | grep 'class="name"' | grep -E "passt-${VERSION_FILTER}" | sed 's/^.*<a [^>]*>\([^<]*\)<.*$/\1/' | tail -n 1)

PASST_VERSION=$(basename ${PASST_RPM} | awk -F- '{print $2}')

PASST_APPARMOR_RPM=$(curl -sL ${BASE_URL}/${BUILD_OS_VERSION_ID}/noarch | grep 'class="name"' | grep -E "passt-apparmor-${PASST_VERSION}" | sed 's/^.*<a [^>]*>\([^<]*\)<.*$/\1/' | tail -n 1)

URL="${BASE_URL}/${BUILD_OS_VERSION_ID}/${ARCH}/${PASST_RPM}"
mkdir -p ${TMP_DIR}/download/${BUILD_OS}/${ARCH}
cd ${TMP_DIR}/download/${BUILD_OS}/${ARCH}
curl -sOL ${URL}

URL="${BASE_URL}/${BUILD_OS_VERSION_ID}/noarch/${PASST_APPARMOR_RPM}"
mkdir -p ${TMP_DIR}/download/${BUILD_OS}/noarch
cd ${TMP_DIR}/download/${BUILD_OS}/noarch
curl -sOL ${URL}

# INSTALL
OUT_DIR="${ARTIFACTS_DIR}/packages/${BUILD_OS}"
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${TMP_DIR}/download/${BUILD_OS}/${ARCH}/passt-*.${ARCH}.rpm ${OUT_DIR}/RPMS/${ARCH}/
mkdir -p ${OUT_DIR}/RPMS/noarch
mv ${TMP_DIR}/download/${BUILD_OS}/noarch/passt-apparmor*.noarch.rpm ${OUT_DIR}/RPMS/noarch/

