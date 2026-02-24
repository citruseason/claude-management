# Code Review Checklist

## Correctness
- [ ] Logic is correct and handles all cases
- [ ] Edge cases are covered (null, empty, boundary values)
- [ ] Error handling is appropriate
- [ ] No off-by-one errors
- [ ] Race conditions considered (if applicable)

## Code Quality
- [ ] Single responsibility principle followed
- [ ] No code duplication (DRY)
- [ ] Clear, descriptive naming
- [ ] Appropriate abstraction level
- [ ] No dead code or commented-out code

## Conventions
- [ ] Consistent with existing codebase style
- [ ] Proper use of language idioms
- [ ] Import organization follows project patterns
- [ ] File naming matches project conventions

## Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation at system boundaries
- [ ] No injection vulnerabilities (SQL, XSS, command)
- [ ] Sensitive data not logged or exposed

## Performance
- [ ] No obvious O(n^2) or worse operations on large datasets
- [ ] No N+1 query patterns
- [ ] No unnecessary allocations in hot paths
- [ ] Resource cleanup (connections, file handles)

## Maintainability
- [ ] Code is readable without excessive comments
- [ ] Changes are testable
- [ ] No hidden dependencies or global state
- [ ] Complex logic has explanatory comments
