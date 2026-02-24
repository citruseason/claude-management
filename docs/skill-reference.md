# Skill & Agent Reference

Complete reference for all skills and agents in the claude-management plugin.

---

## Skills

### Onboarding

#### /init

Initialize a new project with workflow directory structure, base rules, and .gitignore setup. Safe to run multiple times.

| Property | Value |
|----------|-------|
| Agent | — (inline) |
| Context | inline |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/init                                 # Set up project (English, default)
/init --lang ko                       # Set up project (Korean)
```

**Process**:
1. Detects existing state (CLAUDE.md, .work/, .gitignore)
2. Creates `.work/lessons.md` and `.work/plans/` if missing
3. Appends base workflow rules to CLAUDE.md from plugin (skip if present)
4. Adds `.work/` to .gitignore (skip if present)
5. Discovers external skills in `.claude/skills/` and generates skill registry
6. Displays setup summary and available commands

**Idempotent**: Safe to run multiple times — checks before each action, skips what already exists, never overwrites.

---

### Pipeline

#### /run

Run the full development pipeline as a single automated command. Orchestrates specialized agents for each phase.

| Property | Value |
|----------|-------|
| Agent | — (inline, spawns subagents via Task tool) |
| Context | inline |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/run Add JWT authentication to the Express API
/run Fix the 500 error on GET /api/users/:id
/run Refactor database layer to connection pooling
/run Patch XSS vulnerability --mode hotfix
```

**Modes**:

| Mode | Pipeline | Auto-detect keywords |
|------|----------|---------------------|
| feature | PLAN → WORK → VERIFY → REVIEW → SHIP | (default) |
| bugfix | EXPLORE → WORK → VERIFY → SHIP | bug, fix, error, crash |
| refactor | PLAN → WORK → VERIFY → REVIEW → SHIP | refactor, restructure |
| hotfix | WORK → VERIFY → SHIP | urgent, hotfix, emergency |

**User gates**: Pauses for confirmation after PLAN and before SHIP. All other phases execute automatically.

**Auto-fix loop**: If VERIFY or REVIEW finds issues, the orchestrator attempts to fix them automatically (max 2 cycles) before escalating to the user.

**Resume**: If interrupted, `/run --resume` picks up from the last incomplete phase based on plan/todo state.

**Autonomous team decision**: After the plan is created, the orchestrator analyzes step independence and autonomously decides whether to use agent teams (parallel) or subagents (sequential) for WORK and REVIEW phases. No flag needed — it evaluates:
- Can steps execute in parallel? (different files, no dependencies)
- Is the scope large enough to justify team overhead? (5+ files, 3+ directories)
- Would parallel review add value? (multi-concern changes, security-sensitive code)

---

#### /team

Spawn an agent team for parallel work with specialized role presets.

| Property | Value |
|----------|-------|
| Agent | — (uses agent teams, not subagents) |
| Context | inline |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/team Review PR #142                              # Review team (3 reviewers)
/team Research the payment integration             # Research team
/team Implement user dashboard --preset implement  # Implementation team
/team Debug the WebSocket disconnection            # Debug team
```

**Presets**:

| Preset | Teammates | Strategy |
|--------|-----------|----------|
| review | 3 | Code quality + Security + Performance — parallel review, synthesized report |
| research | 2-3 | Codebase explorer + Docs researcher + Git historian — share findings, challenge conclusions |
| implement | 2-4 | File-ownership split — each teammate owns separate modules, plan approval required |
| debug | 3-5 | Competing hypotheses — teammates investigate different theories, debate to find root cause |

**Post-team actions**: After completion, suggests next steps based on preset (e.g., review→`/work`→`/ship`, debug→`/work`→`/verify`).

---

### Exploration

#### /explore

Explore and understand codebase structure, patterns, and conventions.

| Property | Value |
|----------|-------|
| Agent | research-codebase |
| Context | fork |
| Model | sonnet |
| Auto-invoke | yes |

**Usage**:
```
/explore src/                          # Explore directory structure
/explore authentication flow           # Find auth-related code
/explore "how does caching work"       # Understand a subsystem
```

**Output**: Architecture overview, key files, conventions, dependencies, observations.

---

#### /trace

Trace execution paths, data flow, and call chains through the codebase.

| Property | Value |
|----------|-------|
| Agent | research-codebase |
| Context | fork |
| Model | sonnet |
| Auto-invoke | yes |

**Usage**:
```
/trace GET /api/users/:id             # Trace an HTTP endpoint
/trace handlePayment                  # Trace a function call chain
/trace "user signup flow"             # Trace a feature end-to-end
```

**Output**: Call chain with file:line references, data transformations, side effects, error paths.

---

### Review

#### /review

Thorough code review checking correctness, quality, conventions, and maintainability.

| Property | Value |
|----------|-------|
| Agent | review-code |
| Context | fork |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/review src/auth.ts                   # Review a specific file
/review src/routes/                   # Review a directory
/review                               # Review uncommitted changes
```

