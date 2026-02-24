---
name: review
description: Perform a thorough code review checking for correctness, quality, conventions, and maintainability. Use after code changes or to audit existing code.
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: review-code
disable-model-invocation: true
---

# Code Review

Review the following code or changes:

**Target**: $ARGUMENTS

## Instructions

1. Read the target files or diff
2. Apply the full review checklist (see checklist.md in this directory)
3. Check for correctness, code quality, conventions, and maintainability
4. Rate each issue by severity: CRITICAL, WARNING, SUGGESTION
5. Provide an overall assessment

## Review Scope

- If given a file path: review that file
- If given a directory: review all files in that directory
- If given "staged" or "diff": review staged git changes
- If no argument: review recent uncommitted changes

## Output Requirements

- List all issues with severity, file path, and line number
- Provide specific, actionable fix suggestions
- End with overall pass/fail assessment
- Keep feedback constructive and focused on the code, not the author
