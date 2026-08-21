Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for a read-only architecture/forensics audit and, if the evidence is strong enough, implementation of the smallest bounded **lineage-admission mechanism** needed for future MessageLens attachment recovery.

Do NOT implement attachment copying yet.

Do NOT enable the MessageLens segment yet.

Do NOT import messages, graph data, overlays, or donor source registries.

Suggested prompt name:

`prompts/44-MESSAGELENS-ATTACHMENT-RECOVERY-LINEAGE-PROOF.MD`

# Product scope — supersedes broader archive-merge assumptions

The previous MessageLens data-folder audit explored general archive ingestion, including donor provenance, source lineage, attachments, and overlays.

We are deliberately narrowing the product problem.

The supported MessageLens Historical Archives use case is now:

> Recover missing attachment payloads from one or more archived MessageLens data folders that were created from earlier snapshots of the SAME continuing local macOS Messages `chat.db` lineage used by the current MessageLens installation.

We are NOT designing arbitrary MessageLens archive federation.

We are NOT importing donor messages.

We are NOT importing donor graph/search data.

We are NOT importing donor overlays.

We are NOT attempting to preserve or merge the donor archive’s ancestral B/B1/B2/B3 source topology.

The donor MessageLens folder is used only as a **source of attachment payloads and the metadata needed to prove which current messages those payloads belong to**.

# Core hypothesis

MessageLens source scoping preserves the original macOS Messages `message.ROWID`.

Conceptually:

scoped MessageLens message ID
→ unscope
→ original local `chat.db.message.ROWID`

If scoped ID `123456789` unscopes to original ID `1000`, then for data derived from the same continuing `chat.db` lineage:

`original ID 1000`

should refer to:

`current local chat.db.message.ROWID = 1000`

for the same logical message.

The audit must prove whether that is in fact a safe invariant under the supported lineage model.

Do not assume it merely because it is convenient.

# Important distinction

Do NOT require old and current `chat.db` rows to be byte-for-byte identical.

Existing message rows may legitimately acquire later mutable facts such as:

- delivery/read state;
- reactions;
- edits/unsends;
- attachment metadata;
- synchronization housekeeping.

The identity invariant we care about is narrower:

> Within one continuing local `chat.db` lineage, an existing `message.ROWID` continues to denote the same logical message.

The durable logical message GUID can be used as independent corroborating evidence.

# Cross-device caution

Do not assume macOS, iOS, and iPadOS share local SQLite ROWIDs.

They need not.

The supported recovery contract is specifically about:

**earlier snapshots of the same local Mac Messages database lineage**

not arbitrary iCloud-synchronized replicas from different devices.

GUID identifies the logical message.

ROWID provides continuity within this particular local database lineage.

Together they may form a very strong forensic signature.

# First task — prove source-scoping reversibility

Audit the current source-scoping implementation.

Determine exactly how MessageLens derives scoped message IDs from original `chat.db.message.ROWID`.

Document:

- source-scoping formula;
- data type/range;
- inverse operation;
- whether the inverse is lossless;
- whether any source kind uses a different rule;
- whether scoped IDs can collide;
- whether original IDs remain stored separately anywhere.

Add focused tests if necessary proving:

`original ROWID → scoped ID → unscoped ROWID`

round-trips exactly across realistic/current ranges.

Do not change the scheme unless a defect is found.

# Second task — prove ROWID lineage assumptions

Audit the macOS Messages import architecture and any canonical schema documentation.

Determine whether anything in the supported workflow can legitimately cause an existing logical message to move from one local `message.ROWID` to another while remaining within the same continuing `chat.db` lineage.

Inspect for relevant behavior such as:

- ordinary `UPDATE`;
- deletion/reinsertion;
- VACUUM;
- database migration;
- Messages database reconstruction;
- sync replacement;
- schema migrations;
- cleanup operations.

Be precise.

SQLite `VACUUM` behavior alone is not sufficient evidence; inspect whether `message.ROWID` is aliased to an `INTEGER PRIMARY KEY` or otherwise structurally stable in this schema.

Return a clear classification:

### Supported stable lineage

Conditions under which original ROWID can be trusted.

### Unsupported/uncertain lineage

Conditions such as database reconstruction/foreign database/device copy where it cannot be proven.

The product may reject recovery when lineage cannot be proven.

# Third task — identify the strongest forensic ear tag

We need a mechanical admission gate answering:

> Was this donor MessageLens data folder derived from an earlier snapshot of the same local Messages `chat.db` lineage used by the current installation?

Investigate available evidence.

At minimum consider deterministic samples of:

`original message ROWID ↔ message GUID`

from the donor MessageLens data and current live `chat.db`.

The proposed logic is:

donor scoped ID
→ unscope to original ROWID
→ donor stored message GUID

compare against:

current `chat.db.message`
where ROWID = original ROWID
→ current GUID

A matching pair provides strong lineage evidence.

A contradictory pair:

