#! /bin/bash

set -ex

# get binary from coreutils arch command
export arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
export BINARY=yq_linux_${arch}

# Install yq
# example: https://github.com/mikefarah/yq/releases/download/v4.44.6/yq_linux_amd64.tar.gz
curl -svL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/${BINARY}.tar.gz | tar xz
sudo mv -v ${BINARY} /usr/bin/yq
