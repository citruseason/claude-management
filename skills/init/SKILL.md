---
name: init
description: Initialize a new project with workflow directory structure, base rules, and .gitignore setup. Safe to run multiple times — skips what already exists.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
argument-hint: "[--lang en|ko]"
---

# Project Initialization

**Input**: $ARGUMENTS

## Step 1: Parse Language

Parse `--lang` from $ARGUMENTS. Default to `en` if not specified.

Supported values: `en`, `ko`

Store the language choice for use in subsequent steps.

## Step 2: Detect Existing State

Check what already exists in the project:

1. **CLAUDE.md**: Read the project root `CLAUDE.md` (if it exists). Check if it already contains the workflow rules by searching for:
   - English: `## Workflow Orchestration`
   - Korean: `## 워크플로우 오케스트레이션`
2. **.work/ directory**: Check if `.work/` directory exists
3. **.work/lessons.md**: Check if `.work/lessons.md` exists
4. **.work/plans/**: Check if `.work/plans/` directory exists
5. **.gitignore**: Check if `.gitignore` exists and whether it already contains `.work/`

Record which items need to be created vs skipped.

## Step 3: Create Work Directory Structure

If `.work/` does not exist, create it.

If `.work/lessons.md` does not exist, create it with:

```markdown
# Lessons Learned

> Rules written for myself to prevent recurring mistakes.
> Reviewed at session start. Ruthlessly iterated until mistake rate drops.
```

If `.work/plans/` does not exist, create the directory by creating `.work/plans/.gitkeep` (empty file) so the directory is preserved in version control.

Skip any items that already exist — report what was skipped.

## Step 4: Append Workflow Rules to CLAUDE.md

If CLAUDE.md does NOT already contain the workflow rules heading (detected in Step 2):

1. Read the base rules file based on language:
   - English: `${CLAUDE_PLUGIN_ROOT}/base/CLAUDE.md`
   - Korean: `${CLAUDE_PLUGIN_ROOT}/base/CLAUDE-KO.md`
2. If CLAUDE.md does not exist, create it with the base rules content
3. If CLAUDE.md exists but lacks the workflow rules, append the base rules to the end of the file (add two blank lines before appending for separation)

If the workflow rules heading is already present, skip this step entirely and report it was skipped.

**Important**: Never overwrite existing CLAUDE.md content. Only append.

## Step 5: Update .gitignore

If `.gitignore` does not exist, create it with:

```
.work/
```

If `.gitignore` exists but does NOT contain a line matching `.work/`:

- Append `.work/` to the end of the file (with a trailing newline)

If `.gitignore` already contains `.work/`, skip this step and report it was skipped.

## Step 6: Discover Installed Skills

Scan `.claude/skills/` for all `*/SKILL.md` files in the project directory.

For each discovered skill:
1. Read the SKILL.md frontmatter to extract `name` and `description`
2. Classify the skill:
   - Starts with `verify-` -> **verification** (already integrated with /verify)
   - Otherwise -> **external** (installed from outside our plugin)
3. Skip any skills that are symlinks pointing into `${CLAUDE_PLUGIN_ROOT}/skills/` (these are our own plugin skills)

If external skills are found, generate (or regenerate) `.work/skill-registry.md` with the discovered skills (see the Skill Registry format below).

If no `.claude/skills/` directory exists or no skills are found, skip this step.

### Skill Registry Format

`.work/skill-registry.md` is a runtime artifact — auto-generated, gitignored, treated as a cache. If deleted, the next `/init` or `/run` recreates it.

The registry contains:
- A header with generation timestamp
- Summary counts (plugin skills, project verify skills, external skills)
- Tables for each category: Plugin Skills, Project Verify Skills, External Skills
- For external skills: a "Has Verify Wrapper" column (check if `.claude/skills/verify-<skill-name>/SKILL.md` exists)

Classification logic:
- **Plugin skills**: Symlinks into `${CLAUDE_PLUGIN_ROOT}/skills/` or matching known plugin skill names (run, plan, work, verify, explore, trace, review, security-audit, ship, document, changelog, manage-skills, lesson, retrospective, team, init). Skip these.
- **Project verify skills**: Name starts with `verify-`. Already integrated with `/verify`.
- **External skills**: Everything else. These are what we surface.

## Step 7: Display Summary

Display a setup summary showing what was done and what was skipped.

If language is `en`:

```
## Setup Complete

