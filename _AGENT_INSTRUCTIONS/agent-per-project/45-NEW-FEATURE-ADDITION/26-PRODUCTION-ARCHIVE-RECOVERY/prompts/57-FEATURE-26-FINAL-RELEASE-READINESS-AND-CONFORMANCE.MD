Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for a long-running **final release-readiness, architecture-conformance, cleanup, and verification pass** over Feature 26 — Historical Archives.

This is NOT a feature-design prompt.

Do not add new capabilities merely because you can imagine them.

The goal is:

> Determine whether Historical Archives, as now implemented and manually validated, is clean enough architecturally and operationally to declare Feature 26 complete.

If bounded defects, obsolete scaffolding, documentation drift, accessibility issues, or clear architecture violations are found, fix them.

If a finding requires new product design, schema migration, broad architectural redesign, or expansion of feature scope, document and defer it rather than reopening the feature.

Suggested prompt name:

`prompts/57-FEATURE-26-FINAL-RELEASE-READINESS-AND-CONFORMANCE.MD`

# Current product contract

Historical Archives now contains two intentionally different source arms.

## Mac Messages

Purpose:

> Add historical messages from another folder derived from the same continuing local Mac Messages `chat.db` lineage.

It supports:

- Messages-folder structural qualification;
- same-Messages-lineage admission;
- GUID-based overlap comparison;
- explicit ready-state evidence;
- source-scoped historical import;
- real Directed Instrumentation;
- combined-history graph preparation;
- terminal verification;
- durable `Folders Already Added` membership;
- selected-source management;
- source-scoped removal;
- deterministic reimport.

Mac Messages folders are **durable Historical Archives sources**.

## MessageLens

Purpose:

> Recover missing attachment payloads from an older MessageLens data folder derived from the same continuing local Mac Messages `chat.db` lineage.

It supports:

- current and supported legacy MessageLens donor qualification;
- ephemeral donor semantics;
- same-Messages-lineage admission;
- exact message/attachment matching;
- physical payload-presence evidence;
- exact recoverable count/byte preflight;
- preservation-safe recovery;
- execution-time integrity verification;
- atomic no-overwrite installation;
- exact-scope `attachmentReconciliation` mutation authority;
- real count/byte progress;
- terminal verification;
- idempotent rescan.

MessageLens folders are **ephemeral recovery donors**, not durable Historical Archives sources.

They do NOT:

- import donor messages;
- import donor graph/search data;
- import donor overlays;
- become `Folders Already Added`;
- acquire synthetic durable identity;
- receive removal semantics.

# Manual validation already completed

Do not rerun destructive/manual experiments.

The following real-format validation has already succeeded and is documented.

## Mac Messages

The historical Messages ingestion/removal journey has been repeatedly exercised against the disposable staging archive.

The UI now has:

- stable ready state;
- responsive authorization;
- Narrator + Directed Instrumentation;
- real graph progress;
- stable Tracks;
- terminal acknowledgement;
- coherent removal journey.

## MessageLens controlled-loss validation

A controlled-loss test deliberately removed:

- **7 attachment payload files**
- **918,067 bytes**

from a disposable receiving MessageLens archive.

The intact same-lineage donor independently produced preflight:

- exactly 7 recoverable;
- exactly 918,067 bytes.

Recovery restored exactly 7.

Independent post-recovery verification proved for all seven:

- expected file existed;
- exact byte size matched;
- SHA-256 matched the pre-loss manifest.

A second scan reported:

- zero recoverable.

This evidence is already recorded in Feature 26 documentation.

Do not recreate the controlled loss.

# Read first

Before editing, read the canonical project instructions and the final Feature 26 documentation necessary to understand the settled architecture.

At minimum include:

- project start/architecture guidance;
- Feature 26 index;
- architecture-conformance audit;
- D1 typed-state remediation;
- D2 stable Track remediation;
- D3 source-identity remediation;
- canonical Historical Archives source-identity guide;
- canonical Messages-lineage admission guide;
- canonical attachment archive/recovery guide;
- Narrator + Directed Instrumentation / Presence rendering guidance;
- recent MessageLens qualification/preflight/recovery implementation records;
- controlled-loss validation record;
- current changelog/version rules;
- architecture tripwire rules.

Do not treat every historical Feature 26 response as current architecture.

Historical records explain evolution.

Canonical docs define current rules.

# Phase 1 — establish final invariants

Before editing, write a concise final Feature 26 invariant checklist.

At minimum include:

## Durable-source truth

