#!/bin/bash

THIS_DIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=$(readlink -f ${THIS_DIR}/../../)
cd $SCRIPT_DIR

# jinja2-cli
mkdir -p ./tmp
python3 -m venv tmp/venv
source tmp/venv/bin/activate
python3 -m pip install --upgrade pip
pip install j2cli
