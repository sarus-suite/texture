# Installation

## Opensuse

    # Define required variables
    $ . /etc/os-release
    $ OS_NAME=$(echo $ID | sed 's/-leap$//')
    $ ARCH=$(uname -m)

    # Add repository to install opensuse dependencies (i.e. passt)
    $ zypper addrepo https://download.opensuse.org/repositories/Virtualization:/containers/${VERSION_ID} ${OS_NAME}-containers-${VERSION_ID}
    $ zypper --gpg-auto-import-keys refresh

    # Add local repository for sarus-suite
    $ zypper install -y createrepo_c tar gzip
    $ cd ~
    $ curl -sOL https://github.com/sarus-suite/texture/releases/latest/download/sarus-suite-${OS_NAME}-${VERSION_ID}-${ARCH}.tar.gz
    $ tar xvzf sarus-suite-${OS_NAME}-${VERSION_ID}-${ARCH}.tar.gz
    $ createrepo ~/sarus-suite
    $ zypper addrepo --no-gpgcheck -f file://${HOME}/sarus-suite sarus-suite

    # INSTALL
    $ zypper install -y sarus-suite
    
