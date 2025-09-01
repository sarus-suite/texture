# Userspace

## Setup

    curl -sL https://github.com/sarus-suite/texture/releases/latest/download/setup | sh
    . sarus-suite/lib/sarus_env

## Test
    sarusmgr test

## Clean-up userspace setup
    
    sarus_env_deactivate
    rm -rf sarus-suite
