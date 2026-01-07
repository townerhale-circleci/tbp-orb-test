#!/bin/bash

#code based on: https://federicoterzi.com/blog/solving-github-status-stuck-on-pending-with-circlecis-approvals/

set -e

echo "Patching approval job named: $CIRCLE_JOB"

for i in {1..10}
do
  echo "waiting for status to appear. $i"

  sleep 10

  echo "getting workflow name"
  curl -s --request GET \
    --url "https://circleci.com/api/v2/workflow/$CIRCLE_WORKFLOW_ID" \
    --header 'Accept: application/vnd.github.v3+json' \
    --header "Circle-Token: $CIRCLE_TOKEN" > workflow-info.json

  cat workflow-info.json
  CIRCLECI_WORKFLOW_NAME=$(cat workflow-info.json| jq -r  '.name')
  CIRCLECI_JOB_NAME="$CIRCLECI_WORKFLOW_NAME/$TARGET_JOB"

  echo "getting commit statuses"
  curl -s --request GET \
    --url "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/statuses/$CIRCLE_SHA1" \
    --header 'Accept: application/vnd.github.v3+json' \
    --header "Authorization: Bearer $GITHUB_TOKEN" > commit-statuses.json

  jq -r '.[].context' commit-statuses.json | tee commit-statuses.txt

  echo "finding status..."
  if grep -q "ci/circleci: $CIRCLECI_JOB_NAME" "commit-statuses.txt"; then
    echo "status appeared, patching the pending state"
    URL=$(cat commit-statuses.json| jq -r --arg name "$CIRCLECI_JOB_NAME" -c 'map(select(.context | contains($name))) | .[].target_url' | head -1)

    echo sending status update to github
    curl -s --request POST \
      --url "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/statuses/$CIRCLE_SHA1" \
      --header 'Accept: application/vnd.github.v3+json' \
      --header "Authorization: Bearer $GITHUB_TOKEN" \
      --header 'Content-Type: application/json' \
      --data '{
        "state": "success",
        "target_url": "'"$URL"'",
        "description": "Patched pending state, please visit circleCI to start the approval.",
        "context": "ci/circleci: '"$CIRCLECI_JOB_NAME"'"
      }'

    exit 0
  fi
done

echo "Could not patch CircleCI approval, timed out"
echo "Job name = $CIRCLECI_JOB_NAME"
echo "Project username = $CIRCLE_PROJECT_USERNAME"
echo "Project repo name = $CIRCLE_PROJECT_REPONAME"