---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-05-31
depends_on:
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md
---

# 77 - Recovered Message Graph Parity Audit

## Purpose

This audit compares the current legacy recovered-message evidence universe with
the graph-backed recovered repository candidate.

It is a cutover gate. The graph repository must not replace the legacy
repository until the semantic differences below are either accepted or repaired.

## Compared Sources

Legacy recovered evidence:

```text
working.db.recovered_unlinked_messages
working.db.recovered_unlinked_attachments
```

Graph recovered candidate:

```text
working_ss.db.messages
LEFT JOIN working_ss.db.chat_to_message
WHERE chat_to_message.message_ss_id IS NULL
```

Identity bridge used for comparison:

```text
legacy recovered id
→ pack(liveChatDbSourceId, legacy id)
→ graph message ss_id
```

This confirms the architectural expectation that legacy recovered `id` behaves
as the live source message ROWID, while graph identity is source-scoped.

## Real-Data Snapshot

Observed on 2026-05-31:

| Metric | Count |
| --- | ---: |
| legacy recovered messages | 20,895 |
| legacy recovered attachments | 3,852 |
| legacy no-handle outgoing recovered messages | 11,902 |
| legacy recovered messages flagged with attachments | 3,622 |
| graph messages without chat topology | 20,698 |
| graph no-handle outgoing messages without chat topology | 11,785 |
| graph orphan messages with attachments | 3,622 |

## Identity Parity

| Comparison | Count |
| --- | ---: |
| legacy recovered rows present in graph by packed legacy id | 20,892 |
| legacy recovered rows still graph-orphaned | 20,697 |
| legacy recovered rows now projectable into chat topology | 195 |
| legacy recovered rows absent from graph entirely | 3 |
| graph orphan rows not present in legacy recovered | 1 |

## Interpretation

The graph candidate is very close to the legacy recovered evidence universe, but
it is not a byte-for-byte replacement.

The difference is mostly architectural and appears desirable:

- 20,697 legacy recovered rows remain graph-orphan evidence.
- 195 legacy recovered rows now have `chat_to_message` topology and therefore
  should be ordinary conversation evidence, not recovered evidence.
- 3 legacy recovered rows are absent from both `macos_import_ss.messages` and
  `working_ss.messages`; they require follow-up before legacy storage can be
  retired completely.
- 1 graph orphan row is not in legacy recovered evidence, which indicates graph
  recovery can identify at least one newer orphan row that legacy recovered
  tables do not contain.

## Resolution Of The 3 Legacy-Only Rows

The 3 legacy-only rows were traced further after the initial audit and then
explained by user action.

They are present in:

```text
working.db.recovered_unlinked_messages
```

They are absent from:

```text
macos_import.db.recovered_unlinked_messages
macos_import.db.messages
macos_import_ss.db.messages
working_ss.db.messages
```

The rows are short-code SMS alerts with no sender handle id. The user later
identified these as rows affected by testing the Discard action on the Unknown
Senders / From unfamiliar sources page.

The discard path is user intent, not source truth:

```text
Unknown Senders Discard
→ StrayHandleDismissed
→ user_overlays.db.dismissed_handles
→ graph-era visibility/read surfaces
```

It does not mutate `working.db.recovered_unlinked_messages`. Therefore the
legacy table still shows these rows while graph-era unknown-source surfaces may
hide them.

Batch/source classification:

| legacy working batch | classification | count |
| ---: | --- | ---: |
| 164 | graph-era dismissed / legacy-retained | 2 |
| 337 | graph-era dismissed / legacy-retained | 1 |

These rows should not be treated as source-integrity loss. They represent the
expected difference between legacy recovered storage, which is unaware of the
new graph-era discard overlay, and graph-era visibility surfaces, which honor
that user intent.

## Retention Strategy

Known user-suppressed legacy-only rows should not block graph cutover by
themselves.

The retention rule is:

```text
If a legacy-only recovered row is absent from graph-era visible recovered
evidence because the user intentionally dismissed that sender/handle, classify
it as expected suppression, not evidence loss.
```

Only unresolved legacy-only rows block cutover.

```text
legacy-only rows
  - known user-suppressed → acceptable visibility delta
  - unknown/unexplained → retention blocker
```

Until then:

- do not treat dismissed rows as source/import loss
- do not copy dismissed rows into graph storage to force count parity
- do not delete legacy recovered storage until unresolved legacy-only rows are
  zero or explicitly explained
- do not delete `working.db.recovered_unlinked_messages`

## Attachment Parity

Attachment parity for matched graph-orphan recovered rows is strong:

| Comparison | Count |
| --- | ---: |
| matched legacy recovered rows with attachments | 3,622 |
| matched rows with graph attachment edges | 3,622 |
| attachment count mismatches on matched rows | 0 |

