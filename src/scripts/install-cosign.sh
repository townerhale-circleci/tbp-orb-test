#! /bin/bash

Install_Cosign() {
  shopt -s expand_aliases
  set -e

  export arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

  semver='^v([0-9]+\.){0,2}(\*|[0-9]+)$'
  if [[ ${COSIGN_VERSION} =~ $semver ]]; then
    echo "INFO: Custom Cosign Version ${COSIGN_VERSION}"
  else
    echo "ERROR: Unable to validate cosign version: '${COSIGN_VERSION}'"
    exit 1
  fi

  curl -svLO https://github.com/sigstore/cosign/releases/download/"${COSIGN_VERSION}"/cosign-linux-${arch}
  curl -svLO https://github.com/sigstore/cosign/releases/download/"${COSIGN_VERSION}"/cosign-linux-${arch}.sig
  curl -svLO https://raw.githubusercontent.com/sigstore/cosign/"${COSIGN_VERSION}"/release/release-cosign.pub
  
  # For now, we're using a binary to validate itself which is just wrong, but laziness purveils.
  cp -v cosign-linux-${arch} cosign
  chmod +x cosign
  if ! ./cosign verify-blob -key release-cosign.pub -signature cosign-linux-amd64.sig cosign-linux-amd64; then
    echo "Failed to verify cosign signature"
    exit 1
  fi

  mkdir -p "$HOME"/.cosign && mv cosign "$HOME"/.cosign/
  echo "export PATH=${HOME}/.cosign:$PATH" >> "$BASH_ENV"
  source "$BASH_ENV"
  cosign version
}

Install_Cosign
