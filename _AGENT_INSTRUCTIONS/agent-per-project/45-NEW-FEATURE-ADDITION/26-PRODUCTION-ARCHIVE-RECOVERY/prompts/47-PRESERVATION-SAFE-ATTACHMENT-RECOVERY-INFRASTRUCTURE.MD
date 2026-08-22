Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation.

The previous task established the dormant read-only attachment-matching layer for future MessageLens attachment recovery.

This task implements the next bounded layer:

> preservation-safe attachment installation infrastructure plus the read-only donor/current evidence adapters required to feed it.

Do NOT enable the MessageLens Historical Archives segment yet.

Do NOT build the final recovery UI yet.

Do NOT perform real recovery against production, staging, donor, or archived attachment payloads.

Suggested prompt name:

`prompts/47-PRESERVATION-SAFE-ATTACHMENT-RECOVERY-INFRASTRUCTURE.MD`

## Context

The attachment-recovery audit established this matching chain:

```text
same-Messages-lineage admission
→ original message ROWID + matching message GUID
→ exact message/attachment ROWID relationship
→ noncontradictory attachment GUID
→ verified donor payload
→ recoverable attachment candidate.
```

Attachment IDs use the same reversible `SourceScopedRowKey` mechanism as messages.

Filenames, paths, MIME types, and display labels have no identity authority.

Current dormant classification includes:

- recoverable;
- already present;
- donor missing;
- message mismatch;
- attachment mismatch;
- conflict;
- ambiguous;
- unsafe donor path.

Preflight can expose exact recoverable counts and byte totals.

No donor messages, graph data, source registries, or overlays are imported as historical content.

Recovery will require:

- filesystem mutation;
- overlay/attachment-location metadata mutation where current architecture requires it.

It will NOT require:

- message import;
- import-ledger mutation;
- graph mutation;
- graph rebuild.

The remaining infrastructure blocker identified by the audit is:

> the existing attachment writer needs a safe temporary-file → verification → no-overwrite atomic installation path, plus read-only donor/current database evidence adapters.

That is this task.

## Read first

Read:

- `47-MESSAGELENS-ATTACHMENT-MATCHING-AND-PRESERVATION-SAFE-RECOVERY.md`;
- canonical attachment storage/writer code;
- attachment archive ownership documentation;
- current attachment overlay/location metadata;
- current attachment import/archiving services;
- current donor inspection implementation;
- current source-scoping and Messages-lineage admission;
- mutation authority documentation;
- Feature 26 architecture/conformance records relevant to attachment ownership.

Before editing, document the current attachment write path and identify exactly which existing components own:

- canonical destination path;
- payload presence checks;
- file copy/write;
- metadata registration;
- overlay/location mutation;
- integrity verification.

Do not introduce a second attachment-storage authority.

# Goal

Create a reusable attachment installation primitive with this contract:

> Given an already-proven recovery candidate and a read-only donor payload, install the payload into current MessageLens attachment storage without overwriting an existing valid payload, without exposing partial files, and without mutating donor data.

The operation should be safe to retry.

# Preservation-safe installation semantics

The desired sequence is conceptually:

1. validate recovery candidate again at execution boundary;
2. resolve canonical destination through current attachment-storage authority;
3. confirm destination is still missing;
4. open donor payload read-only;
5. copy donor payload to a temporary file inside the destination filesystem/atomic-rename domain;
6. flush/close as appropriate;
7. verify copied temp payload against available trusted metadata;
8. atomically install using no-overwrite semantics;
9. update required current attachment metadata/overlay only after successful installation;
10. verify resulting current payload;
11. report success.

Do not blindly implement this exact sequence if current storage architecture provides a better equivalent primitive.

The important invariants are:

- no partial destination file;
- no overwrite of existing valid payload;
- donor never modified;
- metadata does not claim success before payload installation succeeds;
- retry is safe.

# Atomicity

Investigate what filesystem primitive is available on supported macOS/Dart stack for atomic installation.

Prefer:

- temp file created in destination directory/filesystem;
- verification;
- atomic rename/move/link with no-overwrite semantics.

