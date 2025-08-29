# Installation

## Opensuse

    # Define required variables
    $ . /etc/os-release
    $ OS_NAME=$(echo $ID | sed 's/-leap$//')
    $ ARCH=$(uname -m)

    # Add local repository for sarus-suite
    $ zypper install -y createrepo_c tar gzip
    $ cd ~
    $ curl -sOL https://github.com/sarus-suite/texture/releases/latest/download/sarus-suite-${OS_NAME}-${VERSION_ID}-${ARCH}-packages.tar.gz
    $ tar xvzf sarus-suite-${OS_NAME}-${VERSION_ID}-${ARCH}-packages.tar.gz
    $ createrepo ~/sarus-suite
    $ zypper addrepo --no-gpgcheck -f file://${HOME}/sarus-suite sarus-suite

    # INSTALL
    $ zypper install -y sarus-suite
    