same original ROWID
→ different GUID

is immediate evidence that the donor must NOT be trusted for attachment recovery.

# Sampling strategy

Design a deterministic robust fingerprint.

Do not simply compare the first three rows.

Consider sampling across:

- low/middle/high original ROWID range;
- date range;
- multiple conversations;
- sent/received messages;
- sufficiently many records.

Determine an appropriate sample count from actual data scale and cost.

Potential approaches:

- deterministic evenly distributed anchors;
- stable hash-selected anchors;
- first/last plus distributed interior points;
- all overlapping messages if cheap enough.

Do not introduce probabilistic ambiguity unnecessarily if an exact or near-exact comparison is inexpensive.

# Admission semantics

Recommend a typed result such as conceptually:

- `sameLineage`
- `contradictoryLineage`
- `insufficientEvidence`

Use project naming conventions.

Do not reduce this to a boolean if insufficient evidence is meaningfully distinct from contradiction.

Potential rules:

## sameLineage

Sufficient independent donor ROWID↔GUID anchors match current `chat.db`, with no contradiction.

## contradictoryLineage

At least one strong contradiction exists:

same original ROWID
→ different logical GUID.

Reject recovery.

## insufficientEvidence

Not enough comparable records exist to prove lineage safely.

Reject automatic recovery unless another authoritative proof exists.

Do not implement a “probably okay” mode.

# Exact-match versus sampling decision

Audit whether it is computationally cheap to compare all donor message identities that also exist in current `chat.db`.

If so, prefer exact comparison over sampling.

For example, if donor contains ~100k messages and SQLite can efficiently join:

original ROWID + GUID

against current `chat.db`, an exact lineage check may be preferable and still fast.

Determine this empirically/architecturally.

Do not prematurely optimize to sampling if a database join can prove the relationship exactly.

# Message-level attachment recovery invariant

Even after donor archive lineage is admitted, attachment recovery should be conservative per message.

Design the future invariant:

donor attachment candidate
→ donor scoped message ID unscopes to original ROWID
→ current chat.db contains that ROWID
→ current logical message GUID matches donor GUID
→ attachment identity/metadata also satisfies future recovery rules
→ only then may payload recovery be considered.

Thus the archive-level ear tag is not the sole safety mechanism.

Each recovered payload will eventually receive its own identity proof.

Do not implement payload recovery yet.

# MessageLens archive identity

Preserve the previous audit conclusion that a donor MessageLens data folder has its own:

`archiveInstanceId`

This identifies the donor MessageLens archive itself.

Do not confuse:

archive identity

with:

underlying Apple Messages `chat.db` lineage.

They answer different questions.

Conceptually:

- `archiveInstanceId` = which MessageLens archive snapshot/source?
- ROWID↔GUID lineage proof = was this archive derived from the same local Messages database lineage?

Both may eventually be recorded.

# Ear-tag model

Recommend a durable/provable representation for an admitted MessageLens attachment-recovery source.

Potential evidence may include:

- source kind = MessageLens attachment recovery;
- donor `archiveInstanceId`;
- canonical donor identity;
- current MessageLens archive lineage admission result;
- fingerprint/check method version;
- date admitted;
- non-identity donor path/locator.

Do not add persistence/schema in this audit unless existing metadata can support it cleanly.

If a schema change would be required, report rather than implement.

# Do not split donor ancestry

Explicit product rule:

> Treat a donor MessageLens data folder as an unsplittable attachment-recovery source.

Do NOT attempt to reconstruct donor B1/B2/B3 historical source ancestry for this feature.

Do NOT import donor messages.

Do NOT preserve donor source-scoped message groups as new current sources.

The donor's internal source history may be useful as diagnostic evidence only.

# No duplicate-message problem

Because MessageLens-folder recovery will not import donor messages:

- overlapping donor histories cannot create duplicate message text;
- donor B/B1/B2/B3 provenance does not need to be merged into current history;
- message overlap is only relevant for matching attachment payloads to current messages.

Document this as a deliberate scope constraint.

# Foreign/smuggled donor

The key threat model is:

> User selects a MessageLens data folder derived from an entirely different Messages installation.

The lineage gate must reject this before any attachment copying occurs.

Test realistic foreign-donor cases.

At minimum:

- same ROWIDs but different GUIDs;
- some coincidentally shared GUIDs at different ROWIDs;
- same display/folder name;
- copied donor at different path;
- disconnected/remounted donor path.

Path similarity must provide no lineage authority.

# Current live chat.db dependency

Audit exactly how the current MessageLens installation identifies its live/current Mac Messages source and current `chat.db`.

The lineage check must use the authoritative current Messages database source.

Do not let UI-selected paths or historical source metadata substitute for it.

# Read-only donor inspection

All lineage inspection must be read-only.

Do not:

- migrate donor databases;
- rewrite donor archive marker;
- alter donor MessageLens metadata;
- create WAL/SHM in donor folder if avoidable;
- alter attachment payloads.

