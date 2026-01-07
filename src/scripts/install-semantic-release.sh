#! /bin/bash

set -x

INSTALL_CMD="yarn add -D --ignore-workspace-root-check"
REMOVE_CMD="yarn remove --silent --skip-integrity-check"
if [ "$PACKAGE_MANAGER" = "npm" ]; then
  INSTALL_CMD="npm i --save-dev --force"
  REMOVE_CMD="npm uninstall --silent"
fi

if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
  INSTALL_CMD="pnpm add --save-dev"
  REMOVE_CMD="pnpm remove --silent"
fi

$REMOVE_CMD --silent --skip-integrity-check semantic-release-slack-bot || echo "package gone\!"

$INSTALL_CMD \
  "semantic-release@^25.0.0" \
  "conventional-changelog-conventionalcommits@^9.0.0"\
  "@semantic-release/changelog@^6.0.0" \
  "@semantic-release/git@^10.0.1" \
  "@semantic-release/github@^12.0.0" \
  "@semantic-release/npm@^13.1.0" \

if [ -z "$SLACK_WEBHOOK" ]; then
  echo "SLACK_WEBHOOK is not set, skipping semantic-release-slack-bot setup"
  exit 0
else
  $INSTALL_CMD "@timebyping/semantic-release-slack-bot@^1.1.4"
fi
