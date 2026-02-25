# Workflow Guide

This guide shows how to use claude-management skills together through real scenarios.

## Core Loop

Every task follows the same cycle:

```
/plan  →  /work  →  /verify  →  /review  →  /ship
```

You can run the full pipeline automatically with `/run`, or enter at any point manually. The skills chain together — each step produces artifacts the next step consumes.

### Automated: `/run`

```
/run Add JWT authentication to the Express API
```

This single command orchestrates the entire pipeline. It:
1. Reviews `.work/lessons.md` for active rules
2. Auto-detects mode (feature/bugfix/refactor/hotfix)
3. Creates the plan
4. **Autonomously decides** whether to use agent teams or subagents for each phase
5. Pauses for user approval after PLAN and before SHIP
6. Auto-fixes issues found during verify/review (max 2 cycles)
7. Captures lessons learned at the end

The orchestrator analyzes the plan to decide execution strategy — no flag needed:
- Steps modify different files across multiple modules? → **agent team** (parallel)
- Steps are sequential or touch the same files? → **subagent** (sequential)

```
Pipeline: feature
Phases: PLAN → WORK → VERIFY → REVIEW → SHIP
Task: Add JWT authentication to the Express API

## Phase 1: PLAN
  Delegating to workflow-planner...
  Plan created: .work/plans/01-add-jwt-auth/ (5 steps)
  Proceed with implementation? [y]

## Phase 2: WORK
  Delegating to workflow-implementer...
  [Step 1/5] ✓ Install dependencies
  [Step 2/5] ✓ Create auth middleware
  [Step 3/5] ✓ Add login endpoint
  [Step 4/5] ✓ Protect API routes
  [Step 5/5] ✓ Add tests
  All steps complete.

## Phase 3: VERIFY
  Delegating to workflow-verifier...
  Tests: 28 passed | Lint: clean | Build: ok
  Status: PASS

## Phase 4: REVIEW
  Delegating to review-code...
  Issues: 0 critical, 1 suggestion
  Status: PASS

## Phase 5: SHIP
  Files: 5 changed
  Commit: Add JWT authentication for API routes
  Confirm? [y]
  ✓ Committed: abc1234

Pipeline complete.
```

**Modes**:

| Mode | Pipeline | Auto-detect keywords |
|------|----------|---------------------|
| feature | PLAN → WORK → VERIFY [→ MANAGE-SKILLS] → REVIEW → SHIP | (default) |
| bugfix | EXPLORE → WORK → VERIFY [→ MANAGE-SKILLS] → SHIP | bug, fix, error, crash |
| refactor | PLAN → WORK → VERIFY [→ MANAGE-SKILLS] → REVIEW → SHIP | refactor, restructure |
| hotfix | WORK → VERIFY → SHIP | urgent, hotfix, emergency |

```
/run Fix the 500 error on /api/users/:id           # auto-detected: bugfix
/run Refactor DB layer to connection pooling        # auto-detected: refactor
/run Patch XSS vulnerability --mode hotfix          # explicit mode
```

### Manual: Individual skills

---

## Scenario 1: Feature Implementation

> Add JWT authentication to an Express API

### Step 1: Plan

```
/plan Add JWT authentication to the Express API
```

The planner agent explores your codebase, finds the existing auth patterns, route structure, and middleware setup. It produces:

```
.work/plans/01-add-jwt-auth/
├── plan.md        # Goal, context, approach, detailed steps
└── todo.md        # Checkable progress tracker
```

**plan.md** (excerpt):
```markdown
# Implementation Plan: Add JWT Authentication

## Goal
Add JWT-based authentication to all /api/* routes.

## Context
- Express app in src/app.ts, routes in src/routes/
- Currently no auth middleware
- User model exists in src/models/user.ts

## Step 1: Install dependencies
- Files: package.json
- Details: Add jsonwebtoken, bcryptjs, and their @types
- Verify: npm install succeeds

## Step 2: Create auth middleware
- Files: src/middleware/auth.ts (new)
- Details: JWT verification middleware, extract user from token
- Verify: Unit test passes
...
```

**todo.md**:
```markdown
# TODO: Add JWT Authentication

- [ ] [Step 1: Install dependencies](./plan.md#step-1-install-dependencies)
- [ ] [Step 2: Create auth middleware](./plan.md#step-2-create-auth-middleware)
- [ ] [Step 3: Add login endpoint](./plan.md#step-3-add-login-endpoint)
- [ ] [Step 4: Protect API routes](./plan.md#step-4-protect-api-routes)
- [ ] [Step 5: Add tests](./plan.md#step-5-add-tests)

## Review
```

