---
name: document
description: Generate technical documentation from code analysis. Creates API docs, architecture docs, setup guides, and inline documentation.
allowed-tools: Read, Write, Edit, Grep, Glob
context: fork
agent: docs-generator
---

# Documentation Generation

Generate documentation for:

**Target**: $ARGUMENTS

## Instructions

1. Analyze the target code to understand its purpose and API
2. Identify the appropriate documentation type:
   - API documentation (endpoints, functions, types)
   - Architecture overview (system design, data flow)
   - Setup guide (installation, configuration)
   - Module documentation (purpose, usage, examples)
3. Write documentation following project conventions
4. Include practical code examples
5. Cross-reference with existing documentation

## Output Requirements

- Accurate reflection of current code (not aspirational)
- Clear and concise language
- Working code examples
- Consistent terminology
- Proper markdown formatting