Be careful:

a normal rename can overwrite an existing destination depending on API/platform behavior.

Do not assume no-overwrite behavior without proving it.

If the standard Dart API cannot provide an atomic no-overwrite install, determine the narrowest correct implementation using existing native/platform utilities or a safe equivalent.

Do not implement a race-prone:

`if (!exists) copy`

sequence and call it safe.

The destination may become populated between check and install.

# Existing destination behavior

At execution time, recheck destination truth.

If destination now exists:

## Existing valid payload

Classify as:

`alreadyPresent`

and perform no overwrite.

This should be a successful/idempotent no-op from the recovery-operation perspective.

## Existing conflicting payload

Do not overwrite.

Return explicit conflict.

Do not delete the current file.

# Temporary files

Use a bounded, recognizable temporary-file convention owned by the attachment writer.

Requirements:

- temp file resides in a location allowing atomic final installation;
- name cannot collide with final payload;
- abandoned temp files are detectable/cleanable;
- temp file is never treated as a valid attachment payload;
- cleanup occurs after copy/verification failure.

Do not scatter random temp-file naming in the recovery workflow.

# Crash/interruption safety

Audit behavior if the process dies:

- midway through donor copy;
- after temp verification;
- immediately before final install;
- after install but before metadata update;
- after metadata update.

Design recovery so rerunning inspection can safely converge.

Ideally:

payload installed but metadata update missed
→ current preflight recognizes physical payload and reconciles through existing attachment truth.

If current architecture cannot safely reconcile this state, report the exact gap.

Do not add a durable recovery journal unless genuinely required.

# Payload verification

Reuse the strongest existing metadata supported by Response 47.

Potential evidence may include:

- expected byte size;
- stored hash;
- attachment GUID relationship;
- canonical metadata.

Do not invent hashing schemas.

If a trusted donor hash exists:

- verify temp payload against it.

If only byte size exists:

- verify size;
- document weaker integrity semantics.

If current attachment storage already computes canonical hashes, reuse it.

Do not duplicate checksum logic.

# Donor path safety

Preserve all existing read-only matching-layer rules:

- no absolute donor paths where prohibited;
- no traversal;
- no symlink escape;
- donor candidate remains within selected archive root;
- no unsafe path resolution.

The writer should consume an already-validated donor payload reference rather than re-parsing arbitrary donor path strings.

# Canonical destination

Do not build destination filenames/paths in Historical Archives.

Attachment storage owns destination identity.

If current attachment writer already maps attachment metadata to canonical path:

reuse it.

If overlay metadata controls the canonical current location:

use the established overlay/storage service.

No recovery-specific private path algorithm.

# Overlay/location metadata mutation

Audit exactly what database/overlay mutation is required after payload installation.

Determine whether recovery must:

- register canonical archived path;
- mark payload as archived/present;
- update an existing location field;
- create overlay metadata;
- perform no DB write at all.

Implement only the minimum current-authoritative mutation.

Do not copy donor overlay records.

The donor overlay is evidence only if needed for locating donor payload.

Current metadata is updated using current ownership rules.

# Ordering of filesystem and metadata mutation

Prefer:

```text
payload successfully installed
→ then metadata updated.
```

Do not publish metadata pointing to a file that does not yet exist.

If metadata update fails after successful file installation:

- preserve the installed file if it is valid;
- return a partial/recoverable result;
- ensure retry can reconcile rather than duplicating/overwriting.

Define typed outcome semantics.

# Typed installation result

Create/reuse a typed result with clear outcomes such as conceptually:

- installed;
- alreadyPresent;
- conflict;
- donorMissing;
- donorChanged;
- verificationFailed;
- unsafeSource;
- metadataUpdateFailed.

Use actual repository naming conventions.

Do not reduce everything to bool/exception.

Exceptions remain appropriate for unexpected infrastructure failures; expected recovery classifications should be typed.

# Read-only donor evidence adapter

Response 47 identified the need for concrete read-only donor/current database adapters.

