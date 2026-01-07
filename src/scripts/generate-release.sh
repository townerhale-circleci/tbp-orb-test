#! /bin/bash
#
# Take arguments and create or change release config.
#
# Further Reading:
# - https://github.com/UpHabit/semantic-release-jira-releases
# - https://github.com/semantic-release/github
# - https://semantic-release.gitbook.io/semantic-release/usage/configuration
# - https://github.com/semantic-release/commit-analyzer/blob/master/lib/default-release-rules.js

set -ex

function create-releaserc() {
  cat <<- "EOF" | jq . > .releaserc.json
  {
    "branches": [],
    "extends": [],
    "plugins": [
      [
        "@semantic-release/commit-analyzer",
        {
          "preset": "conventionalcommits",
          "releaseRules": [
            { "breaking": true,      "release": "major" },
            { "revert": true,        "release": "patch" },
            { "type": "feat",        "release": "minor" },
            { "type": "fix",         "release": "patch" },
            { "type": "perf",        "release": "patch" },
            { "message": "*",        "release": "patch" },
            { "subject": "*",        "release": "patch" },
            { "scope": "no-release", "release": false   }
          ]
        }
      ],
      [
        "@semantic-release/release-notes-generator",
        {
          "preset": "conventionalcommits",
          "presetConfig": {
            "types": [
              {"type": "feat",     "section": "Features"},
              {"type": "fix",      "section": "Bug Fixes"},
              {"type": "chore",    "section": "Other"},
              {"type": "docs",     "section": "Other"},
              {"type": "style",    "section": "Other"},
              {"type": "refactor", "section": "Other"},
              {"type": "perf",     "section": "Other"},
              {"type": "test",     "section": "Other"},
              {"type": "",         "section": "Other"}
            ]
          },
          "linkReferences": false
        }
      ],
      [
        "@semantic-release/changelog",
        {
          "changelogTitle": "# Changelog\n\nSee\n[PR Guidelines](http://go/pr) for commit guidelines."
        }
      ]
    ]
  }
EOF

  jq --arg branch $RELEASERC_BRANCH '.branches += [{ name: $branch }]' .releaserc.json | sponge .releaserc.json
}

# https://github.com/semantic-release/github/blob/master/README.md
function add-github() {
  cat <<- "EOF" | cat .releaserc.json - | jq -s '{ branches: .[0].branches, extends: .[0].extends, plugins: (.[0].plugins + .[1].plugins) }' | sponge .releaserc.json
    {
      "plugins": [
        [
          "@semantic-release/github",
          {
            "assets": [],
            "failComment": false,
            "failTitle": false
          }
        ]
      ]
    }
EOF
}

# https://github.com/semantic-release/npm/blob/master/README.md
function add-npm() {
  cat <<- "EOF" | cat .releaserc.json - | jq -s '{ branches: .[0].branches, extends: .[0].extends, plugins: (.[0].plugins + .[1].plugins) }' | sponge .releaserc.json
    {
      "plugins": [
         [
           "@semantic-release/npm",
           {
           }
        ]
      ]
    }
EOF
}

function add-end() {
  cat <<- "EOF" | cat .releaserc.json - | jq -s '{ branches: .[0].branches, extends: .[0].extends, plugins: (.[0].plugins + .[1].plugins) }' | sponge .releaserc.json
    {
      "plugins": [
        [
          "@semantic-release/git",
          {
            "assets": [
              "CHANGELOG.md",
              "package.json",
              "yarn.lock"
            ],
            "message": "chore(release): releases ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
          }
        ],
        [
           "@timebyping/semantic-release-slack-bot",
           {
              "notifyOnSuccess": true,
              "slackChannel": "release-notifications"
           }
        ]
      ]
    }
EOF
}

function add-end-muted() {
  cat <<- "EOF" | cat .releaserc.json - | jq -s '{ branches: .[0].branches, extends: .[0].extends, plugins: (.[0].plugins + .[1].plugins) }' | sponge .releaserc.json
    {
      "plugins": [
        [
          "@semantic-release/git",
          {
            "assets": [
              "CHANGELOG.md",
              "package.json",
              "yarn.lock",
              "package-lock.json"
            ],
            "message": "chore(release): releases ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
          }
        ]
      ]
    }
EOF
}

command=$RELEASERC_COMMAND
echo "Running command on .releaserc.json: $command"

case $command in
  create)
    create-releaserc
    ;;

  add-github)
    add-github
    ;;

  add-npm)
    add-npm
    ;;

  add-end)
    if [ -z "$SLACK_WEBHOOK" ]; then
      add-end-muted
    else
      add-end
    fi
    ;;

  *)
    echo "\"$command\" is not a valid command."
    echo "usage: $0 [create, add-github, add-npm, add-end]"
    exit 1
    ;;
esac
