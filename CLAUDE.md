## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
- **No Guessing**: Contracts are based on BE outputs. FE never guesses API shapes.
- **Gate Enforcement**: Gate failures block the next phase. Record failures and remediation.

## Self-Improvement Loop

- After ANY correction from the user: update `.work/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Review lessons at session start

## WF Pipeline

### Run Directory

Each `/wf` invocation creates a run directory at `.work/YYYYMMDD-HHmm-<slug>/`:

```
.work/20260225-1430-user-dashboard/
├── plan/
│   ├── plan.md (or index.md + tasks/)
│   └── tasks/
├── artifacts/
│   ├── <feature>-contract.md
│   ├── <feature>-evidence.md
│   └── <feature>-migration.md
├── kanban.md
├── worklog.md
├── schedule.md
├── review.md
└── done.md
```

### Kanban Board

6 columns: Backlog, Ready, In Progress, Blocked, Review, Done.

Card format:
`T-XXX | Title | Owner: ROLE | Scope: FE/BE/DBA | Phase: FE_A/BE/FE_B | Dep: T-YYY | Gate: contract/test | Link: plan/tasks/T-XXX.md`

### Gates

4 gates control the pipeline flow:
1. **Plan Gate** — plan artifacts exist, all tasks have scope/phase/gate
2. **Contract Gate** — contract artifact + verification evidence before FE_B
3. **Migration Gate** — migration plan + rollback + risk assessment (when DBA involved)
4. **Test Gate** — per-scope test execution + evidence at wave completion

### Agent Team

| Role | Agent | Responsibility |
|------|-------|---------------|
| Planner | workflow-planner (WF Mode) | Task decomposition, kanban init |
| Router | wf-router | DAG construction, wave scheduling |
| FE Specialist | wf-fe-specialist | FE_A (mocks) and FE_B (contract integration) |
| BE Specialist | wf-be-specialist | API implementation, Contract Artifact generation |
| DBA Specialist | wf-dba-specialist | Migrations, rollback plans |
| Integrator | wf-integrator | Worklog updates, gate checks |
| Reviewer | wf-reviewer | Quality/regression/risk review |
| Implementer | workflow-implementer | FULL-scope tasks, agent failure fallback |
