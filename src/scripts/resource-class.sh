#! /bin/sh

echo 'export RESOURCE_CLASS="$(($PLATFORM == "linux/amd64" ? "2xlarge" : "arm.2xlarge"))' >> $BASH_ENV
