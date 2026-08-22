Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation.

The MessageLens Historical Archives arm now has:

- supported legacy/current donor qualification;
- shared same-Messages-lineage admission;
- exact per-message/per-attachment identity matching;
- exact recoverable count/byte preflight;
- preservation-safe single-payload installer;
- atomic no-overwrite installation;
- metadata-after-payload ordering;
- exact-scope `attachmentReconciliation` mutation capability;
- immediate first paint;
- performant O(N) preflight with real Directed Instrumentation;
- forensic validation that the current real donor correctly yields zero recoverable payloads.

The next task is to implement the **actual batch recovery executor and Historical Archives recovery journey**, and to prepare a controlled-loss manual validation procedure.

Do NOT mutate the user’s real archives yourself.

Suggested prompt name:

`prompts/55-BATCH-ATTACHMENT-RECOVERY-AND-CONTROLLED-LOSS-END-TO-END-VALIDATION.MD`

# Product scope

The MessageLens arm has one operation:

> Recover missing attachment payloads from an older same-lineage MessageLens data folder.

It must never:

- import donor messages;
- import donor graph/search data;
- import donor overlays;
- change message provenance;
- rebuild the conversation graph merely for attachment recovery.

The donor remains read-only.

The receiving MessageLens archive gains only missing attachment payloads plus the minimum current-owned attachment metadata needed to recognize them.

# Current validated preflight behavior

The real donor currently yields:

- donor claims: 33,399;
- already present: 33,392;
- ambiguous: 6;
- conflict: 1;
- recoverable: 0.

Physical inventory confirms every donor managed payload path already exists in the current development archive.

This is expected because the development archive was cloned from the working archive and has remained synchronized with it.

Therefore actual recovery must be validated using a deliberately created **controlled-loss condition** in a disposable receiving archive.

# Part 1 — batch recovery executor

Implement a canonical batch executor above the existing preservation-safe single-candidate installer.

The batch executor accepts only:

- a same-lineage-admitted donor;
- a completed typed recovery preflight;
- the exact list/set of `recoverable` candidates produced by that preflight;
- a valid exact-scope `attachmentReconciliation` capability.

It must not rediscover candidates from arbitrary paths or raw metadata.

# Batch semantics

For each preflight-approved candidate:

1. revalidate candidate at execution boundary;
2. verify donor payload with the full execution-time integrity proof, including SHA-256 where available/required;
3. resolve canonical current destination through attachment-storage authority;
4. install through the existing preservation-safe installer;
5. update current-owned metadata only after payload installation;
6. verify final installed state;
7. publish typed outcome/progress;
8. continue according to bounded failure policy.

Do not bypass the canonical single-payload installer.

# Real execution-time hashing

Prompt 53 correctly moved expensive SHA-256 work out of preflight.

Recovery execution is where full payload integrity verification belongs.

For each payload actually being recovered:

- stream hash calculation;
- do not load multi-GB files entirely into memory;
- expose real byte progress if available without compromising performance.

Do not hash already-present files merely because they were in the original donor population.

# Batch progress

Recovery has natural exact denominators.

Expose typed progress suitable for Directed Instrumentation.

At minimum:

`Recovered attachments      412 / 1,842`

Also expose real bytes if known and useful:

`Copied data                8.4 GB / 19.2 GB`

Use exact bytes actually processed/copied.

Do not estimate time remaining.

Do not advance progress from timers.

Progress should update often enough to feel alive but not per byte/row if that harms performance.

Use existing batching conventions.

# Per-item outcome semantics

Preserve typed outcomes from the installer.

At batch level classify at least:

- installed;
- alreadyPresent;
- conflict;
- donorMissing/donorChanged;
- verificationFailed;
- metadataUpdateFailed;
- another unexpected systemic failure.

Expected per-item failures should generally not erase earlier successful recoveries.

Design the policy:

### Expected item-level issue

Record/classify and continue.

### Systemic invariant/storage/authority failure

Stop safely.

Do not silently swallow either.

# Idempotency

This is essential.

If recovery installs N payloads successfully, rerunning the same donor should result in:

- those N now classified `alreadyPresent`;
- no duplicate files;
- no overwrite;
- no duplicate metadata;
- zero recoverable if those were the only missing payloads.

Add strong tests.

# Interruption/crash convergence

Prove safe behavior for interruption after:

- temp copy starts;
- temp verification completes;
- final atomic install succeeds;
- metadata update fails;
- some subset of batch items completed.

A rerun must converge from current physical truth.

Do not require a durable recovery journal unless existing architecture genuinely needs one.

If current idempotent design is sufficient, document why.

# Mutation authority

The batch executor must itself require/operate inside exact-scope:

`attachmentReconciliation`

authority.

It must not accept a loosely typed “mutation allowed” bool.

The capability rules added under Prompt 47 remain mandatory.

