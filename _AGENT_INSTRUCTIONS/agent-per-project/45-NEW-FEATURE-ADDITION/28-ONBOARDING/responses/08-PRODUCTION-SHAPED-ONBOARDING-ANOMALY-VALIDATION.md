---
tier: project
scope: onboarding-source-anomalies
owner: 28-ONBOARDING
last_reviewed: 2026-08-25
source_of_truth: validation-record
---

# Production-Shaped Onboarding Anomaly Validation

## Result

A fresh post-correction first import ran against a disposable admitted
development archive using the canonical read-only Apple Messages and Contacts
source boundaries. The operation completed durably with no fatal failure and
produced exactly 137,373 import-ledger messages and 137,373 Conversation Graph
messages.

The original validation run exposed one systemic **measurement** defect rather
than source loss.
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
reference forms remain unchanged rather than acquiring invented identity. The
fresh completed durable snapshot records exactly 7 unresolved reaction targets,
confirming the correction end to end.

## Validation Environment

- App identity: `com.bigbenchsoftware.MessageLens.development`
- Build mode: debug
- Archive: disposable development archive on `WD_ELEMENTS`
- Messages source: live `chat.db`, opened through the established read-only
  source boundary
- Contacts source: live selected AddressBook store, opened read-only
- Production MessageLens archive: not used or modified
- Live source maximum message ROWID: 153,546
- Importable source messages: 137,373
- Operation ID: `0587f6bc-e6af-4c59-b1d0-d4427b7ee1d9`
- Status: `completed`

The application was stopped before database verification. All four staging
SQLite stores passed both `quick_check` and `integrity_check`.

## Post-Correction Durable Confirmation

The corrected Debug binary completed the fresh operation on 2026-08-25. Its
1,184-byte durable snapshot records:

- status `completed`;
- kind `initialImport`;
- all three typed stages completed;
- current terminal stage `durableReadinessVerification`;
- progress revision 809;
- failure `null`;
- `unresolved_reaction_target_count: 7`.

The run started at `2026-08-25T13:23:11.918079Z` and finished at
`2026-08-25T13:24:01.057564Z`, a total of 49.14 seconds. The live source had
advanced by 10 importable messages since the first validation run. That
ordinary source growth explains the corresponding message, chat, attachment,
and relationship count changes below; the typed anomaly totals remained
stable.

## Exact Distribution

The names below are the persisted `SourceImportAnomalyCounts` fields. The
reaction rows preserve the value emitted by the pre-correction validation
binary and the corrected value persisted by the fresh run. The carrier
denominator remained stable across both runs.

| Outcome | Count | Denominator | Rate | Classification |
| --- | ---: | ---: | ---: | --- |
| Normalized handles | 244 | 257 | 94.9416% | Ordinary |
| `preservedUnnormalizedHandleCount` | 13 | 257 | 5.0584% | Recurrent but explainable |
| `messageTimestampUnavailableCount` | 0 | 137,373 | 0% | None observed |
| `recoveredUnlinkedMessageCount` | 20,740 | 137,373 | 15.0976% | Recurrent canonical topology |
| `richTextDecodeUnavailableCount` | 35 | 136,724 attributed-body candidates | 0.0256% | Rare/local |
| `attachmentMetadataDegradedCount` | 0 | 40,240 | 0% | None observed |
| `unresolvedReactionTargetCount`, raw pre-fix snapshot | 6,032 | 6,041 | 99.8510% | Systemic implementation defect |
| `unresolvedReactionTargetCount`, corrected semantics | 7 | 6,041 | 0.1159% | Rare/local |
| `omittedContactRecordCount` | 0 | 113 | 0% | None observed |
| `contactEnrichmentUnavailableCount` | 16 | 113 | 14.1593% | Recurrent but explainable enrichment |
| `omittedContactChannelCount` | 0 | 157 | 0% | None observed |
| `omittedChatMessageRelationshipCount` | 0 | 116,634 | 0% | None observed |
| `omittedChatHandleRelationshipCount` | 0 | 325 | 0% | None observed |
| `omittedMessageAttachmentRelationshipCount` | 0 | 39,624 | 0% | None observed |
| Fatal anomalies | 0 | one complete operation | 0% | None observed |

