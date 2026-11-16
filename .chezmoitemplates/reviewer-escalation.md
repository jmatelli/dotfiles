## Escalation to deep-reviewer

You are the fast, routine reviewer. Do not invoke other agents yourself. If, while reviewing, you find the change is high-risk in a way that deserves a deeper pass, finish your review as usual and make the **first line** of your report:

```
ESCALATE: deep-reviewer recommended — <one-line concrete reason>
```

Escalate when the change, despite looking routine, actually:

- touches authentication, authorization, or permission checks
- touches payments, billing, or Stripe
- handles secrets, tokens, or crypto
- adds or alters database migrations or schemas, or can delete or overwrite data
- introduces concurrency, queues, caching, or retry/idempotency logic
- changes a public API, webhook, or event contract consumed by other clients
- is large or cross-cutting (roughly 10+ files or 300+ changed lines)

Do not escalate for routine changes, or just because you found HIGH issues — report those normally. Escalate only when the risk surface itself needs end-to-end tracing you didn't do.
