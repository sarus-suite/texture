#!/usr/bin/bash

cd $(dirname $0)

ARCH=$(uname -m)

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
cd ${REPO}

if [ -z "${VERSION}" ]
then
  VERSION=$(git describe --always --tags)	
fi	
COMMIT=$(git rev-parse HEAD)

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
BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

go build -v -x \
-ldflags "$GO_LDFLAGS \
-X=parallax/common.Version=${VERSION} \
-X=parallax/common.Commit=${COMMIT} \
-X=parallax/common.BuildDate=${BUILD_DATE}" \
-o dist/parallax

file dist/parallax
readelf -l dist/parallax | grep interpreter || true
ldd dist/parallax || echo "static :/"