Implement the donor adapter needed to feed existing matcher/preflight from an archived MessageLens folder.

Requirements:

- donor databases opened read-only/immutable using established source-opening architecture;
- no schema migration;
- no WAL/SHM mutation where avoidable;
- no archive-marker mutation;
- support only fields actually needed for attachment matching;
- fail closed on unsupported schema/compatibility.

Do not expose donor Drift databases as writable repositories.

# Current evidence adapter

Implement the current-side adapter through existing authoritative stores.

It must provide the matcher with:

- current message identity;
- current attachment relationship/identity;
- payload-presence truth;
- canonical destination/storage evidence.

Do not query `chat.db` or current working stores through new ad-hoc connections.

Reuse canonical providers/repositories.

# Schema compatibility

The real target is an older archived MessageLens data folder.

Audit which schema version(s) the March archive may contain.

The donor adapter must not migrate the archive in place.

If current generated Drift code cannot safely read older schemas read-only:

- add a narrowly scoped compatibility reader using explicit SQL/read-only access;
- do not mutate donor;
- document supported versions.

If compatibility cannot be achieved without schema-specific adapters, implement only the bounded versions required by current known archive lineage and document limitations.

# Mutation authority

Determine the correct `ArchiveMutationCoordinator` operation for future actual attachment recovery.

Do NOT broaden coordinator semantics casually.

For dormant writer tests, use isolated temp storage.

If actual payload installation infrastructure itself needs an authority/capability contract, introduce the narrowest typed seam needed so future UI cannot call the writer outside an admitted recovery operation.

Do not enable the operation from UI.

# Concurrency

Audit races with:

- live attachment archiving;
- another recovery;
- cleanup;
- user accessing payload;
- background attachment indexing.

The writer must not overwrite a concurrently created payload.

No-overwrite final installation is the key invariant.

If canonical attachment storage already has locking/serialization, participate in it.

Do not create an unrelated mutex if a stronger owner already exists.

# Idempotency

This should be a first-class invariant.

Running the same recovery candidate twice should result in:

first run:
`installed`

second run:
`alreadyPresent`

with no duplicate files and no destructive changes.

Test this.

# Batch recovery service — dormant only

If the single-file primitive is cleanly established, you MAY create a dormant batch executor operating on a previously computed list of proven `recoverable` candidates.

It may expose:

- total candidate count;
- completed count;
- bytes copied;
- typed per-item results.

Do not connect to UI.

Do not perform real archive recovery.

The batch executor should process one attachment at a time or in a bounded safe concurrency model consistent with storage ownership.

Do not maximize throughput at the expense of atomicity or clear failure semantics.

# Progress

Future recovery has natural real denominators:

- N proven recoverable attachments;
- total recoverable bytes where known.

If a dormant batch executor is added, expose typed observations such as:

- current completed attachments / total;
- bytes copied / total bytes;
- current attachment identifier only for diagnostics.

Do not build progress widgets.

# Failure policy for batch execution

One failed attachment should not necessarily invalidate successfully installed earlier attachments.

Design/report whether batch semantics are:

- continue and summarize failures;
- stop on unsafe systemic failure;
- another bounded policy.

Prefer:

expected per-file recovery conflicts/errors
→ classify and continue

infrastructure/invariant violation
→ stop.

Do not silently swallow failures.

# Graph/import invariants

Prove again:

attachment payload recovery does NOT:

- import donor messages;
- write import ledger;
- mutate conversation graph;
- rebuild graph;
- alter message provenance;
- change source-scoped IDs.

Add tripwires if useful.

# Persistent recovery-source semantics

Do NOT implement final cartouche/source persistence.

However, determine whether the dormant executor needs donor identity for audit.

If needed, carry:

- donor `archiveInstanceId`;
- selected donor locator;
- same-lineage admission token/evidence;

as operation context only.

Do not add schema.

# UI remains disabled

The MessageLens segmented control remains disabled.

No chooser.

No ready state.

No Recover button.

No new cartouche.

No production call path to the writer.

Dormant/test-only infrastructure only.

# Untracked duplicate prompt