**Output**: Issues listed by severity (CRITICAL/WARNING/SUGGESTION) with file:line references and fix suggestions. Overall pass/fail assessment.

**Supporting files**: `skills/review/checklist.md` — full review checklist used by the agent.

---

#### /security-audit

Scan for security vulnerabilities, secrets, injection flaws, and OWASP compliance.

| Property | Value |
|----------|-------|
| Agent | review-security |
| Context | fork |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/security-audit                       # Audit entire project
/security-audit src/routes/auth.ts    # Audit specific files
```

**Output**: Findings classified by OWASP category with severity, attack scenario, and remediation steps.

---

### Workflow

#### /plan

Create a detailed implementation plan before starting work.

| Property | Value |
|----------|-------|
| Agent | workflow-planner |
| Context | fork |
| Model | inherit |
| Auto-invoke | yes |

**Usage**:
```
/plan Add user authentication
/plan Refactor database layer to use connection pooling
/plan Fix memory leak in WebSocket handler
```

**Output**: Creates `.work/plans/[number-name]/` with:
- `plan.md` — detailed design document (inline steps for short plans, index + sub-files for long plans)
- `todo.md` — progress tracker with links to plan sections

---

#### /work

Execute an implementation plan step by step.

| Property | Value |
|----------|-------|
| Agent | — (inline) |
| Context | inline |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/work                                 # Execute latest plan
/work Fix the null check in user endpoint
```

**Process**: Reads latest plan from `.work/plans/`, implements each unchecked step, verifies as it goes, checks items off in `todo.md`.

---

#### /verify

Run all registered verify-* skills and general checks.

| Property | Value |
|----------|-------|
| Agent | workflow-verifier |
| Context | fork |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/verify                               # Run all verify-* skills + tests
/verify verify-api                    # Run specific verify skill
/verify src/routes/auth.ts            # Run skills covering this file
```

**Process**:
1. Discovers all `verify-*/SKILL.md` in `.claude/skills/`
2. Executes each skill's checks sequentially
3. Runs general checks (tests, lint, build, types)
4. Produces integrated report with PASS/FAIL per skill
5. Offers to auto-fix issues found
6. Lists external (non-verify-*) skills as available but not auto-executed

---

#### /ship

Create commits and pull requests for completed work.

| Property | Value |
|----------|-------|
| Agent | — (inline) |
| Context | inline |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/ship                                 # Commit current changes
/ship with PR                         # Commit and create pull request
```

**Process**: Reviews diff, stages files (never .env/credentials), writes commit message, optionally creates PR with summary and test plan.

---

### Maintenance

#### /manage-skills

Analyze code changes and auto-generate/update project verification skills.

