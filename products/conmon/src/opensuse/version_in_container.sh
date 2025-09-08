#!/usr/bin/bash

cd /tmp
zypper install -y libsystemd0 libseccomp2 &>/dev/null

./conmon --version
