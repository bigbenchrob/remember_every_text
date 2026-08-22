Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation after a read-first architecture review.

Prompt 51 correctly stopped because older genuine MessageLens archives predate `.messagelens-archive.json` and contain no `archiveInstanceId` or equivalent durable archive identity.

Do NOT invent a fake legacy UUID.

Do NOT use path, filename, timestamps, filesystem metadata, or content hashes as a substitute durable Historical Archives identity.

Instead, revisit the product model.

The key architectural question is:

> Does an older MessageLens attachment-recovery donor need to be a durable Historical Archives source at all?

The current product direction says no.

This task should formalize and implement that distinction.

Suggested prompt name:

`prompts/52-EPHEMERAL-MESSAGELENS-RECOVERY-DONORS-VS-DURABLE-HISTORICAL-SOURCES.MD`

## Context

Historical Archives now contains two conceptually different arms.

### Mac Messages

A selected Messages folder may become a durable historical content source.

MessageLens may import message facts from it.

Therefore it needs:

- canonical `HistoricalArchiveSourceIdentity`;
- durable source registration;
- source-scoped provenance;
- later removal;
- Folders Already Added membership.

### MessageLens

A selected older MessageLens data folder is used only to recover missing attachment payloads for messages already present in the current MessageLens archive.

It does NOT contribute:

- messages;
- graph facts;
- overlays;
- donor source registry;
- durable historical message provenance.

The donor is simply:

> a read-only recovery location used for one recovery session.

It may be selected again later and rescanned idempotently.

Therefore a MessageLens recovery donor may not need durable Historical Archive source identity at all.

## Product rule

Formalize:

> A MessageLens attachment-recovery donor is an ephemeral recovery candidate, not a durable Historical Archives source.

This means:

- no `Folders Already Added` cartouche;
- no durable donor membership;
- no later “Remove this folder…” semantics;
- no need to reconstruct legacy `archiveInstanceId`;
- no fake identity minted from path;
- donor path may be used only as a current-session locator;
- safety derives from compatibility + same-Messages-lineage proof + per-message/per-attachment proof.

Modern MessageLens donors may still expose `archiveInstanceId` as useful diagnostic/archive evidence, but that UUID is not required to authorize attachment recovery if the donor is otherwise a supported historical format and passes the stronger recovery proofs.

## Preserve D3

Do NOT weaken D3.

`HistoricalArchiveSourceIdentity` remains the sole authority for durable historical sources.

The correction is:

> Legacy MessageLens recovery donors are not durable historical sources, so they do not require `HistoricalArchiveSourceIdentity`.

Do not add a second durable identity system.

Do not put path-based identity back into the product.

## Read first

Read:

- Prompt 51 audit/result;
- canonical historical archive identity docs;
- `HistoricalArchiveSourceIdentity`;
- MessageLens ready-state implementation from Prompt 50;
- shared same-Messages-lineage service;
- attachment matching/preflight;
- safe attachment installer infrastructure;
- D1 typed Historical Archives state;
- D2 Tracks;
- current MessageLens source identity assumptions in presentation/workflow.

Identify every place where the MessageLens arm currently requires:

- `archiveInstanceId`;
- `HistoricalArchiveSourceIdentity`;
- durable source registration;
- source-like membership.

Classify each as truly necessary or inherited from Mac Messages symmetry.

## Structural qualification for ephemeral recovery donors

Define a supported MessageLens recovery donor using historical format evidence rather than durable source identity.

The qualification pipeline should conceptually become:

selected folder
→ recognizable MessageLens data-folder structure?
→ supported historical/current format?
→ required donor databases readable read-only?
→ same-Messages-lineage admission?
→ attachment recovery preflight
→ ready state.

No durable identity is required between compatibility and lineage admission.

## Current-format donor

If `.messagelens-archive.json` exists:

- validate it;
- read `archiveInstanceId`;
- retain it as diagnostic/session evidence;
- do not require persistence merely because it exists.

A current-format donor remains an ephemeral recovery candidate unless future product requirements say otherwise.

## Legacy donor

If modern marker is absent:

do not immediately classify as invalid.

Instead determine whether the folder matches a **documented supported historical MessageLens archive format**.

Prompt 51 established known genuine generations:

- May 31 — `0.1.16+17`
- June 20 — `0.1.16+17`
- July 27 — `0.2.15+33`

These archives:

- predate markers;
- contain healthy compatible SQLite databases;
- contain no archiveInstanceId;
- are readable by current attachment evidence infrastructure.