- Mac Messages source identity has one canonical authority.
- Imported membership derives from durable source facts, not display labels.
- Source provenance survives overlap.
- Removal is source-scoped.
- Donor/source folders are never mutated.

## MessageLens recovery truth

- donor is ephemeral;
- donor path is locator, not durable identity;
- no synthetic archive UUID;
- same-lineage admission required;
- per-message/per-attachment proof required;
- physical filesystem truth determines payload presence;
- preservation-safe writer is sole payload installation authority;
- exact-scope mutation capability required;
- recovery is idempotent;
- no message/graph/overlay import.

## State truth

- D1 sealed presentation-state model remains sole workflow representation;
- contradictory presentation states cannot be reconstructed through compatibility fields;
- stale async callbacks cannot resurrect abandoned sessions.

## Spatial truth

- D2 stable A–I center Track skeleton remains universal;
- Narrator silence does not move Directed Instrumentation;
- variable cartouche lists remain independent native flow.

## Identity truth

- D3 `HistoricalArchiveSourceIdentity` remains sole durable historical-source identity authority;
- Messages lineage is a separate canonical proof;
- display names and paths cannot substitute for lineage.

## Mutation truth

- `ArchiveMutationCoordinator` remains sole process-local mutation authority where prescribed;
- attachment recovery requires exact-scope `attachmentReconciliation` capability;
- capability cannot be retained/reused outside scope.

## Time truth

- `DateConverter` remains sole Apple timestamp authority.

## Presentation truth

- sidebar and center own distinct responsibilities;
- modals remove invalid/duplicate/terminal conditions from ordinary center flow where established;
- orange means referential correspondence only;
- blue means selected object;
- Narrator commentary is phase-scoped;
- silence is legitimate;
- Directed Instrumentation reports real work only;
- terminal completed truth remains perceptible.

Use this checklist to drive the audit.

# Phase 2 — audit for temporary scaffolding

Search Feature 26 and related infrastructure for implementation scaffolding that should not ship.

Look for:

- temporary debug prints;
- ad-hoc logging added solely during diagnosis;
- benchmark hooks;
- controlled-loss helper code accidentally reachable in product;
- fixture-only APIs in production libraries;
- temporary timing instrumentation;
- debug-only buttons;
- manually forced source paths;
- hard-coded staging paths;
- hard-coded donor paths;
- references to the seven-file controlled-loss manifest;
- `/tmp` paths;
- special cases for test archive versions outside canonical compatibility rules;
- commented-out old implementations;
- TODO/FIXME notes introduced during this feature.

Do not remove useful production diagnostics merely because they helped debugging.

Classify before deleting.

# Phase 3 — audit superseded UI/state code

Historical Archives went through many iterations.

Prove whether any obsolete production code remains from:

- giant Execution Gate panel;
- old Preflight Summary;
- Activity Log;
- old Progress card;
- Result Summary;
- old `alreadyImported` center-panel state;
- `Choose Another Folder`;
- persistent orange success reference;
- operation-wide static Narrator;
- pre-Track top spacers;
- old context/stage compatibility state;
- operation-only Track branches;
- selected-source Track bypass;
- MessageLens disabled-segment placeholders;
- pre-ephemeral-donor durable-source assumptions.

Remove code only when mechanically unreachable/obsolete.

Do not delete a fallback that still has a legitimate failure/debugging role without replacing that role.

# Phase 4 — state architecture conformance

Audit every current `HistoricalArchivesPresentationState` variant.

Produce a current variant table showing:

- purpose;
- source arm(s);
- required evidence;
- allowed controls;
- allowed notices;
- progress ownership;
- next transitions.

Check for:

- variants no longer reachable;
- variants whose payload still contains obsolete Mac-Messages-only assumptions;
- MessageLens recovery states implemented outside the sealed model;
- redundant booleans that can contradict the variant;
- widgets inferring state from nullability/progress rather than matching the variant.

Fix clear violations.

Do not redesign the union merely to rename things.

# Phase 5 — async/session conformance

Trace every delayed/asynchronous path in Historical Archives:

- folder chooser completion;
- structural inspection;
- lineage admission;
- attachment preflight;
- import authorization;
- graph observations;
- removal;
- duplicate modal dismissal;
- invalid modal dismissal;
- success modal dismissal;
- completion dwell;
- MessageLens recovery;
- recovery terminal verification;
- segment switching;
- navigation away.

For each prove:

> Can a completion from an obsolete session mutate/present state after a newer session begins?

Use the established session/occurrence architecture.

