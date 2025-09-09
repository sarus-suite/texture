#!/usr/bin/bash

cd /tmp

# if it is not a texture-build container, update it
PACKAGES_FILE="run.packages"
if [ ! -f /etc/texture.build ] && [ -f "${PACKAGES_FILE}" ]
then
  PACKAGES=$(cat ${PACKAGES_FILE} | paste -s -d" ")
  zypper install -y ${PACKAGES}
fi

./conmon --version
