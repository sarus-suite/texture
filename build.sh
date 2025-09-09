#!/bin/bash
#
# One build script to rule them all
# 

SCRIPTNAME="$(basename $0)"
SCRIPT_DIR=$(readlink -f $(dirname $0))
cd $SCRIPT_DIR

PRODUCTS_TO_FETCH="crun fuse-overlayfs parallax passt"
PRODUCTS_TO_BUILD="conmon podman squashfuse"
PRODUCTS_TO_BUILD_RPM="conmon crun fuse-overlayfs parallax"
FINAL_PRODUCT_TO_BUILD="sarus-suite"

function print_help() {
  cat <<EOF

  Usage: $SCRIPTNAME <OPTIONS>

  Options:
    --build-os <OS> : build artifacts for a specific OS.
                      Default: $DEFAULT_BUILD_OS
                      Supported build OSes: ${SUPPORTED_BUILD_OS}


EOF
}

function parse_args() {
  [ $# -eq 0 ] && return

  case "$1" in
    "--build-os")
      shift
      BUILD_OS="$1"
      [ -z "${BUILD_OS}" ] && echo "ERROR: unspecified build os" && exit 1
      shift
      ;;
    "--help"|"-h")
      print_help
      exit 0
      ;;
    *)
     echo "ERROR: unrecognized option: \"$1\""
     print_help
     exit 1
     ;;
  esac	
}

function check_input() {
  check_build_os || exit 1
  export BUILD_OS
  check_build_container_image || exit 1
}

. lib/common.sh

parse_args $@ || exit 1
check_input || exit 1

. etc/release.cfg

cd products
for PRODUCT in ${PRODUCTS_TO_FETCH}
do
  echo "Fetching ${PRODUCT} ..."
  echo 
  ${PRODUCT}/fetch.sh
  RC=$?
  if [ $RC -eq 0 ]
  then
    RESULT="succeeded"
  else
    RESULT="failed"
  fi
  echo
  echo "${PRODUCT} fetching ${RESULT}. RC=$RC"
  echo
  if [ $RC -ne 0 ]
  then
    break
  fi
done

for PRODUCT in ${PRODUCTS_TO_BUILD}
do
  echo "Building ${PRODUCT} ..."
  echo 
  ${PRODUCT}/build.sh
  RC=$?
  if [ $RC -eq 0 ]
  then
    RESULT="succeeded"
  else
    RESULT="failed"
  fi
  echo
  echo "${PRODUCT} building ${RESULT}. RC=$RC"
  echo
  if [ $RC -ne 0 ]
  then
    break
  fi
done

for PRODUCT in ${PRODUCTS_TO_BUILD_RPM}
do
  echo "Building ${PRODUCT} RPM ..."
  echo 
  ${PRODUCT}/build_rpm.sh
  RC=$?
  if [ $RC -eq 0 ]
  then
    RESULT="succeeded"
  else
    RESULT="failed"
  fi
  echo
  echo "${PRODUCT} RPM building ${RESULT}. RC=$RC"
  echo
  if [ $RC -ne 0 ]
  then
    break
  fi
done

for PRODUCT in ${FINAL_PRODUCT_TO_BUILD}
do
  echo "Building ${PRODUCT} RPM ..."
  echo
  ${PRODUCT}/build.sh
  RC=$?
  if [ $RC -eq 0 ]
  then
    RESULT="succeeded"
  else
    RESULT="failed"
  fi
  echo
  echo "${PRODUCT} RPM building ${RESULT}. RC=$RC"
  echo
done

exit $RC
