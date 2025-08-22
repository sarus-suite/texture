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
    python3 -m pip install --upgrade pip
    pip install j2cli
  fi

  popd >/dev/null
}
