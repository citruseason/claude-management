#!/usr/bin/env bash
# PostToolUse hook: Auto-format files after Edit/Write
# Reads tool output from stdin (JSON), runs formatter on changed file

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

EXTENSION="${FILE_PATH##*.}"

case "$EXTENSION" in
  js|jsx|ts|tsx|json|css|scss|md|yaml|yml)
    if command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    if command -v black &>/dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null || true
    elif command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rb)
    if command -v rubocop &>/dev/null; then
      rubocop -a --fail-level=error "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
