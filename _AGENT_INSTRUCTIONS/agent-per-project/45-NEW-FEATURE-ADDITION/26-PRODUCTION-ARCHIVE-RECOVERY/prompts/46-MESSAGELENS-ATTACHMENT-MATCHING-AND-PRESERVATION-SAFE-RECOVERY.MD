Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for a read-first architecture/design audit and, where clearly bounded, dormant implementation of the **attachment identity/matching layer** required for future MessageLens attachment recovery.

Do NOT enable the MessageLens segment yet.

Do NOT copy attachment payloads yet.

Do NOT import donor messages, graph data, overlays, or source registries.

Suggested prompt name:

`prompts/46-MESSAGELENS-ATTACHMENT-MATCHING-AND-PRESERVATION-SAFE-RECOVERY.MD`

# Context

Historical Archives now has a mechanically enforced shared Messages-lineage admission gate.

Both source arms must prove:

> the candidate derives from the same continuing local Mac Messages `chat.db` lineage.

The current Mac Messages arm uses that proof before historical message ingestion.

The future MessageLens arm will use the same proof for a much narrower purpose:

> Recover missing attachment payloads from an archived MessageLens data folder derived from the same Messages lineage.

The donor MessageLens archive is treated as an **unsplittable attachment-recovery source**.

It is NOT a source of messages to import.

It is NOT a source of graph data.

It is NOT a source of overlays.

It is NOT a source of donor B/B1/B2/B3 provenance to reconstruct.

# Product contract

The future MessageLens arm has one job:

> Find attachment payloads present in an older same-lineage MessageLens archive that belong unambiguously to messages already represented in the current MessageLens archive, and safely restore those missing payloads.

The current task is to establish the identity and preservation semantics that make this operation mechanically safe.

Do not implement the actual copy/mutation stage until those semantics are explicit.

# Hard safety rule

A donor payload may eventually be recovered only when MessageLens can prove:

1. donor archive has passed same-Messages-lineage admission;

2. donor attachment is associated with a donor message;

3. donor message can be mapped back to its original Apple Messages `message.ROWID`;

4. current authoritative Messages history contains that same original message identity;

5. donor and current message GUIDs agree;

6. donor attachment metadata identifies the same logical attachment expected by the current message;

7. the destination payload is genuinely missing or recoverable without overwriting a different valid payload;

8. the donor payload exists and passes whatever integrity checks are available;

9. copy destination is canonical and safely owned by current MessageLens;

10. recovery does not mutate donor data.

If any necessary identity link is ambiguous:

> do nothing.

No “best guess” recovery.

# Read first

Read the canonical documentation and implementation for:

- Messages lineage admission;
- source-scoped message ID packing/unpacking;
- attachment import;
- attachment metadata schema;
- current attachment archive/storage ownership;
- attachment paths;
- current message ↔ attachment relationships;
- any attachment deduplication logic;
- current attachment recovery/relinking utilities;
- source import databases;
- working databases;
- archive environment;
- attachment migration/history;
- Historical Archives typed state and mutation authority;
- Feature 26 audits 44–46.

Before proposing changes, map exactly how an attachment enters MessageLens today and how its identity survives from `chat.db` into current MessageLens storage.

# First audit — attachment anatomy

Document the complete attachment identity chain from Apple Messages to MessageLens.

For a representative attachment determine all available identifiers/facts such as:

- Apple `attachment.ROWID`;
- attachment GUID;
- filename;
- transfer name;
- MIME type;
- UTI;
- file size;
- created date;
- local path;
- message relationship;
- message GUID;
- original message ROWID;
- source-scoped MessageLens attachment ID;
- source-scoped message ID;
- current canonical payload/storage identifier;
- attachment archive relative path;
- hash, if any;
- metadata used to detect missing payloads.

Use actual schema/implementation terminology.

Do not assume attachment GUID is globally reliable until verified.

# Critical question — what is the logical attachment identity?

Determine which evidence uniquely identifies:

