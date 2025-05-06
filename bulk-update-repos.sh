#!/bin/bash

# Script to bulk-update GitHub repositories
# Usage: ./bulk-update-repos.sh

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI not found. Install it: https://cli.github.com/"
    exit 1
fi

# Authenticate if not already
gh auth status || gh auth login

# Directory to clone repos
WORK_DIR="github-repos"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Get list of repositories
REPOS=$(gh repo list ravirajladha --limit 100 --json name --jq '.[].name')

# Footer to add to READMEs
FOOTER="\n\n## Portfolio Note\nThis project is part of my portfolio showcasing full-stack development skills."

# Topics to add
TOPICS="portfolio,full-stack"

for REPO in $REPOS; do
    echo "Processing $REPO..."
    # Clone repo
    gh repo clone "ravirajladha/$REPO" "$REPO"
    cd "$REPO"
    
    # Update README
    if [ -f "README.md" ]; then
        echo -e "$FOOTER" >> README.md
        git add README.md
        git commit -m "Add portfolio footer to README" || echo "No README changes"
    fi
    
    # Add topics
    gh repo edit "ravirajladha/$REPO" --add-topic "$TOPICS"
    
    # Push changes
    git push origin main || git push origin master
    cd ..
done

# Clean up
cd ..
rm -rf "$WORK_DIR"

echo "Done! Repositories updated."