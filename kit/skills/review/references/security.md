# Security lens (any repo)

1. **Isolation.** The caller's scope predicate is present and first (backend lens 1–2); related ids from the body
   validated; joins carry the scope equality in `ON`; bulk endpoints report scoped-out ids as not found.
2. **Authorization.** Permission declared per route; owner-only actions checked in the service; delegation never
   grants more than the grantor has; self-edit and last-owner protections; recent re-authentication on sensitive
   mutations where the repo has it.
3. **Credentials and PII.** No token, password, OTP or invite code in logs; PII masked in logs; redaction before any
   LLM call that sees user data; audit rows carry ids, not personal data; nothing from real config files printed.
4. **Abuse limits.** Cost-bearing or credential-touching endpoints rate-limited; sign-in/invite paths have their own
   limits; fail closed on an unknown role, permission or scope mode.
5. **Cache and revocation.** Cached authorization state is versioned or invalidated in the same transaction as the
   change; a TTL is a bound, not the mechanism.
6. **Frontend.** URLs sanitised, no raw HTML, secrets never in public env vars, session handling unchanged.
7. **Dependencies.** A new package → its audit status (OSV, `pip-audit`, `npm audit`) stated; an accepted
   vulnerability justified in the repo's security doc.

A real but pre-existing issue is listed once under residual risk with a pointer to where it is recorded (or "not
recorded — should be").