Search for unguarded:

- Futures;
- timers;
- `endOfFrame` callbacks;
- modal completion callbacks;
- progress streams/listeners.

The legitimate `endOfFrame` paint barriers should remain if correctly scoped.

# Phase 6 — mutation-authority audit

Perform a focused post-Prompt-55 authority audit.

Trace:

## Mac Messages

inspection  
→ registration  
→ import  
→ graph preparation  
→ verification  
→ removal.

## MessageLens

preflight  
→ authorization  
→ `runWithCapability`  
→ batch executor  
→ preservation-safe installer  
→ metadata reconciliation  
→ final verification.

Confirm:

- no direct mutation bypass;
- no broad capability;
- exact operation scope;
- capability invalid outside originating async scope;
- nested scope rules hold;
- widgets cannot invoke low-level writers directly;
- expected read-only operations do not accidentally require mutation authority.

Add/fix tripwires if necessary.

# Phase 7 — database/read-only audit

Confirm donor/source safety.

## Mac Messages donor

- read-only;
- no WAL/SHM mutation where architecture promises immutable access;
- no schema migration.

## MessageLens donor

- read-only compatibility adapters;
- no marker creation;
- no schema migration;
- no synthetic identity persistence;
- no attachment mutation.

## Current stores

Confirm canonical construction/opening.

Search for ad-hoc SQLite connections introduced during optimization/forensics.

Ensure worker-isolate database work still uses an approved read-only construction seam rather than bypassing database ownership.

# Phase 8 — performance audit

Do not perform another broad optimization campaign.

Instead verify that the fixes which made MessageLens preflight:

~210 seconds
→ ~7.5 seconds benchmark
→ ~5–8 seconds manually

remain structurally protected.

Check for regressions such as:

- N² matching;
- per-claim database queries;
- preflight SHA-256;
- exhaustive SQLite integrity scans;
- duplicate preflight execution;
- main-isolate CPU work;
- repeated filesystem probes.

Preserve:

- O(N) indexed matching;
- worker-isolate database work;
- 250-claim filesystem progress batching;
- 1,000-claim relationship batching;
- execution-boundary SHA-256.

Architecture tests should protect the important rules where practical.

# Phase 9 — Directed Instrumentation truth audit

Enumerate every displayed Historical Archives progress row.

For each identify:

- real execution boundary;
- numerator source;
- denominator source;
- completion condition.

Cover:

## Mac Messages import

- source addition;
- graph preparation;
- Participants;
- Conversations;
- Messages;
- Attachments;
- Relationships;
- final verification.

## Mac Messages removal

same appropriate removal/rebuild observations.

## MessageLens preflight

current measured phases/counts.

## MessageLens recovery

- donor verification;
- payload installation;
- final verification;
- attachment count;
- byte progress.

Confirm:

- no timer advances work;
- no elapsed-time-derived percentages;
- no denominator borrowed from a different scope;
- no stale row remains Working after completion;
- terminal dwell contains only Done states.

# Phase 10 — Narrator lifecycle audit

Enumerate every Narrator statement and its typed-state ownership.

Confirm:

- source-specific comments expire when their phase expires;
- combined-history comments disappear before final verification;
- MessageLens preflight Narrator remains truthful;
- recovery Narrator remains truthful;
- removal Narrator changes with scope;
- silent final verification stays silent where established;
- success modal, not Narrator, owns terminal acknowledgement.

Search for strings rendered outside canonical projection that could become stale.

# Phase 11 — Track/layout audit

Confirm one stable center A–I skeleton remains.

Check both arms and all major states:

- hub;
- selected Mac Messages source;
- Mac ready;
- Mac importing;
- Mac removing;
- MessageLens inspecting;
- MessageLens ready;
- MessageLens recovering;
- failures;
- notices.

Confirm:

- no state-dependent Track boundary;
- no arbitrary top spacers replacing Track responsibility;
- Narrator Track remains fixed;
- Directed Instrumentation does not jump;
- sidebar variable list remains independent.

Do not make aesthetic spacing changes unless correcting a clear violation.

# Phase 12 — sidebar/center/modal ownership audit

For each arm confirm final ownership.

## Mac Messages sidebar

- source selector;
- durable folders already added;
- start new Messages-folder attempt.

## Mac center

- selected-source story/management;
- candidate evidence;
- import/removal journey.

## MessageLens sidebar

- source selector;
- recovery guidance;
- choose ephemeral donor.

No durable donor list unless product has explicitly adopted one.

## MessageLens center