This supports the graph repository candidate for attachment-bearing recovered
evidence.

## Text and GUID Parity

For rows matched by packed source identity:

| Comparison | Count |
| --- | ---: |
| GUID mismatches | 0 |
| trimmed text mismatches | 0 |

This supports source-scoped identity as the correct bridge and confirms that
ordinary recovered text is preserved in the graph path for matched rows.

## Notable Samples

### Legacy Rows Now Projectable

These rows exist in legacy recovered evidence but now have graph chat topology:

| legacy id | chat ss_id | sample |
| ---: | ---: | --- |
| 10577 | 8796093022580 | Let’s not talk about that. |
| 25145 | 8796093022570 | And I knew he liked it. |
| 25153 | 8796093022570 | Can we chat around 5-5:30? |

Interpretation: graph topology has repaired records that legacy classified as
unlinked. If accepted, these should disappear from the recovered bucket and
appear in ordinary conversation evidence.

### Legacy Rows Absent From Graph

These rows exist in legacy recovered evidence but are absent from current graph
and import_ss data:

| legacy id | sent at UTC | sample |
| ---: | --- | --- |
| 130510 | 2026-02-12T05:13:09.000Z | TD Alert: Chequing ***9921 is below $100 |
| 134337 | 2026-04-09T22:10:36.000Z | On Its Way: Purolator Your Way has shipp |
| 134421 | 2026-04-10T14:32:36.000Z | CRA Multi-Factor Authentication (MFA): Y |

Interpretation: these initially appeared to be source rows that were present
when legacy recovered tables were built but no longer exist in the current live
source/import graph. They were later explained by user testing of the Unknown
Senders discard flow and are now classified as user-suppressed legacy-only
rows, not unexplained source-integrity loss.

### Graph Orphan Not In Legacy

| source rowid | sent at UTC | sample |
| ---: | --- | --- |
| 148959 | 2026-05-26T18:43:17.000Z | TD will not send you sign-in links by text. Beware of scams. |

Interpretation: graph recovered evidence can identify new orphan rows that are
not represented in legacy recovered tables.

## Cutover Implications

Replacing the legacy recovered repository with the graph repository would:

- preserve the large majority of recovered evidence
- preserve attachment evidence for matched rows
- preserve text/GUID facts for matched rows
- intentionally remove 195 now-projectable rows from recovered views
- add 1 graph-only orphan row
- omit 3 legacy-only rows from graph-era visible recovered evidence because
  they were intentionally dismissed by the user

The 195-row difference is likely correct under the graph architecture:
recovered evidence means "not safely projectable into normal conversation
topology." Once topology exists, the message belongs in conversation evidence.

The 3 legacy-only rows are different. They are now understood as expected
user-intent suppression from the Unknown Senders discard flow. They are no
longer classified as source-integrity blockers.

## Recommendation

Do not wire the graph recovered repository into production yet.

Next safe implementation step:

1. Keep the legacy recovered repository as the production provider.
2. Use the diagnostic provider around the pure parity comparator so the app can
   produce the same comparison without one-off SQL.
3. Keep graph recovered cutover gated on diagnostics until unresolved
   legacy-only rows remain zero on current real data.

Status: diagnostic boundary added. A pure `compareRecoveredMessageEvidence`
comparator now classifies:

- graph-orphan matches
- now-projectable legacy rows
- legacy-only rows
- known suppressed legacy-only rows
- unresolved legacy-only rows
- graph-only rows
- attachment-count mismatches
- GUID/text mismatches

It is intentionally repository-agnostic. The application-level
`recoveredMessageParityDiagnosticProvider` composes:

- legacy recovered evidence repository
- graph recovered candidate repository
- `GraphRecoveredMessageProjectabilityRepository`
- overlay dismissed-handle state
- the pure parity comparator

This provider is diagnostic-only. It does not replace the production recovered
message repository, does not mutate overlay/working data, and must not be used
as a presentation workaround.

## Cutover Criteria

Graph recovered repository can replace the legacy repository only when:

- graph-orphan matched rows preserve text, sender, semantic, and attachment
  evidence
- now-projectable legacy rows are intentionally excluded from recovered views
  and visible in conversation evidence
- unresolved legacy-only rows are zero, or remaining legacy-only rows are
  explicitly classified as user-suppressed/expected
- recovered no-handle outgoing inference remains acceptable on real contact
  scopes
- diagnostics explain expected count differences
- parity reports `canCutOverWithoutEvidenceLoss`

## Non-Goals

Do not:

- force now-projectable messages back into recovered evidence
- collapse recovered identity by GUID
- delete legacy recovered tables while legacy-only rows remain unaccounted for
- add presentation-specific recovered workarounds