Use canonical historical format evidence to recognize them.

Do not hard-code user folder names or dates.

## Historical format signature

Establish a typed compatibility signature based on actual format history.

This may include:

- specific required database set;
- schema/version evidence inside those databases;
- known table/column combinations;
- archive-owned directory layout;
- attachment archive structure;
- another canonical historical fact.

Do not admit a folder merely because familiar filenames exist.

A fake folder containing empty `working_ss.db` and `attachment_archive` must not qualify.

Recognition must be based on sufficient structural/schema evidence to say:

> This is a supported historical MessageLens data-folder generation.

## Identity versus compatibility

Keep these separate.

A legacy donor may be:

- structurally recognized as MessageLens;
- schema-compatible for attachment recovery;
- lacking durable archive identity;
- still perfectly usable as an ephemeral recovery donor after lineage proof.

This is not an identity workaround.

No durable identity is being asserted.

## Same-lineage admission becomes the safety authority

For legacy recovery donors, the strongest safety gate is the existing exact Messages lineage proof.

The donor must pass:

original ROWID ↔ GUID comparison
→ `sameLineage`.

If:

- `contradictoryLineage`;
- `insufficientEvidence`;

then recovery remains blocked.

Thus the absence of archiveInstanceId does not reduce the safety of matching attachment payloads to current messages.

## Per-attachment proof remains mandatory

Even after archive-level lineage passes:

each donor attachment candidate must still satisfy existing exact per-message/per-attachment matching.

Do not weaken:

- original message ROWID;
- GUID agreement;
- attachment ROWID relationship;
- attachment GUID noncontradiction;
- donor path safety;
- payload verification;
- current payload missing state.

## Typed donor candidate

Introduce/refine a typed ephemeral candidate model.

Conceptually:

`MessageLensAttachmentRecoveryDonor`

may contain:

- selected root locator;
- detected donor format generation;
- optional archiveInstanceId;
- compatibility evidence;
- same-lineage admission;
- read-only adapter/capability evidence as appropriate.

It must NOT imply durable Historical Archives source membership.

Do not persist the locator merely to satisfy a type.

## Historical Archives presentation state

Use D1 sealed presentation state.

The MessageLens ready-state payload should carry an ephemeral donor candidate/preflight result.

Do not force it into a `HistoricalArchiveSourceIdentity` slot.

If the current shared state payload is too source-oriented, narrow/generalize the payload only as much as two real source-arm semantics now justify.

Do not reopen nullable combinatorial state.

## MessageLens segment hub

Preserve the current MessageLens sidebar:

- recovery-specific guidance;
- `Choose MessageLens Folder…`;
- no persistent donor cartouche list unless there is already a separate justified recovery-history feature.

The absence of durable source identity reinforces this decision.

## Qualification outcomes

After this correction:

### Not a MessageLens data folder

Arbitrary unrelated folder.

Modal:

**This doesn’t appear to be a MessageLens data folder.**

### Recognizable but unsupported MessageLens archive

Known MessageLens structure/version but current recovery adapter cannot safely inspect it.

Distinct modal.

### Supported current-format donor

Proceed.

### Supported legacy-format donor without archiveInstanceId

Proceed as ephemeral donor.

Do not warn merely because archiveInstanceId is absent.

### Foreign lineage

Reject through existing lineage modal.

### Insufficient lineage evidence

Reject through existing uncertainty modal.

## No durable source registration

MessageLens donor qualification/preflight must not:

- call source registrar;
- create source ledger membership;
- create Folders Already Added entry;
- persist donor path as identity;
- create a synthetic archive UUID.

Add tripwires.

## Modern archiveInstanceId role

Document clearly:

For MessageLens attachment recovery:

`archiveInstanceId` answers:

> Which MessageLens archive produced this candidate, when available?

It does NOT answer:

> Is this safe to recover attachments from?

Safety is established by same-Messages-lineage and per-attachment proof.

It may be useful for:

- diagnostics;
- future recovery history;
- duplicate-session logging.

But it is not required for legacy donor admission.

## Repeated donor selection

Because donors are ephemeral and recovery is idempotent:

the same donor may be selected repeatedly.

Each time:

- structural compatibility rechecked;
- lineage rechecked;
- attachment preflight recomputed from current payload state.

No “already added” error.

This is desirable.

## Ready state

A supported legacy donor should now be able to reach the same read-only ready state as a supported modern donor.

Primary evidence remains:

- recoverable attachment count;
- recoverable byte total;
- diagnostic classifications under Details.

Do not expose archiveInstanceId absence in primary copy.