- inspection;
- recoverable evidence;
- recovery journey.

## Modals

Check:

- invalid folder;
- unsupported folder;
- foreign lineage;
- insufficient lineage;
- duplicate Mac source;
- destructive removal confirmation;
- zero-recoverable acknowledgement;
- import success;
- recovery success/partial completion.

Find controls duplicated across ownership boundaries.

# Phase 13 — terminology/copy consistency

Perform a restrained copy audit.

Do NOT rewrite working prose for style.

Look only for contradictions/inconsistency such as:

- “archive” where user-facing product has settled on “folder”;
- “import” where MessageLens arm actually means “recover”;
- “added source” applied to ephemeral MessageLens donor;
- `Message Lens` versus `MessageLens`;
- MacOS/macOS inconsistencies;
- stale “Choose Another Folder”;
- “known source” language;
- technical terms leaked into primary UI;
- success copy implying donor became permanent.

Fix clear inconsistencies.

Preserve approved copy otherwise.

# Phase 14 — accessibility audit

Audit the final interactive surfaces for existing project accessibility conventions.

At minimum check:

- segmented control;
- chooser buttons;
- Add/Recover/Cancel;
- Details disclosure;
- destructive Remove;
- modal actions;
- progress semantics;
- reduced-motion behavior;
- orange correspondence;
- blue selection;
- disabled controls.

Ensure information is not conveyed solely by:

- color;
- animation;
- spinner.

Progress rows should have meaningful textual state.

Do not launch a broad accessibility redesign.

Fix bounded clear defects.

# Phase 15 — error/failure audit

Enumerate failure paths and confirm no generic control-panel fallback has silently survived as ordinary UX.

For each failure ask:

- does user receive concise human meaning?
- are technical diagnostics available under Details/logs?
- does failure preserve truthful completed progress?
- does it avoid false success?
- does hub/source state reflect durable truth?
- can retry occur safely where supported?

Search for broad exception catches and swallowed failures.

# Phase 16 — recovery integrity audit

Post controlled-loss validation, prove the production path still enforces:

same lineage  
→ message identity  
→ attachment identity  
→ physical missing state  
→ explicit authorization  
→ execution-time hash/size verification  
→ temp installation  
→ atomic no-overwrite `link(2)`  
→ metadata after payload  
→ final verification.

Ensure no fast path added during manual testing bypasses any layer.

# Phase 17 — source-scoping audit

Confirm message and attachment scoped IDs use only canonical `SourceScopedRowKey` packing/unpacking.

Search for duplicate bit arithmetic.

Protect:

20-bit source / 43-bit row scheme

through canonical authority.

No presentation/application code should manually unpack IDs.

# Phase 18 — DateConverter audit

Search repository-wide again for Apple epoch arithmetic introduced during Feature 26.

`DateConverter` remains sole authority.

No magnitude heuristics.

No SQL epoch addition.

No local helper.

# Phase 19 — documentation drift

Compare current behavior against canonical docs.

Specifically ensure canonical docs reflect:

- two-arm product contract;
- shared Messages-lineage gate;
- durable Mac source vs ephemeral MessageLens donor;
- legacy MessageLens compatibility;
- preflight versus execution-time hashing;
- preservation-safe writer;
- exact-scope mutation capability;
- controlled-loss validation;
- stable Tracks;
- Narrator lifecycle.

Mark superseded conclusions in historical audit records only through follow-up references; do not rewrite history.

# Phase 20 — D4

The architecture audit previously left D4 deliberately unresolved:

> frozen legacy Drift tables remain writable through generated APIs.

Reassess only whether Feature 26 now depends on those writable APIs in a way that creates a release blocker.

Do NOT solve D4 merely because it exists.

Classify:

- still deferred/non-blocking;
- now a Feature 26 release blocker.

If blocking, STOP and report.

# Phase 21 — dead code and dependency cleanup

After all audits, search for:

- unused imports;
- unused providers;
- obsolete helpers;
- duplicate types;
- dead strings;
- superseded tests;
- dependencies added during experimentation but no longer needed.

Use analyzer/compiler evidence.

Do not perform speculative cleanup.

# Phase 22 — final architecture tripwires

Review the architecture suite.

Ensure it protects the final settled rules, particularly:

- D1 typed state;
- D2 Tracks;
- D3 source identity;
- shared lineage authority;
- MessageLens ephemeral donor;
- no donor source registration;
- no donor message import;
- no graph rebuild for recovery;
- preservation-safe writer only;
- mutation capability required;
- DateConverter;
- canonical source-scoping;
- preflight no hashing;
- physical file truth;
- no direct recovery file copy.

