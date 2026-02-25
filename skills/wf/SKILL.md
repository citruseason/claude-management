---
name: wf
description: Single-entry-point workflow orchestrator using Agent Teams. Runs plan, work (parallel + resync), review, skills, done. The recommended command for complex multi-scope tasks.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task, AskUserQuestion
argument-hint: "<task description>"
---

# WF Orchestrator

You are executing the WF v1.3 workflow pipeline. Follow each phase below **in exact order**. Do NOT skip phases.

**Task**: $ARGUMENTS

---

## Phase 0: Initialize

### 0a. Review Lessons

Read `.work/lessons.md` if it exists. Apply active rules during this pipeline run.

### 0b. Detect Incomplete Runs

Scan `.work/*/` for run directories that do NOT contain a `done.md` file.

**If no incomplete runs found**: Skip to 0c (new run).

**If incomplete runs found**: For each incomplete run, parse the run directory name timestamp (`YYYYMMDD-HHmm` prefix) and compare with the current date/time to determine age.

Use `AskUserQuestion` to present options:

> 미완료 런이 감지되었습니다:
> [list each incomplete run as: `- .work/[run-name]/` (last worklog entry: [summary])]
> [If any run is 24+ hours old, append for that run: `⚠ 이 런은 [N시간] 전에 중단되었습니다.`]
>
> 선택:
> 1. 재개 — [run-name] 런을 재개합니다
> 2. 새로 시작 — 새로운 런을 생성합니다
> 3. 폐기 — 미완료 런을 아카이브합니다

**If user selects "재개"**:
1. Set the run directory to the selected incomplete run
2. Execute `resumePoint()` logic (see Phase 0e) to determine which phase to resume from
3. Skip to the determined phase (bypass 0c and 0d)

**If user selects "새로 시작"**:
- Proceed to 0c (new run). The incomplete run remains as-is.

**If user selects "폐기"**:
1. Create `.work/_archived/` if it does not exist
2. Move the incomplete run directory to `.work/_archived/[run-name]/`
3. Log: `| [timestamp] | WF | Archived | — | Archived incomplete run [run-name] |`
4. Re-scan for remaining incomplete runs (loop back to detection)
5. If no more incomplete runs, proceed to 0c

### 0c. Generate Run Name

Generate the run directory name:
- Format: `YYYYMMDD-HHmm-<slug>`
- `YYYYMMDD-HHmm` = current date and time
- `<slug>` = kebab-case summary of the task (max 5 words)

Example: `20260225-1430-user-dashboard`

Store the full path: `.work/YYYYMMDD-HHmm-<slug>/`

### 0d. Display Pipeline

Output the pipeline overview:

```
WF Pipeline
Run: .work/[run-name]/
Task: [task description]
Phases: PLAN -> WORK -> REVIEW -> SKILLS -> DONE
```

Record the current git HEAD commit hash in the first worklog entry:
```
| [timestamp] | WF | Init | — | HEAD: [git rev-parse --short HEAD output] |
```

This HEAD hash is the baseline for detecting codebase changes on resume.

Initialize OMC state for the pipeline run:
```
state_write(mode="team", key="wf-run", value={"run": "[run-name]", "phase": "init", "task": "[task description]"})
```

### 0e. Resume Point Detection (resumePoint)

This step runs ONLY when resuming an existing run (user selected "재개" in 0b).

#### HEAD Change Detection

Read the worklog for the most recent `HEAD:` entry. Compare with the current `git rev-parse --short HEAD`.

- **If same**: Proceed to the consistency check below.
- **If different**: Use `AskUserQuestion`:
  > 코드베이스가 변경되었습니다.
  > 이전 HEAD: [old hash]
  > 현재 HEAD: [new hash]
  >
  > 선택:
  > 1. 재개 — 변경사항을 무시하고 이전 지점부터 재개
  > 2. 재계획 — Phase 1부터 다시 시작 (계획 재수립)

  If "재계획": override resume point to Phase 1 (skip the decision table below).

#### Kanban-Worklog Consistency Check

Spawn **wf-integrator** via the Task tool:

> Reconcile kanban.md and worklog.md for the WF run at `.work/[run-name]/`. Check that:
> - Every task marked Done in kanban has a corresponding "Completed" entry in worklog
> - Every task marked In Progress in kanban has a corresponding "started" entry
> - No task is in a state that contradicts the worklog
> Report discrepancies. Fix kanban to match worklog (worklog is source of truth).

After both checks pass, evaluate the following rules **in order** (first match wins):

