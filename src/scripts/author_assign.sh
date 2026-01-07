#! /bin/bash
#shellcheck disable=SC2027,SC2086

if (! command -v gh &> /dev/null)
then
    echo "gh not installed. add 'add-github-commiter' to your workflow"
    exit
fi

if [[ -n $(gh pr view $CIRCLE_PULL_REQUEST --json assignees | jq '.assignees') ]]
then
    issue_num=$(echo $CIRCLE_PULL_REQUESTS | awk -F "pull/" '{print $2}')
    curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/pinginc/$CIRCLE_PROJECT_REPONAME/issues/"$issue_num"/assignees" -d '{"assignees":["'$CIRCLE_USERNAME'"]}'
fi