Add missing high-value tripwires.

Avoid brittle implementation-detail tests.

# Phase 23 — final full verification

Run the strongest practical verification.

At minimum:

- complete Flutter test suite;
- complete architecture tripwire suite;
- Settings suite;
- Historical Archives focused suite;
- Mac Messages import/removal suites;
- MessageLens qualification/preflight/recovery suites;
- source-scoping tests;
- lineage tests;
- attachment writer/installer/batch tests;
- mutation coordinator tests;
- Onboarding/readiness regressions;
- DateConverter tests;
- Track/layout tests;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Do not rerun real GUI mutation.

The controlled-loss validation already provides manual end-to-end evidence.

# Phase 24 — release-readiness record

Create a final Feature 26 release-readiness/conformance record under `responses/`.

It should summarize:

1. final product contract;
2. final architecture;
3. final Historical Archives state model;
4. final Track contract;
5. durable Mac Messages source semantics;
6. ephemeral MessageLens donor semantics;
7. shared Messages-lineage admission;
8. Mac Messages import/removal mutation boundaries;
9. MessageLens attachment-recovery mutation boundaries;
10. Narrator + Directed Instrumentation behavior;
11. performance findings and protections;
12. manual validations completed;
13. controlled-loss recovery evidence;
14. architecture violations found and corrected during this pass;
15. obsolete scaffolding/dead code removed;
16. accessibility corrections, if any;
17. documentation corrections;
18. remaining deliberately deferred issues;
19. D4 status;
20. complete verification results;
21. explicit release-readiness recommendation.

The record should answer plainly:

Is Feature 26 — Historical Archives — architecturally conformant, behaviorally validated, documented, and ready to be considered complete?

Do not answer “yes” merely because tests pass.

Base the recommendation on the full audit.

Phase 25 — determine whether Feature 26 is complete

Classify the result as one of:

READY

No known defect or architecture violation remains that should block completion of Feature 26.

Small future enhancements may exist, but they are not required for the product contract already implemented.

READY WITH DEFERRED NON-BLOCKERS

Feature 26 is complete for its defined scope, with clearly documented issues that belong to broader architecture or future work and do not compromise the feature.

D4 may fall here if confirmed non-blocking.

NOT READY

A specific unresolved defect, architecture violation, safety issue, or product inconsistency should prevent Feature 26 from being closed.

If NOT READY:

- identify the exact blocker;
- explain why it is a blocker;
- propose the smallest next remediation;
- do not broaden into unrelated work.

Scope discipline

Historical Archives has already undergone extensive product and architecture refinement.

Do NOT use this pass to introduce ideas such as:

- arbitrary archive federation;
- MessageLens message import;
- donor overlay merging;
- persistent MessageLens donor history;
- generalized recovery provenance UI;
- new historical source types;
- progress percentages merely for polish;
- new database abstractions unrelated to a confirmed violation;
- redesign of working UI.

The test for adding work in this pass is:

Does the current defined Historical Archives product require this to be correct, safe, coherent, accessible, or maintainable?

If not, defer it.

User-visible behavior preservation

The following manually approved behaviors should remain materially unchanged unless a confirmed defect requires correction.

Mac Messages

- Mac Messages | MessageLens segmented control.
- explanatory sidebar structure.
- Folders Already Added.
- durable source cartouches.
- source selection in blue.
- duplicate correspondence in subtle bounded orange only.
- invalid/duplicate conditions handled by modal.
- empty virgin center panel.
- ready-state evidence.
- Add Messages to MessageLens.
- Cancel returns to virgin state.
- immediate operation feedback.
- Narrator scope transition.
- real graph progress.
- terminal all-Done dwell.
- success acknowledgement.
- selected-source story.
- destructive remove flow.
- real removal Directed Instrumentation.

MessageLens

- recovery-specific sidebar guidance.
- no durable donor cartouches.
- legacy/current donor qualification.
- same-lineage gate.
- fast preflight.
- real preflight progress.
- exact recoverable count/bytes.
- calm zero-recoverable acknowledgement.
- Recover Attachments only when recoverable candidates exist.
- real attachment/byte progress.
- final verification.
- completion/partial-result acknowledgement.
- hub return.
- idempotent rescan.

Do not “normalize” intentional differences between the two arms.

Manual evidence inventory

The final readiness record should explicitly distinguish:

Automated evidence

Tests, analyzer, architecture tripwires, builds.

