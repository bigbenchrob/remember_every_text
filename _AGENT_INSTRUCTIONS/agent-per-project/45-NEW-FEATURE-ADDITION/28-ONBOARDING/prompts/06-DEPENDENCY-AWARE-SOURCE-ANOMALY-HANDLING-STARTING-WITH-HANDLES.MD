Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for a read-first dependency audit and bounded implementation, with **handle normalization/import anomalies as the first concrete remediation target**.

Do NOT create a generic “skip bad rows” framework.

Do NOT assume that failure policy for handles applies to messages, chats, attachments, reactions, or contacts.

Suggested prompt name:

`06-DEPENDENCY-AWARE-SOURCE-ANOMALY-HANDLING-STARTING-WITH-HANDLES.MD`

# Context

The healthy production-shaped Onboarding path is now substantially improved:

- ~49 second full run on representative data;
- real progress observations;
- responsive UI;
- no multi-second dead frames;
- typed durable operation snapshots;
- bounded failure localization.

The next release blocker is source-record anomalies.

Historically, at least one tester’s intake appears to have stopped around an unusual handle resembling:

`*city*`

associated with Hong Kong.

The key product insight is:

> A handle normalization failure should not necessarily prevent the messages associated with that handle from being imported.

Handles participate in relationships and may be referenced by thousands of messages.

If normalization fails, the main loss should ideally be:

- inability to merge that handle with canonical aliases;

not:

- loss of the handle;
- loss of chat relationships;
- loss of dependent messages;
- termination of the whole intake stage.

Also note:

> Handles are now almost entirely hidden from ordinary users and appear mainly as metadata.

Therefore preserving a structurally correct but semantically unnormalized handle may have very little user-facing cost.

# Governing principle

Before deciding whether any anomalous source record may be skipped, preserved opaquely, quarantined, or must stop import, determine:

> What other data structurally depends on this record?

A source anomaly is local only if its downstream relationships can remain truthful.

# Part 1 — dependency map

Audit source-domain dependencies for:

- handle;
- chat;
- message;
- attachment;
- reaction;
- contact.

For each produce:

- source identity;
- downstream references;
- whether raw source identity can be preserved;
- what semantic transformations are optional;
- what transformations are required for graph integrity;
- consequence of dropping the record;
- consequence of preserving it opaquely.

Do not implement policy for all domains yet.

# Part 2 — handles specifically

Trace the entire handle pipeline.

At minimum identify:

source `chat.db.handle` row
→ raw source identity
→ raw handle value
→ normalization
→ canonicalization/alias grouping
→ import representation
→ chat/participant relationships
→ working graph
→ presentation metadata.

Determine exactly where normalization failure currently becomes fatal.

# Important semantic separation

Separate:

## Identity preservation

“This is source handle ROWID X.”

from:

## Semantic normalization

“This value represents canonical phone/email/contact alias Y.”

The first may be structurally essential.

The second may be best-effort.

Do not conflate them.

# Desired handle fallback

If architecture permits, introduce a typed fallback such that a handle whose value cannot be normalized still preserves:

- source ROWID;
- source-scoped/canonical MessageLens identity;
- raw source value where safe/required;
- all chat/participant/message relationships.

But it does NOT participate in:

- canonical phone/email alias merging;
- normalization-based deduplication;
- contact matching that depends on successful normalization.

Use actual domain naming conventions.

Conceptually this may be an:

- opaque handle;
- unnormalized handle;
- raw handle identity.

Choose the term that best fits existing architecture.

# No synthetic semantic identity

Do not invent a fake normalized phone/email value.

Do not hash the raw string and pretend it is canonical semantics.

The fallback identity should derive from source identity, not guessed interpretation.

# Canonical alias grouping

Audit current grouping rules.

For a normal handle:

raw variants
→ normalized canonical alias
→ merged semantic identity.

For an unnormalizable handle:

raw source identity
→ remains distinct.

That is acceptable.