## Zero-result donor

Preserve current calm zero-recoverable behavior.

A legacy donor with nothing recoverable is still valid.

## Actual recovery mutation

This task may remain read-only through ready state if current UI still intentionally omits `Recover Attachments`.

Do not broaden scope unless actual recovery orchestration is separately approved.

The goal here is to remove the inappropriate durable-identity barrier.

## Architecture ownership

Place historical MessageLens format recognition in the MessageLens donor compatibility/attachment-recovery domain, not in widget code.

Historical Archives orchestrates:

choose
→ qualify compatibility
→ lineage
→ preflight.

Attachments/recovery domain owns what donor format evidence is sufficient for safe attachment matching.

## Tests

Add/update focused tests proving:

1. durable Mac Messages sources still require `HistoricalArchiveSourceIdentity`;

2. MessageLens recovery donors do not require durable HistoricalArchiveSourceIdentity;

3. modern donor with archiveInstanceId qualifies;

4. supported legacy donor without archiveInstanceId qualifies;

5. no synthetic UUID is created for legacy donor;

6. path is not promoted to durable identity;

7. fake folder with copied filenames fails;

8. historical format recognition uses schema/structural evidence;

9. recognizable unsupported archive receives incompatible result;

10. same-lineage gate remains mandatory for legacy donor;

11. contradictory lineage rejects;

12. insufficient lineage rejects;

13. attachment preflight remains required;

14. per-attachment proof remains unchanged;

15. no source registration occurs;

16. no cartouche is created;

17. same donor may be selected again idempotently;

18. D1 typed states remain intact;

19. D2 Tracks remain intact;

20. D3 durable-source identity remains intact for the things it actually owns.

Do not mechanically create one test per item.

## Architecture tripwires

Add strong repository checks preventing:

- MessageLens recovery donor from requiring `buildSourceKey`/path identity;
- source registrar use in MessageLens recovery flow;
- synthetic legacy archiveInstanceId creation;
- persistent donor membership;
- bypass of lineage gate.

## Canonical documentation correction

Update the canonical historical archive identity guidance.

It currently records the Prompt 51 limitation.

Clarify:

> `HistoricalArchiveSourceIdentity` is required for durable Historical Archives sources.

> MessageLens attachment-recovery donors are ephemeral recovery candidates and do not become durable sources; therefore supported legacy donors may be used without archiveInstanceId when their format is recognized and same-Messages-lineage/per-attachment proof succeeds.

This is a refinement of ownership, not weakening identity.

Update Prompt 51 follow-up documentation to mark its “unsupported” conclusion as superseded by the clarified product model.

Do not erase the historical record.

## Known legacy target

The real manual target is the older archived MessageLens folder already tested.

After implementation it should proceed beyond the previous invalid-folder modal.

Expected manual sequence:

MessageLens
→ Choose MessageLens Folder…
→ select historical data folder
→ supported legacy recognition
→ same-lineage admission
→ attachment preflight
→ ready state / zero-result / truthful lineage outcome.

Do not hard-code its path.

## Safety

No real mutation.

No donor writes.

No marker creation.

No archiveInstanceId creation in donor.

No message import.

No graph mutation.

No overlay merge.

No attachment copying unless separately authorized.

## Verification

Run:

- MessageLens donor qualification tests;
- legacy compatibility tests;
- lineage tests;
- attachment preflight tests;
- Historical Archives state/presentation tests;
- Mac Messages regressions;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

## Stop conditions

STOP if:

- supported historical MessageLens formats cannot be distinguished from arbitrary fake folders without durable identity;
- same-lineage evidence cannot be obtained from those formats;
- legacy donor databases require in-place migration;
- attachment preflight cannot consume them safely;
- enabling ephemeral donors would weaken durable-source D3 semantics.

Do not invent path identity as fallback.

## Final report

Report:

- final distinction between durable historical source and ephemeral recovery donor;
- supported legacy format evidence;
- typed donor candidate model;
- role of optional archiveInstanceId;
- qualification pipeline;
- lineage behavior;
- source registration/cartouche behavior;
- canonical documentation correction;
- tests/tripwires;
- commit hash;
- manual retest instructions;
- whether the real legacy donor can now reach attachment preflight/ready state.

Acceptance standard:

> A legacy MessageLens folder should not need a durable source identity when it is never becoming a durable source. It should be admitted as an ephemeral recovery donor only when its historical MessageLens format is recognized, it passes the same current Messages-lineage proof, and each recoverable attachment remains independently provable.
