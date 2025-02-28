#!/bin/bash

# dumper.sh
# This script dumps the file paths and contents of .py and .swift files.

# Exit immediately if a command exits with a non-zero status
set -e

# Find all .py and .swift files
find . \( -name "*.py" -o -name "*.swift" \) -print0 | while IFS= read -r -d '' file; do
    # Remove the leading './' from the file path for cleaner output
    rel_path="${file#./}"

    # Print the file path
    echo "---/$rel_path---"

    # Print the file content
    if cat "$file"; then
        : # Do nothing if cat succeeds
    else
        echo "Error reading file: $file" >&2 # Redirect error message to stderr
    fi

    # Print a newline for separation
    echo -e "\n"
done
