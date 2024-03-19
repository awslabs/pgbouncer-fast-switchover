#!/bin/bash

# copy this file to pgbouncer to compare diff between branch a (origin), branch b (diff)

# Directory to store the individual diff files
diff_dir="../pgbouncer-rr-patch"
mkdir -p "$diff_dir"

# Get a list of all modified files between two commits, branches, or a commit and the working tree
# Here, we're comparing the current state to the main/master branch
# Adjust "main" to your target branch or commit as needed
git diff --name-only a | while read -r file; do
    # Replace slashes with dashes to avoid directory structure issues
    dir_path=$(dirname "${diff_dir}/$file")
    mkdir -p $dir_path
    # Create a diff file for each changed file
    git diff a -- "$file" > "${diff_dir}/${file}.diff"
done

echo "Diff files have been saved in ${diff_dir}/"
