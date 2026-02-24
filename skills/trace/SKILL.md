---
name: trace
description: Trace execution paths, data flow, and call chains through the codebase. Use when debugging or understanding how a feature works end-to-end.
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: research-codebase
---

# Execution Path Trace

Trace the execution path for the following:

**Target**: $ARGUMENTS

## Instructions

1. Identify the entry point (route, event handler, CLI command, etc.)
2. Follow the call chain step by step, reading each function
3. Track data transformations at each step
4. Note branching logic, error handling, and side effects
5. Map the complete path from entry to final output

## Output Format

```
Entry: [file:line] function_name
  -> [file:line] function_name (transforms: X -> Y)
    -> [file:line] function_name (side effect: DB write)
      -> [file:line] function_name
  <- returns: [description]
```

## Output Requirements

- Show the complete call chain with file paths and line numbers
- Note all data transformations along the path
- Identify side effects (DB writes, API calls, file I/O)
- Highlight error handling and alternative paths
- Flag any potential issues discovered during tracing
