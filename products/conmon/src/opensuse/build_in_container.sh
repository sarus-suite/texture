#!/usr/bin/bash

#cd $(dirname $0)
cd /tmp
zypper install -y gcc git make glib2-devel glibc-devel libseccomp-devel pkgconfig runc systemd systemd-devel

. ./release.cfg
. ./system.cfg

REPO="conmon"
GIT_REPO_URL="https://github.com/containers/${REPO}.git"

if [ -n "${CONMON_VERSION}" ]
then
  GIT_BRANCH="${CONMON_VERSION}"
fi
GIT_COMMIT=""

# FETCH
rm -rf ${REPO}

if [ -n "$GIT_BRANCH" ]
then
  GIT_BRANCH_OPT="--branch ${GIT_BRANCH} --depth 1"
else
  GIT_BRANCH_OPT=""
fi

git clone ${GIT_BRANCH_OPT} ${GIT_REPO_URL} ${REPO}
cd ${REPO}

if [ -n "$GIT_COMMIT" ]
then
  git checkout ${GIT_COMMIT}
fi

make
bin/conmon --version