| # | Condition | Resume From | Action |
|---|-----------|-------------|--------|
| 1 | `plan/` directory missing OR `plan/plan.md` missing OR `kanban.md` missing | Phase 1 (start) | Full re-plan — essential artifacts are absent |
| 2 | `schedule.md` missing AND all kanban tasks in Backlog | Phase 1 | AskUserQuestion: "계획은 있으나 실행이 시작되지 않았습니다. 계획을 유지하고 실행할까요, 재계획할까요?" If re-plan → Phase 1. If keep → Phase 2a. |
| 3 | `schedule.md` missing AND kanban has tasks NOT in Backlog | Phase 2a (routing) | Plan exists, some work recorded without schedule — re-route |
| 4 | `schedule.md` exists AND kanban has non-Done tasks | Phase 2b (wave resume) | Execute `resumeWave()` (see 0f) to find the starting wave |
| 5 | All kanban tasks in Done AND `review.md` missing | Phase 3 (review) | All work complete, review not yet started |
| 6 | `review.md` exists AND status != PASS | Phase 3 (review) | Fix cycle. Count "Re-review" entries in worklog. If count >= 2: AskUserQuestion — "리뷰가 2회 이상 실패했습니다. 계속하시겠습니까, 중단하시겠습니까?" If 중단 → abort pipeline. |
| 7 | `review.md` status == PASS AND `done.md` missing | Phase 5 (done) | Only finalization remains |

**Principle**: When ambiguous, resume one phase earlier than strictly necessary. It is safer to redo a cheap phase than to skip a required one.

After determining the resume point, display:

```
WF Pipeline — Resume
Run: .work/[run-name]/
Task: [original task from plan]
Resume from: Phase [N] — [phase name]
Reason: [which rule matched and why]
```

**STOP and wait for user confirmation before proceeding to the resume phase.**

### 0f. Wave Resume Detection (resumeWave)

This step runs ONLY when resumePoint() returns Phase 2b (rule 4).

Read `schedule.md` for the wave list. For each wave (starting from Wave 0):

1. **All tasks in wave are Done in kanban AND gate-pass recorded in worklog** -> Wave is complete. Skip it.
2. **Some tasks in wave are Done, others are not** -> Partially complete wave. Set `startFromWave = [this wave number]`. Note which tasks are already Done (they will be skipped).
3. **No tasks in wave have started** -> Set `startFromWave = [this wave number]`.

First match of rule 2 or 3 determines the `startFromWave`.

Output:

```
Resume Wave Detection:
- Completed waves: [list]
- Resume from: Wave [N]
- Tasks to skip (already Done): [list or "none"]
- Tasks to execute: [list]
```

Pass `startFromWave` and the skip list to Phase 2b.

---

## Phase 1: PLAN

**You MUST create plan artifacts before any implementation.**

Use the **Task tool** to spawn a **workflow-planner** agent with this prompt:

> WF MODE — Create an implementation plan for the following task. Create the run directory at `.work/[run-name]/` and populate it with plan files, kanban board, and worklog following the WF v1.3 format.
>
> Task: [full task description]
>
> Each task must have a **type** field (one of: implement, design, test, migrate) instead of scope/phase.
>
> If the task description is unclear or ambiguous, ask the user clarifying questions before creating the plan.

### Plan Gate Check

After the planner returns, use the **Task tool** to spawn a **wf-integrator** agent to verify the Plan Gate:

> Check the Plan Gate for the WF run at `.work/[run-name]/`. Verify: plan files exist, all tasks have a type field defined (implement/design/test/migrate), kanban is initialized, worklog is initialized, no circular dependencies.

If the Plan Gate fails, report the failure and retry the planner.

### Display Plan Summary

```
## Phase 1: PLAN

Run directory: .work/[run-name]/
Tasks: [N]
  T-001: [title] (Type: [type])
  T-002: [title] (Type: [type])
  ...

Gates required: Plan Gate, Test Gate

Proceed with implementation?
```

**STOP and wait for user confirmation.** If the user requests changes, re-run the planner.

---

## Phase 2: WORK

**Resume behavior**: If resuming at Phase 2a, execute the full Phase 2 flow (re-route, then execute all waves). If resuming at Phase 2b (via resumeWave() in 0f), skip 2a entirely and start wave execution from the `startFromWave` determined during resume detection.

### 2a. Route

Use the **Task tool** to spawn a **wf-router** agent:

> Analyze the plan at `.work/[run-name]/` and create an execution schedule. Build the dependency DAG, group tasks into waves, assign OMC agent types based on task type (design→oh-my-claudecode:designer, implement→oh-my-claudecode:executor, test→oh-my-claudecode:test-engineer, complex implement→oh-my-claudecode:deep-executor), and produce `schedule.md`.

### 2b. Execute Waves

Read the execution schedule from `.work/[run-name]/schedule.md`.

**If resuming** (startFromWave is set): Skip waves before startFromWave. For the startFromWave itself, skip tasks that are already marked Done in the skip list. Log skipped waves/tasks to worklog.

For each skipped wave, append to worklog:
```
| [timestamp] | WF | Wave skipped (resume) | Wave [N] | All tasks previously completed |
```

For each skipped task within the resume wave, append:
```
| [timestamp] | WF | Task skipped (resume) | T-XXX | Previously completed — found in Done column |
```

For each wave in the schedule (starting from startFromWave, or Wave 0 for fresh runs):

**Agent type mapping by task type:**
- `design` tasks → `oh-my-claudecode:designer`
- `implement` tasks → `oh-my-claudecode:executor`
- `test` tasks → `oh-my-claudecode:test-engineer`
- `implement` tasks flagged as complex → `oh-my-claudecode:deep-executor`

**If the wave has a single task:**
Use the **Task tool** to spawn the assigned OMC agent (from the schedule) with:

> Execute task [T-XXX] from the WF plan at `.work/[run-name]/`. Read the task details at `plan/tasks/T-XXX.md`. Follow the kanban protocol: move card to In Progress, implement, move to Review, log to worklog.

**If the wave has multiple tasks:**
Use the **Task tool** to create an agent team. For each task in the wave, spawn the assigned OMC agent as a teammate:

> Create an agent team to execute Wave [N] of the WF plan at `.work/[run-name]/`.
> Teammates:
> - [OMC Agent Type]: Execute [T-XXX] — [title]. Files: [ownership list]
> - [OMC Agent Type]: Execute [T-YYY] — [title]. Files: [ownership list]
> ...
> Each teammate: read task details from plan/tasks/, follow kanban protocol, log to worklog.
> File ownership boundaries are strict — no teammate modifies another's files.

### 2c. Gate Check (between waves)

After each wave completes, use the **Task tool** to spawn a **wf-integrator** agent:

> Check gates for Wave [N] of the WF run at `.work/[run-name]/`.
> - Check Test Gate: verify all wave tasks have test evidence
> - Update kanban: move completed tasks forward, move next wave's tasks to Ready

If a gate fails:
1. Report which gate failed and why
2. Spawn the responsible OMC agent to fix the issue (max 2 retries)
3. Re-check the gate
4. If still failing after 2 retries, report to user and stop

### 2d. Work Complete Check

After all waves are done, verify:
- All tasks in `kanban.md` are in Review or Done
- Test Gate has passed for all waves (check worklog for gate-pass entries)

If any tasks remain incomplete, report which ones and ask user: retry / re-plan / abort.

---

## Phase 3: REVIEW

Use the **Task tool** to spawn an **oh-my-claudecode:code-reviewer** agent:

> Review the WF run at `.work/[run-name]/`. Check code quality, regression risk, gate compliance, and overall risk. Read the worklog, kanban, and code changes. Produce `review.md`.

Optionally, if the task involved security-sensitive changes, also spawn an **oh-my-claudecode:security-reviewer** agent:

> Security review the WF run at `.work/[run-name]/`. Check for security vulnerabilities, unsafe patterns, and risk in the code changes. Append security findings to `review.md`.

### Review Gate

Read `review.md` from the run directory.

- **PASS** -> proceed to Phase 4
- **NEEDS_CHANGES** ->
  1. Identify which tasks need fixes from the review issues
  2. Spawn the responsible OMC agent(s) to fix the issues
  3. Re-run the code-reviewer (max 2 fix-review cycles)
  4. If still NEEDS_CHANGES after 2 cycles, report to user
- **FAIL** -> report to user and stop

---

## Phase 4: SKILLS

This phase manages verify-* skills using `/manage-skills` and `/verify-implementation`.

### 4a. Skill Maintenance

Run `/manage-skills` to analyze the WF run's session changes and maintain verify-* skills:

1. Analyze all files changed during this WF run (from worklog or git diff)
2. Extract patterns and conventions that emerged during the session
3. Map changes to discovered verify-* skills
4. Identify coverage gaps
5. Auto-decide CREATE vs UPDATE for each gap
6. Create new verify-* skills or update existing ones as needed
7. Verify-* skills are automatically discovered via filesystem glob

If `/manage-skills` produces no changes (full coverage already exists), note this and proceed.

### 4b. Verification Run (Optional)

If new verify-* skills were created or updated in 4a, optionally run `/verify-implementation` to validate the current codebase against the updated skill set:

- Verification runs all discovered verify-* skills in **parallel** via Task tool
- If PASS: proceed to Phase 5
- If WARN: note warnings in worklog, proceed to Phase 5
- If FAIL: present failures to user, offer fix options (전체 수정 / 개별 수정 / 건너뛰기), re-verify if fixes applied

### 4c. Summary

Log to worklog:
- Skills created: [count]
- Skills updated: [count]
- Verification status: [PASS/WARN/FAIL/SKIPPED]

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
| Task | Title | Type | Status |
|------|-------|------|--------|
| T-001 | ... | implement | Done |
| T-002 | ... | design | Done |

## Artifacts Produced
- [list of files, evidence files, migration plans if any]

## Review Status
[PASS/NEEDS_CHANGES — summary from review.md]

## Skills Updated
[List of new/updated verify-* skills, or "None"]

## Metrics
- Total tasks: [N]
- Waves executed: [N]
- Gates passed: [N] (Plan Gate + Test Gate)
- Review issues: [N] (fixed: [N])
```

2. Update `kanban.md`: move all tasks from Review to Done

3. Clear OMC pipeline state:
```
state_clear(mode="team", key="wf-run")
```

4. Append final worklog entry:
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
```

---

## Error Handling

- **Phase failure**: Report which phase failed and why. Do NOT silently skip phases. Write error state for resume recovery:
  ```
  state_write(mode="team", key="wf-run-error", value={"run": "[run-name]", "phase": "[failed-phase]", "error": "[reason]"})
  ```
- **Agent failure**: If an OMC agent errors out, fall back to `oh-my-claudecode:deep-executor` for that task.
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
