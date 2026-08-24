---
tier: project
scope: onboarding-source-anomalies
owner: 28-ONBOARDING
last_reviewed: 2026-08-24
source_of_truth: validation-record
---

# Production-Shaped Onboarding Anomaly Validation

## Result

A complete first import ran against a disposable admitted development archive
using the canonical read-only Apple Messages and Contacts source boundaries.
The operation completed durably with no fatal failure and produced exactly
137,363 import-ledger messages and 137,363 Conversation Graph messages.

The run exposed one systemic **measurement** defect rather than source loss.
Apple associated-message references commonly wrap their target GUID in `p:` or
`bp:` envelopes. Exact comparison of the raw reference against a message GUID
misclassified 6,032 of 6,041 reaction carriers as unresolved. Canonical
interpretation of those envelopes leaves 7 genuinely unresolved references.

The correction is deliberately shared and source-owned:

```text
Apple associated-message reference
    -> appleAssociatedMessageTargetGuid
    -> source-scoped target existence check
    -> source-scoped graph target projection
```

It changes neither source identity nor imported records. Malformed or unknown
reference forms remain unchanged rather than acquiring invented identity.

## Validation Environment

- App identity: `com.bigbenchsoftware.MessageLens.development`
- Build mode: profile
- Archive: disposable development archive on `WD_ELEMENTS`
- Messages source: live `chat.db`, opened through the established read-only
  source boundary
- Contacts source: live selected AddressBook store, opened read-only
- Production MessageLens archive: not used or modified
- Live source maximum message ROWID: 153,536
- Importable source messages: 137,363
- Operation ID: `8fe89b76-6b74-49a4-ba8f-c99ae7098ff9`
- Status: `completed`

The application was stopped before database verification. All four staging
SQLite stores passed both `quick_check` and `integrity_check`.

## Exact Distribution

The names below are the persisted `SourceImportAnomalyCounts` fields. The
reaction row shows both the value emitted by the pre-correction validation
binary and the corrected result derived from the same immutable imported
evidence.

| Outcome | Count | Denominator | Rate | Classification |
| --- | ---: | ---: | ---: | --- |
| Normalized handles | 244 | 257 | 94.9416% | Ordinary |
| `preservedUnnormalizedHandleCount` | 13 | 257 | 5.0584% | Recurrent but explainable |
| `messageTimestampUnavailableCount` | 0 | 137,363 | 0% | None observed |
| `recoveredUnlinkedMessageCount` | 20,740 | 137,363 | 15.0987% | Recurrent canonical topology |
| `richTextDecodeUnavailableCount` | 35 | 136,714 attributed-body candidates | 0.0256% | Rare/local |
| `attachmentMetadataDegradedCount` | 0 | 40,232 | 0% | None observed |
| `unresolvedReactionTargetCount`, raw pre-fix snapshot | 6,032 | 6,041 | 99.8510% | Systemic implementation defect |
| `unresolvedReactionTargetCount`, corrected semantics | 7 | 6,041 | 0.1159% | Rare/local |
| `omittedContactRecordCount` | 0 | 113 | 0% | None observed |
| `contactEnrichmentUnavailableCount` | 16 | 113 | 14.1593% | Recurrent but explainable enrichment |
| `omittedContactChannelCount` | 0 | 157 | 0% | None observed |
| `omittedChatMessageRelationshipCount` | 0 | 116,624 | 0% | None observed |
| `omittedChatHandleRelationshipCount` | 0 | 324 | 0% | None observed |
| `omittedMessageAttachmentRelationshipCount` | 0 | 39,616 | 0% | None observed |
| Fatal anomalies | 0 | one complete operation | 0% | None observed |

There is no separate persisted chat-degradation counter. All 239 structurally
valid chats were imported and projected. Nullable descriptive chat metadata is
not counted as omission, while the typed chat relationship omission counters
were both zero.

## Reconciliation

