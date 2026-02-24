#!/usr/bin/env bash
# Lint check script: Runs appropriate linter based on project type
# Can be used as a hook or standalone

set -euo pipefail

PROJECT_DIR="${1:-.}"

# Detect project type and run appropriate linter
if [ -f "$PROJECT_DIR/package.json" ]; then
  if grep -q '"lint"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    echo "Running npm lint..."
    cd "$PROJECT_DIR" && npm run lint 2>&1
  elif command -v eslint &>/dev/null; then
    echo "Running eslint..."
    eslint "$PROJECT_DIR/src" 2>&1 || true
  fi
elif [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/setup.py" ]; then
  if command -v ruff &>/dev/null; then
    echo "Running ruff..."
    ruff check "$PROJECT_DIR" 2>&1
  elif command -v flake8 &>/dev/null; then
    echo "Running flake8..."
    flake8 "$PROJECT_DIR" 2>&1
  fi
elif [ -f "$PROJECT_DIR/Gemfile" ]; then
  if command -v rubocop &>/dev/null; then
    echo "Running rubocop..."
    rubocop "$PROJECT_DIR" 2>&1
  fi
elif [ -f "$PROJECT_DIR/go.mod" ]; then
  if command -v golangci-lint &>/dev/null; then
    echo "Running golangci-lint..."
    cd "$PROJECT_DIR" && golangci-lint run 2>&1
  fi
else
  echo "No recognized project type found. Skipping lint."
fi

exit 0
