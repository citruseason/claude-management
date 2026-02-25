---
name: run
description: Run the full development pipeline — plan, implement, verify, review, ship — as a single automated command. Autonomously decides whether to use agent teams or subagents based on task characteristics.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
argument-hint: "<task description> [--mode feature|bugfix|refactor|hotfix]"
---

# Run Pipeline

You are executing the full development pipeline. Follow each phase below **in exact order**. Do NOT skip phases. Do NOT start implementing without a plan.

**Task**: $ARGUMENTS

---

## Phase 0: Initialize

### 0a. Review Lessons

Read `.work/lessons.md` if it exists. Pay attention to the `## Active Rules` section — these are mistakes to actively avoid during this pipeline run.

### 0b. Detect Mode

Parse `--mode` from $ARGUMENTS. If no flag is present, auto-detect from the task description:
- Contains "bug", "fix", "error", "crash", "broken" → **bugfix**
- Contains "refactor", "restructure", "reorganize", "clean up" → **refactor**
- Contains "urgent", "hotfix", "emergency" → **hotfix**
- Otherwise → **feature**

### 0c. Check for Resume

If $ARGUMENTS contains `--resume`:
1. Use Glob to find `.work/plans/*/todo.md`
2. Read the most recent `todo.md`
3. If unchecked items exist → skip to Phase 2 (WORK)
4. If all items are checked but no commit was made → skip to Phase 3 (VERIFY)
5. If no plan exists → proceed to Phase 1 (PLAN)

### 0d. Display Pipeline

Output the pipeline plan to the user:

```
Pipeline: [mode]
Phases: [phase list]
Task: [task description]
```

### 0e. Discover External Skills

Scan `.claude/skills/` for all `*/SKILL.md` files that are NOT `verify-*` prefixed and NOT symlinks into `${CLAUDE_PLUGIN_ROOT}/skills/`.

If external skills are found:
1. Read each external skill's SKILL.md frontmatter (name, description)
2. Check if each has a verify-* wrapper
3. Display in the pipeline overview:

```
External skills detected:
  - vercel-react-best-practices (no verify wrapper — will be addressed in Phase 3.5)
  - frontend-design (verify-frontend wrapper active)

External skills without wrappers will be analyzed during verification and addressed in Phase 3.5.
```

If no external skills are found, skip this section entirely (no noise).

Phase sequences by mode:
- **feature**: PLAN → WORK → VERIFY [→ MANAGE-SKILLS] → REVIEW → SHIP
- **bugfix**: EXPLORE → WORK → VERIFY [→ MANAGE-SKILLS] → SHIP
- **refactor**: PLAN → WORK → VERIFY [→ MANAGE-SKILLS] → REVIEW → SHIP
- **hotfix**: WORK → VERIFY → SHIP  (no MANAGE-SKILLS in hotfix mode)

---

## Phase 1: PLAN

**You MUST create plan files in `.work/plans/` before any implementation. Do NOT skip this phase (except for hotfix mode).**

### For feature/refactor mode:

Use the **Task tool** to spawn a **workflow-planner** subagent with this prompt:

> Create an implementation plan for the following task. You MUST create files under `.work/plans/[number-name]/` (e.g. `.work/plans/01-feature-name/`). Check existing `.work/plans/` to determine the next number. Create both `plan.md` (design document with steps) and `todo.md` (checkable progress tracker).
>
> Task: [full task description]

### For bugfix mode:

Use the **Task tool** to spawn a **research-codebase** subagent to explore the bug first, then spawn a **workflow-planner** subagent to create a minimal fix plan in `.work/plans/`.

### After planner returns — VERIFY the plan exists:

1. Use Glob to find `.work/plans/*/plan.md` — confirm new files were created
2. Read the generated `plan.md` and `todo.md`
3. If the plan files do NOT exist, report an error and retry the planner. Do NOT proceed without a plan.

### Display plan summary and wait for approval:

```
## Phase 1: PLAN ✓

Plan created: .work/plans/[number-name]/
Steps: [N]
  1. [Step title]
  2. [Step title]
  ...

Proceed with implementation?
```

**STOP here and wait for user confirmation.** If the user requests changes, re-run the planner with updated instructions.

---

## Phase 1.5: Team Decision

After the plan is approved, decide the execution strategy **autonomously** (do NOT ask the user):

**Use agent teams when ALL of these are true:**
- 3+ plan steps that can execute concurrently
- Steps modify different file sets with no overlap
- 5+ files being changed across 3+ directories

**Use subagents (default) when ANY of these are true:**
- Steps must execute in order (sequential dependencies)
- Multiple steps modify the same files
- Fewer than 3 files or 3 plan steps

Display the decision:

```
Execution strategy:
  WORK: [subagent|agent team] ([brief reason])
  REVIEW: [subagent|review team] ([brief reason])
```

---

## Phase 2: WORK

### Subagent mode (default)

Use the **Task tool** to spawn a **workflow-implementer** subagent with this prompt:

> Execute the implementation plan at `.work/plans/[plan-dir]/`. Read `todo.md` for the progress tracker and `plan.md` for step details. For each unchecked step: read the step details, implement the changes, verify the change works, then check off the item in `todo.md`. After all steps are done, add a review summary to `todo.md`.

### Agent team mode

When team is chosen, use the Task tool to create an agent team. Analyze plan steps to assign file ownership:
- Group steps by which files they modify
- Assign each group to a teammate with clear boundaries
- Ensure no two teammates modify the same file

