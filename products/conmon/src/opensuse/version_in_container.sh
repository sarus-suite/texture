#!/usr/bin/bash

cd /tmp
zypper install -y libseccomp2 &>/dev/null

./conmon --version
