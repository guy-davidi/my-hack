#!/usr/bin/env bash

#-------------------------
# 0) PRE-FLIGHT CHECKS
#-------------------------

# If there are any uncommitted changes, commit them so we don't get "no commits" errors
UNCOMMITTED_CHANGES=$(git status --porcelain)
if [ -n "$UNCOMMITTED_CHANGES" ]; then
  echo "Found uncommitted changes. Committing them first..."
  git add .
  git commit -m "chore: commit local uncommitted changes before script"
  git push
fi

# Make sure we're on the base branch (e.g., 'main') and it's up to date
BASE_BRANCH="main"
git checkout "$BASE_BRANCH"
git pull origin "$BASE_BRANCH"

#-------------------------
# 1) CREATE BRANCHES + PRS
#-------------------------

NUM_PRS=100
declare -a PR_NUMBERS  # Array to store pull request numbers

for i in $(seq 1 $NUM_PRS); do
  BRANCH_NAME="add-char-$i"
  echo "-------------------------"
  echo "Creating branch: $BRANCH_NAME"
  
  # Create and switch to the new branch based on the latest $BASE_BRANCH
  git checkout -b "$BRANCH_NAME" "$BASE_BRANCH"
  
  # Add a small change to the README (one character)
  echo -n "X" >> README.md
  
  # Commit & push the change
  git add README.md
  git commit -m "chore: add char $i to README"
  git push -u origin "$BRANCH_NAME"
  
  # Create the pull request via GitHub CLI
  echo "Creating Pull Request from $BRANCH_NAME into $BASE_BRANCH..."
  gh pr create \
    --base "$BASE_BRANCH" \
    --head "$BRANCH_NAME" \
    --title "Add char $i to README" \
    --body "This PR adds one character (X) for PR #$i"
  
  # Capture the PR number for merging later
  PR_NUMBER=$(gh pr list --head "$BRANCH_NAME" --json number --jq '.[0].number')
  if [ -n "$PR_NUMBER" ]; then
    echo "PR #$PR_NUMBER created for branch $BRANCH_NAME."
    PR_NUMBERS+=("$PR_NUMBER")
  else
    echo "Failed to find PR for branch $BRANCH_NAME."
  fi
  
  # Switch back to the base branch for the next iteration
  git checkout "$BASE_BRANCH"
  
  # Small delay to avoid GitHub rate-limiting (optional)
  sleep 2
done

#-------------------------
# 2) MERGE ALL THE PRS
#-------------------------

echo "-------------------------"
echo "Now merging all created PRs..."
for PR_NUMBER in "${PR_NUMBERS[@]}"; do
  echo "Merging PR #$PR_NUMBER..."
  
  # Attempt to merge using a merge commit (remove --auto if branch protections block it)
  gh pr merge "$PR_NUMBER" --merge --auto
  
  if [ $? -eq 0 ]; then
    echo "PR #$PR_NUMBER merged successfully."
  else
    echo "Failed to merge PR #$PR_NUMBER."
  fi
  
  sleep 2
done

echo "-------------------------"
echo "All done! Created and (attempted to) merged $NUM_PRS pull requests."