### Gate — verify work was done:

1. Read `todo.md` — confirm all items are checked off (`[x]`)
2. If any items remain unchecked, report which steps failed
3. Ask user: retry failed steps / re-plan / abort

Do NOT proceed to verification if work is incomplete.

---

## Phase 3: VERIFY

Use the **Task tool** to spawn a **workflow-verifier** subagent with this prompt:

> Verify the implementation is correct. Run the project test suite, linters, type checks, and build. Check for any verify-* skills in `.claude/skills/` and run those too. For any external (non-verify-*) skills found in `.claude/skills/`, include a structured Gap Analysis section in the report: classify each by type (verification/guidelines/tooling), note which have verify-* wrappers and which do not, and recommend WRAP actions for unwrapped skills. Produce a verification report with PASS/FAIL status.

### Gate:

- **PASS** → proceed to Phase 3.5 (MANAGE-SKILLS, conditional), then Phase 4 (REVIEW)
- **FAIL** →
  1. Use Task tool to spawn a **workflow-implementer** to fix the issues
  2. Re-run Phase 3 (VERIFY)
  3. Maximum 2 fix-verify cycles. If still failing after 2 cycles, report to user and stop.

---

## Phase 3.5: MANAGE-SKILLS (conditional)

**Skip this phase if**: mode is hotfix, OR the Phase 3 verification report contains no Gap Analysis section, OR the Gap Analysis shows zero external skills without wrappers.

**Execute this phase if**: mode is NOT hotfix AND the verification report's Gap Analysis identifies external skills without verify-* wrappers.

This phase executes **at most once** per pipeline run.

1. Extract the Gap Analysis section from the Phase 3 verification report
2. Run `/manage-skills --from-verify` inline, passing the gap analysis data
3. `/manage-skills` will propose WRAP actions for external skills — present to user for approval
4. If user approves wraps and new verify-* wrappers are created:
   - Re-run Phase 3 (VERIFY) to include the newly created wrappers
   - This is NOT counted against the max 2 fix-verify cycles
   - The re-run's Gap Analysis does NOT trigger Phase 3.5 again
5. If user skips or no wraps are needed → proceed to Phase 4

### Gate:
- After Phase 3.5 completes (wrappers created, skipped, or not needed) → proceed to Phase 4 (REVIEW)
- This phase never blocks the pipeline — it is always advisory

---

## Phase 4: REVIEW

**Skip this phase for bugfix and hotfix modes.**

### Subagent mode (default)

Use the **Task tool** to spawn a **review-code** subagent with this prompt:

> Review the code changes from `git diff`. Focus on correctness, conventions, maintainability. Report issues by severity: CRITICAL, WARNING, SUGGESTION.

### Review team mode

When team review is chosen, spawn 3 parallel reviewers via Task tool:
- Code quality reviewer: conventions, clarity, maintainability
- Security reviewer: injection, auth, secrets, data protection
- Performance reviewer: algorithms, queries, memory, concurrency

Synthesize their reports when all complete.

### Gate:

- **No CRITICAL issues** → proceed to Phase 5 (SHIP)
- **CRITICAL issues found** →
  1. Fix critical issues (spawn workflow-implementer via Task tool)
  2. Re-verify (Phase 3)
  3. Re-review only fixed files
  4. Maximum 2 fix cycles. If still critical, report to user.
- **WARNING/SUGGESTION only** → note them in the report but proceed

---

## Phase 5: SHIP

Execute this phase **inline** (do NOT delegate to a subagent):

1. Run `git status` and `git diff` to review all changes
2. Verify no sensitive files (.env, credentials) are in the diff
3. Stage relevant files specifically (do NOT use `git add -A` or `git add .`)
4. Check `git log --oneline -10` for commit message conventions
5. Write a commit message: concise, focused on "why" not "what"
6. Present to user for final approval:

```
## Phase 5: SHIP

Files: [list of staged files]
Commit: [proposed message]

Confirm?
```

**STOP and wait for user confirmation.** Create the commit only after approval.

---

## Phase 6: WRAP-UP

1. Update `todo.md` with a `## Review` section summarizing:
   - What was implemented
   - What was verified
   - Any issues found and resolved
2. If corrections occurred during the pipeline, capture lessons in `.work/lessons.md`
3. Display final summary:

```
Pipeline complete: [mode]
Plan: .work/plans/[name]/
Commit: [hash] — [message]
Files changed: [N]
```

---

## Error Handling

- **Phase failure**: Report clearly which phase failed and why. Do NOT silently skip phases.
- **User abort**: Clean up gracefully. Plan and partial work remain in `.work/plans/` for resuming later.
- **Re-planning**: If implementation reveals the plan was wrong, STOP and go back to Phase 1 with updated context. Do NOT push through a broken plan.
- **Max retries**: Never loop more than 2 times on fix-verify cycles. Escalate to user.
- **Team failure**: If a teammate errors out, fall back to subagent mode for that phase.

## Rules

- You MUST follow the phase order exactly. No skipping, no reordering.
- You MUST create plan files in `.work/plans/` during Phase 1. Verify they exist before proceeding.
- You MUST use the Task tool to spawn subagents for PLAN, WORK, VERIFY, and REVIEW phases.
- You MUST wait for user confirmation after PLAN and before SHIP.
- You MUST check `todo.md` after WORK to verify all items are completed.
- Do NOT start implementing before the plan is created and approved.
- Do NOT commit without user approval.
