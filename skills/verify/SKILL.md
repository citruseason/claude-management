---
name: verify
description: Verify implementation correctness by running tests and executing all registered verify-* skills. Use after implementation, before PR, or during code review.
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: workflow-verifier
disable-model-invocation: true
argument-hint: "[optional: specific verify skill name or file path]"
---

# Verification

Verify the following implementation:

**Target**: $ARGUMENTS

## Step 1: Discover Skills

### 1a. Discover Verify Skills
Scan for all `verify-*/SKILL.md` files under `.claude/skills/` in the project.

- If a specific skill name is given as argument, run only that skill
- If a file path is given, run only skills whose Related Files cover that path
- If no argument, run all discovered verify-* skills

If no verify-* skills are registered, skip to Step 3 (general verification).

### 1b. Discover External Skills
Scan for all other `*/SKILL.md` files under `.claude/skills/` that are NOT:
- `verify-*` prefixed (already covered in 1a)
- Symlinks into `${CLAUDE_PLUGIN_ROOT}/skills/` (plugin skills)

For each external skill, read its SKILL.md frontmatter to extract name and description.

### 1c. Display Discovery Results

Display the list of skills found:

```
Found [N] verification skills:
1. verify-api — Validates API endpoint conventions
2. verify-auth — Checks authentication patterns

Found [M] external skills (not auto-executed):
1. vercel-react-best-practices — React patterns from Vercel
2. web-design-guidelines — Design system guidelines

Note: External skills are not auto-executed. Run /manage-skills to create
verify-* wrappers that integrate them into the verification pipeline.
```

If no external skills are found, omit the external skills section entirely.

## Step 2: Execute Verify Skills

For each registered verify-* skill, sequentially:

**2a.** Read the skill's SKILL.md. Parse its Workflow, Exceptions, and Related Files sections.

**2b.** Execute each check defined in the skill's Workflow:
- Use the specified tools (Grep, Glob, Read, Bash)
- Compare results against PASS/FAIL criteria
- Apply exception filters (skip known non-violations)
- Log each failure with: file path, line number, problem description, fix recommendation

**2c.** Record per-skill results:
- Checks run / passed / failed
- Issues found (with details)
- Exceptions applied

## Step 3: General Verification

Run these standard checks regardless of verify-* skills:

- **Tests**: Run project test suite (`npm test`, `pytest`, `rspec`, etc.)
- **Lint**: Run linter if configured
- **Build**: Verify build succeeds
- **Types**: Run type checker if applicable

## Step 4: Integrated Report

Consolidate all results into a single report:

```markdown
## Verification Report

### Status: PASS / FAIL

### Verify Skills
| # | Skill | Checks | Passed | Issues |
|---|-------|--------|--------|--------|
| 1 | verify-api | 5 | 5 | 0 |
| 2 | verify-auth | 3 | 2 | 1 |

### General Checks
| Check | Status | Details |
|-------|--------|---------|
| Tests | PASS | 42 tests passed |
| Lint | PASS | No issues |
| Build | PASS | — |

### Issues Found
| # | Skill | File | Line | Problem | Fix |
|---|-------|------|------|---------|-----|
| 1 | verify-auth | src/auth.ts | 42 | Missing token validation | Add validateToken() call |

### External Skills (Not Executed)
| # | Skill | Description | Has Wrapper |
|---|-------|-------------|-------------|
| 1 | vercel-react-best-practices | React patterns | No — run /manage-skills |
| 2 | frontend-design | Frontend arch | Yes (verify-frontend) |

To integrate external skills into verification, run /manage-skills to create verify-* wrappers.
```

## Step 5: Fix Proposal (if issues found)

If issues were found, present options via `AskUserQuestion`:
1. **Fix all** — apply all recommended fixes automatically
2. **Fix individually** — review and approve each fix one by one
3. **Skip** — exit without changes

## Step 6: Apply Fixes and Re-verify

For approved fixes:
1. Apply each fix sequentially
2. Re-run only the skills that had issues
3. Show before/after comparison
4. List any remaining issues as requiring manual resolution

## Verification Areas (General)

- **Functional**: Does it work as specified?
- **Tests**: Do all tests pass? Are there missing tests?
- **Integration**: Do components work together correctly?
- **Quality**: Does the code meet quality standards?
- **Security**: Are there new security concerns?
