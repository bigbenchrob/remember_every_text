Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation.

The dormant infrastructure for MessageLens attachment recovery is now complete enough to expose a real user-facing **qualification → inspection → ready-state** journey.

This task should enable the `MessageLens` segment in Historical Archives and wire the arm through **safe read-only preflight**.

Do NOT yet enable the final `Recover Attachments` mutation unless the audit performed during this task proves that the existing preservation-safe installer, capability enforcement, preflight evidence, and operation orchestration can be connected without introducing any new architectural gap.

Preferred outcome for this slice:

> MessageLens segment becomes real and testable through the point where the user can see exactly what can be recovered.

Then STOP before payload mutation unless the mutation wiring is already mechanically complete and requires only trivial composition.

Suggested prompt name:

`prompts/50-ENABLE-MESSAGELENS-HISTORICAL-ARCHIVES-THROUGH-READY-STATE.MD`

# Product contract

Historical Archives now has two arms with deliberately different jobs.

## Mac Messages

Use this when the user wants to:

> add a partially overlapping set of messages from another snapshot/copy of the same continuing local Mac Messages `chat.db` lineage.

This arm:

- proves same Messages lineage;
- compares messages;
- source-scopes original ROWIDs;
- imports genuinely additional historical source facts;
- rebuilds combined browsing data.

## MessageLens

Use this when the user wants to:

> recover missing attachment payloads from an older MessageLens data folder derived from the same continuing local Mac Messages `chat.db` lineage.

This arm must:

- import no donor messages;
- import no donor graph;
- import no donor overlays;
- import no donor source registry;
- rebuild no graph solely for attachment recovery.

It uses the donor only to identify and recover missing attachment payloads for messages already represented in current MessageLens.

# Existing infrastructure now available

The previous work established:

- shared same-Messages-lineage admission;
- canonical MessageLens donor archive identity;
- read-only donor/current attachment evidence adapters;
- exact per-message and per-attachment matching;
- safe donor path validation;
- typed recovery classifications;
- exact recoverable attachment count;
- exact recoverable byte total;
- preservation-safe attachment installer;
- destination-domain temporary files;
- verification before final install;
- atomic no-overwrite `link(2)` installation;
- metadata update only after payload installation;
- retry convergence;
- exact-scope `attachmentReconciliation` mutation capability.

Do not reimplement any of these.

This task is primarily Historical Archives orchestration and presentation.

# Read first

Read:

- shared Historical Archives architecture;
- D1 typed presentation state;
- D2 stable Tracks A–I;
- D3 canonical historical-source identity;
- shared Messages-lineage admission;
- Response 47 attachment matching/preflight;
- Prompt 47 safe installer implementation;
- existing Mac Messages arm;
- current Historical Archives sidebar composition;
- current modal/session/occurrence mechanics;
- canonical Narrator + Directed Instrumentation guidance.

Before editing, explicitly identify which current Historical Archives components are:

- genuinely arm-shared;
- Mac-Messages-specific;
- reusable by MessageLens unchanged;
- requiring source-kind-specific evidence.

Do not generalize merely for symmetry.

# Enable the segmented control

The current sidebar shows:

`Mac Messages | MessageLens`

with MessageLens disabled.

Enable the MessageLens segment.

The control must now switch between two real Historical Archives source arms.

Do not change its labels.

# Arm switching semantics

Define and enforce clear transient-state behavior.

When no operation is active:

switching arms should:

- end the current arm's transient presentation session;
- return the destination arm to its virgin hub state;
- clear selected source;
- clear candidate evidence;
- clear stale notices/references;
- leave durable imported/recovery-source metadata untouched.

Do not carry an active Mac Messages candidate into MessageLens or vice versa.

## During admitted mutation

If a Mac Messages import/removal or future MessageLens recovery operation is actively holding mutation authority:

- do not allow switching into a competing arm if that would abandon or obscure the active operation;
- either disable the segment temporarily or preserve the active arm until terminal state.

Choose the mechanically safest behavior consistent with current UI conventions.

Do not rely on a warning after the fact.

# Sidebar content — MessageLens arm

The Mac Messages sidebar currently explains how to find a Messages folder.

MessageLens needs its own source-specific guidance.

The user is looking for:

> an older MessageLens data folder created by this installation lineage.

Use concise human language.

The sidebar should explain what kind of folder is needed without dumping internal database names.

Representative structure:

Historical Archives umbrella

`Mac Messages | MessageLens`

[MessageLens-specific existing/recovery-source area if warranted]

Add / Recover from a MessageLens Folder

