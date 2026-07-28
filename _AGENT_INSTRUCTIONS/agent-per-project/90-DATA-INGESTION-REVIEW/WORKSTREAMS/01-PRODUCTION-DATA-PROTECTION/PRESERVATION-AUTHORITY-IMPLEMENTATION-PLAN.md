# Production Preservation Authority Implementation Plan

Status: Candidate and adoption preparation complete; real production cutover
not authorized

This plan turns
[`PRODUCTION-PRESERVATION-AUTHORITY.md`](PRODUCTION-PRESERVATION-AUTHORITY.md)
into an implementation sequence. It does not authorize production archive
adoption, production launch, or mutation.

## Objective

Make the following invariant mechanically enforceable and objectively
observable:

> Exactly one production archive identity is designated as the Production
> Preservation Authority. At most one admitted process may exercise that
> authority, and fresh durable evidence demonstrates that newly arriving data
> is being preserved.

Archive admission continues to answer where a process may operate.
Preservation authority answers which admitted production process is responsible
for live preservation.

## Ownership

### Archive environment

Owns:

- qualification of an admitted production archive identity;
- explicit preservation-role assignment to that identity;
- proof that the native process lock was acquired before Dart receives the
  admitted claim;
- fail-closed rejection of non-production or mismatched identities.

### Conversation graph monitor

Owns:

- live Messages source probes;
- observed source cursor;
- committed import cursor;
- incremental-import outcomes;
- source-probe and import failures.

It reports typed facts. It does not own preservation-role assignment or
operational-health policy.

### Attachments

Owns:

- attachment candidate selection;
- preservation execution;
- archived, skipped, and failed outcomes;
- attachment-preservation failures.

It reports typed outcomes. It does not decide whether the process is the
production preservation authority.

### Production preservation

A focused essential aggregates admitted identity and typed monitor/archive
facts into one durable evidence snapshot. It owns:

- heartbeat freshness;
- evidence serialization and atomic replacement;
- current health derivation;
- read-only status inspection.

It does not own graph import or attachment business logic.

### Application bootstrap

Activates preservation evidence only after archive admission. Development and
test processes may preserve their own redundant archives but cannot publish
production-authority evidence.

## Durable Evidence

The authority writes one structured, archive-scoped evidence record through the
admitted root. The record contains:

- format version;
- production `ArchiveInstanceId`;
- application and build identity;
- process launch identity;
- last heartbeat timestamp;
- heartbeat freshness threshold;
- latest successful source probe and observed source cursor;
- latest committed source cursor;
- latest successful incremental import;
- latest attachment-preservation pass;
- candidate, archived, skipped, and failed counts;
- latest blocking failure, if any.

The writer uses atomic replacement. A stale file remains historical evidence;
it never proves current liveness.

Operational state does not belong in overlay storage because it is not user
intent. It does not belong in the Conversation graph because it is not a source
projection.

## Freshness

Initial implementation constants:

```text
heartbeat interval: 30 seconds
heartbeat freshness threshold: 90 seconds
source polling interval: existing 15 seconds
attachment maintenance interval: existing 5 minutes
```

The heartbeat proves that the admitted authority loop is responsive. The source
probe proves access to the live source. The preservation-pass record proves the
attachment pipeline has executed. These facts remain distinct.

A successful attachment pass with zero candidates is healthy evidence.

## Mechanical Exclusivity

Production authority requires all of:

1. admitted `ArchiveEnvironment.production`;
2. production build and application identity;
3. adopted production `ArchiveInstanceId`;
4. explicit preservation-role assignment to that archive identity;
5. native same-root process-lock ownership.

Native bootstrap exposes a claim to Dart only after the root-scoped lock has
been acquired. The preservation controller therefore cannot start merely
because another process has production-like configuration.

The existing process-local archive mutation coordinator remains responsible for
serializing mutations inside the admitted process. It is not the
cross-process preservation authority.

## Implementation Slices

### Slice P0 - Admission evidence

- record that Debug/Run has already been separated from production;
- record that no process currently preserves newly arriving production data;
- keep all preparation isolated from the real production archive;
- explicitly reject the months-old installed application as an automatic
  preservation successor;
- expedite the current signed successor and adoption runbook without weakening
  admission.

Exit: the revised operational state is explicit and preparation cannot be
mistaken for restored preservation.

### Slice P1 - Pure authority and evidence domain

- add immutable preservation assignment, evidence, operation-outcome, and
  health models;
- add freshness evaluation;
- add codecs and malformed/stale-evidence rejection tests;
- activate nothing.

Exit: domain rules are proven without filesystem or production contact.

### Slice P2 - Archive-scoped evidence store

- add an admitted-root evidence store;
- use atomic write/replace and reject symlink targets;
- add temporary-root tests for success, stale evidence, partial-write
  resistance, and identity mismatch;
- add a read-only inspection seam.

Exit: durable evidence works on disposable archives.

### Slice P3 - Runtime controller

- start only after admission;
- qualify production authority mechanically;
- publish heartbeat evidence;
- accept typed source-probe, import, and attachment outcomes;
- persist failures without converting them into healthy heartbeats;
- keep development evidence explicitly non-authoritative.

Exit: disposable production-clone tests prove lifecycle and freshness.

### Slice P4 - Monitor and attachment integration

- report every successful source probe, including no-change probes;
- report observed and committed cursors;
- report incremental-import completion;
- report every source-range and maintenance preservation pass;
- report blocking failures;
- preserve existing feature ownership.

Exit: a production-clone harness demonstrates the complete evidence chain.

### Slice P5 - Status and operational tooling

- add a read-only command that reports assignment, freshness, cursors, latest
  preservation outcome, and failures;
- include the same evidence in support bundles;
- do not make Production Health the owner of the guarantee.

Exit: the slice-admission check is objective and repeatable.

### Slice P6 - Production adoption and handoff

This remains part of the separately authorized production-adoption operation.

- stage a current signed and verified production artifact without contacting
  the production archive;
- create and verify the production checkpoint without moving or rewriting the
  production archive;
- perform one short, controlled cutover in which the offline archive identity
  is adopted atomically and the staged successor starts;
- verify archive identity, Full Disk Access, startup catch-up, source progress,
  and attachment preservation before declaring the handoff complete;
- retain the old installed artifact and a documented operational rollback path
  until the successor is proven;
- retain rollback and handoff evidence.

Exit: the adopted production application is the mechanically admitted
preservation authority.

## Test Strategy

Focused tests must prove:

- development and test can never qualify as production authority;
- a mismatched archive identity cannot publish authority evidence;
- stale heartbeat is unhealthy even when a PID or old evidence file exists;
- no-change source probes update probe evidence truthfully;
- zero-candidate attachment passes count as successful preservation evidence;
- failures remain visible and make health fail closed;
- evidence writes are atomic and archive-scoped;
- the native root lock prevents two admitted same-root authorities;
- operation coordination and preservation authority remain separate;
- support/read-only tooling does not mutate the archive.

Production validation occurs only during the authorized adoption/handoff slice.

## Continuity Rule For Every Slice

Each implementation report must state:

- whether production preservation is active or interrupted;
- the adopted production archive identity and exercising process, if one
  exists;
- evidence timestamps and freshness result when authority exists;
- why preparation cannot contact or mutate production while authority is
  absent;
- whether a handoff is required.

Until adoption completes, the truthful statement is that preservation is
interrupted. No provisional process should be invented to satisfy this form.

If any answer is missing or evidence becomes stale, work stops before further
code changes.
