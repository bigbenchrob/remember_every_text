---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: implementation-record
---

# MessageLens Attachment Preflight Performance And Observability

## Outcome

The MessageLens-folder attachment preflight is now visible before expensive
work begins, performs no payload hashing, uses bounded database and filesystem
passes, and publishes typed completed-work progress. No attachment recovery or
archive mutation was added.

The manual symptom was an unchanged spinner for more than five minutes after
folder selection. A controlled read-only profile against the representative
33,399-payload, 39.99 GB donor established a comparable instrumented baseline
of **210.505 seconds** after the original hash loop had been identified. The
same controlled profile after the corrections completed in **7.455 seconds**.

The original manual run exceeded five minutes because preflight recomputed
SHA-256 over approximately 40 GB in addition to the costs measured below. Its
exact end-to-end duration is unknown because it was stopped during observation.

## Chooser To First Paint

Previously the workflow published inspecting state and immediately began
resolving preflight dependencies. Donor SQLite work was also performed by
methods marked asynchronous while their `sqlite3` calls remained synchronous
on the UI isolate. Flutter therefore had no guaranteed opportunity to paint
the truthful inspecting state before qualification began.

The corrected sequence is:

```text
folder chooser returns
    -> publish typed MessageLens inspecting state
    -> await SchedulerBinding.endOfFrame
    -> prove the same session/occurrence still owns the work
    -> resolve preflight
    -> run donor SQLite reads in worker isolates
```

The barrier is a rendering boundary, not an arbitrary delay. Rebuilds do not
start preflight; only the workflow command does.

## Profile Findings

The first controlled profile used the real donor and a deterministic empty
current-side adapter so donor costs could be compared exactly before and after.

| Phase | Before | After |
|---|---:|---:|
| Structural qualification | 66 ms | 374 ms |
| Compatibility inspection | 118,258 ms | 91 ms |
| Lineage admission fixture | 0 ms | 0 ms |
| Donor relationship evidence (39,381) | 2,616 ms | 2,788 ms |
| Current relationship fixture | 0 ms | 0 ms |
| Donor payload records (33,399) | 70 ms | 832 ms |
| Indexed relationship matching | 37 ms | 49 ms |
| Current payload fixture | 15 ms | 20 ms |
| Donor payload presence (33,393 matched claims) | 89,393 ms | 3,239 ms |
| Classification and totals | 30 ms | 37 ms |
| **Total** | **210,505 ms** | **7,455 ms** |

The small phase variations reflect external-disk cache state. The material
changes are compatibility inspection and payload presence.

## Pathologies Corrected

### Mutation-time integrity work during preflight

Compatibility inspection ran both `PRAGMA quick_check` and
`PRAGMA integrity_check` over donor databases on every folder selection. A
standalone immutable timing showed `quick_check` alone required 89.61 seconds
for the 136 MB import ledger on the external disk.

Preflight now validates the exact schema and evidence it reads. Exhaustive
database integrity validation remains available through
`validateExecutionIntegrity()` and belongs immediately before a future
recovery execution. That future execution must also reread exact relationship
evidence. No mutation exists in this slice, so exhaustive validation has not
been bypassed by any writer.

### Full payload hashing during preflight

Every donor claim previously called the verified-payload path and streamed its
complete file through SHA-256. The representative donor records 39,993,228,039
payload bytes. Preflight now trusts the admitted donor's stored hash for
candidate comparison and checks path safety, regular-file presence, and exact
size only.

`inspectVerified()` is unchanged. It recomputes SHA-256 and produces the
read-only payload capability immediately before preservation-safe
installation. Integrity proof is relocated, not removed.

### Repeated filesystem probes

The old loop repeatedly checked the archive root, shard directories, final
path, and size for every claim. The replacement performs one non-following,
symlink-aware traversal of `attachment_archive/`, stats each claimed regular
file once, and classifies missing and unsafe paths fail-closed.

### Repeated current-store reads

Current payload status previously performed one overlay lookup per claim.
Current archive metadata is now read in one snapshot, then its physical files
are inspected through the same bounded inventory mechanism. Relationship
queries project only columns required to construct identity evidence.

### Main-isolate database work

Donor format, relationship, and payload-record reads now open, use, and close
their read-only SQLite connections wholly inside worker isolates. Database
objects are never transferred between isolates.

## Matching Complexity

The service constructs indexed maps for donor archive keys and current
message/attachment row pairs, then performs one pass over payload claims.
Matching is O(N) in the evidence collections. No N-by-M scan or query-inside-
claim loop remains.

## Directed Instrumentation

The final rows are derived from measured implementation boundaries:

- `Verifying this MessageLens folder`
- `Reading attachment records`
- `Matching attachments`
- `Checking current attachment files`
- `Checking donor attachment files`
- `Calculating recovery summary`

Enumerable phases display raw completed/total counts. Relationship matching
publishes every 1,000 claims. Current and donor payload checks publish in
approximately 250-claim completed-work batches. Progress has no timer.

After lineage admission, Narrator changes from checking the selected folder to:

> This folder matches your Messages history. Now I’m checking which
> attachments are missing here.

The existing ready and zero-result presentations remain unchanged.

## Session And Cancellation

The workflow passes its presentation session and inspection occurrence as the
ownership check. Navigation or a newer selection invalidates that check.
Qualification boundaries, matching batches, and filesystem traversal observe
cancellation. A cancelled preflight returns the typed `Cancelled` result and
cannot resurrect abandoned Historical Archives state.

## Safety Invariants

- Donor and current evidence remain read-only during preflight.
- No source registration, schema, persistence, archive payload, or recovery
  mutation changed.
- Same-Messages lineage admission remains mandatory.
- Exact per-message/per-attachment matching remains fail-closed.
- Full database integrity and payload SHA-256 verification remain mandatory at
  the future execution boundary.
- Mac Messages Historical Archives behavior and Tracks A-I are unchanged.

## Verification

Focused tests cover:

- one current metadata snapshot rather than per-claim overlay reads;
- 250-item filesystem progress batches;
- preflight size classification without payload hashing;
- execution-time rejection of a same-size hash mismatch;
- phase ordering and bounded numerators;
- typed cancellation;
- inspection state painting before preflight resolution;
- real numerator/denominator projection;
- one explicit preflight per selected occurrence;
- read-only donor behavior and execution-integrity availability;
- architecture tripwires prohibiting timers, preflight hashing, mutation, and
  execution-integrity scans during preflight.

The controlled profile is intentionally not a CI wall-clock assertion. It used
the real external donor read-only and a deterministic current-side fixture.
Manual app retesting should therefore confirm full current-side timing and
first-paint perception on the active development archive.

Final automated verification on 2026-08-22:

- focused attachment, lineage, Historical Archives lifecycle, and architecture
  coverage: 128 tests passed;
- complete Flutter suite: 1,932 tests passed;
- `flutter analyze`: no issues;
- `flutter build macos --debug`: succeeded;
- `git diff --check`: clean.

The debug build retained the existing Xcode empty-build-number diagnostic and
the existing `volume_controller` privacy-manifest processing warning. Neither
warning was introduced by this slice.
