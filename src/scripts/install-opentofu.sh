#! /bin/bash

set -ex

# Check if tofu command exists and if the version matches
if command -v tofu &> /dev/null; then
    # Handle potential multi-line output from 'tofu version'
    INSTALLED_VERSION=$(tofu version | head -n 1 | grep 'OpenTofu v' | awk '{print $2}' | sed 's/v//' || echo "unknown")
    if [ "$INSTALLED_VERSION" = "$OPENTOFU_VERSION" ]; then
        echo "OpenTofu version $OPENTOFU_VERSION is already installed."
        exit 0
    elif [ "$INSTALLED_VERSION" != "unknown" ]; then
        echo "Found OpenTofu version $INSTALLED_VERSION, but expected $OPENTOFU_VERSION. Proceeding with installation."
    else
        echo "Could not determine installed OpenTofu version. Proceeding with installation."
    fi
else
    echo "OpenTofu not found. Proceeding with installation."
fi

# Define architecture and OS
export ARCH=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
export OS_NAME="linux"

# Construct the download URL
DOWNLOAD_URL="https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_${OS_NAME}_${ARCH}.zip"

echo "Downloading OpenTofu version ${OPENTOFU_VERSION} for ${OS_NAME}/${ARCH} from ${DOWNLOAD_URL}"

# Create a temporary directory for download and extraction
TEMP_DIR=$(mktemp -d)

# Download, extract, and install OpenTofu
curl -fL "$DOWNLOAD_URL" -o "$TEMP_DIR/tofu.zip"
unzip "$TEMP_DIR/tofu.zip" -d "$TEMP_DIR"

# Ensure the binary exists before moving
if [ -f "$TEMP_DIR/tofu" ]; then
    sudo mv "$TEMP_DIR/tofu" /usr/local/bin/tofu
else
    echo "Error: 'tofu' binary not found in the downloaded archive."
    rm -rf "$TEMP_DIR" # Clean up temp dir
    exit 1
fi

# Clean up
rm -rf "$TEMP_DIR"

# Verify installation
echo "Verifying installation..."
tofu version