The anomaly fields describe independent dependency axes and therefore cannot
all be added together. For example, one reaction carrier may also have an
attributed body and may be unlinked. The truthful invariants are domain
specific.

### Handles

```text
257 processed = 244 normalized + 13 preserved unnormalized
```

Every opaque handle retained its source-scoped identity and graph handle.
None acquired a canonical alias or contact match.

### Chats

```text
239 imported = 239 projected
324 imported chat-handle edges = 324 projected + 0 omitted
```

### Messages and Coverage

```text
137,363 imported = 137,363 projected
137,363 total = 116,623 conversation-linked + 20,740 recovered + 0 unaccounted
```

The edge table contains 116,624 rows because one message has two valid chat
edges. Feature 27 correctly uses distinct message identity and therefore
reports 116,623 conversation-linked messages.

Timestamp availability is a separate complete axis:

```text
137,363 = 137,363 available + 0 unavailable
```

### Rich Text

```text
136,714 attributed-body candidates
    = 136,679 with resulting text
    + 35 with content unavailable
```

The 35 messages remain present in both stores with their identity, raw source
evidence, and available relationships. None had a plain-text fallback.

### Attachments

```text
40,232 processed = 40,232 with descriptive evidence + 0 degraded
39,616 imported message-attachment edges = 39,616 projected + 0 omitted
```

Payload archival is a separate preservation concern. A normal post-completion
maintenance sweep later archived 5 payloads, skipped 95, and failed 0; it was
not part of the Onboarding operation or anomaly total.

### Contacts

```text
113 source contacts = 97 projected enrichments + 16 unavailable enrichments
157 channels = 157 retained + 0 omitted
```

Messages do not depend on Contacts enrichment for existence.

### Reactions

```text
6,041 carriers = 6,034 resolved targets + 7 unresolved targets
```

The pre-fix exact comparison recognized only 9 raw GUID references. The shared
Apple-reference interpretation additionally resolves 5,478 `p:` envelopes and
547 `bp:` envelopes. All 7 unresolved carriers remain projected evidence.

## Representative Technical Samples

Only source ROWIDs and typed consequences were inspected. No message text,
names, addresses, phone numbers, email addresses, or raw handle values are
recorded here.

| Domain | Source ROWIDs | Typed reason | Downstream consequence |
| --- | --- | --- | --- |
| Handle | 303, 120, 126, 157, 161 | `preservedUnnormalizedHandleCount` | All five graph handles survive; each retains chat membership; no alias or contact match is fabricated. ROWID 303's related chat retains 45 messages and its sender relation retains 23 messages. |
| Message | 9,253, 9,308, 9,375, 9,415, 9,421 | `recoveredUnlinkedMessageCount` | Each message is projected with no invented chat edge and remains owned by Recovered Messages. |
| Rich text | 13,719, 25,904, 32,598, 37,097, 41,803 | `richTextDecodeUnavailableCount` | Each message identity is projected; available chat and attachment edges remain intact; no plain text is fabricated. |
| Contact | 1, 2, 3, 12, 82 | `contactEnrichmentUnavailableCount` | Contact enrichment is not projected; parent Messages evidence is unaffected. |
| Reaction | 4,077, 37,395, 147,943, 148,037, 148,117 | `unresolvedReactionTargetCount` | Carrier message remains projected; target relation stays null. |

No attachment or relationship-omission samples exist because those counters
were zero.

## Graph Integrity

Import and graph counts agree exactly for every source-owned graph population:

| Population | Import | Graph |
| --- | ---: | ---: |
| Handles | 257 | 257 |
| Chats | 239 | 239 |
| Messages | 137,363 | 137,363 |
| Attachments | 40,232 | 40,232 |
| Chat-handle edges | 324 | 324 |
| Chat-message edges | 116,624 | 116,624 |
| Message-attachment edges | 39,616 | 39,616 |

Contacts intentionally reconcile through enrichment policy: 113 source facts
produce 97 graph contacts and 16 explicitly unavailable enrichments.