> this donor attachment is the same logical attachment as the attachment expected by this current message.

Potential identity strength may come from combinations such as:

- current message identity + attachment GUID;
- original message ROWID + attachment original ROWID;
- message GUID + attachment GUID;
- source-scoped attachment identity;
- another canonical key.

Do not choose by convenience.

Establish which identifiers are stable across snapshots of the same `chat.db` lineage.

# Source-scoping reversibility for attachments

Audit whether attachment IDs are source-scoped using a reversible scheme analogous to messages.

If so, prove:

```text
original Apple attachment ROWID
→ scoped attachment ID
→ original Apple attachment ROWID
```

round-trips exactly.

Determine whether message and attachment IDs use the same bit layout or different rules.

Do not duplicate scoping arithmetic.

Use canonical source-scoping utilities.

Add tests if the attachment round-trip is not already protected.

# Relationship identity

An attachment should not be matched in isolation if the relationship to its message provides stronger evidence.

Audit the donor/current relationship chain:

```text
donor attachment
→ donor message-attachment relation
→ donor scoped message ID
→ original message ROWID
→ donor message GUID
```

and compare with current authoritative facts.

Determine whether current MessageLens still retains:

- same original attachment ROWID;
- same attachment GUID;
- same message-attachment ordering/index;
- another stable relationship marker.

# Current-message authority

The future recovery workflow must not trust donor MessageLens message records merely because they exist.

Once same-lineage admission has passed, donor message metadata is evidence for matching.

Current authoritative identity should come from the established current MessageLens/current Messages data architecture.

Determine which current store should be queried for:

- original message ROWID;
- current message GUID;
- expected attachments;
- current payload presence.

Do not introduce a second competing message-identity authority.

# Important distinction — record metadata versus payload

Separate:

## Attachment record exists

MessageLens knows an attachment should exist.

from:

## Attachment payload exists

The actual image/video/file is physically available in current managed storage.

The MessageLens recovery arm should target the latter problem.

Audit how current code determines:

- payload present;
- payload missing;
- payload inaccessible;
- metadata-only attachment;
- intentionally absent attachment;
- unsupported attachment.

Do not equate an attachment database row with a recoverable missing file.

# Donor payload discovery

Determine how an archived MessageLens data folder stores attachment payloads.

Document:

- root directory;
- relative path semantics;
- whether paths are canonical;
- whether donor metadata stores absolute paths;
- whether payload location derives from attachment ID/GUID/hash;
- whether archive moves break stored paths;
- whether attachment directories are content-addressed;
- whether symlinks exist;
- whether files can be external to the archive root.

The future recovery service must not trust arbitrary donor paths without containment checks.

# Path safety

Design the future donor-path rules.

At minimum:

- resolve donor payload candidate under the selected donor archive root;
- reject path traversal;
- reject references escaping the donor archive;
- do not follow unsafe symlinks outside the donor root unless canonical architecture explicitly permits them;
- donor remains read-only.

Similarly, destination must be determined by current MessageLens attachment-storage authority.

Do not build destination paths manually in the recovery feature if a canonical attachment archive service exists.

# Attachment payload integrity

Audit what evidence can validate that the donor file is plausibly the expected payload.

Potential evidence:

- exact byte size;
- file hash;
- MIME/type;
- filename/extension;
- attachment GUID;
- stored metadata.

Determine whether MessageLens already stores hashes.

If no hash exists, do not invent a requirement that would necessitate schema changes.

Recommend the strongest available verification.

# Collision semantics

Define future behavior for each case.

## Current payload missing, donor payload valid

Candidate for recovery.

## Current payload already exists and appears valid

Do nothing.

Do not overwrite it merely because donor also has a copy.

## Current payload exists but differs from donor

This is a conflict.

Do not overwrite automatically.

Classify/report it for Details/diagnostics.

## Donor metadata exists but donor payload missing

Not recoverable.

Do not fail the entire folder necessarily; classify.

## Multiple donor payload candidates match one current attachment

