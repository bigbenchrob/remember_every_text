Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation.

The previous task established a bounded, dormant Messages-lineage proof for future MessageLens attachment recovery.

This task promotes that proof to the correct architectural level:

> Same-`chat.db` lineage is a Historical Archives admission requirement shared by both source arms.

Then retrofit the existing **Mac Messages** arm to use it before offering message import.

Do NOT implement MessageLens attachment recovery yet.

Do NOT enable the MessageLens segment yet.

Suggested prompt name:

`prompts/45-SHARED-HISTORICAL-ARCHIVES-MESSAGES-LINEAGE-ADMISSION.MD`

# Product rule

Historical Archives supports two distinct future operations.

## Mac Messages arm

Purpose:

> Add a partially overlapping set of messages from another snapshot/copy of the same continuing local Mac Messages `chat.db` lineage.

After lineage is proven, MessageLens may:

- compare original message identities;
- determine overlap;
- source-scope original ROWIDs;
- add historical source facts;
- rebuild combined browsing data.

## MessageLens arm

Purpose:

> Recover missing attachment payloads from an older MessageLens data folder derived from the same continuing local Mac Messages `chat.db` lineage.

After lineage is proven, MessageLens will eventually:

- import no donor messages;
- import no donor graph;
- import no donor overlays;
- use donor message/attachment evidence only to recover payloads belonging unambiguously to current messages.

The operations differ.

The admission rule is shared.

# Shared Historical Archives invariant

Before either arm may perform its source-specific consequential operation:

> MessageLens must mechanically establish that the candidate derives from the same continuing local Mac Messages `chat.db` lineage as the current installation.

Do not rely on:

- user assertion;
- folder path;
- display name;
- archiveInstanceId;
- apparent date overlap;
- message-count similarity.

Use the canonical ROWID↔GUID lineage evidence established by Prompt 44 / Response 45.

# Read first

Read:

- the implementation/audit from the previous task:
  `responses/45-MESSAGELENS-ATTACHMENT-RECOVERY-LINEAGE-PROOF.md`;
- dormant lineage implementation under `features/attachments`;
- source-scoping implementation;
- `HistoricalArchiveSourceIdentity`;
- Mac Messages inspection/preflight workflow;
- current typed Historical Archives presentation states;
- current Narrator + Directed Instrumentation design;
- current source database opener;
- canonical Historical Archives/database architecture docs.

Before editing, map the current ownership of the lineage service and determine what is MessageLens-attachment-specific versus genuinely Historical-Archives-wide.

# Existing lineage proof

Preserve the established semantics unless audit finds a concrete defect.

Current result categories:

- `sameLineage`
- `contradictoryLineage`
- `insufficientEvidence`

Current proof:

- scoped donor IDs losslessly recover original `chat.db.message.ROWID`;
- lineage comparison uses original ROWID ↔ durable message GUID;
- one conflicting GUID rejects the candidate;
- admission requires 64 matches distributed across at least three of four ROWID bands;
- all overlapping comparable records are checked;
- paths/labels/archiveInstanceId provide no lineage authority;
- current `chat.db` is read through the established authoritative read-only opener;
- donor/current databases are not mutated.

Do not casually weaken these rules.

# First architectural correction — move ownership

The lineage proof currently lives under `features/attachments` because it was developed for MessageLens attachment recovery.

That is now too narrow.

The same proof is required before Mac Messages historical ingestion.

Move/extract the genuinely shared lineage contract and service to the narrowest correct shared Historical Archives / source-scoped-import / Messages-source domain boundary.

Choose ownership based on repository architecture.

Do NOT create a generic global “database lineage” utility.

This specifically proves:

> same local Apple Messages `chat.db` lineage.

Attachment-specific future matching remains under Attachments.

# Preserve one authority

After extraction, there must be one lineage authority.

Do not leave:

- attachment lineage checker;
- Mac Messages lineage checker;

as separate implementations.

Both future arms must consume the same typed contract.

Add architecture tripwires preventing duplicate ROWID↔GUID lineage algorithms.

# Mac Messages current weakness

