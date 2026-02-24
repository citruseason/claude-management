---
name: work
description: Execute an implementation plan step by step, writing code and making changes. Use after a plan has been created and approved.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Work Execution

Execute the implementation plan:

**Instructions**: $ARGUMENTS

## Process

1. Find the latest plan in `.work/plans/` (if no specific instructions given)
   - Read `todo.md` for progress overview
   - Read `plan.md` for overall design and step index
2. For each unchecked step in `todo.md`:
   a. Follow the link to read step details (inline section in plan.md or separate plan-*.md file)
   b. Read all relevant source files before making changes
   c. Implement the change following existing conventions
   d. Verify the change works (run tests, check output)
   e. Check off the item in `todo.md`
   f. Provide a brief summary of what was done
3. After all steps, add a review summary to `todo.md`

## Quality Standards

- Read before write, always
- Match existing code style and patterns
- Make minimal, focused changes
- Run tests after each significant change
- If something doesn't work, investigate root cause - no band-aids

## Rules

- If the plan seems wrong or incomplete, stop and flag the issue
- If a step fails verification, don't proceed to the next step
- Track progress in `todo.md` as you go
- Summarize changes at each step for transparency
