---
name: retrospective
description: Run a retrospective on recent work. Analyzes what went well, what didn't, and captures improvements for future sessions.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Retrospective

Run a retrospective on:

**Scope**: $ARGUMENTS

## Process

1. Review what was accomplished:
   - Read latest `.work/plans/*/todo.md` for completed work
   - Check git log for recent commits
   - Review any issues or bugs encountered

2. Analyze three dimensions:
   - **What went well**: Practices, tools, or approaches that worked
   - **What didn't go well**: Pain points, blockers, or mistakes
   - **What to improve**: Specific, actionable improvements

3. Extract patterns:
   - Recurring issues that need systemic fixes
   - Successful patterns to reinforce
   - Process gaps to address

4. Update artifacts:
   - Add new lessons to `.work/lessons.md`
   - Update workflow rules if patterns emerge
   - Create action items for improvements

## Output Format

```markdown
# Retrospective - [Date/Scope]

## Accomplished
- [list of completed items]

## What Went Well
- [positive patterns]

## What Didn't Go Well
- [pain points and issues]

## Action Items
- [ ] [specific improvement to make]

## Lessons Captured
- [new lessons added to lessons.md]
```

## Rules

- Be honest about what didn't work
- Focus on systemic improvements, not blame
- Every "what didn't go well" should have a corresponding action item
- Keep action items specific and achievable
