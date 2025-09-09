#!/usr/bin/bash

cd $(dirname $0)

# if it is not a texture-build container, update it
PACKAGES_FILE="build.packages"
if [ ! -f /etc/texture.build ] && [ -f "${PACKAGES_FILE}" ]
then
  PACKAGES=$(cat ${PACKAGES_FILE} | paste -s -d" ")
  zypper install -y ${PACKAGES}
fi

. ./release.cfg
. ./system.cfg

REPO="squashfuse"
GIT_REPO_URL="https://github.com/vasi/${REPO}.git"

if [ -n "${SQUASHFUSE_VERSION}" ]
then
  GIT_BRANCH="${SQUASHFUSE_VERSION}"
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

tag=$(git describe --always --tags)
echo "Git describe output: ${tag}"
clean_tag=${tag#v}  # Remove leading 'v' if present

if [[ "$clean_tag" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)-g([0-9a-f]+)$ ]]; then
  # git describe output is in the format: 0.5.1-7-gc8dbb79
  export SQUASHFUSE_VERSION="${BASH_REMATCH[1]}"
  export SQUASHFUSE_RELEASE="${BASH_REMATCH[2]}.g${BASH_REMATCH[3]}"
elif [[ "$clean_tag" == *-* ]]; then
  # git describe output is in the format: 0.5.1-2
  export SQUASHFUSE_VERSION=${clean_tag%%-*} # Everything before the first dash
  export SQUASHFUSE_RELEASE=${clean_tag##*-} # Everything after the last dash
else
  # git describe output is in the format: 0.5.1
  export SQUASHFUSE_VERSION=$clean_tag
  export SQUASHFUSE_RELEASE=1
fi

echo "Version for RPM build: ${SQUASHFUSE_VERSION}"
echo "Release for RPM build: ${SQUASHFUSE_RELEASE}"

mkdir -p rpm/SOURCES
tar --transform "s/^squashfuse/squashfuse-${SQUASHFUSE_VERSION}/" -czf rpm/SOURCES/squashfuse-${SQUASHFUSE_VERSION}.tar.gz ../squashfuse

ARCH="$(uname -m)"
test -e $ARCH || ln -s . $ARCH
rpmbuild --target=$ARCH --clean -ba -D"_topdir ${PWD}/rpm" ../squashfuse.spec
rm -r $ARCH rpm/BUILDROOT # rpm/SOURCES