**Ambiguous tasks**: If the task is vague (e.g., "improve the authentication system"), the planner asks clarifying questions before creating the plan:

```
/plan Improve the authentication system

> Before I create a plan, I have a few questions:
> 1. What specific aspect needs improvement — security, performance, or UX?
> 2. Are there any compatibility constraints?
> 3. What triggered this request?

[User answers...]

Plan created: .work/plans/02-improve-auth/ (4 steps)
```

### Step 2: Work

```
/work
```

The implementer reads the latest plan in `.work/plans/`, follows each step, and checks items off in `todo.md`:

```
Working on: 01-add-jwt-auth

[Step 1] Installing dependencies...
  ✓ Added jsonwebtoken, bcryptjs to package.json
  ✓ npm install succeeded

[Step 2] Creating auth middleware...
  ✓ Created src/middleware/auth.ts
  ✓ Unit test passes

[Step 3] Adding login endpoint...
  ...
```

### Step 3: Verify

```
/verify
```

Runs all project tests + any registered verify-* skills:

```
## Verification Report

### Status: PASS

### General Checks
| Check   | Status | Details           |
|---------|--------|-------------------|
| Tests   | PASS   | 28 tests passed   |
| Lint    | PASS   | No issues         |
| Build   | PASS   | —                 |
| Types   | PASS   | No errors         |
```

### Step 4: Review

```
/review src/middleware/auth.ts src/routes/auth.ts
```

The code review agent inspects the changed files:

```
[SUGGESTION] src/middleware/auth.ts:15
  Token expiration is set to 30 days — consider a shorter default (e.g. 1 day) with refresh tokens.

[WARNING] src/routes/auth.ts:42
  Password comparison uses == instead of bcrypt.compare(). This is a security issue.

Overall Assessment: Needs Changes
Critical Issues: 1
```

Fix the issue, then re-verify:

```
/verify
```

### Step 5: Ship

```
/ship
```

Stages changes, writes a commit message from the diff, and creates the commit:

```
Staged 5 files:
  src/middleware/auth.ts (new)
  src/routes/auth.ts (new)
  src/models/user.ts (modified)
  package.json (modified)
  tests/auth.test.ts (new)

Commit: Add JWT authentication for API routes
```

---

## Scenario 2: Bug Fix

> Users report 500 error on /api/users/:id when ID doesn't exist

### Step 1: Explore

```
/explore /api/users/:id endpoint
```

```
Architecture Overview:
- Route defined in src/routes/users.ts:23
- Handler calls UserService.findById() at src/services/user.ts:45
- findById() returns User | undefined but handler doesn't check for undefined

Key Finding:
- src/routes/users.ts:25 — calls user.toJSON() without null check
- This throws TypeError when user is undefined → Express catches as 500
```

### Step 2: Trace (optional, for complex bugs)

```
/trace GET /api/users/:id
```

```
Entry: src/routes/users.ts:23 router.get('/:id')
  → src/routes/users.ts:25 UserService.findById(req.params.id)
    → src/services/user.ts:45 db.query('SELECT * FROM users WHERE id = $1')
    ← returns: User | undefined
  → src/routes/users.ts:26 user.toJSON()  ← THROWS if user is undefined
  ← 500 Internal Server Error
```

### Step 3: Fix directly

```
/work Fix null check in GET /api/users/:id — return 404 when user not found
```

```
[Fix] src/routes/users.ts:25
  Added: if (!user) return res.status(404).json({ error: 'User not found' })
  ✓ Existing tests pass
  ✓ Added test for 404 case
```

### Step 4: Verify and ship

```
/verify
/ship
```

---

## Scenario 3: Self-Maintaining Verification

This is the most powerful pattern. It creates project-specific verification skills that evolve with your codebase.

### Bootstrap: First time setup

After implementing some features, run:

```
/manage-skills
```

The skill analyzes your git changes:

```
## Session Change Analysis

Files changed: 12
Directories affected: src/routes/, src/middleware/, src/models/

## Coverage Gap Analysis

| File                      | Status    | Action |
|---------------------------|-----------|--------|
| src/routes/users.ts       | UNCOVERED | CREATE |
| src/routes/auth.ts        | UNCOVERED | CREATE |
| src/middleware/auth.ts     | UNCOVERED | CREATE |
| src/models/user.ts        | UNCOVERED | CREATE |
| package.json              | EXEMPT    | —      |

## Proposed Actions

1. CREATE verify-api — 4 route files share REST conventions
   (response format, error handling, status codes)

2. CREATE verify-auth — 2 auth files share security patterns
   (token validation, password hashing, middleware chain)

Proceed? [Yes/No/Modify]
```

After approval, it creates:

```
.claude/skills/
├── verify-api/SKILL.md      # Checks REST conventions across all routes
└── verify-auth/SKILL.md     # Checks auth security patterns
```

### Daily use: Verify runs everything

Now when you run `/verify`, it automatically discovers and executes these skills:

```
/verify
```

```
## Verification Report

### Status: FAIL

### Verify Skills
| # | Skill       | Checks | Passed | Issues |
|---|-------------|--------|--------|--------|
| 1 | verify-api  | 8      | 7      | 1      |
| 2 | verify-auth | 5      | 5      | 0      |

### Issues Found
| # | Skill      | File               | Line | Problem                        | Fix                    |
|---|------------|--------------------|------|--------------------------------|------------------------|
| 1 | verify-api | src/routes/posts.ts | 31   | Missing error response format  | Use ApiError.notFound() |

Fix all / Fix individually / Skip?
```

### Integration: /verify triggers /manage-skills

When `/verify` finds external skills without wrappers, it offers to create them:

```
/verify

## Verification Report
### Status: PASS

### Gap Analysis
#### External Skills Without Wrappers
| # | Skill | Type | Recommended Action |
|---|-------|------|-------------------|
| 1 | vercel-react-best-practices | guidelines | WRAP -> verify-react |

1 external skill(s) lack verify-* wrappers.
Create wrappers now? [Yes / Skip]
```

Selecting "Create wrappers now" invokes `/manage-skills --from-verify`, which skips
redundant discovery and directly proposes the WRAP actions identified by `/verify`.

In the `/run` pipeline, this handoff happens automatically in Phase 3.5.

### Evolution: Skills grow with your code

As you add new features, `/manage-skills` detects the gaps:

```
/manage-skills
```

```
## Coverage Gap Analysis

New files not covered by existing skills:
- src/routes/payments.ts → UPDATE verify-api (new route file)
- src/services/stripe.ts → CREATE verify-payments (external API integration)

Proposed:
1. UPDATE verify-api — add src/routes/payments.ts to Related Files
2. CREATE verify-payments — Stripe integration checks (webhook signature, idempotency keys)
```

The verification system evolves alongside your codebase without manual maintenance.

---

## Scenario 4: Agent Team — Parallel Code Review

> PR #142 has changes across auth, payments, and API layers. Review it thoroughly.

### Spawn a review team

```
/team Review PR #142
```

Three parallel reviewers are spawned, each with a specialized lens:

```
Agent team created: pr-142-review
Teammates:
  1. code-quality — checking conventions, clarity, maintainability
  2. security — checking auth flows, input validation, secrets
  3. performance — checking queries, algorithms, resource usage

[All teammates working in parallel...]

code-quality: Found 3 issues (0 critical, 2 warning, 1 suggestion)
security: Found 1 issue (1 critical — SQL injection in search endpoint)
performance: Found 1 issue (0 critical, 1 warning — N+1 query)
```

The leader synthesizes all findings:

```
## Consolidated Review Report

### Critical (must fix before merge)
1. [security] src/routes/search.ts:31 — SQL injection via search parameter
   Fix: Use parameterized query

### Warnings
1. [code-quality] src/services/payment.ts:88 — Magic number, extract to constant
2. [code-quality] src/routes/users.ts:12 — Inconsistent error response format
3. [performance] src/routes/orders.ts:45 — N+1 query loading order items

### Suggestions
1. [code-quality] src/middleware/auth.ts:5 — Consider extracting token refresh to separate middleware
```

### Fix and ship

```
/work Fix the SQL injection and N+1 query from the review
/verify
/ship
```

---

## Scenario 5: Agent Team — Parallel Implementation

> Build a user dashboard with frontend, backend API, and tests.

### Run the pipeline

```
/run Implement user dashboard with profile, settings, activity feed
```