Use established immutable/read-only inspection architecture.

If current donor database formats cannot be safely opened read-only, report the compatibility gap.

# Current chat.db safety

The lineage proof must read current `chat.db` only.

Do not modify it.

Use existing source opener/query architecture.

Do not create another raw SQLite access path if a canonical read path exists.

# Performance audit

Measure/estimate cost of:

- extracting donor original ROWID/GUID evidence;
- looking up matching current `chat.db` rows;
- exact comparison versus deterministic sample.

A lineage check should ideally complete quickly enough to be part of folder qualification/preflight.

If exact comparison takes only hundreds of milliseconds or a few seconds, prefer certainty.

If materially expensive, justify the deterministic fingerprint design.

# UX recommendation

Do not implement final UI yet, but recommend how this should appear in the future MessageLens arm.

Likely flow:

Choose MessageLens folder
→ inspect archive marker/compatibility
→ verify same Messages lineage
→ if foreign/contradictory: modal → hub
→ if insufficient evidence: modal/failure → hub
→ if same lineage: continue to attachment recovery inspection.

Human copy should not expose ROWIDs or GUIDs.

Representative meaning:

**This MessageLens folder belongs to a different Messages history and can’t be used for attachment recovery.**

or:

**I couldn’t verify that this folder came from the same Messages history.**

Do not finalize copy unless useful.

# Architecture ownership

Determine where the lineage proof belongs.

Likely candidates:

- Historical Archives / MessageLens recovery domain service;
- source-scoped import domain;
- archive-environment service.

Choose based on existing ownership.

Do not bury it in:

- widget code;
- Settings presentation;
- source registration;
- attachment copier.

It should be reusable by the future recovery workflow.

# Typed evidence

Prefer a typed evidence/result model containing diagnostic facts such as:

- comparableCount;
- matchingCount;
- contradictionCount;
- admission status;
- method/version.

Presentation should consume typed facts, not parse strings.

Do not persist diagnostics unless necessary.

# Architecture tripwires

Add/propose protections preventing future weakening.

At minimum ensure:

1. scoped-to-original ID conversion uses canonical source-scoping logic;

2. lineage proof compares original ROWID with durable message GUID;

3. display labels/path strings cannot prove lineage;

4. `archiveInstanceId` alone cannot prove same Messages lineage;

5. contradictory ROWID↔GUID evidence rejects recovery;

6. insufficient evidence cannot silently become success;

7. no MessageLens donor message import occurs in attachment-recovery workflow;

8. donor is inspected read-only;

9. current `chat.db` is read-only;

10. per-message identity verification remains required by future payload recovery.

# Documentation

Create the next Feature 26 audit/design record under `responses/`.

Document:

1. narrowed product scope;
2. source-scoping reversibility;
3. `chat.db.message.ROWID` stability analysis;
4. GUID role;
5. exact/sampled lineage proof;
6. admission result semantics;
7. donor archive identity versus Messages lineage identity;
8. unsplittable donor rule;
9. foreign donor rejection;
10. future per-message attachment proof;
11. read-only requirements;
12. performance findings;
13. UX recommendation;
14. architecture ownership;
15. implementation slices.

Update the previous broad MessageLens data-folder audit to note that its general archive-ingestion assumptions have been superseded by the narrower attachment-recovery product contract.

Do not erase the historical audit.

# Implementation authority

You MAY implement, if safely bounded and schema-free:

- typed lineage evidence/result;
- canonical read-only lineage comparison service;
- source-scoping round-trip tests;
- lineage tests;
- architecture tripwires;
- dormant/non-UI infrastructure.

Do NOT:

- enable MessageLens segment;
- add attachment copying;
- add donor registration UI;
- import messages;
- import overlays;
- change graph;
- change source provenance;
- add schema migration;
- mutate real archives.

If persistence/schema is required, stop and report before implementation.

# Verification

Run:

- source-scoping tests;
- lineage service tests;
- historical archive tests;
- current-source database read tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if application code changes.

Do not run real attachment recovery.

Do not mutate production/staging/donor data.

# Final report

Return:

- whether scoped IDs losslessly recover original `chat.db` ROWIDs;
- exact evidence supporting or limiting ROWID stability;
- whether exact ROWID↔GUID comparison is practical;
- final lineage admission algorithm;
- thresholds/rules if sampling is required;
- typed result/evidence model;
- foreign donor rejection behavior;
- archiveInstanceId versus chat.db-lineage distinction;
- implementation completed, if any;
- tests/tripwires added;
- unresolved gaps;
- whether we can now safely proceed to designing actual attachment matching/recovery.

Acceptance standard:

> MessageLens should recover attachments from an archived MessageLens folder only when it can mechanically establish that the donor was derived from the same continuing local Mac Messages `chat.db` lineage, and each future recovered payload must still be tied unambiguously to the same logical current message.
