#!/usr/bin/env bash

# Set the base branch (the branch into which PRs will be created)
BASE_BRANCH="main"

# Fetch all remote branches except the base branch
BRANCHES=$(git branch -r | grep -v "$BASE_BRANCH" | grep -v '\->' | sed 's/origin\///g')

# Loop through each branch and create a pull request into the base branch
for BRANCH in $BRANCHES; do
  echo "Checking differences between $BASE_BRANCH and $BRANCH"
  
  # Check if there are any differences between the branch and the base branch
  if git diff --quiet "$BASE_BRANCH".."$BRANCH"; then
    echo "No changes found between $BASE_BRANCH and $BRANCH. Skipping PR creation."
    continue
  fi
  
  echo "Creating PR from branch $BRANCH to $BASE_BRANCH"
  
  # Create the PR using GitHub CLI
  gh pr create --base "$BASE_BRANCH" --head "$BRANCH" \
    --title "PR: Merge $BRANCH into $BASE_BRANCH" \
    --body "This pull request merges changes from branch $BRANCH into $BASE_BRANCH."
  
  if [ $? -eq 0 ]; then
    echo "PR created successfully for $BRANCH"
  else
    echo "Failed to create PR for $BRANCH"
  fi
  
  # Add a delay to avoid rate-limiting by GitHub
  sleep 3
done
