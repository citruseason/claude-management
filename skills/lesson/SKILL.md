---
name: lesson
description: Record a lesson from a correction or insight, write a preventive rule, and refine existing lessons. Implements the Self-Improvement Loop from CLAUDE.md.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Self-Improvement Loop

**Input**: $ARGUMENTS

## Step 1: Review Existing Lessons

Read `.work/lessons.md`. If the file doesn't exist, create it with:
```markdown
# Lessons Learned

> Rules written for myself to prevent recurring mistakes.
> Reviewed at session start. Ruthlessly iterated until mistake rate drops.
```

Check if a similar lesson already exists:
- Search for related keywords in existing entries
- If a match is found, go to Step 4 (refine) instead of Step 2 (create)

## Step 2: Categorize and Record

Determine the category:
- **Bug Pattern**: A type of bug to watch for
- **Convention**: A coding convention to follow
- **Process**: A workflow improvement
- **Architecture**: A design decision or constraint

Append to `.work/lessons.md`:

```markdown
### [Category] Short title

**Context**: What happened and why this lesson was triggered
**Rule**: The specific, actionable rule to follow going forward
**Prevention**: How to catch this before it becomes a problem
**Example**:
```
// WRONG
user.toJSON()  // user might be undefined

// RIGHT
if (!user) return res.status(404).json({ error: 'Not found' })
user.toJSON()
```
```

## Step 3: Write Preventive Rule

This is the key step. Don't just record what happened — write a rule that **prevents** the same mistake.

The rule must be:
- **Specific**: not "be careful with null" but "always null-check single-record DB query results before accessing properties"
- **Actionable**: something that can be checked mechanically
- **Scoped**: tied to a clear trigger condition ("when doing X, always do Y")

If the lesson suggests a pattern that could be automated, note it:
- Could this become a verify-* skill check? → Add `**Automation**: candidate for verify-* skill`
- Could this become a hook? → Add `**Automation**: candidate for PreToolUse/PostToolUse hook`

## Step 4: Refine Existing Lessons

If a similar lesson already exists:
1. Read the existing entry
2. Determine what's new: broader scope? more specific rule? better example?
3. **Update** the existing lesson rather than adding a duplicate:
   - Sharpen the rule if it was too vague
   - Add the new example alongside the existing one
   - Broaden the scope if the pattern applies more widely
   - Increment a `**Occurrences**` counter if present, or add one: `**Occurrences**: 2`

Multiple occurrences of the same lesson signal it needs stronger prevention (hook, verify-* skill, or CLAUDE.md rule).

## Step 5: Surface to Session Start

If the lesson is high-impact (security, data loss, or 3+ occurrences), add a one-line summary to the top of `.work/lessons.md` under a `## Active Rules` section:

```markdown
## Active Rules

- Always null-check single-record DB queries before property access
- Never commit .env files — use .env.example
- Run /verify before /ship
```

These are reviewed at session start to keep critical rules top of mind.

## Rules

- Never add a duplicate — always search and refine first
- Every lesson must have a concrete Rule and Example
- Vague lessons are useless — if you can't write a specific rule, dig deeper
- Focus on patterns, not one-off incidents
- High-occurrence lessons should escalate to automation (verify-* skill or hook)
