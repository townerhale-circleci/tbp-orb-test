#!/bin/sh
# https://danger.systems/js/reference.html
cat <<- "EOF" > dangerfile.ts
import { danger, warn, fail, markdown, message } from "danger";
import { checkTitle } from 'danger-plugin-prfect'

markdown("*NOTE*: This bot only reruns when CI is rerun. If you fix something and the error does not go away, rerun circle.");

// No PR is too small to include a description of why you made a change
if (danger.github.pr.body.length < 10) {
  fail('Please include a description of your PR changes.');
}

// Make sure Title is correct
// https://regexr.com/74aun
const matches = danger.github.pr.title.match(/^(?<type>\w*)(?:\((?<scope>.*)\))?!?:(\s(?<ticket>[a-zA-Z]{2,5}-\d{1,9}):?)?\s(?<subject>.*)$/);

if (matches) {
  const { type, scope, ticket, subject } = matches.groups;
  const labels = danger.github.issue.labels;

  // List all labels
  labels.map((x) => {
    message(`label: "${x.name}"`);
  });

  if (type === undefined) {
    fail("Type cannot be empty. Suggested value is feat.");
  } else {
    message(`type: "${type}"`);
  }

  message(`scope: ${scope === undefined ? "undefined" : `"${scope}"`}`);

  const validLabel = labels.find(x => x.name === "dependencies") !== undefined
  if (ticket === undefined && !validLabel) {
    warn("If this is a dependency update or automation, add the label `dependencies`. ");
  }

  // Check that someone has been assigned to this PR if not created with automated label
  if (!validLabel && danger.github.pr.assignee === null) {
    fail("Please assign someone to merge this PR, such as yourself.");
  }

  message(`subject: "${subject}"`);

  const author = danger.github.pr.user.login;
  checkTitle(subject, {
    titleLength: author !== "dependabot[bot]",
    returnOnly: false,
  });
} else {
  fail('Your PR title does not match the format "feat: ENG-2459: Description". See go/pr.');
}

// Validate Linear ticket
if (matches) {
  const { ticket } = matches.groups;
  const hasDepsLabel = danger.github.issue.labels.find(x => x.name === "dependencies") !== undefined;

  if (ticket && !hasDepsLabel) {
    const Authorization: string = process.env.LINEAR_API_KEY;
    if (!Authorization) {
      warn("LINEAR_API_KEY is unset; skipping Linear ticket validation");
    } else {
      const parts = ticket.split("-");
      const body = JSON.stringify({
        query: `
          query($teamKey: String!, $number: Float) {
            issues(filter: { number: { eq: $number }, team: { key: { eq: $teamKey } } }) {
              nodes { id }
            }
          }
        `,
        variables: {
          teamKey: parts[0],
          number: Number(parts[1]),
        },
      });

      (async () => {
        try {
          const res = await fetch("https://api.linear.app/graphql", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization,
            },
            body,
          });
          if (res.ok) {
            const json = await res.json();
            const nodes = json?.data?.issues?.nodes ?? [];
            if (Array.isArray(nodes) && nodes.length > 0) {
              message(`Linear ticket: ${ticket}`);
            } else {
              fail(`Linear ticket ${ticket} was not found`);
            }
          } else {
            warn(`Linear API request failed with status ${res.status}: ${await res.text()}`);
            return;
          }
        } catch (e) {
          warn(`Linear validation error: ${e instanceof Error ? e.message : String(e)}`);
        }
      })();
    }
  }
}
EOF