The orchestrator creates a plan, analyzes step independence, and **autonomously decides** to use an agent team because steps modify different modules:

```
Pipeline: feature
Phases: PLAN → WORK → VERIFY → REVIEW → SHIP

## Phase 1: PLAN
  Plan created: .work/plans/03-user-dashboard/ (6 steps)
  Proceed? [y]

  Execution strategy:
    WORK: agent team (3 teammates — steps touch 3 independent modules)
    REVIEW: review team (3 reviewers — changes span auth + API + tests)

## Phase 2: WORK (agent team)
  Analyzing step file ownership...
  Spawning implementation team:
    - frontend-dev: Steps 1,3 — owns src/components/dashboard/
    - backend-dev: Steps 2,4 — owns src/routes/dashboard.ts, src/services/
    - test-dev: Steps 5,6 — owns tests/dashboard/

  [All teammates working in parallel...]

  frontend-dev: ✓ Steps 1,3 complete (3 components created)
  backend-dev: ✓ Steps 2,4 complete (2 endpoints + service)
  test-dev: ✓ Steps 5,6 complete (12 tests)

## Phase 3: VERIFY
  Tests: 54 passed | Lint: clean | Build: ok
  Status: PASS

## Phase 4: REVIEW (agent team)
  3 parallel reviewers — all PASS (2 suggestions noted)

## Phase 5: SHIP
  Commit: Implement user dashboard with profile, settings, activity feed
  Confirm? [y]
  ✓ Committed: def5678

Pipeline complete.
```

---

## Scenario 6: Agent Team — Debugging

> Users report intermittent 502 errors on the payment endpoint.

```
/team Debug the intermittent 502 errors on POST /api/payments
```

Five investigators spawn with competing hypotheses:

```
Agent team created: debug-502
Teammates:
  1. network-theory — investigating load balancer / timeout issues
  2. database-theory — investigating connection pool exhaustion
  3. stripe-theory — investigating Stripe API failures
  4. memory-theory — investigating memory leaks causing OOM
  5. concurrency-theory — investigating race conditions

[Teammates investigating and debating...]

network-theory → stripe-theory: "I checked nginx logs — no 502s from the
  load balancer. The 502 originates from the app. Your Stripe timeout theory
  is more likely."

stripe-theory → all: "Found it. Stripe webhook handler at
  src/routes/payments.ts:89 has no timeout. When Stripe is slow (>30s),
  the request exceeds the gateway timeout."

database-theory → stripe-theory: "Confirmed. Connection pool metrics are
  normal. The Stripe call is the bottleneck."

## Consensus

Root cause: Missing timeout on Stripe API call in webhook handler.
File: src/routes/payments.ts:89
Fix: Add 10s timeout to Stripe client, return 202 for webhook processing.
Confidence: HIGH (4/5 investigators agree, evidence from logs confirms)
```

Then fix it:

```
/work Add 10s timeout to Stripe client and return 202 for webhook processing
/verify
/ship
```

---

## Scenario 7: Session Wrap-up

At the end of a work session, capture what you learned.

### Record specific lessons

```
/lesson Always check for null returns from database queries before accessing properties
```

The skill searches `.work/lessons.md` for existing similar lessons first. If none found, it creates a new entry:

```
Added to .work/lessons.md:

### [Bug Pattern] Null check on DB query results
**Context**: GET /api/users/:id returned 500 because findById() result wasn't null-checked
**Rule**: Always null-check single-record DB query results before accessing properties
**Prevention**: After any findById/findOne/first query, add an if-not-found guard before using the result
**Example**:
  // WRONG
  const user = await User.findById(id)
  user.toJSON()  // throws if user is undefined

  // RIGHT
  const user = await User.findById(id)
  if (!user) return res.status(404).json({ error: 'Not found' })
  user.toJSON()
**Automation**: candidate for verify-* skill (check all route handlers for null guards after DB queries)
```

If you hit the same lesson again later, `/lesson` **refines** the existing entry instead of duplicating — sharpens the rule, adds the new example, and increments the occurrence counter. At 3+ occurrences, it escalates to the `## Active Rules` section at the top of lessons.md for session-start review.

### Run retrospective

```
/retrospective
```

