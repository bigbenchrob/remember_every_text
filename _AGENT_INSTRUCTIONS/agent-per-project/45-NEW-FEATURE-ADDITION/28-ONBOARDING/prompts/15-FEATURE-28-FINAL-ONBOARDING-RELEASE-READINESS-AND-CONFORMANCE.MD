# Correction To Prompt 15: Six-Node Human Journey

Treat every reference requiring a visible Verify Journey node as stale.

The current canonical human Journey topology is:

```text
Messages -> History -> Contacts -> Ready -> Import -> Start
```

Durable verification remains a mandatory internal Coordinator gate between
Import and Start. Do not restore Verify as a seventh visible node.

This preserves both required truths:

- the human path remains focused on meaningful Episodes;
- verification remains mechanically required;
- Start cannot become constructible until verification passes;
- verification failure keeps Onboarding in a typed failure or remediation
  state;
- no artificial dwell or fake Verify Episode is required.

Apply this correction throughout the final release-readiness audit:

- audit the Journey path as six human nodes;
- audit Verify semantics as an internal gate only;
- audit terminal handoff as Import -> internal verification -> Start -> OK;
- do not claim that Verify was visibly or retrospectively observed in manual
  evidence;
- preserve the distinction between human topology and the internal state
  machine in architecture tripwires.

The audit must prove that Start remains mechanically impossible until durable
verification succeeds and that verification failure never exposes Start.
