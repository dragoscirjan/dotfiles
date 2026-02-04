---
description: Multi-lens code review
agent: general
---

Run a comprehensive code review on the current diff.

## Steps

1. Get the diff: `git diff main...HEAD`

2. Invoke ALL reviewers in parallel:
   - **@review-code** - Always runs (generic quality, security, design)
   - **@review-frontend** - For `.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`, and files in `components/`, `pages/`, `ui/`
   - **@review-backend** - For `.go`, `.py`, `.rs`, `.java`, `.rb`, and `.ts`/`.js` in `api/`, `server/`, `services/`
   - **@review-infra** - For `.github/`, `.gitlab-ci*`, `Dockerfile*`, `docker-compose*`, `*.tf`, `ansible/`, `k8s/`, `helm/`

3. Synthesize findings into one report grouped by category, then severity:

```
## Security
### Critical
- file:line - Issue description

## Performance
### High
- ...

## Code Quality
...
```

4. End with:
   - Issue counts by severity
   - Top 3 priorities to fix
   - Patterns observed across codebase