### Actions Taken
- [x] Created .work/lessons.md          (or: Already existed — skipped)
- [x] Created .work/plans/              (or: Already existed — skipped)
- [x] Added workflow rules to CLAUDE.md  (or: Already present — skipped)
- [x] Added .work/ to .gitignore        (or: Already present — skipped)

### Available Commands

| Command           | Description                              |
|-------------------|------------------------------------------|
| /run              | Full pipeline (plan→work→verify→ship)    |
| /plan             | Create implementation plan               |
| /work             | Execute the plan                         |
| /verify           | Run verification checks                  |
| /review           | Code quality review                      |
| /ship             | Commit and create PR                     |
| /explore          | Explore codebase structure               |
| /trace            | Trace execution paths                    |
| /team             | Spawn parallel agent team                |
| /security-audit   | Security vulnerability scan              |
| /manage-skills    | Auto-generate verify-* skills            |
| /document         | Generate documentation                   |
| /changelog        | Update changelog                         |
| /lesson           | Record a lesson learned                  |
| /retrospective    | Session retrospective                    |

### Installed Skills Detected
| Source | Name | Type | Status |
|--------|------|------|--------|
| external | vercel-react-best-practices | guidelines | Available |
| external | web-design-guidelines | guidelines | Available |
| plugin | verify-api | verification | Active |

Tip: Run /manage-skills to create verify-* wrappers for external skills.

Run `/run <task>` to start your first automated pipeline.
```

Note: The "Installed Skills Detected" section is only shown if external or project verify skills were discovered in Step 6. If none were found, omit this section entirely.

If language is `ko`:

```
## 설정 완료

### 수행된 작업
- [x] .work/lessons.md 생성              (또는: 이미 존재 — 건너뜀)
- [x] .work/plans/ 생성                  (또는: 이미 존재 — 건너뜀)
- [x] CLAUDE.md에 워크플로우 규칙 추가     (또는: 이미 존재 — 건너뜀)
- [x] .gitignore에 .work/ 추가           (또는: 이미 존재 — 건너뜀)

### 사용 가능한 명령어

| 명령어             | 설명                                     |
|-------------------|------------------------------------------|
| /run              | 전체 파이프라인 (계획→작업→검증→배포)        |
| /plan             | 구현 계획 생성                             |
| /work             | 계획 실행                                 |
| /verify           | 검증 체크 실행                             |
| /review           | 코드 품질 리뷰                             |
| /ship             | 커밋 및 PR 생성                            |
| /explore          | 코드베이스 구조 탐색                        |
| /trace            | 실행 경로 추적                             |
| /team             | 병렬 에이전트 팀 생성                       |
| /security-audit   | 보안 취약점 스캔                            |
| /manage-skills    | verify-* 스킬 자동 생성                    |
| /document         | 문서 생성                                 |
| /changelog        | 변경 로그 업데이트                          |
| /lesson           | 교훈 기록                                 |
| /retrospective    | 세션 회고                                 |

### 감지된 설치 스킬
| 출처 | 이름 | 유형 | 상태 |
|------|------|------|------|
| 외부 | vercel-react-best-practices | 가이드라인 | 사용 가능 |
| 외부 | web-design-guidelines | 가이드라인 | 사용 가능 |
| 플러그인 | verify-api | 검증 | 활성 |

팁: /manage-skills를 실행하여 외부 스킬에 대한 verify-* 래퍼를 생성하세요.

`/run <작업>`을 실행하여 첫 번째 자동화 파이프라인을 시작하세요.
```

## Rules

- Idempotent: safe to run multiple times — always check before creating
- Never overwrite existing content in CLAUDE.md — only append
- Never delete or modify existing .gitignore entries
- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin file references
- Report every action (created/skipped) in the summary