Ambiguous unless they are provably byte-identical / same canonical payload.

Fail closed for that attachment.

## One donor payload appears to map to multiple current attachments

Audit whether this is legitimate deduplication or a collision.

Do not assume.

# Copy semantics — design only unless trivial/dormant

Determine the canonical destination operation.

The future copy should be:

- donor read-only;
- destination owned by current MessageLens;
- atomic where possible;
- no destructive overwrite;
- temp file + verification + atomic rename if current architecture supports it;
- cleanup-safe if interrupted.

Do not implement payload copying in this task unless there is already a canonical dormant copy primitive and hooking it up does not perform real recovery.

Prefer design/audit first.

# Preservation principle

Recovery must preserve:

- current messages;
- current attachment records;
- current source provenance;
- current graph;
- current overlays;
- donor archive;
- donor attachment files.

The operation should add missing payload bytes, not rewrite message history.

# Recovery provenance / “ear tag”

We have discussed an ear tag for an archived MessageLens folder.

Keep its role narrow.

Potential future recovery-source identity:

- source kind: MessageLens attachment recovery;
- donor `archiveInstanceId`;
- same-lineage admission evidence;
- path as locator only;
- recovery occurrence ID if needed.

Do not assign donor ownership to the current message.

The recovered attachment remains attached to the existing current message.

The donor archive is only:

> where we recovered the missing payload from.

Determine whether recovery provenance needs persistence at all.

If useful for later audit/removal, recommend the smallest representation.

Do not add schema in this task.

# Removal semantics reconsidered

Because MessageLens attachment recovery does not import donor messages, reconsider whether:

`Remove this folder…`

should exist for MessageLens recovery sources.

Potential model:

- donor is used once;
- recovered payload becomes ordinary current MessageLens attachment data;
- donor does not remain an active content source;
- there may therefore be nothing meaningful to “remove.”

Alternatively, if recovery provenance is retained and reversible deletion is valuable, define precisely what removal would mean.

Do not force parity with Mac Messages.

Return a product/architecture recommendation.

# Persistent cartouche semantics reconsidered

Likewise audit whether MessageLens recovery should have:

`Folders Already Added`

at all.

Potential interpretations:

### A. Recovery Sources Used

Useful historical/audit record.

### B. No persistent source list

After recovery, donor is no longer operationally relevant.

### C. Persist donor identity only to prevent accidental reprocessing

But do not imply that it remains a live source.

Do not implement UI.

Recommend the clearest model.

# Duplicate donor selection

If the same donor `archiveInstanceId` is selected twice:

- should MessageLens reject it as already processed?
- should it rescan because additional attachments may now be missing/present?
- should a second recovery be idempotent and harmless?

Prefer idempotent architecture where practical.

Determine what donor identity and current attachment state allow.

# Matching algorithm

Design a deterministic matching pipeline.

Conceptually:

1. donor archive passes structural compatibility;
2. donor archive passes same-lineage admission;
3. enumerate donor attachment candidates;
4. map donor message scoped ID → original ROWID;
5. verify donor message GUID;
6. resolve current message corresponding to original ROWID;
7. verify current message GUID equals donor GUID;
8. establish attachment identity relationship;
9. determine current payload state;
10. locate donor payload safely;
11. validate donor payload;
12. classify:

- recoverable;
- already present;
- donor payload missing;
- message mismatch;
- attachment mismatch;
- conflict;
- ambiguous.

Do not collapse classification into recovered/not-recovered.

# Typed preflight evidence

Design a typed read-only result that can later power the ready screen.

Potential useful aggregate counts:

- attachment records examined;
- missing current payloads;
- safely recoverable payloads;
- already present;
- donor payload missing;
- conflicts/ambiguous matches;
- total bytes recoverable.

Only include counts the audit proves can be computed truthfully.

The primary ready screen should eventually emphasize:

> I found N missing attachments that can be safely recovered.

Potentially:

> Recoverable size: X GB

