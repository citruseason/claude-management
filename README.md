# claude-management

WF pipeline orchestrator plugin for Claude Code — plan, parallel work with gates, review, done.

## Features

- **`/wf` Pipeline** — Single command: PLAN → WORK (parallel waves + gates) → REVIEW → SKILLS → DONE
- **OMC-integrated Agents** — Planner, Router, Executor, Designer, Test Engineer, Reviewer, Security, Integrator, Fallback
- **Parallel Wave Execution** — Tasks run in parallel waves based on dependency DAG
- **2 Gates** — Plan and Test gates enforce correctness between phases
- **Kanban Tracking** — 6-column board tracks task state throughout the pipeline
- **Safety Hooks** — Block force pushes, auto-format on save, pre-push verification reminder
- **Pre-push Verification** — Non-blocking hook recommends running `/verify-implementation` before push

## Install

```bash
git clone https://github.com/citruseason/claude-management.git

# Session only
claude --plugin-dir ./claude-management

# Permanent
claude plugin install ./claude-management
```

## How It Works

```
┌─────────────────────────────────────────────────────────────────────┐
│                         /wf <task>                                  │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─ PHASE 1: PLAN ─────────────────────────────────────────────────────┐
│                                                                     │
│  workflow-planner                                                   │
│  ├── Task decomposition (T-001, T-002, ...)                        │
│  ├── Type annotation (implement, design, test, migrate)            │
│  ├── Kanban board initialization                                    │
│  └── Dependency graph construction                                  │
│                                                                     │
│  ┌─ Plan Gate ──────────────────────────────────────────────────┐   │
│  │ ✓ Plan files exist  ✓ All tasks have type/gate              │   │
│  │ ✓ Kanban initialized  ✓ No circular dependencies            │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ⏸  User approval required                                         │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─ PHASE 2: WORK ─────────────────────────────────────────────────────┐
│                                                                     │
│  wf-router → DAG analysis → Wave grouping → schedule.md            │
│                                                                     │
│  ┌─ Wave 1 ──────────────────────────────────────────────────────┐  │
│  │                                                               │  │
│  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │  │
│  │   │  implement  │  │   design    │  │    test     │         │  │
│  │   │    Task     │  │    Task     │  │    Task     │         │  │
│  │   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │  │
│  │          │                │                │                  │  │
│  │          ▼                ▼                ▼                  │  │
│  │      executor         designer       test-engineer           │  │
│  │                                                               │  │
│  └───────────────────────────┬───────────────────────────────────┘  │
│                              ▼                                      │
│  ┌─ Test Gate ───────────────────────────────────────────────────┐  │
│  │ Test execution + evidence at wave completion                  │  │
│  └───────────────────────────┬───────────────────────────────────┘  │
│                              ▼                                      │
│  wf-integrator: kanban updates, gate checks, worklog               │
│                                                                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─ PHASE 3: REVIEW ───────────────────────────────────────────────────┐
│                                                                     │
│  wf-reviewer                                                        │
│  ├── Code quality check                                             │
│  ├── Contract consistency (FE ↔ BE 일치 검증)                       │
│  ├── Gate compliance (모든 gate 통과 증거 확인)                      │
│  ├── Regression risk assessment                                     │
│  └── review.md 생성 → PASS / NEEDS_CHANGES / FAIL                  │
│                                                                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─ PHASE 4: SKILLS ───────────────────────────────────────────────────┐
│  /manage-skills (verify-* 관리) → /verify-implementation (병렬 검증) │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─ PHASE 5: DONE ─────────────────────────────────────────────────────┐
│  done.md (summary, metrics) + kanban finalized + worklog closed    │
└─────────────────────────────────────────────────────────────────────┘
```

## Usage

```
/wf Build user dashboard with profile API and settings page
/wf Add payment integration with Stripe webhooks
/wf Implement search with Elasticsearch backend and React UI
```

The pipeline:
1. **PLAN** — Decomposes the task into T-XXX tasks with scope/phase/gate annotations. Pauses for approval.
2. **WORK** — Router builds dependency DAG, groups into waves, runs specialists in parallel.
3. **REVIEW** — Reviewer checks code quality, contract consistency, gate compliance.
4. **SKILLS** — Runs `/manage-skills` to maintain verify-* skills, optionally runs `/verify-implementation` in parallel.
5. **DONE** — Produces `done.md` summary.

## Agents

| Agent | Role |
|-------|------|
| workflow-planner | Task decomposition, kanban init, type/gate annotation |
| wf-router | DAG construction, wave grouping, agent assignment |
| oh-my-claudecode:executor | General implementation tasks |
| oh-my-claudecode:designer | UI/UX design tasks |
| oh-my-claudecode:test-engineer | Test writing and execution |
| oh-my-claudecode:code-reviewer | Code quality, regression risk review |
| oh-my-claudecode:security-reviewer | Security review |
| wf-integrator | Gate checks, worklog updates, kanban coordination |
| oh-my-claudecode:deep-executor | FULL-scope tasks, agent failure fallback |

## Gates

| Gate | Purpose | Blocks |
|------|---------|--------|
| Plan | All tasks have type/gate | WORK phase |
| Test | Test execution + evidence | REVIEW phase |

## Skills

Skills extend the pipeline with reusable capabilities.

| Skill | Type | Description |
|-------|------|-------------|
| manage-skills | Maintenance | Analyzes session changes + user input, creates/updates verify-* skills via dynamic discovery |
| verify-implementation | Verification | Parallel runner for discovered verify-* skills with fix-and-re-verify workflow |
| web-design-guidelines | Reference | UI review against Vercel Web Interface Guidelines |
| vercel-react-best-practices | Reference | React/Next.js performance and pattern rules |
| frontend-design | Reference | Creative frontend design guidance |

**Skill Types:**
- **Maintenance** — Invoked by the WF pipeline (Phase 4) or directly to maintain verification skills
- **Verification** — Runs discovered verify-* skills in parallel to validate implementation quality
- **Reference** — Contextual guidance consulted by specialist agents during relevant work

## Directory Structure

```
claude-management/
├── .claude-plugin/plugin.json    # Plugin manifest
├── agents/                       # 5 agents
├── skills/
│   ├── wf/SKILL.md                        # /wf pipeline skill
│   ├── manage-skills/SKILL.md             # Verify-* skill maintenance + dynamic discovery
│   ├── verify-implementation/SKILL.md     # Parallel verification runner
│   ├── web-design-guidelines/SKILL.md     # UI quality rules (Vercel)
│   ├── vercel-react-best-practices/SKILL.md # React/Next.js (Vercel)
│   └── frontend-design/SKILL.md           # Creative design (Anthropic)
├── hooks/hooks.json              # Safety hooks
├── scripts/
│   ├── block-force-push.sh                # Safety: prevent force push
│   ├── format-on-save.sh                  # Auto-format on file save
│   └── recommend-verify.sh                # Pre-push: recommend /verify-implementation
├── settings.json                 # Default permissions
├── CLAUDE.md                     # WF conventions
└── .mcp.json                     # MCP server config (Context7)
```

## License

MIT
