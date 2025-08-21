#!/bin/bash
#
# One build script to rule them all
# 

SCRIPT_DIR=$(readlink -f $(dirname $0))
cd $SCRIPT_DIR

PRODUCTS_TO_FETCH="crun parallax"
PRODUCTS_TO_BUILD="conmon podman squashfuse"
PRODUCTS_TO_BUILD_RPM="parallax"

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

PRODUCT="sarus-suite"
echo "Building ${SARUS_SUITE} RPM ..."
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

exit $RC
