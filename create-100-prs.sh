#!/usr/bin/env bash

# Number of PRs to create
NUM_PRS=100
# The base branch into which you'll merge (could be 'main' or 'master', etc.)
BASE_BRANCH="main"

# Make sure we're up to date
git checkout "$BASE_BRANCH"
git pull origin "$BASE_BRANCH"

for i in $(seq 1 $NUM_PRS); do
  # 1. Create & switch to a new branch
  BRANCH_NAME="add-char-$i"
  git checkout -b "$BRANCH_NAME" "$BASE_BRANCH"
  
  # 2. Add exactly one character (e.g., an 'X') to the end of the README
  #    Using `echo -n` so it doesn't add a newline— 
  #    If you prefer a new line each time, use: echo "X" >> README.md
  echo -n "X" >> README.md
  
  # 3. Commit the change
  git add README.md
  git commit -m "Add 1 char (X) to README for PR #$i"
  
  # 4. Push the branch
  git push -u origin "$BRANCH_NAME"
  
  # 5. Create the Pull Request via GitHub CLI
  gh pr create \
    --title "Add 1 char to README #$i" \
    --body "This PR adds a single character (X) to the README file. (PR #$i)" \
    --base "$BASE_BRANCH" \
    --head "$BRANCH_NAME"
  
  # 6. Switch back to the base branch
  git checkout "$BASE_BRANCH"
done
