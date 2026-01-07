#! /bin/bash

cd $ROOT_DIR || exit 1

ARGS="--recursive --no-color --fix -f junit"

if [[ $FAIL_ON_ERROR == "true" ]]; then
  ARGS="$ARGS --minimum-failure-severity=warning"
else
  ARGS="$ARGS --force"
fi

tflint $ARGS | tee tflint-out.xml
