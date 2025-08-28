#!/bin/bash

function get_github_repo_latest_release() {
  local REPO="${1}"
  local URL="https://api.github.com/repos/${REPO}/releases/latest"
  ( curl -s ${URL} | jq -r ".tag_name" )
  return $?
}

function build_venv_j2cli() {
  pushd $SCRIPT_DIR >/dev/null

  if [ ! -f tmp/venv/bin/activate ]
  then
    # jinja2-cli
    mkdir -p ./tmp
    python3 -m venv tmp/venv
    source tmp/venv/bin/activate
    python3 -m pip install --upgrade pip &>/dev/null
    pip install j2cli &>/dev/null
  fi

  popd >/dev/null
}

function j2cli() {
  ARGS=$@	
  build_venv_j2cli
  source ${SCRIPT_DIR}/tmp/venv/bin/activate
  j2 $ARGS
  deactivate
}

function create_tmp_folders() {
  TMP_DIR="${SCRIPT_DIR}/tmp/${BUILD_OS}/${ARCH}"
  [ ! -d "${TMP_DIR}" ] && mkdir -p ${TMP_DIR}
  BUILD_DIR="${TMP_DIR}/build"
  [ ! -d "${BUILD_DIR}" ] && mkdir -p ${BUILD_DIR}
  USERSPACE_DIR="${TMP_DIR}/userspace"
  [ ! -d "${USERSPACE_DIR}" ] && mkdir -p ${USERSPACE_DIR}
  PACKAGES_DIR="${TMP_DIR}/packages"
  [ ! -d "${PACKAGES_DIR}" ] && mkdir -p ${PACKAGES_DIR}
  ARTIFACTS_DIR="${TMP_DIR}/artifacts"
  [ ! -d "${ARTIFACTS_DIR}" ] && mkdir -p ${ARTIFACTS_DIR}
}

ARCH=$(uname -m)

pushd $SCRIPT_DIR >/dev/null

. lib/build_os.sh

popd >/dev/null

