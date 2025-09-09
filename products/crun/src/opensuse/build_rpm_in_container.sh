#!/usr/bin/bash

cd $(dirname $0)

# if it is not a texture-build container, update it
PACKAGES_FILE="build_rpm.packages"
if [ ! -f /etc/texture.build ] && [ -f "${PACKAGES_FILE}" ]
then
  PACKAGES=$(cat ${PACKAGES_FILE} | paste -s -d" ")
  zypper install -y ${PACKAGES}
fi

. ./release.cfg
. ./system.cfg

ARCH="$(uname -m)"
test -e $ARCH || ln -s . $ARCH
mkdir -p ${PWD}/rpm
rpmbuild --target=$ARCH --clean -ba -D"_topdir ${PWD}/rpm"  ./${PRODUCT}.spec
