#!/usr/bin/bash

SUPPORTED_BUILD_OS="opensuse-15.5"
DEFAULT_BUILD_OS="opensuse-15.5"

function check_build_os() {

  if [ "$USERSPACE_RUN" == "yes" ]
  then
    BUILD_OS=${OS}  	  
  fi

  # Set defaults
  if [ -z "${BUILD_OS}" ]
  then
    BUILD_OS=${DEFAULT_BUILD_OS}
  fi

  if ! (echo ",${SUPPORTED_BUILD_OS}," | grep -q ",${BUILD_OS},")
  then
    echo "ERROR: Unsupported build-os, please choose one from: ${SUPPORTED_BUILD_OS}"
    return 1
  fi

  case ${BUILD_OS} in
    opensuse-*)
       BUILD_OS_NAME='opensuse'
       BUILD_OS_VERSION=$(echo $BUILD_OS | sed 's/^[^-]*-//')
       ;;
  esac
}
