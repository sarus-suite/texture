load ./common

@test "parallax version" {
    run parallax --version
    assert_output --partial 'arallax version'
}

@test "parallax migrate workflow" {

  function setup() {
    IMAGE_NAME='alpine'
    MOUNT_PROGRAM="$(which parallax-mount-program.sh)"
    PARALLAX="$(which parallax)"
    mkdir -p "/dev/shm/$USER"
    TEST_DIR=$(mktemp -d -p /dev/shm/$USER)
    GRAPHROOT="${TEST_DIR}/graphroot"
    RUNROOT="${TEST_DIR}/runroot"
    RO_IMAGESTORE="${TEST_DIR}/ro_imagestore"
    mkdir -p "${GRAPHROOT}"
    mkdir -p "${RUNROOT}"
    mkdir -p "${RO_IMAGESTORE}"
  }

  function clean_up() {
    rm -rf ${TEST_DIR}
    rmdir "/dev/shm/$USER" 2>/dev/null || return 0    
  }

  function run_workflow() {
    # CHECK IMAGE EXISTENCE
    podman --root ${GRAPHROOT} --runroot ${RUNROOT} --storage-opt additionalimagestore=${RO_IMAGESTORE} --storage-opt mount_program=${MOUNT_PROGRAM} image exists ${IMAGE_NAME}
    #RC=-1

    # PULL LOCALLY
    podman --root ${GRAPHROOT} --runroot ${RUNROOT} pull ${IMAGE_NAME}
    #RC=0

    # CHECK IMAGE EXISTENCE
    podman --root ${GRAPHROOT} --runroot ${RUNROOT} image exists ${IMAGE_NAME}
    #RC=0
  
    # MIGRATE
    ${PARALLAX} --podmanRoot ${GRAPHROOT} --roStoragePath ${RO_IMAGESTORE} --migrate --image ${IMAGE_NAME}
    #RC=0

    # CLEAN UP locally
    podman --root ${GRAPHROOT} --runroot ${RUNROOT} rmi ${IMAGE_NAME}
    #RC=0

    # CHECK IMAGE EXISTENCE locally
    podman --root ${GRAPHROOT} --runroot ${RUNROOT} image exists ${IMAGE_NAME}
    #RC=-1
  
    # CHECK IMAGE EXISTENCE also remotely
    podman --root ${GRAPHROOT} --runroot ${RUNROOT} --storage-opt additionalimagestore=${RO_IMAGESTORE} --storage-opt mount_program=${MOUNT_PROGRAM} image exists ${IMAGE_NAME}
    #RC=0
  
    # CLEAN UP remotely
    ${PARALLAX} --podmanRoot ${GRAPHROOT} --roStoragePath ${RO_IMAGESTORE} --rmi --image ${IMAGE_NAME} 
    #RC=0
  
    # CHECK IMAGE EXISTENCE globally
    podman --root ${GRAPHROOT} --runroot ${RUNROOT} --storage-opt additionalimagestore=${RO_IMAGESTORE} --storage-opt mount_program=${MOUNT_PROGRAM} image exists ${IMAGE_NAME}
    #RC=-1

  }

  setup
  run_workflow
  clean_up

}