```
# Retrospective - 2026-02-24

## Accomplished
- Added JWT authentication (plan 01-add-jwt-auth)
- Fixed null check bug in user endpoint
- Set up verify-api and verify-auth skills

## What Went Well
- Plan-first approach caught the middleware ordering issue early
- verify-api skill caught missing error format in new route

## What Didn't Go Well
- Missed null check in initial implementation — caught by bug report, not by tests

## Action Items
- [ ] Add null-return test cases to the test template
- [ ] Update verify-api to check for null handling in all route handlers

## Lessons Captured
- [Bug Pattern] Null check on DB query results
```

---

## Scenario 9: Code Review and Security Audit (pre-PR)

Before merging a PR or reviewing someone else's code.

### Full review

```
/review src/
```

Reviews all files in the directory for quality, correctness, and conventions.

### Targeted security audit

```
/security-audit src/routes/auth.ts src/middleware/auth.ts
```

```
[HIGH] Injection | src/routes/auth.ts:18
  Email parameter used directly in SQL query without parameterization.
  Attack: SQL injection via login email field
  Fix: Use parameterized query — db.query('SELECT * FROM users WHERE email = $1', [email])

[MEDIUM] Data Protection | src/middleware/auth.ts:32
  JWT secret loaded from process.env without fallback validation.
  Attack: If JWT_SECRET is undefined, tokens are signed with "undefined" string.
  Fix: Add startup validation — if (!process.env.JWT_SECRET) throw new Error('JWT_SECRET required')

Risk Summary: HIGH — 1 critical injection vulnerability found
```

### Generate documentation

```
/document src/routes/
```

Produces API documentation from the actual route code, including request/response examples.

---

## Scenario 8: External Skill Integration

> You've installed external skills from skills.sh and want them to work with the pipeline.

### Streamlined: /verify discovers and /manage-skills wraps

After installing external skills, simply run the pipeline:

```
/run Add new dashboard component
```

During Phase 3 (VERIFY), the verifier discovers the external skills and reports them
in the Gap Analysis. Phase 3.5 automatically invokes `/manage-skills --from-verify`
to create wrappers. After approval, VERIFY re-runs with the new wrappers active.

You can also do this manually:

```
/verify                    # Discovers gaps, offers to create wrappers
/manage-skills             # Or run independently for full analysis
```

---

## Quick Reference

### Which skill do I use?

| I want to...                        | Skill             |
|-------------------------------------|-------------------|
| Set up a new project                | `/init`           |
| Run the full pipeline automatically | `/run` (auto-decides team vs subagent) |
| Spawn a parallel team for a task    | `/team`           |
| Understand how code works           | `/explore`        |
| Follow a specific execution path    | `/trace`          |
| Plan a new feature or change        | `/plan`           |
| Implement the plan                  | `/work`           |
| Check if implementation is correct  | `/verify`         |
| Review code quality                 | `/review`         |
| Check for security vulnerabilities  | `/security-audit` |
| Commit and create PR                | `/ship`           |
| Generate documentation              | `/document`       |
| Update changelog                    | `/changelog`      |
| Set up project verification skills  | `/manage-skills`  |
| Record a lesson learned             | `/lesson`         |
| Reflect on the session              | `/retrospective`  |
| Integrate external skills           | `/init` then `/manage-skills` |

### Recommended workflows by task type

| Task Type          | Automated                    | Team (explicit)                      | Manual                                                   |
|--------------------|------------------------------|--------------------------------------|----------------------------------------------------------|
| New feature        | `/run Add feature X`         | (auto if multi-module)               | `/plan` → `/work` → `/verify` → `/review` → `/ship`    |
| Bug fix            | `/run Fix bug Y`             | `/team Debug issue Y`                | `/explore` → `/trace` → `/work` → `/verify` → `/ship`  |
| Refactor           | `/run Refactor Z`            | (auto if multi-module)               | `/plan` → `/work` → `/verify` → `/review` → `/ship`    |
| Hotfix             | `/run Patch Q --mode hotfix` | —                                    | `/work` → `/verify` → `/ship`                           |
| Code audit         | —                            | `/team Review PR #42`                | `/review` → `/security-audit`                            |
| First-time setup   | —                            | —                                    | `/init` → `/manage-skills` → `/verify`                   |
| Pre-PR check       | —                            | `/team Review current changes`       | `/verify` → `/review` → `/ship`                         |
| Session end        | —                            | —                                    | `/retrospective` → `/lesson`                             |
| Documentation      | —                            | —                                    | `/document` → `/changelog`                               |