An untracked `46b-...` prompt was reported as byte-identical to Prompt 46.

If it remains present and is genuinely byte-identical/redundant, remove the untracked duplicate as housekeeping.

Do not modify any non-identical or user-authored prompt without proving equivalence.

# Tests

Add/update focused tests covering at minimum:

## Atomic installation

1. valid donor payload installs successfully;

2. final destination is never partially visible;

3. temp file is removed after success;

4. temp file is removed after copy failure;

5. verification failure leaves no final destination;

6. existing valid destination is not overwritten;

7. destination appearing concurrently cannot be overwritten;

8. conflicting existing destination returns conflict;

9. second identical recovery becomes alreadyPresent.

## Verification

10. size mismatch rejects;

11. hash mismatch rejects where hash exists;

12. verified payload passes;

13. donor payload changing between preflight/execution fails closed.

## Path safety

14. traversal rejected;

15. absolute unsafe path rejected;

16. symlink escape rejected;

17. writer accepts only validated donor references.

## Metadata

18. metadata update occurs only after payload installation;

19. metadata failure cannot produce false overall success;

20. retry can reconcile installed payload after metadata failure.

## Read-only adapters

21. donor DB opens read-only;

22. donor inspection performs no migration;

23. unsupported schema fails closed;

24. current evidence uses canonical repositories/providers;

25. no ad-hoc current database constructor added.

## Idempotency/batch

26. repeated batch does not duplicate payloads;

27. completed count reflects real successful/already-present processing;

28. byte progress uses real bytes;

29. expected per-item failure semantics are preserved.

## Architecture

30. no message import;

31. no import-ledger mutation;

32. no graph mutation/rebuild;

33. no donor overlay merge;

34. shared lineage proof remains required upstream;

35. D1/D2/D3 remain intact;

36. Mac Messages arm unchanged.

Do not mechanically create one test method for every item.

# Documentation

Create the next Feature 26 implementation/audit record under `responses/`.

Document:

- existing attachment writer shortcomings;
- final atomic/no-overwrite installation primitive;
- temp-file strategy;
- verification strategy;
- crash/interruption semantics;
- metadata mutation ordering;
- read-only donor adapter;
- current evidence adapter;
- compatibility support;
- idempotency;
- concurrency;
- batch semantics if implemented;
- typed outcomes;
- progress observations;
- explicit confirmation that infrastructure remains dormant.

Update canonical attachment-storage guidance where appropriate so future agents do not bypass the preservation-safe writer.

Add an architecture rule similar to:

> Historical attachment recovery must install payloads only through the canonical preservation-safe attachment writer. Do not copy directly into managed attachment storage.

Update version/changelog according to repository rules if application code changes.

# Verification

Run:

- attachment writer tests;
- donor/current adapter tests;
- attachment matcher/preflight tests;
- lineage tests;
- Historical Archives regressions;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

No real recovery.

No real archive mutation.

# Stop conditions

STOP if:

- atomic no-overwrite installation cannot be guaranteed on supported storage;
- metadata update semantics require schema changes;
- donor compatibility requires in-place migration;
- canonical destination ownership is unclear/conflicted;
- current attachment architecture cannot reconcile payload-installed/metadata-failed state safely;
- mutation authority must be redesigned broadly.

Do not implement a race-prone fallback.

# Final report

Report:

- canonical attachment writer reused/changed;
- exact atomic installation mechanism;
- no-overwrite guarantee;
- temp-file strategy;
- verification evidence;
- metadata mutation required;
- crash/retry semantics;
- donor adapter;
- current evidence adapter;
- supported donor schema versions;
- batch executor/typed progress if implemented;
- concurrency behavior;
- duplicate prompt cleanup;
- tests/tripwires;
- unresolved blockers;
- confirmation that actual attachment recovery can now be safely wired into the MessageLens Historical Archives arm.

Acceptance standard:

> Once a donor attachment has been proven recoverable, MessageLens must be able to install its payload into current managed storage atomically, without overwriting valid data, without exposing partial files, without mutating the donor, and in a way that naturally converges under retry.
