Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for a read-first dependency audit and bounded implementation of safe anomaly handling for the remaining Onboarding source domains.

Prompt 06 established the governing precedent for handles:

> **Semantic interpretation is enrichment; source identity and relationships are structural truth.**

An unnormalizable handle can now be preserved as an opaque source identity. Its relationships survive, but it cannot alias, deduplicate, or contact-match. Typed anomaly counts persist through Onboarding completion.

No schema change was required.

This task determines where that principle applies—and where it emphatically does NOT apply—for:

- chats;
- messages;
- attachments;
- reactions;
- contacts;
- rich-text/attributed-string decoding.

Do NOT create a generic “catch exception → skip row” mechanism.

Suggested prompt name:

`07-DEPENDENCY-AWARE-ANOMALY-POLICY-FOR-REMAINING-ONBOARDING-DOMAINS.MD`

# Central product requirement

One strange source fact should not terminate an otherwise healthy Onboarding Journey unless continuing would make MessageLens's durable representation false or structurally unsafe.

But:

> Continuing is not automatically better than failing.

For every anomaly we must ask:

1. Can source identity still be established?
2. Can required relationships still be represented truthfully?
3. Is the missing interpretation optional enrichment or essential content?
4. Can the anomaly be isolated without changing the meaning of dependent records?
5. Can MessageLens account explicitly for what it could not preserve?
6. Would continuing make the final “Onboarding complete” claim misleading?

# Hard rule

Never silently discard source evidence merely to make Onboarding finish.

Every anomaly must resolve into a typed outcome such as:

- preserved normally;
- preserved with degraded interpretation;
- locally omitted with explicit accounting;
- recovered through canonical fallback;
- fatal because safe continuation is impossible.

Use actual project terminology.

# Read first

Read:

- Feature 28 audit;
- Prompt 02 durable operation snapshot;
- Prompt 04 observability implementation;
- Prompt 05 production-shaped profiling;
- Prompt 06 handle anomaly implementation;
- canonical import/database docs;
- Recovered Messages;
- Unknown Sources;
- typedstream/rich-text decoding architecture;
- graph projection;
- attachment import/archive architecture;
- reactions;
- Contacts import/matching;
- source-scoped identity guidance.

Before editing, produce a dependency graph for each remaining domain.

# General anomaly taxonomy

Establish a typed policy vocabulary.

Do not necessarily create one universal enum if domain-specific types are cleaner.

Conceptually distinguish:

## Fully preserved

Normal case.

## Preserved with degraded interpretation

Structural identity/content survives, optional semantic enrichment does not.

Handle opaque fallback is the precedent.

## Locally omitted with explicit accounting

The anomalous child fact can be omitted without falsifying its parent.

Potential example: an unusable reaction might not require dropping its message.

This must be proven per domain.

## Recovered through canonical fallback

Existing architecture already has a truthful fallback representation.

## Fatal structural/integrity failure

Continuing would:

- lose required identity;
- create false relationships;
- misattribute content;
- violate referential integrity;
- make durable completion untrustworthy.

# Dependency impact table

For each domain produce:

| Domain | Identity authority | Parents | Dependents | Optional enrichment | Safe degraded form? | Safe local omission? | Fatal conditions |

This table should drive implementation.

# Domain 1 — Chats

Trace:

```text
source chat row
→ chat identity
→ participant relationships
→ messages
→ conversation graph
```

Audit anomalies such as:

- missing/invalid chat identifier;
- malformed metadata;
- missing participants;
- inconsistent chat-handle relationships;
- unusual service/type fields.

Determine what can degrade safely.

A chat is structurally significant because many messages may depend on it.

Do not simply quarantine a malformed chat if that would orphan thousands of messages.

Investigate whether MessageLens already has a recovered/unlinked representation for messages whose source chat relationship cannot be reconstructed.

If so, determine whether that is the canonical fallback.

# Domain 2 — Messages

Trace:

```text
source message ROWID/GUID
→ content/decode
→ chat relationship
→ sender/handle relationship
→ attachments/reactions
→ import fact
→ graph message
```

Separate message identity from message interpretation.

Potential anomalies:

- missing GUID;
- missing chat relationship;
- malformed attributed string;
- undecodable text;
- unusual service metadata;
- malformed timestamp;
- missing handle;
- unexpected flags;
- NULL combinations.

Determine which fields are required to preserve the logical message.

# Message content principle

A message whose text cannot be decoded may still be a real message.

Audit whether MessageLens can preserve:

- source identity;
- timestamp;
- chat relationship;
- sender;
- attachments;
- raw/alternate content evidence;

while representing text as unavailable/undecoded.

Do not invent message text.

Do not drop a message merely because rich-text extraction fails if structural evidence remains trustworthy.

# Missing GUID

Treat separately.

Feature 27 deliberately uses physical current `chat.db.message.ROWID` as its denominator.

Determine whether GUID is structurally required for MessageLens import or merely required for some identity/reconciliation operations.

Do not fabricate GUIDs.

If a message without usable GUID cannot safely enter normal graph identity, determine whether Recovered Messages or another canonical evidence path can preserve it.

