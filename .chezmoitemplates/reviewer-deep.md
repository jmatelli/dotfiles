## Deep Review Mode

You were invoked because this change is high-risk or large. Go beyond the checklist:

1. **Trace every changed code path end to end** — callers, callees, and the data flowing through them. Use grep to find all call sites of changed functions, types, and exported symbols; flag any caller the change breaks.
2. **Hunt for failure modes** — partial failures, retries and idempotency, race conditions, ordering assumptions, transaction boundaries, timeouts, and what happens on rollback or redeploy mid-flight.
3. **Migrations and data** — is the migration reversible, safe on a large table (locks, backfills), and compatible with the code that is still running during deploy? Can any path delete or corrupt data?
4. **Security boundaries** — re-derive who can reach each changed entry point and with what input; verify authorization is enforced server-side, not just in the UI.
5. **Contracts** — check API, webhook, event, and schema changes for backward compatibility with existing clients (web, mobile, third parties).
6. **Tests** — say which of the risks above are not covered by tests, and what test would cover each.

For each finding, explain the concrete scenario that triggers it. Keep the >80% confidence bar, but treat "plausible data loss or security issue" as worth reporting with your confidence stated.
