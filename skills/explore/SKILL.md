---
name: explore
description: Explore and understand codebase structure, patterns, and conventions. Use when you need to understand how code is organized or find specific implementations.
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: research-codebase
---

# Codebase Exploration

Explore the codebase to answer the following question or investigate the specified area:

**Query**: $ARGUMENTS

## Instructions

1. Start with a broad structural overview using Glob
2. Narrow down to relevant files and patterns
3. Read key files to understand implementation details
4. Trace dependencies and data flow as needed
5. Provide a structured summary of findings

## Output Requirements

- Include specific file paths and line numbers for all references
- Distinguish between facts (what the code does) and opinions (what it should do)
- Highlight any surprising patterns or potential issues discovered
- Keep the summary concise and actionable
