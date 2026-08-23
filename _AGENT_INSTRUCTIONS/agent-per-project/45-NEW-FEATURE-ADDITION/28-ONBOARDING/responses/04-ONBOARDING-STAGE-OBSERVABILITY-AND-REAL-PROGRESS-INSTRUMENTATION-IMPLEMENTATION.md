---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-23
source_of_truth: feature-implementation-record
---

# Onboarding Stage Observability And Real Progress Instrumentation

## Outcome

Onboarding now exposes real completed work throughout its source import,
rich-text enrichment, and row-oriented Conversation Graph projection pipeline.
The existing durable `OnboardingOperationSnapshot` remains the sole operation
authority. No watchdog, timeout, stall state, sleep detector, Start Fresh path,
record quarantine, schema migration, or second progress authority was added.

The user-facing progress surface can now present factual evidence such as:

```text
Messages  42000 / 137000
```

The numerator is advanced by the service that completed the work. The widget
does not query a database, count rows, or invent progress.

## Top-Level Stages

The four established durable stages are unchanged:

1. `environmentPreparation`
2. `messageDataBuild`
3. `durableReadinessVerification`
4. `automaticRecoveryReset`

Suboperations remain observations within those stages. A final numerator does
not complete a stage; the existing operation and durable-verification
boundaries retain completion authority.

## Before And After

Before this slice, each top-level stage exposed entry and eventual
return/failure only. Selected graph repositories had internal 250-row
observers, but the ordinary Onboarding graph build did not consume them.

After this slice:

```text
source importer
  -> SourceImportWorkProgress
  -> ConversationGraphBuildObservation
  -> OnboardingProgressReporter
  -> OnboardingOperationSnapshot
  -> Onboarding overlay projection
```

The same chain carries graph projection observations. Provider rebuilds do not
initiate work; `ConversationGraphBuildController` retains its existing
single-execution/coalescing behavior.

## Execution Map

### `environmentPreparation`

```text
OnboardingGate
  -> typed preparing/resetting substage
  -> MessageDataResetService
  -> close derived stores
  -> remove only enumerated rebuildable database files
  -> invalidate providers
  -> verify deletion
```

This is a short, file-count-bounded operation. It remains coarse because its
few asynchronous database/file lifecycle calls do not provide a meaningful
row denominator.

### `messageDataBuild`

The fixed orchestration order remains:

```text
import chats
import handles
import contacts
  -> contact records
  -> email channels
  -> phone channels
import messages
extract rich text
persist rich text
import attachment metadata
import chat-message relationships
import chat-handle relationships
import message-attachment relationships
project handles
project contacts
project chat-handle relationships
project conversations
project messages
project attachments
project chat-message relationships
project message-attachment relationships
```

All source-row loops publish real start, bounded batch, and exact-final
observations. Contact records and their two channel loops remain distinct
typed substages. Reactions are not a separate import pass: their Apple source
facts remain part of message records and therefore share message progress.

Rich-text decoding is per attributed-body candidate through the existing Rust
extractor boundary. Extraction and persistence are separate typed
observations. The Dart loop yields after each 1,000 completed extractions so a
painted progress surface is not held behind a long CPU loop.

Onboarding imports attachment metadata only. It does not scan, hash, copy, or
archive attachment payload files in this stage. No filesystem byte progress is
therefore claimed.

The graph's existing row observers are reused for conversations, messages, and
attachments. Fast set-based handle, contact, and relationship projectors retain
typed start/completion transitions but no fabricated denominator.

### `durableReadinessVerification`

```text
typed verification substage
  -> canonical read-only source-ledger message count
  -> canonical read-only graph message count
  -> OnboardingInstallationReadyProof
```

This remains a coarse pair of count probes. Its 3-second SQLite busy tolerance
is not an operation timeout or a liveness threshold.

### `automaticRecoveryReset`

This uses the same preservation-safe reset boundary as environment
preparation. It publishes a typed resetting substage and remains coarse.

## Typed Contracts

`SourceImportWorkProgress` owns source-import facts:

- typed source work unit;
- completed work count;
- total work count;
- optional last completed source ROWID.

`ConversationGraphBuildObservation` owns graph-build facts:

- typed suboperation;
- started, progress, or completed kind;
- optional completed/total counts;
- optional source ROWID when supplied by source import.

`OnboardingOperationSubstage` is the durable Onboarding vocabulary. It contains
no display strings. The overlay maps it to current human wording.

## Denominators And Numerators

| Work | Denominator | Completed means |
| --- | --- | --- |
| Chats and handles | Exact loaded source row list | Row processing and its ledger write call completed inside the active transaction |
| Contacts, email channels, phone channels | Exact loaded table row list for each loop | Row was accepted or truthfully examined as non-importable under existing policy |
| Messages and attachments | Exact rows returned after the source-scoped cursor | Ledger insert/ignore processing completed |
| Relationship imports | Exact query result list | Relationship insert/ignore processing completed |
| Rich-text extraction | Exact candidate map size | Rust extraction attempt returned for the candidate |
| Rich-text persistence | Exact candidate list size | Existing text-preservation/update decision completed |
| Graph conversations/messages/attachments | Exact repository query result size | Projector completed the row operation |

Source-loop observations describe completed processing inside the owning
transaction. They are not durable commit evidence. Transaction success and
stage completion remain separate facts.