No UI caller may invoke recovery without going through `ArchiveMutationCoordinator.runWithCapability(...)`.

# Historical Archives orchestration

Wire the MessageLens ready state to actual recovery only after the batch executor exists and passes tests.

Ready state:

- exact recoverable attachment count;
- exact recoverable bytes;
- Details;
- `Recover Attachments`;
- `Cancel`.

`Recover Attachments` must use the established primary-button interaction grammar.

# Immediate transition

After the user activates `Recover Attachments`:

- ready state yields immediately;
- operation presentation publishes;
- use `endOfFrame` if necessary to guarantee first paint before expensive work;
- then mutation admission/execution begins.

Do not allow a dead 1–2 second period with the ready screen still visible.

# Narrator lifecycle

Use the stable Narrator Track.

Representative initial Narrator:

**Recovering missing attachments from this MessageLens folder.**

If there is a meaningful scope transition between:

- verifying donor payloads;
- installing them;
- final verification;

Narrator may change only where human interpretation benefits.

Do not narrate every file.

Final verification may be Narrator-silent if Directed Instrumentation is self-explanatory.

# Directed Instrumentation

Use real operation stages.

Derive them from actual execution.

Likely concepts may include:

- Verifying attachment files
- Recovering attachment files
- Checking that recovery finished

Only use stages that correspond to real boundaries.

Within long stages show real counts/bytes.

# Stable Tracks

Preserve A–I stable center skeleton.

Narrator changes/silence must not shift instrumentation.

# Cancellation/navigation

Do not allow arm switching during admitted recovery.

Navigation/session handling must prevent stale presentation resurrection.

Determine whether actual file-copy cancellation is safe/necessary.

At minimum:

- leaving the feature must not cause a late callback to overwrite a newer session;
- an in-progress individual atomic install must finish/fail safely.

Do not implement unsafe mid-file cancellation.

# Terminal verification

After batch completes, re-run enough authoritative evidence to prove:

- installed payloads now physically exist;
- sizes/hashes satisfy current truth;
- metadata is reconciled;
- candidates no longer classify recoverable.

Do not merely trust the batch counter.

# Terminal Directed Instrumentation dwell

Preserve the established ~1.5 second completed-state dwell.

All real rows should be visibly Done before terminal modal.

No spinner during dwell.

# Terminal modal

Use a truthful recovery-specific acknowledgement.

Representative successful wording:

**Attachment recovery complete**

MessageLens recovered **N missing attachments** from the folder you selected.

If some items could not be recovered, do not call the operation fully successful without qualification.

Use a summary such as:

**Attachment recovery finished**

Recovered: N
Could not recover: M

Technical detail belongs under Details/logging, not a giant modal.

`OK` only dismisses the acknowledgement.

# Zero-result behavior

If preflight says zero recoverable:

- no Recover button;
- calm existing zero-result modal;
- no mutation.

# No donor cartouche

Preserve the ephemeral-donor model.

Recovery does not create:

- Folders Already Added entry;
- durable recovery-source cartouche;
- Remove this folder semantics.

After terminal acknowledgement, return to virgin MessageLens hub.

# Controlled-loss manual validation support

This task must prepare a precise manual test procedure for the human.

Do NOT create the loss in real data yourself.

The test receiving archive is the disposable development/staging MessageLens data folder.

The donor is another intact same-lineage MessageLens archive that contains the same attachment payloads.

## Before the human removes anything

Codex must provide a read-only helper/report capable of selecting a small deterministic tranche of safe test payloads from the receiving development archive.

Choose approximately:

- 5–10 attachment payloads;
- preferably images;
- moderate total size;
- unambiguous one-to-one matches;
- donor payload physically present;
- receiving payload physically present;
- no conflicts/ambiguity;
- no symlink/path complications.

The helper/report must output for each chosen payload:

- canonical attachment identity;
- current canonical receiving path;
- donor corresponding path;
- expected byte size;
- expected hash if available.

Also output:

- exact number of files;
- combined bytes.

Do not delete them.

# Controlled-loss manifest

Create a machine-readable/manual-review manifest in a safe temporary/development location containing the exact chosen tranche.

This manifest is for the manual test only.

It must not become product persistence.

The human should be able to compare:

before deletion:
N present

after manual deletion:
N missing

after preflight:
N recoverable

after recovery:
N restored

after second preflight:
0 recoverable.

# IMPORTANT — human deletion timing

The manual test procedure must explicitly say:

> Do not remove any files until implementation is complete, all automated tests pass, the branch is committed/pushed, and Codex has produced the final controlled-loss manifest.

Only THEN should the human remove the exact payload files listed in the manifest from the **disposable receiving development archive**.

Never remove files from the donor.

Never remove database rows.

Never modify attachment metadata manually.

Only remove the listed payload files.

# The human manual sequence

