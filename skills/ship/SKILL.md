---
name: ship
description: Create commits and pull requests for completed work. Validates changes, writes commit messages, and creates PRs with proper descriptions.
allowed-tools: Read, Grep, Glob, Bash
disable-model-invocation: true
---

# Ship Changes

Ship the current changes:

**Instructions**: $ARGUMENTS

## Process

### 1. Pre-flight Check
- Run `git status` to see all changes
- Run `git diff` to review staged and unstaged changes
- Verify no sensitive files (.env, credentials) are included
- Run tests if available

### 2. Stage Changes
- Stage relevant files (specific files, not `git add -A`)
- Double-check staged changes with `git diff --cached`

### 3. Commit
- Write a concise commit message focusing on "why" not "what"
- Follow existing commit message conventions from `git log --oneline -10`
- Use conventional commits format if the project uses it

### 4. Pull Request (if requested)
- Push branch to remote
- Create PR with:
  - Clear title (under 70 characters)
  - Summary of changes (bullet points)
  - Test plan
  - Any migration or deployment notes

## Rules

- Never commit .env files, credentials, or secrets
- Never force push unless explicitly requested
- Always verify staged changes before committing
- Use descriptive branch names (feature/xxx, fix/xxx)
- Include test plan in PR description