Technical mismatch diagnostics belong under Details.

# Human workflow recommendation

Design the future MessageLens arm around the established Historical Archives grammar.

Likely conceptual flow:

Choose archived MessageLens folder
→ structural qualification
→ same-lineage proof
→ inspect attachment recovery opportunities
→ ready state

Narrator representative meaning:

**This folder comes from the same Messages history. I’ll look for attachments that are missing from MessageLens.**

Directed Instrumentation if inspection takes perceptible time.

Ready state might say:

**I found 1,842 missing attachments that can be safely recovered.**

Evidence:

- Attachments recoverable
- Date range if useful
- Total size

Action:

`Recover Attachments`

Secondary:

`Cancel`

Do not finalize copy unless needed for design.

# Recovery operation likely stages

Audit what real stages would exist during future mutation.

Possibilities only if true:

- copying attachment payloads;
- validating copied files;
- updating attachment-location metadata if required;
- refreshing attachment evidence/read models;
- final verification.

There should probably be no graph rebuild if message/relationship facts do not change.

Prove this.

If graph does not need rebuilding, document that as an important distinction from Mac Messages.

# Progress denominator

Attachment recovery seems naturally measurable.

If future copy set contains N recoverable files:

`Recovered 412 / 1,842 attachments`

is a real numerator/denominator.

Potential bytes copied may also be real:

`8.4 GB / 19.2 GB`

Determine what can be known before mutation.

Do not implement progress UI yet unless dormant typed evidence is needed.

# Failure/restart semantics

Design for interruption.

If recovery copies 600 of 1,842 files and app exits:

- can rerun safely?
- will already recovered payloads be recognized and skipped?
- can partially written files exist?
- is each file operation independently atomic?
- do we need a durable transaction journal?

Prefer naturally idempotent recovery:

inspect current state on retry
→ already-present payloads are no longer recoverable candidates
→ continue missing ones.

If a durable journal is unnecessary, say so.

If correctness requires one, flag schema/design requirement.

# Current attachment metadata mutation

Critical question:

Does restoring a payload require changing a database record?

Possibilities:

- current MessageLens already has canonical attachment metadata/path and only file bytes are missing;
- current metadata must be updated to point to the restored payload;
- attachment archival layer needs registration.

Determine exact behavior.

This decides whether attachment recovery is:

mostly filesystem mutation

or:

database + filesystem mutation.

# Mutation authority

Map the future operation onto `ArchiveMutationCoordinator`.

Determine what must be exclusively owned during recovery:

- attachment storage mutation;
- overlay? no;
- import ledger? likely no;
- working graph? likely no;
- current attachment metadata database if modified.

Do not add operation types yet unless dormant type-only infrastructure is clearly required.

# Concurrency

Audit possible races with:

- current live Messages attachment ingestion;
- normal MessageLens attachment archiving;
- user opening an attachment;
- cleanup/pruning;
- another recovery operation.

Define what lock/authority boundary future recovery requires.

# Compatibility

A donor MessageLens archive may be older than current schema.

Determine which donor tables/metadata are required only for matching.

Design read-only compatibility so donor is never migrated.

If archived March data comes from a known earlier MessageLens schema, identify exactly how current code can read it safely.

# March archive target

The theoretical real use case is:

> archived March 30 MessageLens data folder from the same working `chat.db` lineage, containing attachments that are missing from the current MessageLens data folder.

Design should support this case first.

Do not broaden requirements to arbitrary foreign archives.

# Dormant implementation authority

You MAY implement, where schema-free and bounded:

- canonical attachment-recovery candidate/evidence types;
- read-only donor attachment inspection;
- per-message/per-attachment matching service;
- classification logic;
- safe path-containment validation;
- source-scoping round-trip tests for attachments;
- aggregate recovery preflight;
- architecture tripwires.

Do NOT implement:

- actual payload copy;
- attachment database mutation;
- UI;
- MessageLens segment enablement;
- recovery authorization;
- removal;
- schema changes.

