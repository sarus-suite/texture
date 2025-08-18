#!/bin/bash

function get_github_repo_latest_release() {
  local REPO="${1}"
  local URL="https://api.github.com/repos/${REPO}/releases/latest"
  ( curl -s ${URL} | jq -r ".tag_name" )
  return $?
}
