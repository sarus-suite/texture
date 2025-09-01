load ./common

function setup_file() {
  export IMAGE_NAME='alpine'
  export MOUNT_PROGRAM="$(which parallax-mount-program.sh)"
  mkdir -p "/dev/shm/$USER"
  export TEST_DIR=$(mktemp -d -p /dev/shm/$USER)
  export GRAPHROOT="${TEST_DIR}/graphroot"
  export RUNROOT="${TEST_DIR}/runroot"
  export RO_IMAGESTORE="${TEST_DIR}/ro_imagestore"
  mkdir -p "${GRAPHROOT}"
  mkdir -p "${RUNROOT}"
  mkdir -p "${RO_IMAGESTORE}"
}

function teardown_file() {
  chmod +rw -R ${TEST_DIR}	  
  rm -rf ${TEST_DIR}
  rmdir "/dev/shm/$USER" 2>/dev/null || return 0    
}

@test "parallax version" {
    run parallax --version
    assert_output --partial 'arallax version'
}

@test "parallax migrate workflow" {

  # CHECK IMAGE EXISTENCE
  run -1 podman --root ${GRAPHROOT} --runroot ${RUNROOT} --storage-opt additionalimagestore=${RO_IMAGESTORE} --storage-opt mount_program=${MOUNT_PROGRAM} image exists ${IMAGE_NAME}

  # workaround current parallax issue 29 - https://github.com/sarus-suite/parallax/issues/29
  run -0 rm -rf ${RO_IMAGESTORE}/overlay-images

  # PULL LOCALLY
  run -0 podman --root ${GRAPHROOT} --runroot ${RUNROOT} pull ${IMAGE_NAME}

  # CHECK IMAGE EXISTENCE
  run -0 podman --root ${GRAPHROOT} --runroot ${RUNROOT} image exists ${IMAGE_NAME}
  
  # MIGRATE
  run -0 parallax --podmanRoot ${GRAPHROOT} --roStoragePath ${RO_IMAGESTORE} --migrate --image ${IMAGE_NAME}

  # CLEAN UP locally
  run -0 podman --root ${GRAPHROOT} --runroot ${RUNROOT} rmi ${IMAGE_NAME}

  # CHECK IMAGE EXISTENCE locally
  run -1 podman --root ${GRAPHROOT} --runroot ${RUNROOT} image exists ${IMAGE_NAME}
  
  # CHECK IMAGE EXISTENCE also remotely
  run -0 podman --root ${GRAPHROOT} --runroot ${RUNROOT} --storage-opt additionalimagestore=${RO_IMAGESTORE} --storage-opt mount_program=${MOUNT_PROGRAM} image exists ${IMAGE_NAME}
  
  # CLEAN UP remotely
  run -0 parallax --podmanRoot ${GRAPHROOT} --roStoragePath ${RO_IMAGESTORE} --rmi --image ${IMAGE_NAME} 
  
  # CHECK IMAGE EXISTENCE globally
  run -1 podman --root ${GRAPHROOT} --runroot ${RUNROOT} --storage-opt additionalimagestore=${RO_IMAGESTORE} --storage-opt mount_program=${MOUNT_PROGRAM} image exists ${IMAGE_NAME}

}
