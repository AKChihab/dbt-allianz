## Team Practices

### Coding
- Use clear BK names (`*_bk`) and hub keys (`hk_*`).
- Prefer CTEs and small, testable models.
- Avoid complex UDFs; keep SQL portable.

### Reviews
- Require tests for new models.
- Check docs and descriptions.

### Environments
- Local dev with role `DEV_ROLE`.
- Future: add separate schemas (e.g., `DV_DEV`, `DV_PROD`) via targets.

### Onboarding Path
- Junior: seeds, staging, YAML tests.
- Mid: hubs/links/sats, custom tests, docs.
- Senior: orchestration, CI/CD, performance tuning, governance.