The expected consequence is:

> the handle may fail to group with related aliases.

That should not affect importability of dependent messages.

# Raw value preservation

Determine whether the raw handle value is currently stored and whether preserving it is safe/useful.

Potential uses:

- metadata display;
- diagnostics;
- future improved normalization;
- manual forensic inspection.

Do not expose raw values broadly in logs.

Use existing privacy conventions.

# Duplicate opaque handles

If two different source handle rows both fail normalization but contain identical raw strings:

do NOT automatically merge them unless existing source semantics prove that is correct.

Source identity remains authoritative.

# Downstream graph integrity

Prove that dependent:

- chats;
- participants;
- messages;

can still be projected correctly when a handle is opaque.

The graph should preserve:

message
→ chat
→ participant/handle identity

even when semantic alias grouping is unavailable.

# Contact resolution

Audit what happens when handle normalization fails before Contacts matching.

Expected likely behavior:

- no canonical contact match;
- handle remains unresolved/opaque;
- dependent conversation remains usable.

Do not create a fake contact.

# Presentation consequence

Because handles are mostly hidden, ordinary UI should not need a prominent warning.

Potential behavior:

- raw value may appear as metadata;
- unknown/unmatched display fallback may apply;
- conversation content remains available.

Do not add a user-facing “bad handle” dashboard in this slice.

# Accounting

Handle fallback must be explicit and countable.

Add typed intake outcome evidence such as conceptually:

- normalized;
- preservedUnnormalized;
- failedFatal.

Do not silently swallow normalization failures.

At the end of handle intake we should be able to say internally:

N normalized
M preserved without normalization
0 fatal

if that is true.

# Directed Instrumentation

Do not clutter normal Onboarding progress with anomaly counters unless anomalies occur meaningfully.

However, durable/diagnostic progress should know how many handles were:

- processed;
- preserved unnormalized.

Future Details may expose this if useful.

# Failure routing

A normalization exception that can safely fall back to opaque identity must not become a top-level failed Onboarding operation.

A structural handle failure that prevents preserving source identity or relationships may still fail the stage.

Define that boundary precisely.

# Tester archetype

Create a fixture representing an unusual-but-valid handle resembling the historical case.

Do not rely on exact literal `*city*` unless code/history proves that literal caused the old failure.

Test classes of values such as:

- non-phone;
- non-email;
- punctuation-heavy;
- international-looking;
- unexpected service identifier;
- value normalization rejects.

Expected result:

- handle preserved;
- relationships preserved;
- dependent messages import;
- no top-level failure;
- no false canonical merge.

# Existing failure origin

Search git history/docs/tests for the old failure if possible.

If the actual bug is identifiable, document it.

But do not make successful implementation depend on recovering that historical evidence.

The architecture should protect the next weird handle too.

# Part 3 — dependency-aware policy table for other domains

After implementing handle fallback, produce a recommendation table for:

## Chats

Can raw identity be preserved if semantic parsing fails?

What dependencies break if not?

## Messages

Which malformed fields can degrade gracefully?

Which failures make the message unusable?

Can raw message evidence be preserved/recovered?

## Attachments

Can one bad attachment be skipped while message remains truthful?

Does metadata failure affect only that attachment?

## Reactions

Can reaction failure remain local to reaction evidence?

## Contacts

Can contact parsing fail without affecting message/chat import?

Do not implement these policies in this task unless a trivial existing seam already handles them.

The purpose is to avoid applying the handle rule blindly elsewhere.

# Structural anomaly rule

Develop a general principle:

> Preserve source identity and relationships whenever interpretation is optional.

and:

> Fail only when continuing would create false relationships, lose required identity, or make durable graph truth untrustworthy.

This principle should be documented canonically.

# Idempotency

Opaque-handle fallback must be deterministic across reruns.

Same source handle row
→ same MessageLens identity.

Do not create a new fallback identifier on each run.

# Source scoping

