---
name: changelog
description: Generate or update changelog entries from git history and code changes. Follows Keep a Changelog format.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
context: fork
agent: docs-readme
disable-model-invocation: true
---

# Changelog Generation

Generate changelog entries:

**Instructions**: $ARGUMENTS

## Process

1. Analyze git history since the last release tag or changelog entry
   - `git log --oneline <last-tag>..HEAD`
   - Group commits by type (feature, fix, refactor, etc.)
2. Read existing CHANGELOG.md to understand format and conventions
3. Categorize changes:
   - **Added**: New features
   - **Changed**: Changes to existing functionality
   - **Fixed**: Bug fixes
   - **Removed**: Removed features
   - **Security**: Security-related changes
4. Write changelog entries in imperative mood
5. Update CHANGELOG.md with new entries

## Rules

- Every entry must correspond to actual commits/changes
- Use imperative mood ("Add feature" not "Added feature")
- Include issue/PR references where available
- Keep entries concise but descriptive
- Order: Added, Changed, Fixed, Removed, Security
