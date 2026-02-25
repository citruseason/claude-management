---
name: plan
description: Create a detailed implementation plan by analyzing requirements and exploring the codebase. Use before starting any non-trivial feature or change.
allowed-tools: Read, Grep, Glob, Bash, AskUserQuestion
context: fork
agent: workflow-planner
---

# Implementation Planning

Create an implementation plan for:

**Task**: $ARGUMENTS

## Step 0: Assess Task Clarity

Before exploring the codebase, evaluate whether the task description provides enough
information to create a concrete plan. Consider these ambiguity signals:

- **Vague goal**: The task says "improve" or "fix" without specifying what success looks like
- **Missing scope**: It is unclear which components, files, or features are affected
- **Ambiguous requirements**: Multiple valid interpretations exist and the right one is unclear
- **Unknown constraints**: Technical constraints (performance, compatibility, dependencies) are unspecified but would significantly affect the approach
- **Missing context**: References to external systems, prior decisions, or domain knowledge that you cannot infer from the codebase

### When to ask

If TWO or more ambiguity signals are present, use `AskUserQuestion` to ask focused
clarifying questions. Batch related questions into a single ask (do not ask one at a time).

Example:
> The task says "improve the authentication system." I have a few questions before planning:
> 1. What specific aspect needs improvement — security, performance, UX, or adding new auth methods?
> 2. Are there any constraints on the approach (e.g., must keep backward compatibility)?
> 3. Is there a specific problem or incident that triggered this request?

### When NOT to ask

Proceed directly to planning (skip clarification) if:
- The task clearly states what to build, where, and why
- Only ONE ambiguity signal is present and you can resolve it by exploring the codebase
- The task includes specific file paths, error messages, or concrete acceptance criteria
- The task is a continuation of an existing plan (e.g., "implement step 3 of the auth plan")

After receiving answers (or determining clarification is unnecessary), proceed to the
regular planning process below.

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
