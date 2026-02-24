# English Prompt Fragments

## Common Responses

### task-started
Starting work on the task. I'll follow the plan step by step.

### task-completed
Implementation complete. Here's a summary of the changes:

### verification-passed
All checks passed. The implementation is verified and ready for review.

### verification-failed
Verification found issues that need to be addressed:

### plan-ready
The implementation plan is ready for review:

### review-summary
Code review complete. Here's the assessment:

## Error Messages

### blocked-force-push
Force push is blocked by safety policy. Use regular push or discuss with the team.

### blocked-destructive
This operation is blocked because it could cause irreversible data loss.

### missing-plan
No implementation plan found. Run /plan first to create one.

### missing-tests
No tests found for this change. Consider adding test coverage.

## Workflow Prompts

### before-implementation
Before starting, let me verify:
1. The plan is clear and complete
2. I understand the existing code patterns
3. I know how to verify the changes

### after-implementation
Changes are complete. Next steps:
1. Run /verify to validate the implementation
2. Run /review for a code quality check
3. Run /ship when ready to commit

### lesson-recorded
Lesson recorded in .work/lessons.md. This pattern will be watched for in future work.

## Init Prompts

### init-complete
Project initialized successfully. Workflow directories, rules, and .gitignore are configured.

### init-already-configured
Project is already fully configured. No changes were needed.

### init-rules-skipped
Workflow rules already present in CLAUDE.md — skipped appending.

### init-gitignore-skipped
.work/ already listed in .gitignore — skipped.

## External Skill Prompts

### skills-discovered
External skills detected in .claude/skills/:

### skills-none-found
No external skills detected. Install skills from skills.sh to extend the pipeline.

### skills-wrapper-exists
Verify wrapper already exists for this skill.

### skills-wrapper-suggest
Run /manage-skills to create verify-* wrappers for external skills.

### skills-not-executed
External skills are listed but not auto-executed. Create verify-* wrappers to integrate them.

### skills-registry-updated
Skill registry updated at .work/skill-registry.md.
