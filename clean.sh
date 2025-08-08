#!/bin/bash
#
# One build script to rule them all
# 

SCRIPT_DIR=$(readlink -f $(dirname $0))
cd $SCRIPT_DIR

rm -rf ${SCRIPT_DIR}/tmp
rm -rf ${SCRIPT_DIR}/artifacts