| Property | Value |
|----------|-------|
| Agent | — (inline) |
| Context | inline |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/manage-skills                        # Analyze all session changes
/manage-skills auth                   # Focus on auth-related area
/manage-skills verify-api             # Update specific skill
```

**Process**:
1. Analyzes git diff to find changed files
2. Maps changes to existing verify-* skills
3. Detects coverage gaps
4. Proposes CREATE (new skill) or UPDATE (expand existing) actions
5. Creates/updates skills after user approval
6. Verifies all changes are valid
7. Proposes WRAP actions for external skills that lack verify-* wrappers

---

### Documentation

#### /document

Generate technical documentation from code analysis.

| Property | Value |
|----------|-------|
| Agent | docs-generator |
| Context | fork |
| Model | sonnet |
| Auto-invoke | yes |

**Usage**:
```
/document src/routes/                 # API documentation
/document src/services/payment.ts     # Module documentation
/document                             # Project overview
```

---

#### /changelog

Generate or update changelog entries from git history.

| Property | Value |
|----------|-------|
| Agent | docs-readme |
| Context | fork |
| Model | sonnet |
| Auto-invoke | no |

**Usage**:
```
/changelog                            # Generate from last tag to HEAD
/changelog v1.2.0..HEAD              # Specific range
```

---

### Learning

#### /lesson

Implements the Self-Improvement Loop (CLAUDE.md #3). Records lessons, writes preventive rules, and refines existing entries to drive mistake rate down.

| Property | Value |
|----------|-------|
| Agent | — (inline) |
| Context | inline |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/lesson Always validate JWT_SECRET exists at startup
/lesson Check for null returns from DB single-record queries
```

**Process**:
1. Search `.work/lessons.md` for existing similar lessons
2. If duplicate found → **refine** (sharpen rule, add example, increment occurrences)
3. If new → **create** with context, rule, prevention strategy, and example
4. Write a specific, actionable preventive rule (not just a note)
5. Flag automation candidates (verify-* skill or hook)
6. At 3+ occurrences → escalate to `## Active Rules` section for session-start review

---

#### /retrospective

Run a retrospective on recent work.

| Property | Value |
|----------|-------|
| Agent | — (inline) |
| Context | inline |
| Model | inherit |
| Auto-invoke | no |

**Usage**:
```
/retrospective                        # Review current session
/retrospective sprint-12              # Review specific scope
```

**Output**: What went well, what didn't, action items, and captured lessons.

---

## External Skill Integration

