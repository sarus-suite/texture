#!/usr/bin/bash

cd $(dirname $0)

. ./release.cfg
. ./system.cfg

if [ "$ARCH" == "x86_64" ]
then
  GOARCH="amd64"
else
  GOARCH="${ARCH}"
fi

zypper --non-interactive refresh && \
zypper --non-interactive update -y && \
zypper --non-interactive install -y \
  wget \
  tar \
  gzip \
  git \
  btrfsprogs \
  device-mapper-devel \
  libbtrfs-devel \
  squashfs \
  fuse-overlayfs \
  squashfuse \
  inotify-tools \
  patterns-devel-base-devel_basis

# Go toolchain
GO_VERSION=1.24.0
set -eux; \
wget "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"; \
rm -rf /usr/local/go; \
tar -C /usr/local -xzf "go${GO_VERSION}.linux-${GOARCH}.tar.gz"; \
rm "go${GO_VERSION}.linux-${GOARCH}.tar.gz"

export PATH=$PATH:/usr/local/go/bin

REPO="parallax"
GIT_REPO_URL="https://github.com/sarus-suite/${REPO}.git"

if [ -n "${VERSION}" ]
then
  GIT_BRANCH="${VERSION}"
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

echo "--- all GO* vars ---"
env | grep '^GO' || true
echo "--- go env ---"
go env

go get .

CGO_ENABLED="1"
CC=gcc
GOOS=linux
GOFLAGS="-buildvcs=false"
GO_LDFLAGS="-linkmode external"
CGO_LDFLAGS="-g -O2"

mkdir -p dist
go build -v -x \
-ldflags "-X 'github.com/sarus-suite/parallax/version.Version=${VERSION}'" \
-o dist/parallax \

file dist/parallax
readelf -l dist/parallax | grep interpreter || true
ldd dist/parallax || echo "static :/"
