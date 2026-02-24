---
name: manage-skills
description: Analyzes session changes to detect missing verification skills. Explores existing skills, creates new verify-* skills or updates existing ones, and keeps the skill registry in sync.
disable-model-invocation: true
argument-hint: "[optional: specific skill name or area to focus on]"
---

# Manage Skills

Analyze changes and manage verification skills:

**Focus**: $ARGUMENTS

## Step 1: Analyze Session Changes

Collect all changed files:
- `git diff HEAD --name-only` (uncommitted changes)
- `git log --oneline main..HEAD 2>/dev/null` (commits on current branch)
- `git diff main...HEAD --name-only 2>/dev/null` (all changes since branching)

Deduplicate and group files by top-level directory. If an argument specifies a skill name or area, filter accordingly.

## Step 2: Discover Existing Verify Skills

Scan for all `verify-*/SKILL.md` files under `.claude/skills/` in the project (not the plugin).

For each found skill, read its SKILL.md and extract:
- Name and description
- Related file patterns
- Detection commands (grep/glob patterns)

Build a coverage map: which files are covered by which skills.

## Step 2.5: Discover External Skills

Scan `.claude/skills/` for all `*/SKILL.md` files that are NOT `verify-*` prefixed and NOT symlinks into `${CLAUDE_PLUGIN_ROOT}/skills/`.

For each external skill:
1. Read its SKILL.md to understand what it checks/enforces
2. Determine if a `verify-*` wrapper already exists (check for `.claude/skills/verify-<skill-name>/SKILL.md`)
3. Classify the external skill's purpose:
   - **verification**: Contains check/validate/lint/audit instructions -> good candidate for verify wrapper
   - **guidelines**: Contains best practices/conventions/patterns -> good candidate for verify wrapper
   - **tooling**: Contains setup/config/scaffold instructions -> not a verify candidate
   - **other**: Unclear purpose -> ask user

Build an external skills map: which external skills exist, which already have verify wrappers, which are candidates for new wrappers.

## Step 3: Coverage Gap Analysis

For each changed file, check if it's covered by an existing verify-* skill.

Classify each file as:
- **COVERED**: matched by an existing skill's file patterns
- **UNCOVERED**: no matching skill exists

Skip these file types (not verification targets):
- Lock files and generated files (package-lock.json, yarn.lock, build outputs)
- Documentation files (README.md, CHANGELOG.md, LICENSE)
- Test fixture data (fixtures/, __fixtures__/, test-data/)
- Vendor/third-party code (vendor/, node_modules/)
- CI/CD configuration (.github/, .gitlab-ci.yml, Dockerfile)

For covered skills with changed files, check for:
1. Missing file references - changed files in the skill's domain not listed
2. Stale detection commands - patterns that no longer match current files
3. Uncovered new patterns - new types, enums, conventions not checked
4. References to deleted/moved files

## Step 4: Propose Actions

Apply this decision tree:
- UNCOVERED files relate to an existing skill's domain → **UPDATE** that skill
- 3+ related UNCOVERED files share common rules/patterns → **CREATE** new verify skill
- External skill exists without verify wrapper AND is verification/guidelines type → **WRAP** (create verify-* wrapper)
- Otherwise → **EXEMPT** (no skill needed)

Present proposed actions to the user with `AskUserQuestion`:
- List each proposed CREATE/UPDATE/WRAP with rationale
- Let user approve, modify, or skip each action

Example proposal format:

```markdown
## Proposed Actions

### From Code Changes
1. UPDATE verify-api — add new route file to Related Files
2. CREATE verify-db — 3 new migration files share common patterns

### From External Skills
3. WRAP vercel-react-best-practices -> verify-react
   Rationale: External skill contains component structure and hook rules that can be verified
4. WRAP web-design-guidelines -> verify-design
   Rationale: External skill contains spacing, color, and accessibility rules

Note: WRAP creates a thin verify-* skill that references the external skill's rules.
Already wrapped: frontend-design (verify-frontend exists)
```

## Step 5: Update Existing Skills

For approved updates (**add only** - never remove working checks):
- Add new file paths to Related Files
- Add new detection commands for discovered patterns
- Add new workflow steps for uncovered rules
- Remove confirmed-deleted file references
- Update changed values (identifiers, config keys)

## Step 5.5: Create Wrapper Skills

For approved WRAP actions, create a `verify-<name>/SKILL.md` that:

1. References the original external skill by name
2. Extracts the verifiable rules from the external skill's content
3. Translates those rules into concrete check steps with PASS/FAIL criteria

Wrapper skill template:

```yaml
---
name: verify-<name>
description: Verification wrapper for <external-skill-name>. Checks compliance with <external-skill-description>.
disable-model-invocation: true
---
```

Body structure:

```markdown
# Verify: <External Skill Name>

> Wrapper skill that checks compliance with the <external-skill-name> skill.
> Source: .claude/skills/<external-skill-name>/SKILL.md

## Purpose
[Extracted from external skill -- 2-5 numbered verification categories]

## When to Run
[Derived from external skill -- trigger conditions based on file types]

## Related Files
[File patterns relevant to this external skill's domain]

## Workflow
[Concrete check steps with tool, file path, PASS/FAIL criteria, fix instructions]
[Each check should reference a specific rule from the external skill]

## Exceptions
[Realistic non-violation cases]
```

Important: The wrapper reads the external skill's content and translates it into verifiable checks. It does NOT simply say "run the external skill" -- it extracts specific, actionable checks.

## Step 6: Create New Skills

For approved new skills:

1. **Explore**: Read related changed files deeply to understand patterns
2. **Confirm name**: Ask user via `AskUserQuestion`. Name must be `verify-<name>` in kebab-case.
3. **Create** `.claude/skills/verify-<name>/SKILL.md` with:

```yaml
---
name: verify-<name>
description: <what this verifies>
disable-model-invocation: true
---
```

Required sections in the skill body:
- **Purpose**: 2-5 numbered verification categories
- **When to Run**: 3-5 trigger conditions
- **Related Files**: Actual file paths (verified with `ls`, no placeholders)
- **Workflow**: Check steps with tool, file path, PASS/FAIL criteria, fix instructions
- **Exceptions**: 2-3 realistic non-violation cases

4. **Update the verify skill registry**: Add new skill to the project's `/verify` target list if one exists.

## Step 7: Verify Changes

After all edits:
1. Re-read all modified SKILL.md files
2. Validate markdown format (unclosed code blocks, consistent tables)
3. Confirm no broken file references (`ls` each Related Files path)
4. Dry-run one detection command per updated skill

## Step 8: Summary Report

Display final report:

```markdown
## Skill Management Report

### Changes Analyzed
- Files changed: [count]
- Directories affected: [list]

### Actions Taken
- Skills updated: [count] — [names with brief details]
- Skills created: [count] — [names with brief details]
- Files exempted: [count] — [reasons]

### Verification
- All file references valid: YES/NO
- Detection commands working: YES/NO
```

## Exceptions

1. Lock files, generated files, build outputs — skip silently
2. One-time config changes (version bumps, linter tweaks) — exempt
3. Documentation-only changes — exempt
4. Test fixtures and test data — exempt
5. Vendor/third-party code — exempt
6. This skill itself and `/verify` — never self-target
