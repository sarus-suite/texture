#!/usr/bin/bash

#cd $(dirname $0)
cd /tmp

# if it is not a texture-build container, update it
PACKAGES_FILE="build.packages"
if [ ! -f /etc/texture.build ] && [ -f "${PACKAGES_FILE}" ]
then	
  PACKAGES=$(cat ${PACKAGES_FILE} | paste -s -d" ")
  zypper install -y ${PACKAGES}
fi  

REPO="conmon"
cd ${REPO}

make
bin/conmon --version
