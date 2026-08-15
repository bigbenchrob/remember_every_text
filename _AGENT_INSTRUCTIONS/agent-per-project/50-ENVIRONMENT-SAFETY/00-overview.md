---
tier: project
scope: environment-safety
owner: agent-per-project
last_reviewed: 2026-07-27
source_of_truth: doc
links:
  - ../90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
tests: []
---

# Environment Safety

This section defines mandatory operational safety procedures for working with
MessageLens application data. The rules apply to human- and agent-initiated
mutations.

## Canonical Authority Chain

Every app-owned persistent path follows:

```text
native build/process claim
  -> archive marker admission
  -> ArchiveAccessAuthority
  -> environment-scoped persistent providers
  -> ArchiveMutationCoordinator for protected mutations
  -> verified checkpoint evidence when production risk requires it
```

Debug and Profile use:

```text
com.bigbenchsoftware.MessageLens.development
MessageLens Development
~/Library/Application Support/com.bigbenchsoftware.MessageLens.development/
```

The Application Support path is the default development root. A machine may
configure the development-only environment variable
`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` with an existing absolute directory.
When present, native process admission and Dart archive admission independently
canonicalize that directory and must agree on the exact result before any
persistent provider is constructed.

On the primary development machine the ignored editor launch configuration
currently selects:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/
```

This override relocates the complete development archive. Databases,
attachments, logs, operational evidence, marker, and archive-scoped lock all
continue to derive from one admitted root. There is no attachment-specific
path authority. If the external volume or configured directory is absent,
invalid, or not writable, startup fails closed with an archive-admission error;
it never falls back to the internal development root or production.

The former internal development archive is intentionally preserved unchanged
at its default Application Support path. Configuring the override does not
copy, migrate, merge, or delete that archive.

Production retains:

```text
com.bigbenchsoftware.MessageLens
MessageLens
~/Library/Application Support/com.bigbenchsoftware.MessageLens/
```

Tests have no default Application Support root. They must inject a registered
temporary or in-memory archive.

Persistent providers fail closed before archive admission. A development or
test identity cannot accept a production marker or canonical production root.
The machine-local override is rejected by production and test identities.
Apple Messages and Contacts sources remain separate read-only inputs; access to
them never grants authority over an app-owned archive.

## Mutation And Recovery

Protected import, graph, onboarding, reset, historical-archive, attachment, and
maintenance workflows enter one reentrant archive-scoped mutation
coordinator. `DbMaintenanceLock` is a derived readiness/UI signal, not a second
authority.

High-risk production operations require a verified checkpoint receipt tied to
the same archive identity. Checkpoints are offline, complete inventories with
hashes and SQLite integrity evidence. Restore verification always targets a new
disposable root; the checkpoint tool refuses to overwrite an existing archive.

## Production Status

The non-production boundary is implemented. The existing production archive
has not been marked or adopted. Do not create its marker, launch an incomplete
production workflow, or treat it as a test fixture.

Production adoption is separately gated by:

[`90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-ADOPTION-RUNBOOK.md`](../90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-ADOPTION-RUNBOOK.md).

The snapshot, recovery, and experimental protocols in this folder remain
mandatory operational guidance. Structural protection reduces reliance on
memory; it does not authorize unreviewed production work.