brief explanation

Choose MessageLens Folder…

Do not blindly reuse the Mac Messages phrase:

`Folders Already Added`

until the source-persistence semantics are explicitly established.

# Important product question — persistent recovery-source list

The previous audit questioned whether MessageLens recovery donors should remain as permanent “added” sources after recovery.

Resolve that now for the ready-state workflow.

Preferred default unless stronger architecture argues otherwise:

> MessageLens donor folders are recovery sources, not permanent content sources.

Therefore do not automatically describe them as:

`Folders Already Added`.

Possible alternatives:

- `Recovery Folders Used`
- `Previous Recovery Folders`
- no persistent list at all before/after recovery.

Do not invent a permanent cartouche model merely for visual parity.

Use current persistence capability as evidence.

If no durable recovery-source record exists and none is required for safety, prefer **no persistent donor list** in this slice.

The virgin MessageLens hub may therefore consist simply of:

guidance

- Choose MessageLens Folder…

Return a recommendation and implement the smallest coherent model.

# Source qualification

Selecting a MessageLens folder must not immediately earn the ready screen.

Run the real read-only gates in order.

At minimum:

1. structural MessageLens archive qualification;
2. donor archive identity/compatibility;
3. same-Messages-lineage admission;
4. attachment recovery preflight.

Do not invent additional checks.

# Structural invalid folder

If selected folder is not a qualifying MessageLens archive:

- restore MessageLens virgin hub;
- show modal;
- no center-panel error residue;
- no blue selection;
- no orange reference;
- no persistence/mutation.

Representative meaning:

**This doesn’t appear to be a MessageLens data folder.**

Do not expose database filenames unless Details is specifically appropriate.

# Unsupported/incompatible MessageLens archive

Distinguish structural invalidity from:

> recognizable MessageLens archive that current build cannot safely inspect.

Use a distinct typed result and human modal/failure copy.

Do not call it simply “not a MessageLens folder.”

Examples may include unsupported schema/version or unreadable required evidence.

Fail closed.

# Same-lineage gate

Use the shared canonical Messages-lineage admission.

Do not implement another checker.

Possible outcomes:

## sameLineage

Continue to attachment preflight.

## contradictoryLineage

Return to hub and show concise modal.

Representative meaning:

**This MessageLens folder belongs to a different Messages history and can’t be used for attachment recovery.**

## insufficientEvidence

Return to hub and show distinct modal.

Representative meaning:

**MessageLens couldn’t verify that this folder came from the same Messages history.**

Do not collapse contradiction and uncertainty.

# Attachment recovery preflight

Once lineage is proven, run the dormant read-only matching/preflight layer.

It should classify donor/current attachment relationships without mutation.

Primary user question:

> Is there anything here that MessageLens can safely recover?

Use the exact aggregate facts already available.

At minimum investigate/display:

- safely recoverable attachment count;
- total recoverable bytes.

Potentially useful additional facts:

- already present;
- donor payload missing;
- conflicts/ambiguous.

But keep diagnostics subordinate.

# Ready-state product wording

If recoverable attachments exist, the MessageLens ready state should make the purpose explicit.

Representative Narrator:

**This folder comes from the same Messages history. I found attachments that are missing from MessageLens.**

Then concise evidence:

- Recoverable attachments: 1,842
- Recoverable size: 19.2 GB

Possibly:

Already present 6,314

only if useful.

Do not show technical mismatch classifications in primary content.

Details may expose them.

# No recoverable attachments

This is not an error.

If the donor is valid, same-lineage, and preflight finds zero recoverable payloads:

show a calm informational state or modal.

Representative meaning:

**There are no missing attachments in this folder that MessageLens can recover.**

Then return to hub or provide a simple acknowledgement.

Do not present a red failure state.

# Ready-state controls

If recoverable payloads exist, primary action should eventually be:

`Recover Attachments`

Secondary:

`Cancel`

Details disclosure as appropriate.

For this slice, determine whether the Recover button should be:

### A. visible but disabled

if mutation wiring is intentionally not enabled yet;

or:

### B. omitted

until the final recovery operation is implemented.

Prefer not to tease a nonfunctional control.

If mutation wiring is not enabled in this slice, use a read-only ready composition and stop before authorization.

However, if all mutation infrastructure is already mechanically complete and only orchestration is missing, you MAY proceed further under the bounded authorization below.

# Conditional authority to wire actual recovery

After implementing read-only arm qualification/preflight, perform an explicit architecture check.

You MAY wire the actual recovery operation ONLY if all of these are already true:

1. recoverable candidates are typed and execution-ready;
2. donor/current adapters are canonical;
3. preservation-safe installer is complete;
4. exact-scope `attachmentReconciliation` capability is required mechanically;
5. batch execution can be composed without schema changes;
6. interruption/retry naturally converges;
7. current attachment metadata can be updated safely;
8. no graph rebuild is required;
9. no donor mutation occurs;
10. no unresolved persistent-source/removal semantics are required to start recovery.

If any condition is false or uncertain:

STOP at ready-state implementation and report the blocker.

Do not invent the missing piece just to make the button work.

# If actual recovery is NOT wired

This is an acceptable successful outcome.

The MessageLens segment may be enabled through:

Choose folder
→ qualify
→ prove lineage
→ inspect attachments
→ show exact recoverable evidence

with mutation still dormant.

This gives the human a real, testable second arm without risking payload mutation.

# If actual recovery IS safely wireable

Only then continue with the following operation contract.

## Authorization

Primary:

`Recover Attachments`

No redundant confirmation modal unless current product conventions require one.

The ready evidence itself should provide informed authorization.

## Operation Narrator

Representative source-specific meaning:

**Recovering missing attachments from this MessageLens folder.**

If later scope changes meaningfully, Narrator may transition.

Do not narrate every file.

## Directed Instrumentation

Use real denominators already available.

At minimum:

Recovered attachments 412 / 1,842

Potentially:

Copied data 8.4 GB / 19.2 GB

Only if bytes are exact.

Do not add fake progress bars.

Raw counts are acceptable and consistent with Mac Messages.

## Failure

Expected per-file conflicts/missing payloads should be classified without necessarily aborting the entire batch.

Systemic invariant/storage failure may stop recovery.

At terminal state summarize truthfully:

- Recovered
- Already present
- Could not recover

Do not claim all-or-nothing success if individual files failed.

## Success

A recovery operation does not create new messages or graph content.

Terminal acknowledgement should say what actually changed.

Representative:

**Attachment recovery complete**

MessageLens recovered 1,842 missing attachments from the folder you selected.

`OK`

Do not say “folder added” unless the product adopts persistent donor-source semantics.

# Persistent source/cartouche behavior

Do not force Mac Messages semantics.

If recovery donor is not a durable active source:

- no new Folders Already Added cartouche;
- after recovery, return to virgin MessageLens hub;
- success modal acknowledges outcome;
- donor may be selected again later for an idempotent rescan.

This is currently the preferred model.

If existing architecture already persists donor recovery history safely, you may propose a quiet recovery-history UI later, but do not add it here unless necessary.

# Duplicate donor selection

The same donor folder should be safe to choose again.

Preflight should simply find:

- already present payloads;
- any still-missing recoverable payloads.

Thus repeated donor selection can be naturally idempotent.

Do not reject merely because archiveInstanceId was used previously unless there is a strong reason.

# Narrator + Directed Instrumentation during inspection

Measure the read-only preflight.

If structural/lineage/matching checks complete quickly, do not create fake staged UI.

If attachment matching takes perceptible time, expose truthful work.

Representative Narrator:

**I’ll check this MessageLens folder for attachments that are missing here.**

Directed Instrumentation only where real observations exist.

# Typed state model

Use D1 sealed Historical Archives presentation state.

Do not reopen nullable combinatorial state.

Determine whether existing variants can represent both arms through typed payloads/source-kind evidence.

Prefer:

shared semantic variants

- source-kind-specific evidence payloads.

Add new variants only if the human workflow genuinely differs.

Do not create a parallel MessageLens state machine.

# Stable Tracks

Use D2 stable A–I skeleton.

Do not create a second layout.

Narrator Track remains stable.

Center content must not jump when Narrator becomes silent.

# HistoricalArchiveSourceIdentity

Use D3 canonical source identity.

For MessageLens donor identity, use source-kind-specific evidence based on `archiveInstanceId` as established by Audit 44.

Path remains locator evidence only.

Do not reuse Mac Messages path identity semantics.

If `HistoricalArchiveSourceIdentity` needs a narrow source-kind extension already anticipated by D3, use it.

Do not redesign identity broadly.

# Modal grammar

Reuse established modal ownership:

invalid candidate
→ hub + modal

foreign lineage
→ hub + modal

insufficient lineage
→ hub + modal

nothing recoverable
→ calm acknowledgement

No center-panel red error dashboard.

# Sidebar interaction feedback

Use the now-established secondary-button hover/pressed grammar for:

`Choose MessageLens Folder…`

