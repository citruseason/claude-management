---
name: plan
description: Create a detailed implementation plan by analyzing requirements and exploring the codebase. Use before starting any non-trivial feature or change.
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: workflow-planner
---

# Implementation Planning

Create an implementation plan for:

**Task**: $ARGUMENTS

## Instructions

1. Analyze the requirements and break them into concrete deliverables
2. Explore the codebase to understand existing patterns and constraints
3. Identify risks, dependencies, and potential blockers
4. Design the simplest approach that meets all requirements
5. Create ordered, checkable implementation steps
6. Define verification criteria for each step

## Output Format

Create two files under `.work/plans/[number-plan-name]/` (e.g. `.work/plans/01-add-auth/`):
- Check existing `.work/plans/` directory to determine the next number
- Use kebab-case for the plan name

### plan.md — Index / design document
- Goal statement, context, approach
- **Short plan (≤5 steps)**: each step inline as `## Step N: Title` with files, details, verification
- **Long plan (>5 steps)**: steps link to `plan-[step-name].md` sub-files with full detail

### plan-[step-name].md — Step detail (long plans only)
- One file per step: `plan-database-schema.md`, `plan-auth-endpoints.md`, etc.
- Contains files to modify, detailed changes, and verification criteria

### todo.md — Lightweight progress tracker
- Checkable items linking to step details (inline or sub-file):
  `- [ ] [Step 1: Title](./plan.md#step-1-title)` or `- [ ] [Step 2: Title](./plan-auth-endpoints.md)`
- Empty `## Review` section at the bottom (filled after completion)

## Planning Rules

- Every step must be independently verifiable
- Prefer modifying existing code over creating new files
- Order steps to minimize risk (safest changes first)
- If the plan exceeds 10 steps, reconsider the approach
- Include rollback strategy for risky steps
