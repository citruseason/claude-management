# WF Resume Detection

Phase 0 resume logic. Referenced from SKILL.md when incomplete runs are detected.

---

## Incomplete Run Options

Present via `AskUserQuestion`:

> 미완료 런이 감지되었습니다:
> [list: `- .work/[run-name]/` (last worklog entry: [summary])]
> [If 24+ hours old: `⚠ [N시간] 전에 중단되었습니다.`]
>
> 선택:
> 1. 재개 — 해당 런을 재개
> 2. 새로 시작 — 새 런 생성
> 3. 폐기 — 미완료 런을 `.work/_archived/`로 아카이브

---

## Resume Point Detection (resumePoint)

### HEAD Change Detection

Compare worklog's last `HEAD:` entry with current `git rev-parse --short HEAD`.

- **Same**: Proceed to consistency check.
- **Different**: Ask user — 재개 (ignore changes) or 재계획 (Phase 1).

### Kanban-Worklog Consistency Check

Spawn **wf-integrator** to reconcile kanban.md and worklog.md. Worklog is source of truth. Fix kanban discrepancies.

### Resume Decision Table (first match wins)

| # | Condition | Resume From |
|---|-----------|-------------|
| 1 | `plan/` or `plan/plan.md` or `kanban.md` missing | Phase 1 |
| 2 | `schedule.md` missing, all tasks in Backlog | Phase 1 (ask: keep plan or re-plan?) |
| 3 | `schedule.md` missing, some tasks not in Backlog | Phase 2a |
| 4 | `schedule.md` exists, non-Done tasks remain | Phase 2b (run resumeWave) |
| 5 | All tasks Done, `review.md` missing | Phase 3 |
| 6 | `review.md` status != PASS | Phase 3 (if 2+ failures, ask user) |
| 7 | `review.md` PASS, `done.md` missing | Phase 5 |

**Principle**: When ambiguous, resume one phase earlier than necessary.

Display resume point and **wait for user confirmation**.

---

## Wave Resume Detection (resumeWave)

Applies when resume decision is Phase 2b (rule 4).

Read `schedule.md`. For each wave from Wave 0:

1. All tasks Done + gate-pass in worklog → Skip wave
2. Some tasks Done → Resume here (skip Done tasks)
3. No tasks started → Resume here

Output completed waves, resume wave number, tasks to skip/execute. Pass to Phase 2b.