## Observation And Persistence Cadence

- Source import and rich text: `0 / total`, every 1,000 completed rows, exact
  final total.
- Graph repositories continue their neutral 250-row in-process cadence.
- The ordinary Onboarding composition persists only graph observations at
  1,000-row boundaries and exact final totals.
- A typed substage transition is itself a real observation, including
  `0 / total` at a new enumerable substage.
- Repeating the same substage and progress value returns the identical snapshot
  and causes no write, revision, or liveness advancement.

This bounds overlay writes to semantic transitions and approximately one write
per 1,000 completed rows, not one write per source record.

## Failure Context

Malformed handle and message validation remains fail-closed. The new
`SourceImportRecordException` adds only:

- typed source domain;
- source ROWID when available;
- bounded non-payload validation reason.

It does not carry message text, contact names, raw handles, or attachment
paths. The durable failure retains the last successfully observed substage and
count and cannot remain `running` after the exception.

## First Paint And Responsiveness

First-run and reimport paths continue to publish their workflow state and await
an end-of-frame barrier before expensive reset/build work begins. The new
instrumentation does not delay that first frame.

Sqflite/SQLite operations remain at their existing asynchronous boundaries.
The one newly identified CPU-sensitive Dart loop, rich-text extraction, yields
at the same bounded 1,000-record cadence used for progress. No arbitrary delay
or timer heartbeat was introduced.

## Profiling Evidence

The protected live `chat.db` was not readable from the verification shell, so
this pass does not claim a production initial-import benchmark. Available
evidence is intentionally reported at its actual scope:

| Stage | Suboperation | Representative evidence | Work units | Observation | Boundary | Result |
| --- | --- | --- | --- | --- | --- | --- |
| `messageDataBuild` | Ordinary incremental graph build | Recent app logs: about 126-902 ms; most at or below 606 ms | Varies by new source rows | Now typed throughout | Async DB + Rust boundary | Instrumented without changing topology |
| `messageDataBuild` | Historical 1,001-message fixture, handles | 9-11 ms | Source/graph handles | Typed source; graph completion | SQLite | Graph denominator not justified |
| `messageDataBuild` | Historical 1,001-message fixture, conversations | 5-6 ms | Graph conversations | Existing row observer | SQLite | Reused |
| `messageDataBuild` | Historical 1,001-message fixture, messages | 86-92 ms | Graph messages | Existing row observer | SQLite | Reused |
| `messageDataBuild` | Historical 1,001-message fixture, attachments | 4-6 ms | Graph attachments | Existing row observer | SQLite | Reused |
| `messageDataBuild` | Historical fixture relationships | About 42 ms | Relationship rows | Typed transition | SQLite | Too short for extra denominator work |
| preparation/reset | Derived-store reset | No production bound captured | Small fixed file/store set | Typed coarse substage | Async DB/filesystem | Remains coarse |
| durable verification | Two canonical counts | No production bound captured | Two probes | Typed coarse substage | SQLite read-only | Remains coarse |

No N x M scan, repeated database open, or per-row correlated query was
introduced or discovered in the newly instrumented path. Instrumentation uses
already-loaded exact lists and existing repository callbacks.

## Liveness Contract After This Slice

| Suboperation group | Expected observation | Typical observation interval | Worst measured active interval | Remaining gap | Future threshold defensible? |
| --- | --- | --- | --- | --- | --- |
| Source chats/handles/contacts/messages/attachments/relationships | Start, each 1,000, exact final | Workload-dependent; subsecond in small fixtures | No production initial-import maximum measured | A single slow SQLite row call can remain between batches | No |
| Rich-text extraction/persistence | Start, each 1,000, exact final | Workload-dependent | No production maximum measured | One malformed/slow attributed body can occupy an interval | No |
| Graph conversations/messages/attachments | Start, each 1,000, exact final, completed | Subsecond in 1,001-message fixture | 92 ms in available fixture evidence | Production maximum absent | Not yet |
| Graph handles/contacts/relationships | Typed start/completed | 5-42 ms in available fixture evidence | 42 ms in available fixture evidence | Set-based calls remain coarse | No threshold needed at current evidence scale |
| Environment preparation/reset | Typed substage, then stage transition/failure | Unknown | Unknown | Coarse store/filesystem lifecycle | No |
| Durable readiness verification | Typed substage, then completion/failure | Unknown | Unknown | Coarse count probes | No |

Real progress now makes `messageDataBuild` substantially observable, but no
stall threshold is yet justified. Production-sized maximum no-observation
measurements and a trustworthy macOS execution-opportunity/sleep adapter are
still absent. Prompt 05 should profile a controlled production-shaped initial
import before deciding whether any subset can support stall inference.

## Verification

- 85 focused source import, graph, snapshot, Gate, and progress presentation
  tests cover start/final cadence, handles, unusual handles, malformed handles
  and messages, attachments, rich text, graph observations, snapshot
  round-trip, same-value deduplication, failure retention, and determinate
  rendering.
- Architecture tripwires require typed service-owned progress contracts,
  forbid Flutter/Riverpod in those contracts, forbid timer-driven progress,
  and prevent presentation from consuming source/graph observation types.
- All 382 architecture tripwires and all 2,002 Flutter tests pass.
- `flutter analyze` reports no issues, formatting and `git diff --check` are
  clean, and the macOS debug app builds successfully.
