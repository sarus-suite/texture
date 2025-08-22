#!/usr/bin/bash

cd $(dirname $0)
zypper install -y libseccomp-devel libgpgme-devel conmon libcontainers-common crun iptables netavark nftables slirp4netns go git libselinux-devel libseccomp-devel python3 man make libbtrfs-devel rpmdevtools gzip rpm-build glib2-devel fdupes glib2-devel-static go-go-md2man golang-packaging libapparmor-devel libostree-devel glibc-devel-static systemd systemd-devel
ln -s /usr/bin/rpmdev-spectool /usr/bin/spectool

. ./release.cfg
. ./system.cfg

REPO="podman"
GIT_REPO_URL="https://github.com/containers/${REPO}.git"
GIT_BRANCH="${PODMAN_VERSION}"
GIT_COMMIT=""

# FETCH
rm -rf ${REPO}

if [ -n "$GIT_BRANCH" ]
then
  GIT_BRANCH_OPT="--branch ${GIT_BRANCH}"
else
  GIT_BRANCH_OPT=""
fi

git clone ${GIT_BRANCH_OPT} ${GIT_REPO_URL} ${REPO}
cd ${REPO}

if [ -n "$GIT_COMMIT" ]
then
  git checkout ${GIT_COMMIT}
fi

cd ..
cp ./podman.spec ${REPO}/rpm/podman.spec
cp ./podman.conf ${REPO}/rpm/podman.conf

cd ${REPO}
make rpm