Do not create another button style.

# Details

Details may contain:

- donor archive instance ID;
- donor path;
- comparable lineage evidence;
- recoverable/missing/conflict counts;
- bytes;
- schema compatibility information.

Keep primary ready state concise.

# Architecture tripwires

Add protections proving:

1. MessageLens arm can be enabled without importing donor messages;

2. no donor graph/search/presence data is ingested;

3. no donor overlays are merged;

4. same-lineage admission is required before attachment preflight;

5. attachment matcher is required before recovery authorization;

6. recoverable counts derive from typed preflight;

7. MessageLens arm uses stable D1 state model;

8. MessageLens arm uses D2 Tracks A–I;

9. donor identity uses D3 authority/source-kind evidence;

10. donor databases remain read-only;

11. no recovery mutation occurs without exact-scope `attachmentReconciliation` capability;

12. Mac Messages arm remains unchanged.

# Tests

Add/update focused tests for:

## Segment switching

- MessageLens segment is enabled;
- switching from virgin Mac Messages → MessageLens gives virgin MessageLens hub;
- switching back restores virgin Mac Messages hub;
- transient candidate state does not leak across arms;
- switching is mechanically blocked/disabled during active mutation if required.

## Qualification

- arbitrary folder rejects;
- recognizable incompatible archive rejects distinctly;
- same-lineage donor proceeds;
- contradictory lineage modal;
- insufficient lineage modal.

## Preflight

- recoverable count exact;
- recoverable bytes exact;
- zero recoverable is informational, not failure;
- conflicts stay in Details/diagnostics.

## Presentation

- source-specific guidance;
- chooser button feedback;
- stable Tracks;
- Narrator lifecycle;
- no Mac Messages-specific wording leaks into MessageLens arm.

## Architecture

- no donor message import;
- no graph rebuild;
- no overlay merge;
- donor read-only;
- typed state remains coherent;
- source identity remains canonical.

## Conditional recovery, if wired

- capability required;
- real counts advance;
- installed/alreadyPresent/conflict outcomes truthful;
- retry idempotent;
- terminal summary accurate;
- no cartouche/source membership falsely created.

# Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- final two-arm product contract;
- MessageLens sidebar guidance;
- qualification pipeline;
- source identity evidence;
- same-lineage integration;
- attachment preflight;
- ready-state evidence;
- zero-recoverable behavior;
- persistent-source/cartouche decision;
- segment-switching semantics;
- whether recovery mutation was wired or intentionally deferred;
- architecture tripwires.

Update the broad MessageLens audit to mark which earlier general-ingestion concerns are now explicitly superseded by attachment-recovery-only scope.

Update canonical Historical Archives documentation with the arm distinction:

> Mac Messages adds historical messages from the same Messages lineage.

> MessageLens recovers missing attachment payloads from an older MessageLens folder from the same Messages lineage.

Update version/changelog according to repository rules.

# Safety

Do not run real recovery yourself.

Automated tests use temp stores/fixtures.

Do not mutate:

- production MessageLens data;
- staging archive;
- March archive;
- donor folders;
- live chat.db;
- real attachment payloads.

The human will perform manual testing.

# Verification

Run:

- MessageLens-arm presentation/preflight tests;
- attachment matcher tests;
- lineage tests;
- Historical Archives typed-state tests;
- Settings suite;
- Mac Messages regressions;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP before actual recovery wiring if:

- any preservation-safe infrastructure remains incomplete;
- mutation capability is not sufficient;
- donor/current adapter semantics are uncertain;
- recovery requires schema changes;
- persistent donor/removal policy unexpectedly becomes required;
- graph mutation becomes necessary;
- enabling mutation would weaken D1/D2/D3 or source safety.

A fully functioning read-only MessageLens arm through ready state is an acceptable and valuable completion of this task.

# Final report

Report:

- final MessageLens sidebar wording/structure;
- segment-switching behavior;
- qualification pipeline;
- donor identity semantics;
- same-lineage behavior;
- exact recoverable evidence shown;
- zero-recoverable behavior;
- persistent donor/cartouche decision;
- whether actual recovery mutation was wired;
- if deferred, exact blocker;
- if wired, exact capability/orchestration/progress/success semantics;
- tests/tripwires;
- full verification;
- commit hash;
- manual test instructions.

Acceptance standard:

> The MessageLens arm should become a real, understandable Historical Archives workflow whose only promise is to identify missing attachments that can be safely recovered from an older same-lineage MessageLens data folder—without importing donor messages or pretending it is another Mac Messages source.
