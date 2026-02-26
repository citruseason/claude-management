## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
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
`T-XXX | Title | Owner: ROLE | Type: implement/design/test/migrate | Dep: T-YYY | Gate: plan/test | Link: plan/tasks/T-XXX.md`

### Gates

2 gates control the pipeline flow:
1. **Plan Gate** — plan artifacts exist, all tasks have type/gate
2. **Test Gate** — test execution + evidence at wave completion

### Agent Team

| Role | Agent | Responsibility |
|------|-------|---------------|
| Planner | workflow-planner | Task decomposition, kanban init |
| Router | wf-router | DAG construction, wave scheduling |
| Executor | oh-my-claudecode:executor | General implementation tasks |
| Designer | oh-my-claudecode:designer | UI/UX design tasks |
| Test Engineer | oh-my-claudecode:test-engineer | Test writing and execution |
| Reviewer | oh-my-claudecode:code-reviewer | Quality/regression/risk review |
| Security | oh-my-claudecode:security-reviewer | Security review |
| Integrator | wf-integrator | Worklog updates, gate checks |
| Fallback | oh-my-claudecode:deep-executor | FULL-scope tasks, agent failure fallback |

### Skills

| Skill | Type | Purpose |
|-------|------|---------|
| wf | Pipeline | Single-entry WF orchestrator (Phase 0-5) |
| manage-skills | Maintenance | Session-based verify-* skill creation/update with dynamic discovery, user input, and AI session analysis |
| verify-implementation | Verification | Parallel runner for all discovered verify-* skills with fix-and-re-verify workflow |
| web-design-guidelines | Reference | UI review against Vercel Web Interface Guidelines |
| vercel-react-best-practices | Reference | React/Next.js performance and pattern rules |
| frontend-design | Reference | Creative frontend design guidance |
| skill-maker | Maintenance | Skill design and creation guided by best practices |
| authoring-skills | Verification | Skill validation against best practices checklist |

**Skill Types:**
- **Pipeline** — Core orchestrator skill invoked directly by users
- **Maintenance** — Invoked by the WF pipeline (Phase 4) or directly to maintain/create skills
- **Verification** — Runs discovered verify-* skills in parallel to validate implementation quality
- **Reference** — Contextual guidance consulted by specialist agents during relevant work
