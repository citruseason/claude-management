# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `/init` onboarding skill — guided first-time project setup (directories, workflow rules, .gitignore) with i18n support (en/ko)
- External skill integration — `/init` and `/run` discover skills from skills.sh; `/manage-skills` creates verify-* wrappers; `/verify` lists external skills in reports
- Skill registry (`.work/skill-registry.md`) — auto-generated inventory of plugin, verify, and external skills

### Changed
- `/run` pipeline rewritten with imperative phase instructions and mandatory plan verification
- `/verify` now discovers and reports external (non-verify-*) skills alongside verification skills
- `/manage-skills` now proposes WRAP actions to create verify-* wrappers for external skills
- `workflow-orchestrator` agent updated with critical rules enforcement

## [1.0.0] - 2026-02-24

### Added
- Plugin manifest (`.claude-plugin/plugin.json`)
- 12 custom subagents across 4 categories:
  - Research: codebase, docs, git-history
  - Review: code, security, performance
  - Workflow: orchestrator, planner, implementer, verifier
  - Docs: generator, readme
- Agent teams enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` in settings.json
- 15 slash command skills:
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
