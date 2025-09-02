#!/usr/bin/bash

cd $(dirname $0)
zypper install -y libseccomp-devel libgpgme-devel conmon libcontainers-common crun iptables netavark nftables slirp4netns go git libselinux-devel libseccomp-devel python3 man make libbtrfs-devel rpmdevtools gzip rpm-build glib2-devel fdupes glib2-devel-static go-go-md2man golang-packaging libapparmor-devel libostree-devel glibc-devel-static systemd systemd-devel
ln -s /usr/bin/rpmdev-spectool /usr/bin/spectool

cd ${PRODUCT}
make rpm