Use canonical source-scoped identity machinery.

No local ID arithmetic.

If source handle IDs have their own existing canonical mapping, reuse it.

# Database schema

Prefer no schema change.

Audit whether current handle representation can store:

- raw value;
- source identity;
- normalization status/fallback.

If schema change is required, STOP and report before implementing.

Do not overload unrelated fields ambiguously.

# Migration compatibility

Existing successfully normalized handles must remain unchanged.

Do not rewrite working handle identity broadly.

The fallback should affect only normalization failures.

# Tests — handle fallback

Add focused tests covering:

1. normal phone handle still normalizes and canonicalizes;

2. normal email handle still normalizes;

3. unusual but valid unnormalizable handle is preserved;

4. opaque handle retains deterministic source identity;

5. dependent chat relationship survives;

6. dependent messages import;

7. graph projection succeeds;

8. opaque handle does not merge with canonical aliases;

9. repeated import produces same identity;

10. no top-level Onboarding failure occurs.

# Tests — failure boundary

11. structurally unreadable handle row that cannot preserve identity fails typed stage;

12. normalization exception with usable source identity falls back;

13. bounded diagnostic context retains source ROWID/domain;

14. raw handle value does not leak into broad logs/PII diagnostics.

# Tests — regression

15. ordinary handle/contact matching unchanged;

16. phone normalization thresholds unchanged;

17. conversation participant counts remain correct;

18. source-scoping unchanged;

19. Historical Archives/import behavior unchanged where shared;

20. full Onboarding completion still succeeds with opaque handle present.

# Performance

Fallback must not materially slow normal handle import.

Do not route every handle through exception-heavy control flow if a typed normalization result can express failure more cheaply.

Profile representative handle set.

# Architecture tripwires

Protect:

- source identity separate from semantic normalization;
- no dropped dependent messages due solely to normalization failure;
- no fake canonical normalized value;
- no UI-owned fallback identity;
- no local source-scoping arithmetic;
- anomaly accounting is typed, not logged-only.

# Presentation

Do not broadly redesign Onboarding.

If current progress overlay needs a tiny change to avoid top-level failure wording for preserved handles, make the minimum bounded correction.

Do not add a warning modal for every opaque handle.

# Documentation

Create:

`06-DEPENDENCY-AWARE-SOURCE-ANOMALY-HANDLING-STARTING-WITH-HANDLES-IMPLEMENTATION.md`

Document:

- dependency map;
- handle identity vs normalization;
- historical tester archetype;
- old fatal path;
- new opaque/unnormalized fallback;
- downstream relationship preservation;
- contact-resolution consequence;
- anomaly accounting;
- deterministic identity;
- other-domain policy table;
- structural anomaly principle.

Update canonical handle/import/Onboarding docs.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules.

# Verification

Run:

- handle normalization tests;
- handle import tests;
- chat/participant relationship tests;
- message import tests;
- graph tests;
- contact resolution tests;
- Onboarding progress/snapshot tests;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP if:

- current schema cannot represent an unnormalized handle without ambiguity;
- dependent message/chat relationships require normalized semantics rather than source identity;
- preserving opaque handles would corrupt deduplication;
- source identity cannot be made deterministic;
- fallback requires broad graph redesign.

Do not silently skip the handle.

# Final report

Report:

- exact handle dependency chain;
- root cause/type of current fatal normalization behavior;
- final fallback representation;
- whether schema changes were needed;
- relationship preservation behavior;
- contact-resolution behavior;
- anomaly accounting;
- performance impact;
- dependency-aware recommendations for chats/messages/attachments/reactions/contacts;
- tests/tripwires;
- full verification;
- commit hash;
- recommended next Feature 28 slice.

Acceptance standard:

> A handle MessageLens cannot semantically normalize should still be allowed to exist as the exact source identity it is, so every chat and message that depends on it can remain intact. Failure to understand an alias must not become failure to import the conversation history attached to that alias.
