#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)

. ${SCRIPT_DIR}/lib/common.sh

build_venv_j2cli
