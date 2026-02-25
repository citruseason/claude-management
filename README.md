# claude-management

Workflow orchestration plugin for Claude Code with Agent Teams and Skills.

## Features

- **9 Custom Agents** - Research, review, workflow, and documentation specialists
- **16 Slash Commands** - `/init`, `/run`, `/team`, `/explore`, `/plan`, `/review`, `/work`, `/verify`, `/manage-skills`, `/ship`, and more
- **Automated Pipeline** - `/run` orchestrates plan→work→verify→review→ship, autonomously using agent teams when beneficial
- **Agent Teams** - `/team` spawns parallel Claude instances; `/run` auto-decides when to use them
- **Self-Maintaining Verification** - `/manage-skills` auto-generates verify-* skills from code changes; `/verify` runs them all
- **External Skill Integration** - Discovers and integrates skills from skills.sh via verify-* wrappers
- **Safety Hooks** - Block force pushes, auto-format on save, validate commits
- **Multilingual** - English and Korean prompt fragments
- **MCP Integration** - Context7 for up-to-date library documentation

## Documentation

- **[Workflow Guide](docs/workflow-guide.md)** — Scenario-based examples (feature, bug fix, verification loop, session wrap-up)
- **[Skill & Agent Reference](docs/skill-reference.md)** — Complete reference for all 16 skills and 9 agents

## Quick Start

### Install

```bash
git clone https://github.com/citruseason/claude-management.git

# Session only
claude --plugin-dir ./claude-management

# Permanent
claude plugin install ./claude-management
```

### First Run

```
/init                    # Set up project (directories, rules, .gitignore)
/run Add JWT auth        # Full pipeline: plan → work → verify → review → ship
```

### Slash Commands

```
/init                    # Set up project (directories, rules, .gitignore)
/run Add JWT auth        # Full pipeline (auto-decides team vs subagent)
/run Build dashboard     # Auto-uses agent team if multi-module
/team Review PR #42     # Spawn review team (3 parallel reviewers)
/explore src/           # Explore codebase structure
/trace handleRequest    # Trace execution path
/plan Add user auth     # Create implementation plan
/work                   # Execute the plan
/verify                 # Run all verify-* skills + tests
/manage-skills          # Auto-generate verify-* skills from changes
/review src/auth.ts     # Code review
/security-audit         # Security scan
/ship                   # Commit and PR
/document src/api/      # Generate docs
/changelog              # Update changelog
/lesson Always check X  # Record a lesson
/retrospective          # Run retrospective
```

### Plan Modification

`/run` and `/plan` pause after creating a plan for your review:

```
Plan created: .work/plans/01-add-auth/ (5 steps)
Proceed with implementation?
```

You can request changes before approving:

```
> "Add signup endpoint to Step 3"
> "Use Toss Payments instead of Stripe"
> "Split Step 2 into separate middleware files"
```

The planner re-runs with your feedback. Repeat until satisfied, then approve.

### Resume Interrupted Work

Progress is persisted in `.work/plans/*/todo.md`. If a session is interrupted:

```
/run --resume            # Auto-detect last plan, continue from where it stopped
/work                    # Or manually execute the latest plan
```

`--resume` reads `todo.md` and picks up at the right phase:
- Unchecked steps remain → resumes at WORK
- All steps done, no commit → resumes at VERIFY
- No plan exists → starts from PLAN

## Architecture

```
Skill (/command)  -->  Agent (execution)  -->  Tools (Read, Write, Bash, etc.)
  user interface        work engine             system capabilities
```

### Design Principles

| Principle | Description |
|-----------|-------------|
| Agent = Engine | Agents perform the actual work (explore, review, implement) |
| Skill = Interface | Skills delegate to agents via `/slash-command` |
| Fork vs Inline | Read-only tasks fork context; modification tasks run inline |
| Safety First | Destructive skills require explicit confirmation |
| Model Strategy | Read-only agents use sonnet; critical path inherits parent model |

### External Skills

Skills installed from external sources (e.g. [skills.sh](https://skills.sh)) are automatically discovered by `/init` and `/run`. Run `/manage-skills` to create `verify-*` wrappers that integrate external skill rules into the verification pipeline. See [Workflow Guide](docs/workflow-guide.md) for examples.

## Directory Structure

```
claude-management/
├── .claude-plugin/plugin.json    # Plugin manifest
├── base/                         # Workflow rules (CLAUDE.md)
├── agents/                       # 9 custom subagents
├── skills/                       # 16 slash commands
├── hooks/hooks.json              # Event-based quality gates
├── scripts/                      # Hook scripts
├── i18n/                         # Multilingual prompts
├── settings.json                 # Default permissions
└── .mcp.json                     # MCP server config
```

## Agents

### Research
- **research-codebase** - Explore code structure, patterns, dependencies (sonnet)

### Review
- **review-code** - Code quality, correctness, conventions (inherit)
- **review-security** - OWASP-based security audit (inherit)
- **review-performance** - Performance bottleneck analysis (sonnet)

### Workflow
- **workflow-planner** - Implementation planning (inherit)
- **workflow-implementer** - Code implementation (inherit)
- **workflow-verifier** - Testing and verification (inherit)

### Documentation
- **docs-generator** - Technical documentation (sonnet)
- **docs-readme** - README and changelog (sonnet)

## Hooks

| Hook | Event | Action |
|------|-------|--------|
| block-force-push.sh | PreToolUse (Bash) | Block `git push --force`, `git reset --hard`, `rm -rf` |
| format-on-save.sh | PostToolUse (Edit/Write) | Auto-format with prettier/black/rubocop/gofmt |
| lint-check.sh | Manual | Run project-appropriate linter |
| validate-commit-msg.sh | PreToolUse (Bash) | Validate commit message quality |

## Configuration

### Settings (settings.json)

Default permissions allow read operations and safe git commands. Dangerous operations (force push, hard reset, destructive rm) are denied.

### MCP Servers (.mcp.json)

Context7 is included for up-to-date library documentation lookup.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following existing patterns
4. Test with `claude --plugin-dir .`
5. Submit a pull request

## License

MIT
