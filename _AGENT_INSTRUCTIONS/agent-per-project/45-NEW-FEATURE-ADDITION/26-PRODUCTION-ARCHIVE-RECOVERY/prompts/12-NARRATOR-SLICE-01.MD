Work on branch Ftr.archive-recovery.

Implement ONLY the first visible Narrator + Directed Instrumentation slice for Historical Archives, based on:

responses/10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md

Scope this implementation to:

- replacement presentation shell/state composition;
- no-source state;
- source inspection state;
- failed-inspection state;
- archive-understood / ready-for-import state.

Do NOT redesign import-running, completion, already-imported, removal, or diagnostics cleanup yet except where minimal shared presentation scaffolding is unavoidable.

GOAL

Produce the first real MessageLens Narrator + Directed Instrumentation experience while leaving all Historical Archives execution behavior unchanged.

The target journey is:

Historical Archives opens
→ no archive selected
→ Narrator invites the user to choose a Messages archive
→ user chooses folder
→ inspection begins automatically
→ Narrator introduces the inspection
→ one truthful active instrumentation row is shown
→ inspection completes
→ resolved evidence replaces the active inspection state
→ Narrator interprets what was found
→ user receives the genuine decision: Import Archive or choose another folder

No Next button.

No permanent control-panel stack.

No fake internal progress.

PRESENTATION GRAMMAR

Primary hierarchy:

Historical Archives
page identity

Narrator
current meaning

Directed Instrumentation
only current evidence/work

Decision
only when genuinely owned by the human

Details
collapsed by default

Implement this as Historical Archives presentation composition, not as an application-wide generic framework.

NO-SOURCE STATE

Target shape approximately:

Historical Archives

Add an older Messages archive to extend your history.

[ Choose Messages Folder... ]

Details

Do not show empty preflight cards, execution-gate cards, activity logs, phase lists, or disabled import controls.

INSPECTION STATE

After folder selection, inspection starts automatically.

Target meaning:

Narrator:
“Let’s see what’s in this Messages folder.”

Directed Instrumentation:

MESSAGES ARCHIVE

Inspecting archive source working

This must reflect the actual existing inspection Future/state.

Do not simulate substeps such as checking folder, reading database, counting messages, etc. unless those observations genuinely exist independently today.

READY STATE

After successful inspection/dry run, replace the inspection state with resolved evidence.

Representative shape:

Historical Archives

Good. This archive can extend your history back to July 2012.

MESSAGES ARCHIVE

Messages database Found
Messages 8,882
Dates Jul 2012 – Jun 2017
New to MessageLens 2,369
Already represented 6,513

[ Import Archive ] Choose Another Folder

Details

All values must come from existing typed inspection/dry-run facts.

The Narrator date must be derived from the actual earliest archive date.

Do not hard-code July 2012.

If dry-run comparison is unavailable, adapt the evidence honestly rather than presenting fake zeroes.

FAILED INSPECTION

Use the design record’s distinction between retryable and deterministic failure.

For this slice, the primary failure presentation should:

- state what MessageLens could not establish in human language;
- show resolved evidence that remains trustworthy;
- show the failed instrumentation row;
- offer only a truthful next action such as Retry or Choose Another Folder.

Technical exception text, paths, SQLite terminology, etc. go in Details.

DETAILS

Move these away from the primary journey where already available:

- full folder/chat.db paths;
- chat count;
- handle count;
- zero missing-GUID diagnostics;
- exact UTC timestamps;
- GUID comparison methodology;
- attachment-folder details after inspection;
- execution-gate/maintenance terminology;
- source-scoped implementation terminology;
- activity/history diagnostics.

Do NOT delete diagnostic information merely because it leaves the main surface.

Details should be collapsed by default.

STATE COMPOSITION

Introduce the smallest Historical Archives presentation-state projection necessary to express these states cleanly.

Prefer typed presentation state over more preformatted summary-string arrays.

Do not create a generic workflow framework.

Do not move execution ownership.

Do not modify import/removal services.

Do not change mutation authority.

Do not change persistence.

Do not change source selection behavior beyond what is required to support “Choose Another Folder.”

EXISTING PRESENTATION DEBT

The design identifies these as target debt:

- `_ShellHeroCard`
- permanent Execution Gate / Preflight tiles
- `_ShellSectionCard`
- `_MetadataLine`
- `_StatusCallout`
- `_LogRow`
- `_PhaseRow`
- permanent activity log / phase stack
- preformatted summary-line arrays

Remove or bypass only the parts necessary for THIS slice.

Do not perform a broad cleanup of later import/removal states yet.

TESTS

Add focused presentation/state tests proving:

1. no-source state shows Narrator + chooser and no irrelevant status cards;

2. choosing a folder automatically enters inspection without a Next action;

3. inspection shows only truthful current instrumentation;

4. successful inspection automatically becomes ready state;

5. ready state shows actual message count/date range/new/already-represented evidence;

6. import authorization is visible only when preflight permits it;

7. paths and technical diagnostics are absent from the primary view and available under Details;

8. failed inspection shows truthful failure and appropriate action;

9. no generic Next control exists;

10. no fake import/projection phase progression is introduced.

Do not run an actual archive import/removal as part of automated tests.

VERSION / DOCS

Update the Feature 26 implementation record under responses/.

Update version/changelog if required by repository rules.

VERIFICATION

Run focused Historical Archives presentation/workflow tests, relevant architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this slice.

Do NOT implement import-running/completion/removal redesign yet.

Report:

- presentation-state model introduced;
- old control-panel elements displaced in this slice;
- exact states implemented;
- screenshots/manual launch instructions for reviewing the new experience against the disposable staging archive;
- anything in the existing workflow model that made truthful composition awkward.

I think this is the right size. It gives us something tangible enough to react to visually without committing ourselves to the harder progress-observation architecture first.

And the design's acceptance test is excellent: at any moment, without scrolling, the user should be able to answer **what does this mean, what is happening, do you need me, and did it work?** 10\-HISTORICAL\-ARCHIVES\-NARRATOR\-DIRECTED\-INSTRUMENTATION\-DESIGN.md
