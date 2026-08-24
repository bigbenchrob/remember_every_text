Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for a controlled production-shaped validation and bounded corrections if the new anomaly accounting reveals a concrete defect.

Do NOT redesign Onboarding UI yet.

Do NOT implement Start Fresh yet.

Do NOT add watchdog thresholds.

Suggested prompt name:

`08-PRODUCTION-SHAPED-ONBOARDING-ANOMALY-VALIDATION.MD`

# Context

Feature 28 now has dependency-aware anomaly handling across:

- handles;
- chats;
- messages;
- rich text;
- attachments;
- contacts;
- reactions;
- relationship edges.

Prompt 07 established:

- structural identity failures remain fatal;
- safe local degradation/omission is explicitly typed and counted;
- counts propagate through import progress, graph observations, and durable Onboarding snapshots;
- no schema or completion-state changes were required.

The next question is empirical:

> What anomaly distribution does a healthy, production-shaped Onboarding run actually produce?

We should not decide which anomaly counts deserve user-facing attention until we know their real prevalence and meaning.

# Safety

Use a disposable staging/onboarding environment.

Do not mutate production archives or tester installations.

Use the established read-only source access and canonical staging mutation path.

Do not modify live `chat.db`.

# Primary goal

Run a full production-shaped first import and capture the final anomaly totals by domain/outcome.

At minimum report exact counts for:

- normalized handles;
- preserved opaque handles;
- chat degradations/omissions;
- message degradations/omissions;
- rich-text fallbacks/content-unavailable cases;
- attachment anomalies;
- contact anomalies;
- reaction anomalies;
- relationship-edge anomalies;
- fatal anomalies.

Use actual enum/type names.

# Reconciliation

Prove anomaly counts reconcile with the total processed populations.

No anomaly may disappear from accounting.

For each domain document:

`processed = normal + degraded + omitted + fatal`

or the exact domain-specific invariant.

If categories overlap by design, state that explicitly and prove the correct invariant.

# Inspect representative anomalies

For every nonzero anomaly category, select a small deterministic sample.

Record only safe technical evidence:

- source domain;
- source ROWID;
- typed anomaly reason;
- downstream consequence.

Do NOT log:

- message text;
- contact names;
- phone numbers;
- emails;
- raw handles unless specifically required and sanitized.

# Handles

Pay special attention to `preserved opaque` handles.

For each representative sample prove:

- source identity preserved;
- chat relationships preserved;
- dependent messages imported;
- no canonical alias merge occurred;
- no contact match was fabricated.

Determine whether any production-shaped data actually exercises the new fallback.

# Messages/rich text

For any degraded message/rich-text case determine:

- whether plain text fallback existed;
- whether content became unavailable;
- whether message identity/relationships remained intact;
- whether Recovered Messages ownership was used.

# Attachments

For nonzero attachment anomalies distinguish:

- metadata present/payload missing;
- malformed metadata;
- broken relationship;
- unsupported/unavailable payload.

Confirm parent messages remain truthful.

# Contacts/reactions

Verify these remain enrichment/child evidence where policy says so and do not affect message existence improperly.

# Systemic-pattern detection

The point of this task is also to detect whether a nominally “safe local anomaly” is occurring at a scale that actually indicates a systemic defect.

For each anomaly category calculate:

- count;
- denominator;
- rate.

Do not introduce user-facing percentage thresholds yet.

Instead classify:

### Rare/local

Consistent with isolated odd source data.

### Recurrent but explainable

May deserve diagnostic visibility.

### Pervasive/systemic

Likely indicates implementation or compatibility defect despite local fallback safety.

Document rationale.

# Completion truth

Confirm the production-shaped run still reaches durable completion only when:

- all fatal anomaly counts are zero;
- all safely degraded/omitted facts are explicitly accounted;
- canonical import/graph readiness invariants pass.

Do not alter completion rules unless a contradiction is found.

# Feature 27 coverage

After successful Onboarding, run/read the Message History Coverage report against the staging result.

Confirm anomaly handling did not create unexplained current-source losses.

Report:

- total current messages;
- conversation-linked;
- recovered/unlinked;
- unaccounted.

Any unexpected `unaccounted` increase requires investigation before proceeding.

# Graph integrity

Check:

- participant counts;
- conversation counts;
- message counts;
- relationship edges;
- recovered/unlinked counts.

Prove opaque/degraded records did not create dangling or invented relationships.

# Performance

Measure whether anomaly accounting materially changes the ~49-second production-shaped healthy run.

Report:

- total duration;
- major stage durations;
- progress cadence;
- anomaly-accounting overhead.

If overhead is material, profile and fix only bounded obvious pathology.

# Diagnostic persistence

Verify durable snapshots retain:

- exact anomaly totals;
- bounded representative technical refs if designed;
- no PII-heavy payload.

Confirm write volume remains bounded.

# Post-import user-facing recommendation

Based on real distribution, recommend whether anomaly evidence should be:

## Completely silent in ordinary success

if anomalies are rare and harmless.

## Available under Details

if useful diagnostically but not action-worthy.

## Mentioned in terminal completion

only if materially important to the user's understanding.

## Blocking / attention-required

only for categories the human can actually act on or where completion truth is compromised.

Do NOT implement presentation yet.

# Tester diagnostic value

Recommend what a tester should be able to report if Onboarding completes with anomalies.

Potential summary:

- app version;
- final anomaly counts by domain;
- no PII;
- last operation snapshot;
- completion status.

This may inform future `Copy Diagnostic Information`.

# Regression/failure fixtures

Exercise controlled fixtures for:

- opaque handle;
- rich-text fallback;
- missing attachment payload;
- malformed contact;
- malformed reaction;
- fatal structural message/chat anomaly.

Confirm actual production-shaped accounting matches fixture semantics.

# No Start Fresh

Do not wire reset yet.

# No watchdog

Do not revisit liveness.

# No broad UI changes

The current progress presentation is manually approved.

Do not redesign it.

# Tests

Add/update focused tests for:

1. anomaly totals reconcile per domain;
2. full Onboarding can complete with approved nonfatal anomalies;
3. fatal anomaly prevents completion;
4. opaque handles preserve dependent messages;
5. rich-text fallback preserves message identity;
6. attachment anomaly preserves parent message where safe;
7. contact/reaction anomalies do not remove messages;
8. durable snapshot retains exact totals;
9. no PII in persisted diagnostics;
10. Feature 27 coverage remains coherent after nonfatal anomalies.

# Architecture tripwires

Protect:

- no silent anomaly loss;
- no generic catch-and-skip;
- fatal anomalies cannot be downgraded by presentation;
- anomaly accounting comes from domain-owned typed outcomes;
- no user-facing arithmetic in widgets;
- no PII-heavy diagnostic persistence.

# Documentation

Create:

`08-PRODUCTION-SHAPED-ONBOARDING-ANOMALY-VALIDATION.md`

Document:

- profiling environment;
- source scale;
- full anomaly distribution;
- per-domain reconciliation;
- representative samples;
- systemic/local classification;
- completion truth;
- Feature 27 coverage result;
- graph integrity;
- performance;
- diagnostic persistence;
- user-facing recommendation;
- next Feature 28 slice.

Update Feature 28 index/documentation log.

Update version/changelog only if production code changes.

# Verification

Run:

- anomaly policy tests;
- import/graph tests;
- Feature 27 coverage tests;
- snapshot/progress tests;
- architecture tripwires;
- full Flutter suite if code changes;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if code changes.

Commit/push according to repository rules.

# Stop conditions

STOP if:

- nonfatal anomaly counts are unexpectedly pervasive;
- Feature 27 shows unexplained unaccounted messages;
- graph integrity no longer reconciles;
- production-shaped validation requires unsafe mutation of real data;
- anomaly persistence exposes PII.

Do not hide systemic defects behind “safe degradation.”

# Final report

Report:

- exact anomaly distribution;
- whether opaque handles occurred;
- per-domain reconciliation;
- representative technical samples;
- any systemic pattern;
- final Message History Coverage result;
- graph integrity result;
- total Onboarding duration;
- anomaly-accounting overhead;
- recommendation for ordinary UI visibility;
- remaining release blocker;
- tests/verification;
- commit hash.

Acceptance standard:

> Before deciding whether Onboarding should tell a user about anomalies, we must know what a healthy real-sized import actually produces. Rare, safely contained oddities should not become scary interruptions; pervasive degradation must not be hidden behind a successful completion screen.
