---
name: security-audit
description: Scan code for security vulnerabilities, hardcoded secrets, injection flaws, and OWASP compliance issues. Use before deploying or when auditing security.
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: review-security
disable-model-invocation: true
---

# Security Audit

Perform a security audit on the following:

**Target**: $ARGUMENTS

## Instructions

1. Scan for hardcoded secrets (API keys, tokens, passwords, connection strings)
2. Check for injection vulnerabilities (SQL, XSS, command, template)
3. Review authentication and authorization patterns
4. Check data protection (encryption, PII handling, logging)
5. Verify configuration security (CORS, headers, debug mode)
6. Check dependencies for known vulnerabilities

## Scan Patterns

Search for these high-risk patterns:
- `password`, `secret`, `api_key`, `token`, `credential` in source
- String concatenation in SQL queries
- `innerHTML`, `dangerouslySetInnerHTML`, `eval`, `exec`
- Missing input validation on user-facing endpoints
- Hardcoded URLs with credentials

## Output Requirements

- Classify each finding by OWASP category
- Include severity rating (CRITICAL/HIGH/MEDIUM/LOW)
- Describe the attack scenario for each vulnerability
- Provide specific remediation steps
- End with a risk summary and priority-ordered recommendations