The existing Mac Messages arm structurally qualifies a folder and then compares/imports it without proving that its `message.ROWID` namespace belongs to the same current `chat.db` lineage.

Our 2012 test donor happens to satisfy that condition because we know where it came from.

A normal user should not have to supply that trust.

A foreign `chat.db` could contain:

- valid Messages schema;
- plausible messages;
- overlapping GUIDs;
- ROWIDs that happen to collide numerically;

while belonging to a different local database lineage.

Source-scoping those ROWIDs as though they belonged to the current lineage would violate provenance assumptions.

Fix that.

# Where lineage belongs in Mac Messages qualification

Current conceptual flow:

Choose Messages folder
→ structural/readability inspection
→ duplicate/source identity lookup
→ comparison/preflight
→ ready-to-add
→ authorization
→ import.

Insert lineage admission at the earliest point where sufficient evidence exists and before any source-specific import authorization.

Preferred conceptual sequence:

Choose Messages folder
→ prove it structurally contains a usable Messages database
→ identify duplicate already-added source as currently designed
→ prove same Messages lineage
→ perform/complete overlap comparison
→ ready-to-add.

If duplicate recognition can safely happen before lineage because it uses already persisted canonical source identity and performs no mutation, preserve that behavior.

Do not perform expensive lineage work unnecessarily for a source already known to be currently added if the existing duplicate boundary can reject it safely first.

Document ordering and rationale.

# Critical donor difference

Prompt 44's dormant service was designed around a donor MessageLens archive containing scoped MessageLens IDs.

A raw Mac Messages `chat.db` already contains original `message.ROWID`.

Therefore the shared lineage authority should consume canonical identity evidence rather than requiring all callers to manufacture scoped IDs.

Design the seam carefully.

Conceptually, the shared proof needs pairs:

`originalMessagesRowId`

- `messageGuid`

How each source arm obtains those pairs differs:

### Mac Messages

Read directly from candidate `chat.db.message`:

`ROWID`

- `guid`

### MessageLens

Read donor MessageLens message facts:

scoped ID
→ canonical unscope
→ original ROWID

- stored GUID.

The lineage comparison algorithm should not care which arm produced the evidence.

Do not make Mac Messages scope IDs merely to feed the checker.

# Current-source authority

Both arms compare against the authoritative current live Mac Messages `chat.db`.

Use the existing canonical source opener/read architecture.

Do not introduce another direct SQLite path.

Current database comparison remains read-only.

# Typed evidence contract

Refine the shared API if necessary so it consumes typed lineage anchors/evidence.

Potential conceptual types:

`MessagesLineageAnchor`

- originalRowId
- guid

`MessagesLineageEvidence`

- comparable count
- matching count
- contradiction count
- represented ROWID bands
- status

`MessagesLineageAdmission`

- sameLineage
- contradictoryLineage
- insufficientEvidence

Use repository naming/style.

Do not expose raw tuple/maps broadly.

# Mac Messages inspection presentation

Lineage verification is a real qualification step.

It should participate in Narrator + Directed Instrumentation only if perceptible enough to warrant visible work.

First measure/inspect likely duration.

If the exact check is fast, it may resolve as part of inspection without theatrical staging.

If it takes perceptible time, expose a truthful row.

Representative human wording:

`Checking Messages history`

or:

`Verifying Messages history`

Avoid:

- ROWID;
- GUID;
- lineage;
- fingerprint;
- database identity.

Narrator may say, if interpretation is needed:

**First I’ll make sure this folder belongs to the same Messages history.**

But do not add Narrator chatter for a check that completes essentially instantly.

Use judgment consistent with the established grammar.

# Ready state

A Mac Messages candidate must not reach:

`Add Messages to MessageLens`

unless lineage admission is `sameLineage`.

Thus:

structurally valid

- not already added
- same lineage
- valid comparison evidence
  → readyToAdd.

Make this mechanically enforced through the D1 typed state/transitions.

Do not merely disable the button in the widget while leaving a ready state constructible.

# Contradictory lineage

If the candidate structurally looks like a valid Messages folder but lineage evidence proves it belongs to another Messages database:

