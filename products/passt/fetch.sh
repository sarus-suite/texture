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

DOWNLOAD_DIR="${TMP_DIR}/download"
BASE_URL="https://download.opensuse.org/repositories/Virtualization:/containers/"

if [ -n "${PASST_VERSION}" ]
then
  VERSION_FILTER="${PASST_VERSION}"
else
  VERSION_FILTER='[[:digit:]]'
fi

PASST_RPM=$(curl -sL ${BASE_URL}/${BUILD_OS_VERSION}/${ARCH} | grep 'class="name"' | grep -E "passt-${VERSION_FILTER}" | sed 's/^.*<a [^>]*>\([^<]*\)<.*$/\1/' | tail -n 1)

PASST_VERSION=$(basename ${PASST_RPM} | awk -F- '{print $2}')

PASST_APPARMOR_RPM=$(curl -sL ${BASE_URL}/${BUILD_OS_VERSION}/noarch | grep 'class="name"' | grep -E "passt-apparmor-${PASST_VERSION}" | sed 's/^.*<a [^>]*>\([^<]*\)<.*$/\1/' | tail -n 1)

URL="${BASE_URL}/${BUILD_OS_VERSION}/${ARCH}/${PASST_RPM}"
mkdir -p ${DOWNLOAD_DIR}/${ARCH}
cd ${DOWNLOAD_DIR}/${ARCH}
curl -sOL ${URL}

URL="${BASE_URL}/${BUILD_OS_VERSION}/noarch/${PASST_APPARMOR_RPM}"
mkdir -p ${DOWNLOAD_DIR}/noarch
cd ${DOWNLOAD_DIR}/noarch
curl -sOL ${URL}

# INSTALL
OUT_DIR="${PACKAGES_DIR}"
mkdir -p ${OUT_DIR}/RPMS/${ARCH}
mv ${DOWNLOAD_DIR}/${ARCH}/passt-*.${ARCH}.rpm ${OUT_DIR}/RPMS/${ARCH}/
mkdir -p ${OUT_DIR}/RPMS/noarch
mv ${DOWNLOAD_DIR}/noarch/passt-apparmor*.noarch.rpm ${OUT_DIR}/RPMS/noarch/
