#! /bin/bash -ex

cd $ROOT_DIR
git add .
git diff --quiet --staged || git commit -m "docs(terraform): generate documentation updates"
git pull --ff-only --no-edit origin $CIRCLE_BRANCH
git push --set-upstream origin $CIRCLE_BRANCH
