#! /bin/bash -ex

cd $ROOT_DIR
git add .
git rm -f tflint-out.xml || true
git diff --quiet --staged || git commit -m "docs(terraform): lint files"
git diff
git stash push -u
git pull --rebase --no-edit origin $CIRCLE_BRANCH
git push --set-upstream origin $CIRCLE_BRANCH
