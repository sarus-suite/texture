#!/bin/bash
#
# One build script to rule them all
# 

SCRIPT_DIR=$(readlink -f $(dirname $0))

function print_help() {
  cat <<EOF

  Usage: $SCRIPTNAME <OPTIONS>

  Options:
    --build : do not clean artifacts

EOF
}

function parse_args() {
  [ $# -eq 0 ] && return

  case "$1" in
    "--build")
      BUILD="yes"
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

parse_args $@

cd $SCRIPT_DIR

if [ "${BUILD}" == "yes" ]
then
  [ -d tmp ] && find tmp -maxdepth 1 -mindepth 1 ! -name artifacts -exec rm -rf {} \; || true
else
  rm -rf tmp
fi