Codex should provide exact final commands/steps, but conceptually:

### Phase 0 — before deletion

1. Fully quit MessageLens.
2. Ensure donor archive remains intact/read-only.
3. Use the development/staging receiving archive, not production.
4. Generate/review controlled-loss manifest.
5. Verify every listed receiving file exists.
6. Verify every donor counterpart exists.
7. Record N and total bytes.

### Phase 1 — create controlled loss

ONLY AFTER CODEx IMPLEMENTATION/VERIFICATION IS COMPLETE:

8. Remove exactly the N receiving payload files listed in the manifest.
9. Do not touch DB/overlay rows.
10. Do not remove donor files.

### Phase 2 — preflight

11. Launch MessageLens against the disposable receiving archive.
12. Historical Archives → MessageLens.
13. Select intact donor.
14. Expect exactly N recoverable attachments and the exact combined bytes from the manifest.

If count/bytes differ:

STOP.

Do not press Recover.

### Phase 3 — recovery

15. Press `Recover Attachments`.
16. Observe Narrator + real progress.
17. Confirm terminal result says exactly N recovered, assuming no failures.

### Phase 4 — physical verification

18. Verify all N receiving payload files now exist.
19. Verify size/hash against manifest/donor.
20. Verify donor files unchanged.

### Phase 5 — idempotency

21. Run MessageLens preflight against the same donor again.
22. Expect zero recoverable attachments.

That is the critical end-to-end acceptance test.

# Safety guardrails

The product code must not contain special cases for the controlled-loss manifest.

The manual fixture is external test preparation only.

Do not add a debug button that deletes attachments.

Do not programmatically delete the user's real files.

Automated deletion tests must use temp directories only.

# Tests

Add/update comprehensive focused tests.

## Batch executor

1. all valid candidates install;
2. exact installed count;
3. exact bytes;
4. progress monotonic;
5. alreadyPresent handled idempotently;
6. expected item failure can continue;
7. systemic failure stops safely;
8. no candidate outside preflight set can be installed.

## Authority

9. recovery without capability rejected;
10. wrong capability rejected;
11. expired capability rejected;
12. nested-scope misuse rejected.

## Integrity

13. execution-time hash mismatch rejects item;
14. donor changed after preflight rejects;
15. concurrent destination creation cannot be overwritten;
16. metadata after payload ordering preserved.

## Retry

17. interrupted subset + rerun converges;
18. first run installed → second run alreadyPresent;
19. no duplicate metadata/file.

## Presentation

20. ready state has Recover + Cancel only when recoverable > 0;
21. zero result has no recovery action;
22. recovery first frame paints before expensive work;
23. real progress rows/counts;
24. all-Done dwell;
25. terminal modal;
26. hub after OK;
27. no donor cartouche.

## Regression

28. Mac Messages arm unchanged;
29. same-lineage gate unchanged;
30. D1/D2/D3 unchanged;
31. no graph/import-ledger mutation;
32. donor read-only;
33. preflight remains performant.

Do not create one test method mechanically per number.

# Architecture tripwires

Add protections ensuring:

- only canonical batch executor can perform MessageLens recovery;
- only canonical preservation-safe installer writes payloads;
- capability required;
- donor remains read-only;
- no donor message import;
- no graph rebuild;
- no direct file copy from Historical Archives widgets/services.

# Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- batch executor architecture;
- authority boundary;
- real progress;
- per-item/systemic failure semantics;
- interruption/idempotency;
- terminal verification;
- terminal modal;
- no-cartouche ephemeral donor semantics;
- controlled-loss test procedure;
- manifest generation;
- exact human deletion timing.

Update canonical attachment-recovery documentation.

Update version/changelog according to repository rules.

# Verification

Run:

- attachment recovery executor tests;
- installer tests;
- matcher/preflight tests;
- Historical Archives MessageLens tests;
- authority tests;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP before enabling UI mutation if:

- batch executor cannot preserve idempotency;
- terminal verification cannot prove restored truth;
- interruption requires unresolved journaling;
- metadata/payload reconciliation has an unresolved gap;
- capability enforcement is insufficient;
- actual recovery would require graph/import-ledger mutation;
- controlled-loss manifest cannot be generated safely.

# Final report

Report:

- batch executor implementation;
- exact operation stages;
- real progress fields;
- failure/continue policy;
- interruption/retry semantics;
- terminal verification;
- terminal modal wording;
- capability enforcement;
- controlled-loss manifest location/contents;
- exact N files and total bytes selected for manual test;
- exact manual deletion instructions;
- tests/tripwires;
- full verification;
- commit hash.

Acceptance standard:

> Given a deliberately damaged disposable receiving archive with exactly N proven attachment payloads removed, MessageLens should identify exactly N recoverable files, restore exactly those N through the canonical preservation-safe writer under mutation authority, and report zero recoverable when the same donor is scanned again.