# Missing chat relationship

This is particularly important.

A valid source message may exist without a usable conversation relationship.

Audit whether canonical Recovered Messages exists specifically to preserve such evidence.

If yes:

> unlinked message should become recovered/unlinked evidence, not disappear and not necessarily abort Onboarding.

Reuse existing ownership.

Do not create another orphan-message bucket.

# Domain 3 — Rich-text / attributed-string decoding

Trace the Rust/FFI `TypedStreamDeserializer` path and all fallbacks.

Classify failures:

- attributed string unavailable but plain text exists;
- typedstream malformed but another text representation exists;
- no decodable text representation exists;
- decoder infrastructure failure affecting many records.

A single malformed typedstream should ideally be local if message identity/content can otherwise be represented.

A systemic decoder failure may be fatal.

Define the boundary.

# Decoder anomaly accounting

Track exact counts such as:

- rich text decoded;
- plain-text fallback used;
- content unavailable;
- systemic decoder failures.

Do not expose these as noisy primary progress unless useful.

Persist bounded typed anomaly totals through completion.

# Domain 4 — Attachments

Trace:

```text
attachment source identity
→ message relationship
→ metadata
→ payload/location evidence
→ import representation
→ archive behavior
```

Potential anomalies:

- attachment metadata malformed;
- missing physical payload;
- unsafe/unavailable path;
- missing GUID;
- broken message relationship;
- unsupported type.

Distinguish:

> attachment fact exists but payload unavailable

from:

> attachment identity/relationship cannot be established.

Feature 26 established strong physical-payload semantics. Reuse them.

# Attachment principle

One bad/missing attachment should not normally cause its parent message to disappear.

Determine whether MessageLens can preserve:

- message;
- attachment metadata/evidence;
- “payload unavailable” state;

without aborting import.

Do not claim attachment availability when file is absent.

# Domain 5 — Reactions

Trace reaction identity and dependency on target message.

Potential anomalies:

- unknown reaction type;
- missing target;
- malformed sender;
- duplicate reaction;
- malformed metadata.

Reactions are likely child enrichment of a message.

Determine which reaction failures can be locally omitted/accounted without affecting message truth.

Do not assume all are harmless.

# Domain 6 — Contacts

Trace:

```text
AddressBook source record
→ contact identity
→ handles/aliases
→ display name/avatar/metadata
```

Messages must not disappear merely because Contacts data is strange.

Determine:

- which contact failures can degrade to unmatched handle;
- whether malformed contact row can be omitted safely;
- whether contact import failure is currently coupled too strongly to Messages import;
- whether one bad contact can abort Onboarding.

The likely principle is:

> Contacts enrich message identities; they do not own message existence.

Prove it from architecture.

# Cross-domain failure propagation

Audit where one domain currently aborts subsequent domains.

For example:

handle anomaly
→ chat import abort
→ message import never runs.

or:

contact failure
→ whole message build aborts.

Replace inappropriate propagation only where safe policy is now proven.

# Referential integrity

For every proposed degraded/omitted outcome prove:

- foreign-key/import relationships remain valid;
- graph projection does not invent edges;
- participant counts remain truthful;
- message counts remain truthful;
- Feature 27 coverage accounting remains truthful.

Do not “fix” intake by creating dangling references.

# Recovered Messages ownership

Audit how Recovered Messages can serve as a structural safety net.

Use it only for its canonical semantics.

Potentially:

valid message identity

- no usable conversation relationship
  → Recovered Messages.

Do not route arbitrary parse failures there simply to avoid failure.

# Unknown Sources ownership

Similarly determine whether Unknown Sources owns any source anomalies.

Do not duplicate or overload it.

# Completion semantics with anomalies

This is critical.

Onboarding may potentially complete successfully with nonfatal anomalies.

Define what “complete” means then.

Potential model:

## Complete

All source facts were either:

- preserved normally;
- preserved through approved degraded representation;
- locally omitted only where omission is explicitly safe and accounted.

## Complete with attention/evidence

If some anomalies are meaningful enough that the user should know.

Do not add this state casually.

## Failed

At least one fatal structural/integrity anomaly prevents trustworthy durable completion.

The final durable readiness check must understand the policy.

Do not simply ignore anomaly counts.

# User-facing philosophy

Most benign anomalies should NOT interrupt the Journey.

A tester should not have to make a decision about:

- weird handle syntax;
- one malformed reaction;
- one missing attachment payload;

if MessageLens can preserve everything important automatically.

Human attention should be reserved for conditions the human can actually resolve.

# Diagnostic evidence

Persist bounded anomaly summaries:

- domain;
- outcome category;
- count;
- representative source ROWIDs if useful;
- sanitized failure code.

Do not persist raw message text, contact names, phone numbers, emails, or handles merely for diagnostics.

# Representative samples

If thousands of anomalies occur, do not persist thousands of diagnostic entries.

Keep:

- exact counts;
- bounded representative technical references.

Define cap.

# Threshold/escalation

A single locally safe anomaly may be nonfatal.

But 100,000 such anomalies may indicate a systemic defect.

