# claude-management

WF pipeline orchestrator plugin for Claude Code — plan, parallel work with gates, review, done.

## Features

- **`/wf` Pipeline** — Single command: PLAN → WORK (parallel waves + gates) → REVIEW → SKILLS → DONE
- **8 Specialist Agents** — Planner, Router, FE/BE/DBA Specialists, Integrator, Reviewer, Implementer
- **Parallel Wave Execution** — FE_A and BE run in parallel; FE_B starts after Contract Gate
- **4 Gates** — Plan, Contract, Migration, Test gates enforce correctness between phases
- **Kanban Tracking** — 6-column board tracks task state throughout the pipeline
- **Safety Hooks** — Block force pushes, auto-format on save

## Install

```bash
git clone https://github.com/citruseason/claude-management.git

# Session only
claude --plugin-dir ./claude-management

# Permanent
claude plugin install ./claude-management
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
4. **SKILLS** — Detects reusable patterns, proposes verify-* skills.
5. **DONE** — Produces `done.md` summary.

## Agents

| Agent | Role |
|-------|------|
| workflow-planner | Task decomposition, kanban init, scope/phase/gate annotation |
| wf-router | DAG construction, wave grouping, specialist assignment |
| wf-fe-specialist | FE_A (mock-based UI) and FE_B (contract integration) |
| wf-be-specialist | API implementation, Contract Artifact generation |
| wf-dba-specialist | Migrations, rollback plans, risk assessment |
| wf-integrator | Gate checks, worklog updates, kanban coordination |
| wf-reviewer | Code quality, regression risk, contract consistency review |
| workflow-implementer | FULL-scope tasks, agent failure fallback |

## Gates

| Gate | Purpose | Blocks |
|------|---------|--------|
| Plan | All tasks have scope/phase/gate | WORK phase |
| Contract | Contract artifact + evidence exist | FE_B tasks |
| Migration | Migration plan + rollback + risk | Dependent BE tasks |
| Test | Per-scope test evidence | REVIEW phase |

## Directory Structure

```
claude-management/
├── .claude-plugin/plugin.json    # Plugin manifest
├── agents/                       # 8 specialist agents
├── skills/wf/SKILL.md            # /wf pipeline skill
├── hooks/hooks.json              # Safety hooks
├── scripts/                      # Hook scripts
├── settings.json                 # Default permissions
├── CLAUDE.md                     # WF conventions
└── .mcp.json                     # MCP server config (Context7)
```

## License

MIT
