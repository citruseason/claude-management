---
name: wf
description: Single-entry-point workflow orchestrator using Agent Teams. Runs plan, work (parallel + resync), review, skills, done. The recommended command for complex multi-scope tasks.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
argument-hint: "<task description>"
---

# WF Orchestrator

You are executing the WF v1.2 workflow pipeline. Follow each phase below **in exact order**. Do NOT skip phases.

**Task**: $ARGUMENTS

---

## Phase 0: Initialize

### 0a. Review Lessons

Read `.work/lessons.md` if it exists. Apply active rules during this pipeline run.

### 0b. Generate Run Name

Generate the run directory name:
- Format: `YYYYMMDD-HHmm-<slug>`
- `YYYYMMDD-HHmm` = current date and time
- `<slug>` = kebab-case summary of the task (max 5 words)

Example: `20260225-1430-user-dashboard`

Store the full path: `.work/YYYYMMDD-HHmm-<slug>/`

### 0c. Display Pipeline

Output the pipeline overview:

```
WF Pipeline
Run: .work/[run-name]/
Task: [task description]
Phases: PLAN -> WORK -> REVIEW -> SKILLS -> DONE
```

---

## Phase 1: PLAN

**You MUST create plan artifacts before any implementation.**

Use the **Task tool** to spawn a **workflow-planner** agent with this prompt:

> WF MODE — Create an implementation plan for the following task. Create the run directory at `.work/[run-name]/` and populate it with plan files, kanban board, and worklog following the WF v1.2 format.
>
> Task: [full task description]
>
> If the task description is unclear or ambiguous, ask the user clarifying questions before creating the plan.

### Plan Gate Check

After the planner returns, use the **Task tool** to spawn a **wf-integrator** agent to verify the Plan Gate:

> Check the Plan Gate for the WF run at `.work/[run-name]/`. Verify: plan files exist, all tasks have scope/phase/gate defined, kanban is initialized, worklog is initialized, no circular dependencies.

If the Plan Gate fails, report the failure and retry the planner.

### Display Plan Summary

```
## Phase 1: PLAN

Run directory: .work/[run-name]/
Tasks: [N]
  T-001: [title] (Scope: [scope], Phase: [phase])
  T-002: [title] (Scope: [scope], Phase: [phase])
  ...

Gates required: [list of gates]

Proceed with implementation?
```

**STOP and wait for user confirmation.** If the user requests changes, re-run the planner.

---

## Phase 2: WORK

### 2a. Route

Use the **Task tool** to spawn a **wf-router** agent:

> Analyze the plan at `.work/[run-name]/` and create an execution schedule. Build the dependency DAG, group tasks into waves, identify FE/BE parallel opportunities, assign specialist owners, and produce `schedule.md`.

### 2b. Execute Waves

Read the execution schedule from `.work/[run-name]/schedule.md`.

For each wave in the schedule:

**If the wave has a single task:**
Use the **Task tool** to spawn the assigned specialist agent (from the schedule) with:

> Execute task [T-XXX] from the WF plan at `.work/[run-name]/`. Read the task details at `plan/tasks/T-XXX.md`. Follow the kanban protocol: move card to In Progress, implement, move to Review, log to worklog.

**If the wave has multiple tasks:**
Use the **Task tool** to create an agent team. For each task in the wave, spawn the assigned specialist as a teammate:

> Create an agent team to execute Wave [N] of the WF plan at `.work/[run-name]/`.
> Teammates:
> - [Specialist]: Execute [T-XXX] — [title]. Files: [ownership list]
> - [Specialist]: Execute [T-YYY] — [title]. Files: [ownership list]
> ...
> Each teammate: read task details from plan/tasks/, follow kanban protocol, log to worklog.
> File ownership boundaries are strict — no teammate modifies another's files.

### 2c. Gate Check (between waves)

After each wave completes, use the **Task tool** to spawn a **wf-integrator** agent:

> Check gates for Wave [N] of the WF run at `.work/[run-name]/`.
> - If Contract Gate is required before the next wave: verify contract artifacts and evidence
> - If Migration Gate is required: verify migration plan and rollback
> - Check Test Gate: verify all wave tasks have test evidence
> - Update kanban: move completed tasks forward, move next wave's tasks to Ready