- terminate the add attempt;
- return underlying presentation to virgin hub;
- show a concise modal;
- no orange reference;
- no blue selection;
- no source registration;
- no import;
- no center-panel error residue.

Representative meaning:

**This Messages folder belongs to a different Messages history and can’t be added here.**

Do not expose forensic terminology in primary copy.

Details/diagnostics may retain typed counts if appropriate.

# Insufficient evidence

Treat separately from contradiction.

Possible reasons may include:

- too few comparable messages;
- candidate extremely small;
- current database lacks enough corresponding anchors;
- required GUID evidence unavailable.

Fail closed.

Do not automatically admit.

Use a distinct concise modal, representative meaning:

**MessageLens couldn’t verify that this folder came from the same Messages history.**

Do not imply it is definitely foreign.

Return to hub after acknowledgement.

No orange/blue reference.

# Very small legitimate archives

Audit the 64-match threshold in the context of Mac Messages.

A valid same-lineage historical folder might contain fewer than 64 comparable messages.

Do not weaken the gate casually.

Determine whether Prompt 44's threshold was intentionally tuned for the attachment-recovery threat model or is appropriate as a universal admission rule.

If a robust deterministic exact proof can admit a small archive through another criterion, design it explicitly.

Examples might include:

- all N available records match with zero contradiction, but only above a defensible minimum N;
- additional independent database evidence.

Do not invent a permissive heuristic.

If this requires a product decision, STOP and report rather than silently lowering the threshold.

Our 2012 archive has ample evidence and should not be affected.

# Existing 2012 staging source

The known `Messages_2012-IMPORT_SOURCE` should pass same-lineage admission if tested by the human later.

Do not run the real GUI import.

Automated tests may use representative fixtures.

# Duplicate detection

Preserve the established duplicate behavior.

Already-added canonical source:

→ duplicate modal
→ hub
→ after dismissal gentle orange correspondence to existing cartouche
→ fade.

Do not make lineage failure use orange.

Orange means “this existing object is the thing I mean,” not “this candidate failed qualification.”

# Source registration timing

Lineage failure must not leave behind newly persisted source metadata merely because inspection began.

Audit registration timing.

A candidate that fails lineage admission should not become a durable “known source” unless current architecture has a clearly intentional diagnostic registry distinction.

`Folders Already Added` certainly must not contain it.

Prefer no persistence before admission where compatible with current architecture.

# Source identity versus lineage

Keep these concepts separate.

`HistoricalArchiveSourceIdentity`
answers:

> Which historical source locator/identity is this?

Messages lineage admission answers:

> Does this source's original Apple Messages ROWID namespace belong to the same continuing current `chat.db` lineage?

A source may have a perfectly valid canonical historical source identity and still fail lineage admission.

Do not merge these concepts into one type.

# MessageLens future arm

Do not enable it.

Refactor the dormant MessageLens lineage code only enough that the future arm can consume the new shared authority.

Preserve the rule:

MessageLens donor:
scoped message ID
→ canonical unscope
→ original ROWID
→ shared lineage anchor.

Do not implement:

- chooser;
- UI;
- attachment matching;
- payload copying;
- donor registration;
- success/removal semantics.

# Architecture tripwires

Add protections proving:

1. one shared Messages-lineage authority exists;

2. Mac Messages uses it;

3. future MessageLens attachment recovery seam uses the same contract;

4. Mac Messages reads ROWID/GUID directly rather than inventing scoped IDs;

5. MessageLens donor evidence uses canonical unscoping;

6. readyToAdd cannot be constructed without successful lineage admission;

7. contradictory lineage cannot reach import authorization;

8. insufficient evidence cannot reach import authorization;

9. lineage failure performs no archive mutation;

10. display labels/path/archiveInstanceId cannot substitute for lineage proof;

11. current live `chat.db` is accessed through canonical read-only architecture;

12. no duplicate ROWID↔GUID comparison implementation exists elsewhere.

# D1/D2/D3 regression

Verify explicitly:

- sealed Historical Archives presentation state remains intact;
- stable A–I center Track skeleton remains intact;
- `HistoricalArchiveSourceIdentity` remains sole historical source identity authority.

Do not conflate D3 source identity with the new shared lineage gate.

