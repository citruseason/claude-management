---
name: wf
description: Orchestrates the WF v1.3 pipeline end-to-end using Agent Teams. Runs plan, work (parallel waves + resync), review, skills, and done phases. Activates for complex multi-scope implementation tasks requiring structured planning and parallel execution.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task, AskUserQuestion
argument-hint: "<task description>"
---

# WF Orchestrator

Follow each phase **in exact order**. Do NOT skip phases.

**Task**: $ARGUMENTS

---

## Pipeline Checklist

Copy and track progress:

```
- [ ] Phase 0: Initialize (lessons, resume detection, run setup)
- [ ] Phase 1: PLAN (planner → plan gate → user confirm)
- [ ] Phase 2: WORK (route → execute waves → gate checks)
- [ ] Phase 3: REVIEW (code review → fix cycles)
- [ ] Phase 4: SKILLS (manage-skills → verify)
- [ ] Phase 5: DONE (done.md → summary)
```

---

## Phase 0: Initialize

### 0a. Review Lessons

Read `.work/lessons.md` if it exists. Apply active rules during this pipeline run.

### 0b. Detect Incomplete Runs

Scan `.work/*/` for run directories without a `done.md` file.

- **No incomplete runs**: Skip to 0c.
- **Incomplete runs found**: Follow resume logic in [RESUME.md](RESUME.md).

### 0c. Generate Run Name

Format: `YYYYMMDD-HHmm-<slug>` (kebab-case, max 5 words). Store path: `.work/YYYYMMDD-HHmm-<slug>/`

### 0d. Display Pipeline

Output pipeline overview with run name, task description, and phase list. Record git HEAD hash (`git rev-parse --short HEAD`) in the first worklog entry. Initialize OMC state:

```
state_write(mode="team", key="wf-run", value={"run": "[run-name]", "phase": "init", "task": "[task]"})
```

---

## Phase 1: PLAN

**Create plan artifacts before any implementation.**

Spawn **workflow-planner** via Task tool:

> WF MODE — Create an implementation plan for the following task. Create the run directory at `.work/[run-name]/` and populate it with plan files, kanban board, and worklog following the WF v1.3 format.
>
> Task: [full task description]
>
> Each task must have a **type** field (one of: implement, design, test, migrate).
>
> If the task description is unclear or ambiguous, ask the user clarifying questions before creating the plan.

### Plan Gate Check

Spawn **wf-integrator** to verify: plan files exist, all tasks have type field, kanban initialized, worklog initialized, no circular dependencies. If gate fails, retry planner.

### Display Plan Summary

Show task list with types and gates. **STOP and wait for user confirmation.** If user requests changes, re-run the planner.

---

## Phase 2: WORK

**Resume behavior**: Phase 2a → full flow. Phase 2b (via resumeWave in [RESUME.md](RESUME.md)) → start from determined wave.

### 2a. Route

Spawn **wf-router**:

> Analyze the plan at `.work/[run-name]/` and create execution schedule. Build dependency DAG, group into waves, assign OMC agent types by task type (design→designer, implement→executor, test→test-engineer, complex→deep-executor), produce `schedule.md`.

### 2b. Execute Waves

Read schedule from `.work/[run-name]/schedule.md`. If resuming, skip completed waves/tasks and log skips to worklog.

**Single task wave**: Spawn the assigned OMC agent with task details and kanban protocol.

**Multi-task wave**: Create an agent team with strict file ownership boundaries. Each teammate reads from `plan/tasks/`, follows kanban protocol, logs to worklog.

### 2c. Gate Check (between waves)

Spawn **wf-integrator** after each wave to verify Test Gate (test evidence) and update kanban. If gate fails: spawn responsible agent to fix (max 2 retries). If still failing, report to user and stop.

### 2d. Work Complete Check

Verify all kanban tasks are in Review/Done and all Test Gates passed. If incomplete, ask user: retry / re-plan / abort.

---

## Phase 3: REVIEW

Spawn **oh-my-claudecode:code-reviewer**:

> Review the WF run at `.work/[run-name]/`. Check code quality, regression risk, gate compliance. Read worklog, kanban, and code changes. Produce `review.md`.

For security-sensitive changes, also spawn **oh-my-claudecode:security-reviewer** to append security findings.

### Review Gate

- **PASS** → Phase 4
- **NEEDS_CHANGES** → Spawn agents to fix, re-review (max 2 cycles). If still failing, report to user.
- **FAIL** → Report to user and stop.

---

## Phase 4: SKILLS

### 4a. Skill Maintenance

Run `/manage-skills` to analyze session changes, detect verify-* skill gaps, create/update as needed.

### 4b. Verification Run (Optional)

If skills were created/updated, run `/verify-implementation`. On FAIL, present fix options to user.

### 4c. Summary

Log to worklog: skills created/updated count, verification status.

---

## Phase 5: DONE

Inline phase (no dedicated agent).

1. Create `done.md` with: summary, completed tasks table, artifacts, review status, skills updated, metrics (total tasks, waves, gates, review issues)
2. Update kanban: move all Review → Done
3. Clear OMC state: `state_clear(mode="team", key="wf-run")`
4. Append final worklog entry
5. Display final summary to user

---

## Error Handling

- **Phase failure**: Report which phase failed and why. Never silently skip. Write error state for resume recovery.
- **Agent failure**: Fall back to `oh-my-claudecode:deep-executor`.
- **Gate failure**: Max 2 retries, then escalate to user.
- **User abort**: Pipeline state preserved in run directory.
- **Re-planning**: If implementation reveals the plan was wrong, STOP and go back to Phase 1.

## Rules

- Follow phase order exactly. No skipping, no reordering.
- Create plan artifacts in Phase 1 before any implementation.
- Use Task tool for PLAN, WORK, and REVIEW agents.
- Wait for user confirmation after PLAN.
- Check gates between waves — never skip.
- Produce `done.md` at end of every successful run.
- Never proceed past a failing gate without user approval.
- Run directory `.work/YYYYMMDD-HHmm-<slug>/` is the single source of truth.
