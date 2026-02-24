---
name: team
description: Spawn an agent team for parallel work — review, research, implementation, or debugging. Configures teammates with appropriate roles and coordinates their work.
argument-hint: "<task description> [--preset review|research|implement|debug]"
---

# Agent Team

Create and orchestrate an agent team for:

**Task**: $ARGUMENTS

## Preset Detection

Parse the task to determine the team preset:
- `--preset review` or contains "review", "audit", "PR" → **Review Team**
- `--preset research` or contains "research", "investigate", "explore" → **Research Team**
- `--preset implement` or contains "implement", "build", "feature" → **Implementation Team**
- `--preset debug` or contains "debug", "bug", "crash", "error" → **Debug Team**
- No match → ask the user which preset to use

## Presets

### Review Team (3 teammates)

Parallel code review with specialized lenses. Each reviewer works independently on the same code, then findings are synthesized.

```
Create an agent team to review the changes. Spawn three reviewers:
- One focused on code quality and conventions
- One focused on security implications
- One focused on performance impact
Have them each review and report findings. Synthesize their reports when done.
```

**When to use**: Before merging PRs, during code audits, before releases.

### Research Team (2-3 teammates)

Parallel investigation from different angles. Teammates share discoveries and challenge each other's conclusions.

```
Create an agent team to research [topic]. Spawn teammates:
- One exploring the codebase structure and existing patterns
- One researching external documentation, best practices, and historical context
Have them share findings with each other and produce a consolidated report.
```

**When to use**: Onboarding to new codebases, understanding complex systems, evaluating approaches.

### Implementation Team (2-4 teammates)

Parallel implementation with clear ownership boundaries. Each teammate owns separate files/modules.

```
Create an agent team to implement [feature]. Spawn teammates:
[assign each teammate a separate module/layer with clear file ownership]
Require plan approval before they make any changes.
Wait for all teammates to complete before proceeding.
```

**Important rules for implementation teams**:
- Each teammate MUST own different files — never let two teammates edit the same file
- Require plan approval before implementation starts
- Use the shared task list for dependency coordination
- Teammates should message each other when completing interfaces that others depend on

**When to use**: Multi-module features, cross-layer changes (frontend + backend + tests).

### Debug Team (3-5 teammates)

Competing hypothesis investigation. Teammates actively try to disprove each other's theories.

```
Create an agent team to debug [problem]. Spawn teammates to investigate different hypotheses:
[list suspected causes]
Have them talk to each other to try to disprove each other's theories, like a scientific debate.
Update findings when consensus emerges.
```

**When to use**: Complex bugs with unclear root cause, intermittent issues, performance problems.

## Team Management Rules

### Starting the team
1. Determine the preset from the task description
2. Customize the team creation prompt based on the preset and specific task
3. Spawn the team with clear role assignments

### During execution
- Monitor progress periodically
- Redirect teammates if they go off track
- If a teammate gets stuck, provide additional context or spawn a replacement
- Use delegation mode (Shift+Tab) to prevent the leader from implementing directly

### Wrapping up
1. Wait for all teammates to complete their tasks
2. Synthesize findings/results from all teammates
3. Present consolidated output to the user
4. Ask teammates to shut down
5. Clean up the team

## Post-Team Actions

After the team completes, suggest next steps based on preset:
- **Review Team** → apply fixes with `/work`, then `/ship`
- **Research Team** → create plan with `/plan`, then `/run`
- **Implementation Team** → `/verify` then `/review` then `/ship`
- **Debug Team** → `/work` to implement the fix, then `/verify`