# Narrator/Directed Instrumentation

Preserve current stable Narrator Track and Directed Instrumentation geometry.

If lineage checking becomes visible:

- use existing Tracks;
- do not move instrumentation;
- do not add another layout system;
- Narrator commentary expires when its meaning expires.

# Tests

Add/update the smallest clear focused set covering:

## Shared evidence

- raw Mac Messages ROWID/GUID becomes canonical anchor;
- scoped MessageLens ID unscopes to equivalent canonical anchor;
- both feed same lineage authority.

## Same lineage

- sufficient exact matches + no contradiction admits;
- 2012-like fixture reaches ready state;
- overlap comparison follows admission.

## Contradiction

- one same-ROWID/different-GUID contradiction rejects;
- no import authorization;
- no registration/import mutation;
- hub + modal behavior.

## Insufficient evidence

- inadequate evidence produces distinct result;
- no import authorization;
- no mutation;
- no false “different history” claim.

## Foreign database

- valid Messages schema from unrelated lineage rejects;
- shared GUIDs at different ROWIDs do not prove lineage;
- same display/path-like labels do not matter.

## Workflow

- duplicate already-added behavior remains unchanged;
- invalid-folder behavior remains unchanged;
- ready state requires lineage;
- Cancel remains unchanged;
- import/removal journeys remain unchanged after admission.

## Regression

- D1 typed state;
- D2 Tracks;
- D3 identity;
- DateConverter;
- mutation authority;
- maintenance/Onboarding;
- source-1 protection.

# Performance

Measure lineage check cost on representative fixtures.

If all-overlap exact checking remains inexpensive, preserve it.

Do not weaken certainty merely to save trivial time.

If visible, report timing so we can decide whether the human needs instrumentation.

# Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- promotion from attachment-specific proof to shared Historical Archives admission;
- shared anchor/evidence contract;
- Mac Messages direct ROWID/GUID evidence;
- MessageLens future unscoped evidence;
- workflow ordering;
- same/contradictory/insufficient semantics;
- small-archive threshold analysis;
- presentation behavior;
- source identity versus lineage distinction;
- tripwires.

Update the prior Prompt 44/Response 45 documentation to note that lineage admission is now a shared Historical Archives rule.

Update canonical database/Historical Archives guidance with:

> Every Historical Archives source that depends on original Apple Messages ROWID identity must prove same current `chat.db` lineage through the canonical Messages-lineage authority before consequential work is authorized.

Do not rewrite historical records.

Update version/changelog according to repository rules.

# Safety

Do not perform GUI import/removal.

Do not access or mutate real production/staging/donor data unless a read-only fixture-independent check is explicitly required and repository rules permit it.

Prefer fixtures/temp databases.

Never modify:

- live `chat.db`;
- donor `chat.db`;
- production archive;
- staging archive;
- attachment payloads.

# Verification

Run:

- lineage tests;
- Mac Messages inspection/ready-state tests;
- source-scoping tests;
- Historical Archives workflow tests;
- Settings suite;
- import/removal regressions;
- maintenance/Onboarding tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP if:

- the current lineage algorithm cannot validly apply to raw Mac Messages candidates;
- small legitimate Mac Messages sources require an unresolved product-policy decision;
- source registration must be redesigned materially;
- schema/persistence changes are required;
- D1/D2/D3 would need to be weakened;
- MessageLens attachment recovery must be implemented to complete this task.

# Final report

Report:

- final shared lineage authority location/type;
- Mac Messages evidence extraction;
- future MessageLens evidence extraction;
- exact workflow ordering;
- same/contradictory/insufficient rules;
- small-archive policy;
- measured check cost;
- modal behavior;
- registration timing;
- architecture tripwires;
- full verification;
- documentation;
- commit hash;
- confirmation that Mac Messages now fails closed for foreign lineage;
- confirmation that the future MessageLens arm can consume the same admission gate.

Acceptance standard:

> Mac Messages and future MessageLens attachment recovery may do different things after admission, but neither may rely on original Apple Messages ROWID identity until the same canonical service has proven that the candidate belongs to the current local `chat.db` lineage.