Human/manual evidence

Include at minimum the established manual findings:

Mac Messages

- valid historical folder recognition;
- invalid-folder modal behavior;
- duplicate-folder modal + gentle reference;
- import ready state;
- real progress behavior;
- successful historical import;
- heatmaps extending into recovered years;
- source removal;
- heatmaps returning to current-history range after removal;
- stable Tracks/Narrator behavior.

MessageLens

- genuine pre-marker archive recognized;
- immediate first paint after chooser;
- preflight reduced from multi-minute stall to approximately 5–8 seconds;
- progress instrumentation visibly advances;
- zero-result result correctly reconciled;
- controlled-loss seven-file recovery;
- exact preflight count/bytes;
- exact recovered count;
- independent size/SHA-256 verification;
- zero recoverable on repeat.

Do not manufacture manual evidence for paths not actually exercised.

Final cleanup of temporary documentation artifacts

Audit Feature 26 prompt/response files for accidental duplicates such as the previously observed 46b-... prompt.

If a duplicate is byte-identical and clearly accidental/untracked, remove it according to repository policy.

Do not delete distinct historical prompts merely because numbering became awkward.

Ensure Prompt 57 itself is archived completely.

Version/changelog

If application code changes during this final pass:

- apply the required version bump;
- add a concise changelog entry describing release-readiness hardening rather than internal minutiae.

If documentation/tests only change and project rules do not require an application version bump, do not bump merely for activity.

Commit discipline

Do not make a sequence of speculative cleanup commits.

Prefer one coherent final hardening commit, or a very small number if repository/submodule rules require separation.

Before committing:

- inspect full diff;
- verify no unrelated user changes were touched;
- verify no temporary machine paths/manifests entered source control;
- verify worktree/submodules are in expected state.

Commit and push if clean.

Hard stop conditions

STOP and report without forcing completion if any of the following is discovered:

- current product behavior can corrupt or overwrite user data incorrectly;
- same-lineage admission can be bypassed;
- attachment recovery can overwrite a valid current payload;
- mutation authority can be bypassed;
- donor archive can be mutated unintentionally;
- state model permits a materially contradictory reachable state;
- stable Track contract is materially violated;
- DateConverter/source-scoping/source-identity authority has been duplicated;
- MessageLens recovery imports messages/graph/overlays contrary to contract;
- Mac Messages removal can remove another source’s contribution;
- final verification can report success without durable/physical truth;
- a required fix needs schema migration or major redesign;
- D4 is shown to be an actual release blocker.

Do not paper over such a result with tests or documentation.

Final report to user

Return a structured but concise report containing:

1. Readiness classification
   - READY
   - READY WITH DEFERRED NON-BLOCKERS
   - NOT READY
2. Confirmed final product contract
   - Mac Messages
   - MessageLens
3. Architecture findings
   - violations found;
   - corrections made;
   - legitimate patterns explicitly cleared.
4. Cleanup
   - dead/superseded code removed;
   - temporary/debug scaffolding removed;
   - any retained diagnostic infrastructure and why.
5. Safety
   - mutation authority;
   - donor/source immutability;
   - source identity;
   - same-lineage gate;
   - attachment no-overwrite behavior;
   - final verification.
6. UX/presentation
   - typed state;
   - Tracks;
   - Narrator;
   - Directed Instrumentation;
   - accessibility findings.
7. Performance
   - Mac Messages progress;
   - MessageLens preflight;
   - recovery behavior;
   - protections against regression.
8. Manual validation
   - especially controlled-loss result:
     - 7 files;
     - 918,067 bytes;
     - exact detection;
     - exact restoration;
     - all SHA-256/size checks passed;
     - zero on rescan.
9. Deferred issues
   - especially D4;
   - explain why each is or is not blocking.
10. Verification
    - full test totals;
    - architecture totals;
    - analyzer;
    - build;
    - diff/format checks.
11. Documentation
    - final release-readiness record;
    - canonical docs updated.
12. Commit
    - commit hash;
    - branch;
    - worktree/submodule status.
13. Recommendation
    State plainly whether Feature 26 can now be closed and whether Ftr.archive-recovery is ready for the project’s normal integration/merge process.

Acceptance standard

The final question is:

If we stop working on Historical Archives today, is the feature correct because its architecture enforces the intended product rules, sufficiently validated by automated and real-world evidence, free of temporary scaffolding, and documented well enough that a future agent can maintain it without reconstructing this entire development history?

If yes, say so and close the feature.

If no, identify the specific blocker and nothing more.
