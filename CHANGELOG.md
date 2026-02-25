# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `/init` onboarding skill — guided first-time project setup (directories, workflow rules, .gitignore) with i18n support (en/ko)
- External skill integration — `/init` and `/run` discover skills from skills.sh; `/manage-skills` creates verify-* wrappers; `/verify` lists external skills in reports
- Skill registry (`.work/skill-registry.md`) — auto-generated inventory of plugin, verify, and external skills

### Changed
- `/plan` (and Phase 1 of `/run`) now asks clarifying questions via `AskUserQuestion` when task instructions are ambiguous (vague goal, missing scope, unclear requirements); skips clarification for well-defined tasks
- `/run` pipeline rewritten with imperative phase instructions and mandatory plan verification
- `/verify` now discovers and reports external (non-verify-*) skills alongside verification skills
- `/manage-skills` now proposes WRAP actions to create verify-* wrappers for external skills
- `/verify` now produces structured Gap Analysis identifying external skills without wrappers and offers to invoke `/manage-skills`
- `/manage-skills` accepts `--from-verify` flag to skip redundant discovery when invoked from `/verify`'s gap analysis
- `/run` pipeline adds conditional Phase 3.5 (MANAGE-SKILLS) that automatically addresses verification gaps

### Removed
- `research-docs` agent — orphaned, never referenced by any skill or agent
- `research-git-history` agent — orphaned, never referenced by any skill or agent
- `workflow-orchestrator` agent — superseded by `/run` skill which implements the pipeline inline

## [1.0.0] - 2026-02-24

### Added
- Plugin manifest (`.claude-plugin/plugin.json`)
- 9 custom subagents across 4 categories:
  - Research: codebase
  - Review: code, security, performance
  - Workflow: planner, implementer, verifier
  - Docs: generator, readme
- Agent teams enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` in settings.json
- 16 slash command skills:
  - Exploration: /explore, /trace
  - Review: /review, /security-audit
  - Workflow: /run (full pipeline, autonomous team decision), /team, /plan, /work, /verify, /ship
  - Maintenance: /manage-skills (self-maintaining verification system)
  - Documentation: /document, /changelog
  - Learning: /lesson, /retrospective
- Self-maintaining verification loop:
  - /manage-skills analyzes git diffs to auto-generate project-specific verify-* skills
  - /verify discovers and runs all registered verify-* skills with integrated reporting
- Hook scripts for safety and quality:
  - Force push blocking (PreToolUse)
  - Auto-formatting on save (PostToolUse)
  - Lint checking
  - Commit message validation
- MCP server configuration (Context7)
- Multilingual prompt fragments (English, Korean)
- Base workflow rules (CLAUDE.md in English and Korean)
