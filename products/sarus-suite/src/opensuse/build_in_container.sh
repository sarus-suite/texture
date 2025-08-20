#!/usr/bin/bash

cd $(dirname $0)
zypper --non-interactive install rpm-build

. ./release.cfg
. ./system.cfg

ARCH="$(uname -m)"
test -e $ARCH || ln -s . $ARCH
mkdir -p ${PWD}/sarus-suite/rpm
rpmbuild --target=$ARCH --clean -ba -D"_topdir ${PWD}/sarus-suite/rpm"  ./sarus-suite.spec
