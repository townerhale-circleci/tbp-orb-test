#! /bin/bash -ex

TMP_DIR="$(mktemp -d)"
WORK_DIR="$TMP_DIR/infra"
ls -al $TMP_DIR

git clone git@github.com:pinginc/$REPO.git $WORK_DIR
cd $WORK_DIR || exit 1

echo $VERSION > ./versions/$ENVIRONMENT.txt

git add ./versions/
git diff --quiet --staged || git commit -m "chore(ci): deploy $VERSION to $ENVIRONMENT"
git diff
git stash push -u
git pull --rebase --no-edit origin main
git push --set-upstream origin main