Design a principled escalation rule where appropriate.

Do not use arbitrary percentages without evidence.

Possible model:

local anomaly type is safe individually

- unexpectedly pervasive occurrence
  → systemic failure/invariant warning.

Only implement if defensible.

# Progress integration

Current Onboarding reports real record progress.

An anomaly that is safely handled counts as a processed record.

For example:

message 42,001 could not decode rich text but was preserved through approved fallback
→ numerator advances.

Do not freeze progress because optional enrichment failed.

# Durable snapshot integration

Extend existing typed anomaly counts/evidence through the canonical Onboarding snapshot.

Do not create a second anomaly persistence store unless required.

No per-record durable writes.

Batch/coalesce with existing progress persistence.

# Retry semantics

For nonfatal preserved anomalies:

retry is not necessary for Onboarding completion.

Future improved normalization/decoding may remediate them separately.

For fatal structural anomalies:

preserve enough evidence for future retry/remediation.

Do not repeatedly retry a deterministic malformed record during the same run.

# Idempotency

All fallback/degraded outcomes must be deterministic.

Rerunning Onboarding over the same source should not:

- create duplicate opaque records;
- change source identity;
- alternate between categories unpredictably.

# Performance

Anomaly handling must keep the healthy path fast.

Avoid exception-driven normal control flow where typed parse/normalization results can be used.

Profile representative healthy + anomalous fixtures.

# No watchdog

Do not revisit stall detection in this task.

The healthy journey already provides real progress.

# No Start Fresh yet

Do not wire reset.

# Presentation scope

Do not redesign Onboarding broadly.

Tiny changes are permitted if necessary to:

- avoid fatal UI when anomaly was safely handled;
- preserve factual anomaly count in Details/diagnostics.

Do not add modal interruptions for benign anomalies.

# Tests — chats

Cover representative:

- normal chat;
- unusual metadata;
- missing participant relation;
- structurally unusable chat;
- dependent-message consequence.

# Tests — messages

Cover:

- normal message;
- rich-text failure with usable fallback;
- undecodable content with preserved identity where safe;
- missing chat relationship → canonical recovered/unlinked path if appropriate;
- structurally unusable message → fatal or explicit safe omission according to proven policy.

# Tests — attachments

Cover:

- normal;
- payload missing;
- malformed metadata;
- broken relationship;
- parent message preserved where safe.

# Tests — reactions

Cover:

- normal;
- unknown/malformed reaction;
- missing target;
- message preservation.

# Tests — contacts

Cover:

- normal;
- malformed contact enrichment;
- handle remains usable;
- messages unaffected.

# Tests — cross-domain

Prove:

- benign anomaly does not abort subsequent domains;
- fatal structural anomaly does;
- category counts reconcile;
- no silent loss;
- Feature 27 current-message coverage remains coherent;
- full Onboarding can complete with approved degraded records.

# Architecture tripwires

Protect:

1. no generic catch-and-skip import helper;

2. anomaly policy is typed/domain-owned;

3. source identity preserved where interpretation is optional;

4. no fabricated semantic values;

5. no message loss due solely to contact enrichment failure;

6. no message loss due solely to attachment payload absence;

7. recovered/unlinked path uses canonical ownership;

8. anomaly counts persist;

9. no PII-heavy anomaly logs;

10. final readiness cannot ignore fatal anomaly state.

# Documentation

Create:

`07-DEPENDENCY-AWARE-ANOMALY-POLICY-FOR-REMAINING-ONBOARDING-DOMAINS-IMPLEMENTATION.md`

Document:

- final dependency table;
- anomaly taxonomy;
- per-domain policy;
- message/rich-text fallback;
- attachment policy;
- reaction policy;
- contact policy;
- recovered/unknown-source ownership;
- completion semantics;
- diagnostic evidence;
- escalation policy;
- performance impact;
- intentionally fatal conditions.

Update canonical import/Onboarding docs.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules.

# Verification

Run:

- source import tests;
- chat/message/attachment/reaction/contact tests;
- rich-text tests;
- Recovered Messages tests;
- graph tests;
- Feature 27 coverage tests;
- Onboarding snapshot/progress tests;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP for a domain if:

- safe degradation cannot preserve referential truth;
- current schema cannot represent the required fallback;
- policy would require fabricated identity/content;
- completion semantics become ambiguous;
- a schema migration is required.

It is acceptable for different domains to end this task with different policies.

Do not force uniformity.

# Final report

Report:

- final dependency table;
- anomaly taxonomy;
- exact policy for chats;
- messages;
- rich-text;
- attachments;
- reactions;
- contacts;
- which anomalies are degraded/preserved;
- which are locally omitted;
- which remain fatal;
- completion semantics;
- anomaly accounting;
- performance impact;
- tests/tripwires;
- full verification;
- commit hash;
- recommended next Feature 28 slice.

Acceptance standard:

> Onboarding should be resilient because MessageLens understands the structural consequences of an anomaly, not because it blindly ignores errors. Optional interpretation may degrade; required identity and relationships may not. One strange child fact should not destroy its parent, while any condition that would make the resulting message history false must still stop safely.