There are zero dangling chat, message, handle, attachment, sender-handle, or
canonical-sender endpoints. The source registry contains exactly one live
Messages source and one live AddressBook source.

## Completion Truth

The operation reached `completed` only after:

- all three typed stages completed;
- the import ledger and graph both contained 137,363 messages;
- all fatal paths remained absent;
- the typed nonfatal totals were durably recorded;
- durable readiness verification succeeded.

No completion rule changed. The reaction correction changes classification of
existing preserved evidence, not readiness or completion authority.

## Performance

The durable operation timestamps establish:

| Major stage | Duration |
| --- | ---: |
| Environment preparation | 0.48 s |
| Message data build | 44.97 s |
| Durable readiness verification | 0.06 s |
| Total | 45.52 s |

This is 3.42 seconds faster than the previous 48.94-second production-shaped
run, about 7%. Run-to-run variance prevents assigning a precise negative
overhead, but it rules out material anomaly-accounting cost.

The snapshot reached progress revision 809 using the established bounded
observation cadence. Import batch start boundaries remained consistent with
the previous profile: small chat/handle/contact stages completed quickly;
message and rich-text intake occupied about 12.86 seconds; attachment intake
about 5.37 seconds; and the remaining relationship/projection work about 25.47
seconds. These are observational intervals, not new timeout thresholds.

The correction resolves only the distinct referenced target GUIDs and queries
them from the read-only source in bounded chunks. It does not perform one query
per message.

## Durable Diagnostics

The completed operation occupies one `overlay_settings` row. Its JSON payload
is 1,187 bytes and contains:

- operation and process-session identity;
- typed status, stage, and completed-stage names;
- timestamps and progress revision;
- exact fixed-field anomaly totals;
- no message content, contact content, raw handles, or representative ROWIDs.

Representative source ROWIDs remain transient forensic evidence. They were not
added to durable metadata. Repeated progress observations replace the same
bounded snapshot row rather than accumulating diagnostic records.

The validation binary completed before the reaction correction was compiled,
so its durable snapshot truthfully retains the observed pre-fix value 6,032.
The corrected value 7 was recomputed from the immutable staging evidence using
the same shared semantics now used by import and projection. A fresh
post-correction run must confirm that 7 is persisted end to end.

## Presentation Recommendation

Ordinary successful completion should remain calm and silent about these
nonactionable source details. Exact anomaly totals should be available under a
Details or diagnostic-copy surface for testers and support.

A useful PII-free tester report should contain:

- app version;
- operation ID and completion status;
- exact typed anomaly totals;
- current-source coverage totals;
- no source payload or raw identifiers.

Terminal completion should mention anomalies only when they materially change
what the user can understand or act upon. Fatal structural failures already
block completion and belong on an attention-required path.

## Correction Verification

Focused tests prove:

- raw, `p:`, and `bp:` references share one source-owned interpretation;
- malformed envelopes remain unchanged;
- a reaction imported later can resolve an earlier source message;
- graph projection uses the same source-scoped interpretation;
- unrelated-source targets cannot satisfy the lookup;
- the obsolete exact raw-GUID SQL comparison is absent.

Existing anomaly-policy, import, graph, snapshot, completion, architecture,
and Feature 27 fixtures continue to own the remaining Prompt 08 invariants.

Final repository verification passed:

- 414 focused source-import, graph, Onboarding, snapshot, and Message History
  Coverage tests;
- 413 architecture tripwires;
- the complete 2,034-test Flutter suite;
- `flutter analyze` with no issues;
- macOS debug build of `MessageLens Development.app`;
- formatting and `git diff --check`.

## Remaining Release Blocker

Run one fresh production-shaped import with the corrected binary and verify
that the durable snapshot itself records 7 unresolved reaction targets. No
further schema, UI, completion, source identity, or graph change is indicated.

Start Fresh, watchdog thresholds, and user-facing anomaly presentation remain
outside this slice.
