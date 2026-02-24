#!/usr/bin/env bash
# Validate commit message format
# Checks for minimum length, conventional commits format (if used), and common issues

set -euo pipefail

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Only check git commit commands
if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
  exit 0
fi

# Extract commit message from -m flag
COMMIT_MSG=$(echo "$COMMAND" | grep -oP '(?<=-m\s")[^"]+' 2>/dev/null || \
             echo "$COMMAND" | grep -oP "(?<=-m\s')[^']+" 2>/dev/null || \
             echo "")

if [ -z "$COMMIT_MSG" ]; then
  # Message might be in heredoc or file, skip validation
  exit 0
fi

# Check minimum length
if [ ${#COMMIT_MSG} -lt 10 ]; then
  echo "WARNING: Commit message is too short (${#COMMIT_MSG} chars). Consider being more descriptive." >&2
  exit 0  # Warn but don't block
fi

# Check for WIP commits
if echo "$COMMIT_MSG" | grep -qiE '^(wip|fixup|squash)'; then
  echo "NOTE: This looks like a WIP commit. Remember to squash before merging." >&2
  exit 0
fi

exit 0
