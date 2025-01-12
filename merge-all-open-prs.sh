#!/usr/bin/env bash

# Fetch all open pull requests
OPEN_PRS=$(gh pr list --state open --json number --jq '.[].number')

if [ -z "$OPEN_PRS" ]; then
  echo "No open pull requests found."
  exit 0
fi

echo "Merging the following PRs: $OPEN_PRS"

# Loop through each PR number and merge it
for PR_NUMBER in $OPEN_PRS; do
  echo "Merging PR #$PR_NUMBER"
  
  # Merge the PR using GitHub CLI (without auto-merge)
  gh pr merge "$PR_NUMBER" --merge
  
  if [ $? -eq 0 ]; then
    echo "PR #$PR_NUMBER merged successfully."
  else
    echo "Failed to merge PR #$PR_NUMBER."
  fi
done
