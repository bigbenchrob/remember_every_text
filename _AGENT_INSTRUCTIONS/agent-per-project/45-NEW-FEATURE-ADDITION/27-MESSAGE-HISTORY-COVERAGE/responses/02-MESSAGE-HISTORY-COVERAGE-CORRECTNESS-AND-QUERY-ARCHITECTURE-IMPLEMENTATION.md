---
tier: project
scope: message-history-coverage
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: implementation-record
---

# Message History Coverage Correctness And Query Architecture Implementation

## Outcome

Message History Coverage now answers one bounded question:

> For every physical message row currently present in this Mac's
> `chat.db.message`, can MessageLens identify what happened to that exact
> current-source row?

The report no longer compares a current-Mac count with gross multi-source graph
counts. It no longer clamps impossible arithmetic into apparent success.

## Ownership

- Source-scoped import owns read-only enumeration of current
  `chat.db.message.ROWID` evidence and the source date range.
- Conversation Graph owns source-1 topology evidence and classifies each
  projected source row as conversation-linked or recovered/unlinked.
- Settings composes those two typed evidence sets and owns the human-facing
  report.
- `SourceScopedRowSql` and `liveChatDbSourceId` remain the canonical graph-side
  source identity authorities. No local bit arithmetic was introduced.

## Exact Partition

For every denominator ROWID, Settings performs one lookup in the source-1 graph
evidence map:

```text
conversation-linked graph evidence -> accountedInConversations
recovered/unlinked graph evidence   -> recoveredUnlinked
no graph evidence                   -> unaccounted
```

The report constructor rejects:

- negative counts;
- a category larger than the denominator;
- any category sum that does not exactly equal the denominator.

Current-source graph evidence outside the current `chat.db` denominator cannot
offset a missing denominator identity. It remains outside this report's
question. Thus equal gross totals with different identities still produce an
incomplete partition rather than false success.

## Query Shape

The source reader performs one guarded read-only ROWID query and one guarded
date-range aggregate against `chat.db`.

The graph reader performs one source-1-only set query. A materialized distinct
set of `chat_to_message.message_ss_id` values is joined to source-1 message
rows. The retired pair of correlated `EXISTS`/`NOT EXISTS` full scans is gone.

On the same disposable production-shaped staging graph used by the opening
audit, the former correlated query exceeded the audit's 30-second bound. The
new query emitted all 137,340 source-1 classification rows in 0.10 seconds of
read-only SQLite execution. This measures the database phase, not source-file
opening or Dart object allocation, but confirms removal of the query pathology.

Historical source rows are excluded by canonical source identity before they
reach Settings. A regression fixture adds 8,882 source-3 graph rows and proves
that the source-1 classification remains unchanged. Attachment-recovery donors
do not supply either of the two report evidence contracts and therefore cannot
affect coverage.

## Status And Lifecycle

The typed report states are now:

- `complete`;
- `incomplete`;
- `temporarilyUnavailable`;
- `failed`.

When admitted database maintenance is active, the report returns
`temporarilyUnavailable` before constructing the evidence repository or
opening the protected graph store. A maintenance transition invalidates the
Riverpod computation; obsolete async results cannot replace the newer provider
generation. A genuine query or invariant failure produces `failed` and is
logged rather than presented as complete.

The existing panel received only the minimum changes required to display these
honest states. Final presentation redesign remains a later slice.

## Permanent Tripwires

Architecture coverage now prevents reintroduction of:

- gross graph `COUNT(*)` arithmetic in the Settings composition repository;
- correlated per-message `WHERE EXISTS`/`WHERE NOT EXISTS` coverage scans;
- graph-side source decoding outside `SourceScopedRowSql`;
- coverage count clamps in the report model.

## Verification

Focused evidence, reconciliation, provider, export, and widget tests cover:

- every physical ROWID as denominator;
- all three exclusive terminal categories;
- exact partition arithmetic;
- impossible arithmetic failure;
- equal gross totals with mismatched identities;
- 8,882 historical rows having no effect;
- maintenance non-opening and recomputation;
- genuine query failure;
- provider request caching;
- existing report and export presentation.

Verification completed on 2026-08-22:

- 29 focused Message History Coverage tests passed;
- the focused suite plus architecture tripwires passed 410 tests;
- the broader source-scoping, recovered-message, graph/database, and Settings
  suite passed 201 tests;
- the complete Flutter suite passed all 1,951 tests;
- `flutter analyze` reported no issues;
- `dart format` found all 27 touched Dart files already formatted;
- `git diff --check` passed;
- `flutter build macos --debug` built
  `MessageLens Development.app` successfully. Xcode emitted only the existing
  `volume_controller` privacy-manifest processing warning.