If correct matching requires schema changes, stop and report.

# Architecture placement

Keep genuinely attachment-specific matching under the Attachments feature/domain.

Use shared Messages-lineage admission from `source_scoped_import`.

Do not move attachment matching into Historical Archives merely because that feature invokes it.

Historical Archives will orchestrate.

Attachments owns attachment identity/recovery semantics.

# Tests

Add/update focused tests for:

## Attachment ID provenance

1. attachment source scoping round-trips original ROWID if applicable;

2. donor message scoped IDs unscope through canonical utility;

3. no local scoping arithmetic exists.

## Message proof

4. same original ROWID + same GUID admits message relationship;

5. same original ROWID + different GUID rejects;

6. donor/current path/name similarity has no authority.

## Attachment proof

7. matching attachment identity for matched message qualifies;

8. attachment identity mismatch rejects;

9. ambiguous attachment mapping rejects;

10. same filename alone does not prove identity.

## Payload classification

11. current missing + donor present/valid → recoverable;

12. current present → alreadyPresent;

13. donor payload missing → donorMissing;

14. current conflicting payload → conflict, not overwrite;

15. unsafe donor path → rejected;

16. path traversal/symlink escape cannot become recoverable.

## Aggregates

17. recoverable count is exact;

18. recoverable byte total is exact where size known;

19. conflicts remain separately countable;

20. no donor message import occurs.

## Idempotency

21. after a simulated successful payload presence, rerun classifies it alreadyPresent;

22. duplicate donor inspection does not create duplicate recovery candidates.

## Regression

23. shared lineage gate remains required;

24. D1 typed state unchanged;

25. D2 Tracks unchanged;

26. D3 source identity unchanged;

27. Mac Messages arm unchanged;

28. donor/current databases are read-only in inspection.

Do not mechanically create one test per number.

# Documentation

Create the next Feature 26 audit/design/implementation record under `responses/`.

Document:

- attachment identity anatomy;
- logical attachment identity;
- attachment source-scoping behavior;
- message relationship proof;
- payload storage/path semantics;
- path safety;
- integrity evidence;
- collision behavior;
- matching algorithm;
- typed classifications;
- aggregate preflight;
- recovery provenance recommendation;
- persistent cartouche/removal recommendation;
- idempotency/restart design;
- mutation authority;
- concurrency;
- compatibility;
- dormant implementation added.

Update the broad MessageLens archive audit to reflect the narrowed attachment-recovery path where necessary.

Do not rewrite historical records.

# Verification

Run:

- attachment domain tests;
- source-scoping tests;
- lineage tests;
- donor inspection/matching tests;
- Historical Archives regressions;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if code changes.

Do not perform real attachment recovery.

Do not mutate production/staging/donor data.

# Stop conditions

STOP if:

- attachment identity cannot be made unambiguous from existing metadata;
- correct recovery requires schema migration;
- donor must be migrated in place;
- current attachment metadata cannot distinguish missing versus existing payload;
- safe copy requires redesign of attachment archive ownership;
- lineage assumptions conflict with matching evidence.

Do not weaken proof merely to make the March archive work.

# Final report

Return:

- exact donor/current attachment identity chain;
- strongest per-message proof;
- strongest per-attachment proof;
- whether attachment IDs are reversibly source-scoped;
- exact recovery classifications;
- donor path/payload safety rules;
- whether current metadata already knows canonical destination;
- whether database mutation is required for recovery;
- whether graph rebuild is required;
- exact aggregate preflight evidence available;
- idempotency/restart behavior;
- recommended persistent-source/cartouche semantics;
- recommended removal semantics;
- dormant implementation completed;
- tests/tripwires;
- blockers, if any;
- whether actual preservation-safe attachment copying can now be implemented.

Acceptance standard:

> A MessageLens donor attachment must become recoverable only when MessageLens can prove which current logical message and attachment it belongs to, prove that the current payload is missing, locate and validate the donor payload safely, and do all of that without importing donor messages or guessing.
