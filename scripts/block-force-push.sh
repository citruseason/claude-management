#!/usr/bin/env bash
# PreToolUse hook: Block dangerous git commands
# Reads tool input from stdin (JSON), exits 2 to block, 0 to allow

set -euo pipefail

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Block force push
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(-f|--force)'; then
  echo "BLOCKED: Force push is not allowed. Use regular push or discuss with the team." >&2
  exit 2
fi

# Block hard reset
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "BLOCKED: Hard reset can cause data loss. Use soft/mixed reset or stash instead." >&2
  exit 2
fi

# Block destructive clean
if echo "$COMMAND" | grep -qE 'git\s+clean\s+-f'; then
  echo "BLOCKED: git clean -f permanently removes untracked files. Review files first." >&2
  exit 2
fi

# Block rm -rf on important paths
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(/|~|\$HOME|\.\.)'; then
  echo "BLOCKED: Destructive rm -rf on important paths is not allowed." >&2
  exit 2
fi

exit 0
