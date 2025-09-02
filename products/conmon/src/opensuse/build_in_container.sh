#!/usr/bin/bash

#cd $(dirname $0)
cd /tmp
zypper install -y gcc git make glib2-devel glibc-devel libseccomp-devel pkgconfig runc systemd systemd-devel

REPO="conmon"
cd ${REPO}

make
bin/conmon --version
