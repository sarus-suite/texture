# Go toolchain
ARG GO_VERSION=1.24.0
RUN set -eux; \
    UNAME_M="$(uname -m)"; \
    case "${UNAME_M}" in \
      x86_64) GOARCH=amd64;; \
      aarch64) GOARCH=arm64;; \
      *) echo "unsupported arch: ${UNAME_M}"; exit 1;; \
    esac; \
    wget "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"; \
    rm -rf /usr/local/go; \
    tar -C /usr/local -xzf "go${GO_VERSION}.linux-${GOARCH}.tar.gz"; \
    rm "go${GO_VERSION}.linux-${GOARCH}.tar.gz"

ENV PATH=$PATH:/usr/local/go/bin