claude-management discovers and integrates external skills installed in `.claude/skills/` from sources like [skills.sh](https://skills.sh).

### How It Works

```
External skill installed -> /init or /run discovers it -> /manage-skills creates verify-* wrapper -> /verify runs the wrapper
```

### Discovery

External skills are automatically discovered when you run:
- `/init` — during project setup
- `/run` — during Phase 0 (Initialize)

Discovered skills appear in the pipeline overview and are recorded in `.work/skill-registry.md`.

### Integration via Verify Wrappers

External skills are not auto-executed during `/verify`. To integrate them:

1. Run `/manage-skills` — it detects external skills without verify wrappers
2. Approve the WRAP proposal — it creates a `verify-*` wrapper skill
3. The wrapper extracts verifiable rules from the external skill
4. Now `/verify` auto-executes the wrapper alongside other verify-* skills

### Skill Registry

`.work/skill-registry.md` is an auto-generated cache of all discovered skills. It is:
- Rebuilt on every `/init` or `/run`
- Located in `.work/` (gitignored)
- Read-only — never edit manually

### Example

```
$ claude /init

## Installed Skills Detected
| Source | Name | Type | Status |
|--------|------|------|--------|
| external | vercel-react-best-practices | guidelines | Available |
| external | web-design-guidelines | guidelines | Available |
| plugin | verify-api | verification | Active |

Tip: Run /manage-skills to create verify-* wrappers for external skills.

$ claude /manage-skills

### From External Skills
1. WRAP vercel-react-best-practices -> verify-react
   Rationale: Contains component and hook rules that can be verified

$ claude /verify

### Verify Skills
| # | Skill | Checks | Passed | Issues |
|---|-------|--------|--------|--------|
| 1 | verify-api | 5 | 5 | 0 |
| 2 | verify-react | 8 | 7 | 1 |
```

---

## Agents

### Research Agents

Read-only agents that explore and analyze without modifying files.

| Agent | Purpose | Model | Max Turns |
|-------|---------|-------|-----------|
| research-codebase | Code structure, patterns, dependencies | sonnet | 30 |
| research-docs | API docs, library references, documentation gaps | sonnet | 20 |
| research-git-history | Git log/blame/diff analysis, code evolution | sonnet | 20 |

### Review Agents

Read-only agents that audit code quality and security.

| Agent | Purpose | Model | Max Turns |
|-------|---------|-------|-----------|
| review-code | Quality, correctness, conventions, maintainability | inherit | 25 |
| review-security | OWASP-based vulnerabilities, secrets, injection | inherit | 25 |
| review-performance | Algorithmic complexity, N+1 queries, memory leaks | sonnet | 20 |

### Workflow Agents

Agents that drive the plan-work-verify cycle.

| Agent | Purpose | Model | Max Turns | Tools |
|-------|---------|-------|-----------|-------|
| workflow-orchestrator | Full pipeline automation | inherit | 50 | Read, Write, Edit, Grep, Glob, Bash, Task |
| workflow-planner | Implementation planning (read-only) | inherit | 25 | Read, Grep, Glob, Bash |
| workflow-implementer | Code implementation (read-write) | inherit | 30 | Read, Write, Edit, Grep, Glob, Bash |
| workflow-verifier | Testing and verification (read-only) | inherit | 20 | Read, Grep, Glob, Bash |

The **workflow-orchestrator** is the meta-agent: it delegates to planner, implementer, verifier, and reviewer via the Task tool, managing quality gates between phases.

### Documentation Agents

Agents that generate and maintain documentation.

| Agent | Purpose | Model | Max Turns |
|-------|---------|-------|-----------|
| docs-generator | Technical documentation from code analysis | sonnet | 20 |
| docs-readme | README files and changelogs | sonnet | 15 |

---

## Model Strategy

| Category | Model | Rationale |
|----------|-------|-----------|
| Research agents | sonnet | Read-only analysis — cost efficient, fast |
| Review agents (code, security) | inherit | Critical judgment — use the best available model |
| Review agents (performance) | sonnet | Pattern matching — doesn't need strongest reasoning |
| Workflow (planner, implementer, verifier) | inherit | Core path — quality matters most |
| Documentation agents | sonnet | Structured writing — sonnet handles well |

---

## Hooks

| Script | Event | Trigger | Action |
|--------|-------|---------|--------|
| `block-force-push.sh` | PreToolUse | Bash | Block `git push --force`, `git reset --hard`, `rm -rf /` |
| `format-on-save.sh` | PostToolUse | Edit, Write | Auto-format with project formatter (prettier, black, gofmt, etc.) |
| `lint-check.sh` | Manual | — | Run project-appropriate linter |
| `validate-commit-msg.sh` | PreToolUse | Bash (git commit) | Warn on short or WIP commit messages |

---

## File Structure

### Plan files

```
.work/plans/01-add-auth/
├── plan.md                   # Design document (short: inline, long: index)
├── plan-database-schema.md   # Step detail (long plans only)
├── plan-auth-endpoints.md    # Step detail (long plans only)
└── todo.md                   # Progress tracker with links
```

### Lesson files

```
.work/lessons.md              # Accumulated lessons learned
```

### Project verify skills (generated by /manage-skills)

```
.claude/skills/
├── verify-api/SKILL.md       # Project-specific: REST conventions
├── verify-auth/SKILL.md      # Project-specific: auth patterns
└── verify-*/SKILL.md         # Auto-generated per project needs
```

### Skill registry

```
.work/skill-registry.md           # Auto-generated skill inventory
```