There is no separate persisted chat-degradation counter. All 240 structurally
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
240 imported = 240 projected
325 imported chat-handle edges = 325 projected + 0 omitted
```

### Messages and Coverage

```text
137,373 imported = 137,373 projected
137,373 total = 116,633 conversation-linked + 20,740 recovered + 0 unaccounted
```

The edge table contains 116,634 rows because one message has two valid chat
edges. Feature 27 correctly uses distinct message identity and therefore
reports 116,633 conversation-linked messages.

Timestamp availability is a separate complete axis:

```text
137,373 = 137,373 available + 0 unavailable
```

### Rich Text

```text
136,724 attributed-body candidates
    = 136,689 with resulting text
    + 35 with content unavailable
```

The 35 messages remain present in both stores with their identity, raw source
evidence, and available relationships. None had a plain-text fallback.

### Attachments

```text
40,240 processed = 40,240 with descriptive evidence + 0 degraded
39,624 imported message-attachment edges = 39,624 projected + 0 omitted
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
| Chats | 240 | 240 |
| Messages | 137,373 | 137,373 |
| Attachments | 40,240 | 40,240 |
| Chat-handle edges | 325 | 325 |
| Chat-message edges | 116,634 | 116,634 |
| Message-attachment edges | 39,624 | 39,624 |

Contacts intentionally reconcile through enrichment policy: 113 source facts
produce 97 graph contacts and 16 explicitly unavailable enrichments.

There are zero dangling chat, message, handle, attachment, sender-handle, or
canonical-sender endpoints. The source registry contains exactly one live
Messages source and one live AddressBook source.

## Completion Truth

The operation reached `completed` only after:

- all three typed stages completed;
- the import ledger and graph both contained 137,373 messages;
- all fatal paths remained absent;
- the typed nonfatal totals were durably recorded;
- durable readiness verification succeeded.

No completion rule changed. The reaction correction changes classification of
existing preserved evidence, not readiness or completion authority.

## Performance

The original pre-correction profile run's durable timestamps established:

| Major stage | Duration |
| --- | ---: |
| Environment preparation | 0.48 s |
| Message data build | 44.97 s |
| Durable readiness verification | 0.06 s |
| Total | 45.52 s |

This is 3.42 seconds faster than the previous 48.94-second production-shaped
run, about 7%. Run-to-run variance prevents assigning a precise negative
overhead, but it rules out material anomaly-accounting cost.

The fresh corrected Debug run completed in 49.14 seconds. That healthy
run-to-run variance and its identical progress revision provide no evidence of
material overhead from the correction.

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

The completed operation occupies one `overlay_settings` row. The fresh
post-correction JSON payload is 1,184 bytes and contains:

- operation and process-session identity;
- typed status, stage, and completed-stage names;
- timestamps and progress revision;
- exact fixed-field anomaly totals;
- no message content, contact content, raw handles, or representative ROWIDs.

Representative source ROWIDs remain transient forensic evidence. They were not
added to durable metadata. Repeated progress observations replace the same
bounded snapshot row rather than accumulating diagnostic records.

The first validation binary completed before the reaction correction was
compiled, so its durable snapshot truthfully retained the observed pre-fix
value 6,032. The fresh corrected run now persists 7 end to end. Its graph also
reconciles the same evidence mechanically:

```text
6,041 associated-message carriers
    = 6,034 graph messages with resolved associated targets
    + 7 durably recorded unresolved targets
```

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

## Validation Status

**Complete.** The fresh production-shaped import with the corrected binary
persisted exactly 7 unresolved reaction targets while preserving completion,
source/graph reconciliation, full message coverage, zero dangling endpoints,
and SQLite integrity. No further schema, UI, completion, source identity, or
graph change is indicated by this slice.

Start Fresh, watchdog thresholds, and user-facing anomaly presentation remain
outside this slice.
