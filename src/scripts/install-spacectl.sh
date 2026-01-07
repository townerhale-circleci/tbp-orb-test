#! /bin/bash

echo "Checking for spacectl"
arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if command -v spacectl &> /dev/null; then
    echo "spacectl already installed"
    version=$(spacectl -v | awk '{print $3}')
    if [ "$version" != "$SPACECTL_VERSION" ]; then
        echo "spacectl version mismatch. Installed: $version, Expected: $SPACECTL_VERSION. Installing $SPACECTL_VERSION."
        rm -rf spacectl*
    else
        exit 0
    fi
fi
wget "https://github.com/spacelift-io/spacectl/releases/download/v${SPACECTL_VERSION}/spacectl_${SPACECTL_VERSION}_linux_${arch}.zip"
unzip spacectl_${SPACECTL_VERSION}_linux_${arch}.zip -d ./spacectl
mv spacectl/spacectl /home/circleci/bin/spacectl