If a gate fails:
1. Report which gate failed and why
2. Spawn the responsible specialist to fix the issue (max 2 retries)
3. Re-check the gate
4. If still failing after 2 retries, report to user and stop

### 2d. Work Complete Check

After all waves are done, verify:
- All tasks in `kanban.md` are in Review or Done
- All gates have passed (check worklog for gate-pass entries)

If any tasks remain incomplete, report which ones and ask user: retry / re-plan / abort.

---

## Phase 3: REVIEW

Use the **Task tool** to spawn a **wf-reviewer** agent:

> Review the WF run at `.work/[run-name]/`. Check code quality, regression risk, contract consistency, gate compliance, and overall risk. Read the worklog, kanban, artifacts, and code changes. Produce `review.md`.

### Review Gate

Read `review.md` from the run directory.

- **PASS** -> proceed to Phase 4
- **NEEDS_CHANGES** ->
  1. Identify which tasks need fixes from the review issues
  2. Spawn the responsible specialist(s) to fix the issues
  3. Re-run the Reviewer (max 2 fix-review cycles)
  4. If still NEEDS_CHANGES after 2 cycles, report to user
- **FAIL** -> report to user and stop

---

## Phase 4: SKILLS

This phase is handled inline (no dedicated agent).

### Skills Curator Logic

1. Scan `.claude/skills/` for existing verify-* skills
2. Analyze the WF run's changes — which files were modified?
3. Check for coverage gaps:
   - New files not covered by any verify-* skill
   - Patterns that emerged during this WF run (new conventions, new API shapes)
4. If gaps are found:
   - Propose new verify-* skills or updates to existing ones
   - Present proposals to the user
   - If approved, create/update the skills
5. If no gaps: skip this phase silently

### Skills Registry Update

If `.work/skill-registry.md` exists, regenerate it to include any new skills.

---

## Phase 5: DONE

This phase is handled inline (no dedicated agent).

### Done Writer Logic

1. Create `done.md` in the run directory:

```markdown
# Done: [Run Name]

## Summary
[1-3 sentence summary of what was accomplished]

## Tasks Completed
| Task | Title | Scope | Status |
|------|-------|-------|--------|
| T-001 | ... | FE | Done |
| T-002 | ... | BE | Done |

## Artifacts Produced
- [list of contract artifacts, migration plans, evidence files]

## Review Status
[PASS/NEEDS_CHANGES — summary from review.md]

## Skills Updated
[List of new/updated verify-* skills, or "None"]

## Metrics
- Total tasks: [N]
- Waves executed: [N]
- Gates passed: [N]
- Review issues: [N] (fixed: [N])
```

2. Update `kanban.md`: move all tasks from Review to Done

3. Append final worklog entry:
```
| [timestamp] | Done Writer | Pipeline complete | — | All tasks done, review: [status] |
```

4. Display final summary to user:

```
WF Pipeline Complete
Run: .work/[run-name]/
Tasks: [N] completed
Review: [PASS/NEEDS_CHANGES]
Artifacts: [list]
Duration: [if trackable]

Files:
  .work/[run-name]/done.md       — completion summary
  .work/[run-name]/review.md     — review results
  .work/[run-name]/kanban.md     — final kanban state
  .work/[run-name]/worklog.md    — full execution log
  .work/[run-name]/artifacts/    — contract artifacts & evidence
```

---

## Error Handling

- **Phase failure**: Report which phase failed and why. Do NOT silently skip phases.
- **Agent failure**: If a specialist agent errors out, fall back to `workflow-implementer` for that task.
- **Gate failure**: Max 2 retries per gate. After that, escalate to user.
- **User abort**: Pipeline state is preserved in the run directory for later inspection.
- **Re-planning**: If implementation reveals the plan was wrong, STOP and go back to Phase 1.

## Rules

- You MUST follow the phase order exactly. No skipping, no reordering.
- You MUST create the run directory and plan artifacts in Phase 1 before any implementation.
- You MUST use the Task tool to spawn agents for PLAN, WORK, and REVIEW phases.
- You MUST wait for user confirmation after PLAN.
- You MUST check gates between waves — never skip gate checks.
- You MUST produce `done.md` at the end of every successful run.
- Do NOT start implementing before the plan is created and approved.
- Do NOT proceed past a failing gate without user approval.
- The run directory at `.work/YYYYMMDD-HHmm-<slug>/` is the single source of truth for the run.
