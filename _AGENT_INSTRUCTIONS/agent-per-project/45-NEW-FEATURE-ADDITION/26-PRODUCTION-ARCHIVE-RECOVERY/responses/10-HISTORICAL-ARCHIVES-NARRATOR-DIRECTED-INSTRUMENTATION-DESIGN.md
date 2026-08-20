---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-17
source_of_truth: design
links:
  - 03-HISTORICAL-MESSAGES-2012-2016-INGESTION-AUDIT.md
  - 06-HISTORICAL-IMPORT-POST-CORRECTION-VERIFICATION.md
  - 08-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-IMPLEMENTATION.md
  - 09-HISTORICAL-REMOVAL-ONBOARDING-REDIRECT-AUDIT.md
  - 10-FRESH-START-GATING-ANOMALY-AUDIT.md
tests: []
---

# Historical Archives Narrator + Directed Instrumentation Design

## Decision

Historical Archives should stop presenting every available fact as a permanent
control panel. It should become a state-driven journey with two complementary
voices:

- **Narrator** explains what the current boundary means and what decision, if
  any, belongs to the human.
- **Directed Instrumentation** exposes a small set of actual checks or actual
  work at the point where those facts are useful.

The human chooses sources and authorizes consequential actions. MessageLens
performs every known safe intermediate step automatically.

```text
Narrator provides meaning.
Directed Instrumentation provides evidence.
The human provides decisions.
MessageLens provides momentum.
```

This is a Historical Archives design. It is not yet an application-wide
framework.

## Existing Architecture

The current execution ownership is sound and remains unchanged:

```text
HistoricalArchivesWorkflow
  -> folder chooser / source inspector
  -> ArchiveMutationCoordinator
  -> source-scoped archive import or removal service
  -> graph projection
  -> persisted source summary
```

`HistoricalArchivesWorkflow` owns the selected folder and the current
presentation-facing workflow state. The panel-model provider combines that
state with mutation-gate facts. `HistoricalArchivesPanel` renders the complete
center-panel surface. Historical source summaries are persisted in overlay
metadata and rendered separately in the Settings sidebar.

The redesign should change the projection and presentation of this existing
workflow, not its execution path.

## Current Information Inventory

The classifications mean:

- **A - Primary journey:** needed now to understand the current state.
- **B - Directed instrumentation:** useful while the represented check or work
  is current.
- **C - Decision evidence:** needed before a consequential human action.
- **D - Completion evidence:** useful after success.
- **E - Details / diagnostics:** useful on demand.
- **F - Developer-only:** absent from the ordinary journey.

### Shell and gate information

| Current information | Class | Disposition |
|---|---|---|
| Historical Archives identity | A | Persistent compact page identity, not a hero card |
| Generic status pill | A, sometimes redundant | Replace with state-specific Narrator meaning |
| Long generic summary | A | Replace with one brief state-specific transition statement |
| Execution gate available | E | Omit when normal; availability needs no announcement |
| Execution gate busy | B | Show only when it blocks the requested action |
| Execution owner label | E/F | Human description in primary failure; raw owner in Details |
| Maintenance lock wording | E/F | Human consequence in primary view; implementation wording in Details |
| Preflight status tile | A/B | Fold into current Narrator and instrumentation state |

### Selected-folder information

| Current information | Class | Disposition |
|---|---|---|
| Choose Messages Folder | C | Primary decision when no source is selected |
| Clear Selected Folder | C | Secondary action only while reviewing a selected source |
| Explanation of clear-selection semantics | E | Details or concise tooltip/help text |
| Full folder path | E | Details |
| `chat.db` status | B/C | Primary resolved check before import |
| `Attachments/` status | B/E | Show during inspection; retain in Details after resolution |
| Source label | A | Primary identity for the selected archive |

### Preflight and dry-run information

| Current information | Class | Disposition |
|---|---|---|
| Source readable / preflight result | B/C | Primary check and import gate evidence |
| Total messages | B/C/D | Primary instrument; keep through ready and completion |
| Total chats | E | Details |
| Total handles | E | Details |
| Missing GUID count | E/F | Details when nonzero; developer diagnostic when zero |
| Earliest and latest dates | B/C/D | Primary instrument as one human date-range statement |
| Date-range diagnostic | E | Details or failure explanation |
| Likely new messages | C | Primary decision evidence before import |
| Likely already represented / duplicates | C/E | Concise decision evidence; exact comparison detail in Details |
| Comparable GUID count | E/F | Details |
| Dry-run unavailable reason | C/E | Explain limitation before authorization; technical cause in Details |

### Import decision and safety information

| Current information | Class | Disposition |
|---|---|---|
| Begin Import | C | Primary action only after successful preflight |
| Disabled-button explanation | A/B | Replace with current-state narration; avoid dead controls |
| Live Messages source protection | C | Prominent refusal; no import action |
| Source-scoped preservation explanation | C/E | Short consequence near authorization; full invariant in Details |
| Existing/current messages remain | C | Concise decision evidence |
| Overlay/user-intent preservation detail | E | Details |

### Removal information

| Current information | Class | Disposition |
|---|---|---|
| Remove imported archive data | C | Available for an imported source, behind deliberate action |
| Exact removal target `chat.db` path | E | Confirmation Details |
| Source folder is not modified | C | Primary confirmation evidence |
| Live current source remains untouched | C | Primary confirmation evidence |
| Deleted source-fact/topology counts | D/E | Human result summary plus exact counts in Details |
| Developer/testing-only explanation | F | Remove from ordinary presentation |

Removal is currently developer-gated. This design describes the eventual human
journey but does not change that availability policy.

### Activity, progress, result, and known sources

| Current information | Class | Disposition |
|---|---|---|
| Entire activity log | E/F | Details; never a permanent primary section |
| Current coarse operation | B | Directed Instrumentation |
| Waiting phases unrelated to current work | F | Do not render |
| Succeeded phases | B/D | Keep only the concise current tableau or completion proof |
| Skipped phases | E | Failure Details only |
| Result-summary prose | D | Replace with one unmistakable completion surface |
| Known source label | A | Sidebar source identity |
| Known source date range | A/D | Sidebar orientation |
| Known source message count | A/D | Sidebar summary |
| Last preflight/import status | E or warning | Quiet summary; elevate only a current failure |
| Last-run counts and time | E | Details |
| Add an Archive Folder | C | Primary sidebar action |

## Current Interaction Problems

1. All states render nearly the same stack of cards. The user must determine
   which section matters now.
2. Waiting, active, completed, diagnostic, and decision information coexist
   rather than replacing one another as the journey changes.
3. The status hero, preflight card, activity log, progress list, and result
   summary repeat overlapping facts.
4. Success can occur below the fold while earlier setup material remains above
   it.
5. Disabled controls explain workflow state indirectly instead of the page
   stating the current meaning directly.
6. The selected source survives removal and immediately returns to preflight.
   That is mechanically coherent but does not communicate a fresh human
   starting point.
7. Internal terms such as execution gate and topology appear too readily.
8. The current phase list describes more apparent progression than the
   execution services actually report in real time.

## Narrator + Directed Instrumentation Principles

### Narrator

The Narrator appears at semantic boundaries:

- no source -> source selected;
- source selected -> source understood;
- ready -> import authorized;
- work -> completion;
- imported -> removal decision;
- failure -> recovery choice.

It uses one short heading and, only when needed, one supporting sentence. It
does not report heartbeat status and does not repeat reassurance.

Narrator should intervene when the human meaning or scope of the work changes,
not merely because another implementation stage begins. Narrator explains
changes in meaning and scope; Directed Instrumentation exposes the factual
work within that scope. A technical stage transition that does not alter the
human mental model does not earn new Narrator content.

Narrator commentary also has a lifecycle. It is present only while its
interpretation applies to the current human-visible state. When that meaning
expires, Narrator either transitions to a newly earned interpretation or
becomes silent. Silence is preferable to commentary that merely paraphrases
self-explanatory instrumentation.

### Directed Instrumentation

Instrumentation shows only facts backed by a current check, operation, or
completed result. A row has one of four visible states:

- pending, only when it is genuinely next;
- active, only while that work is known to be active;
- resolved, with a real result;
- failed, with the relevant human consequence.

Rows unrelated to the current state are absent. No percentage is shown without
a measurable denominator.

### Decision boundary

A control appears only for:

- folder selection;
- import authorization after evidence review;
- removal authorization;
- retry after failure;
- cancellation where cancellation is actually supported;
- resolving ambiguity or permission.

There is no generic Next control.

## Modest Visual Grammar

### Transition statement

The Narrator surface. A compact heading and optional supporting sentence,
unframed or minimally framed. It changes when the meaning changes.

### Instrumentation tableau

A small group of check/work rows belonging to the current phase. It is not a
dashboard and does not retain irrelevant waiting rows.

### Resolved check row

Names one check and its result, for example `Messages database - Found` or
`8,882 messages - July 2012 to June 2017`.

### Active work row

Names the operation currently known to be active. Activity treatment may move,
but the text remains a factual operation, not generic reassurance.

### Warning or failure row

States what failed in human terms and whether retry is meaningful. Technical
details remain disclosed on demand.

### Decision surface

Presents the evidence, consequence, and the one decision now owned by the
human. Primary and destructive actions are visually distinct.

### Completion surface

Replaces the working tableau above the fold. It states success, gives the
meaningful result, and offers the next genuine action.

### Details disclosure

Contains paths, raw counts, diagnostics, activity history, internal operation
labels, and support information. It is collapsed by default.

## Complete Historical Archives Journey

### 1. No folder selected

**Narrator:** `Add an older Messages archive to extend your history.`

**Instrumentation:** none. There is no work yet.

**Human decision:** choose a Messages folder.

**Controls:** `Choose Messages Folder...`; known imported sources remain
available in the sidebar.

**Automatic next:** choosing a folder immediately starts inspection.

**Details:** brief explanation of expected folder structure and non-destructive
source reading.

**Above the fold:** identity, Narrator, chooser.

### 2. Choosing a folder

The native folder chooser owns this moment. The page does not add another
modal layer. Cancellation returns unchanged to the no-folder state.

### 3. Inspecting the selected source

**Narrator:** `Let's see what's in this Messages folder.`

**Instrumentation:** one truthful active row, `Inspecting the archive source`.
Resolved source checks may appear when the inspection call returns.

**Facts:** folder existence, `chat.db` existence/readability, optional
`Attachments/` directory, message/chat/handle counts, missing GUID count,
DateConverter-derived range, and GUID comparison result.

**Human decision:** none.

**Controls:** optional cancel/change-source only if the current implementation
can safely honor it. No Next button.

**Automatic next:** successful inspection becomes ready for review; failed
inspection becomes the appropriate failure state.

**Details:** full folder and database paths.

**Above the fold:** Narrator and the active inspection row.

### 4. Archive understood and ready

**Narrator:** `Good. This archive can extend your history back to July 2012.`

The exact month comes from the inspected earliest date, not fixed copy.

**Instrumentation:** compact resolved evidence:

```text
Messages database                         Found
Messages                                  8,882
Dates                         Jul 2012 - Jun 2017
New to this MessageLens archive            2,369
Already represented                        6,513
```

Rows adapt truthfully when dry-run comparison is unavailable.

**Human decision:** authorize import or choose another folder.

**Controls:** `Import Archive` and a quiet `Choose Another Folder` action.

**Automatic next:** authorization starts the entire import/projection sequence.

**Details:** folder path, attachments status, chats, handles, missing GUIDs,
comparison method, exact UTC dates, safety invariants.

**Above the fold:** Narrator, five or fewer evidence rows, import action.

### 5. Import running

**Narrator:** `Adding this archive to MessageLens.`

**Instrumentation:** only operations known to be complete or active. With the
current service contract, the truthful initial tableau is bounded:

```text
Archive source checked                     Done
Adding archive messages                 Working
Preparing conversations                 Waiting
Updating search and heatmap             Waiting
```

The latter rows must not advance until the underlying services expose real
stage observations. Until then, a single active `Adding archive to
MessageLens` row is more truthful than simulated substage movement.

**Human decision:** none.

**Controls:** none unless real cancellation semantics exist. Navigation may be
restricted by existing mutation policy, not by presentation convention.

**Automatic next:** all existing non-decision stages continue and completion
replaces the running view.

**Details:** activity history and technical stage/result counts as they become
available.

**Above the fold:** Narrator and current instrumentation.

### 6. Import success

**Narrator:** `Done. Your MessageLens history now reaches back to July 2012.`

**Instrumentation / completion evidence:** imported message count, archive
date range, and `Ready to browse`.

**Human decision:** browse messages, add another archive, or later manage this
source.

**Controls:** `Browse Messages` when a truthful navigation target is defined;
`Add Another Archive` is secondary. The surface does not require acknowledgment
to complete the workflow.

**Automatic next:** operationally complete before the success surface appears.

**Details:** source label/path, import completion time, new/duplicate counts,
graph node/edge result counts, and activity history.

**Above the fold:** completion statement and key evidence. Success must never
depend on scrolling.

### 7. Already-imported archive selected

**Narrator:** `This archive is already part of MessageLens.`

**Instrumentation:** source label, date range, source message count, and current
representation evidence. Avoid presenting zero newly insertable rows as an
error.

**Human decision:** leave it in place, choose another source, or enter source
management/removal.

**Controls:** no enabled Import action when there is no meaningful new work;
`Remove from MessageLens...` is deliberate and secondary/destructive.

**Details:** last import time, prior result, comparison counts, paths.

### 8. Removal authorization

**Narrator:** `Remove this archive from MessageLens?`

**Decision evidence:** identify the source and date range; state that imported
MessageLens records for this source will be removed and the original folder,
current Messages source, attachment preservation data, and user intent will not
be modified.

**Human decision:** remove or cancel.

**Controls:** destructive `Remove Archive` and `Cancel`.

**Details:** exact path, source identity, expected affected counts, and
reprojection explanation.

### 9. Removal running

**Narrator:** `Removing this archive from MessageLens.`

**Instrumentation:** current truthful coarse operation. Existing removal is a
single awaited service call, so do not imply sequential live movement unless
the service publishes it.

```text
Removing imported archive data          Working
Refreshing remaining conversations      Waiting
```

**Human decision:** none.

**Automatic next:** removal and reprojection continue to completion.

### 10. Removal success

**Narrator:** `Removed. The original Messages folder was not changed.`

**Completion evidence:** source removed from MessageLens and remaining message
history prepared for browsing.

**Human decision:** choose another archive or finish.

**Controls:** `Choose Messages Folder...` when desired.

**Presentation reset:** after showing unmistakable completion, the primary
journey should return to a fresh no-selection composition rather than silently
rerunning the removed donor's preflight as the enduring state. This is a
presentation-state correction; it must not trigger import or alter source data.
The persisted known-source summary must also stop implying that the removed
source is currently imported. If current metadata cannot express that truth,
that limitation must be addressed explicitly in the implementation slice.

### 11. Retryable failure

Examples include a temporarily busy mutation gate, source temporarily
unavailable, database lock, or an import failure whose existing operation is
safe to retry.

**Narrator:** `MessageLens couldn't finish this archive yet.`

**Instrumentation:** the last resolved rows, one failed row, and the human
consequence. Do not mark unattempted work as failed.

**Human decision:** retry, choose another folder, or reveal Details.

**Controls:** `Retry` only when the application can rerun the owning operation
deterministically; otherwise offer the relevant corrective action.

**Automatic next:** retry repeats only the owned safe operation and then
continues automatically.

**Details:** exception, internal stage, owner, paths, activity history, and
support diagnostics.

### 12. Non-retryable or diagnostic failure

Examples include selecting live `~/Library/Messages/chat.db`, a missing
`chat.db`, structurally unreadable source, or an invariant violation requiring
diagnosis.

**Narrator:** state what this folder is or why MessageLens cannot use it.

**Instrumentation:** resolved source facts plus the failed check.

**Human decision:** choose another folder; diagnostics may be disclosed or
exported where supported.

**Controls:** `Choose Another Folder`; no misleading Retry when the same input
will deterministically fail.

**Details:** technical error and exact path.

## Primary Screen Hierarchy

Every major state uses the same order:

```text
Historical Archives                         page identity

[Narrator transition statement]             current meaning

[Directed Instrumentation]                  current evidence/work

[Decision or completion action]             only when earned

Details                                     collapsed
```

Known sources remain a sidebar concern. The center panel concentrates on one
current investigation. The page does not preserve inactive cards merely to
keep its height stable.

## What Moves Behind Details

The default collapsed Details area owns:

- full folder and `chat.db` paths;
- raw source label when it adds nothing beyond the display name;
- chats and handles counts;
- zero missing-GUID diagnostics;
- comparable-GUID methodology and counts;
- exact UTC timestamps;
- attachment-folder status after preflight;
- execution owner and maintenance terminology;
- source-scoped identity and projection implementation detail;
- graph node/edge counts;
- full activity history;
- waiting and skipped phases;
- prior run timestamp and raw failure text;
- developer-only removal diagnostics.

A nonzero anomaly or current failure may promote one of these facts into the
primary journey. Details is not a place to hide a consequential warning.

## Fact-To-Instrument Contract

| Instrument | Existing factual source |
|---|---|
| folder access | filesystem inspection in `ArchiveSourceInspectionRepository` |
| Messages database found/readable | `ArchiveSourceInspection.chatDbStatusLabel` / `isReadable` |
| attachment folder found | `attachmentsStatusLabel` |
| message count | read-only `COUNT(*)` from source `message` |
| date range | source `MIN(date)` / `MAX(date)` converted only by `DateConverter` |
| chat/handle counts | read-only source counts |
| missing GUIDs | read-only source query |
| likely new/already represented | `ArchiveSourceDryRunEstimate` GUID comparison |
| mutation availability | `ArchiveMutationCoordinatorState` and existing maintenance signal |
| import completed | returned `SourceScopedArchiveGraphImportResult` |
| inserted messages | `MessageImportResult.insertedMessageCount` |
| projected graph facts | `SourceScopedArchiveGraphProjectionResult` result objects |
| removal completed | `SourceScopedArchiveGraphRemovalResult` |
| deleted source facts/edges | removal result counts |
| historical source summary | persisted overlay source metadata |

The presentation must not infer stage completion from elapsed time, animation,
or the existence of a future result.

## Automatic Transitions And Human Decisions

| Boundary | Owner | Behavior |
|---|---|---|
| open Historical Archives | MessageLens | show current truthful state |
| choose folder | human | native folder selection |
| inspect source | MessageLens | automatic after selection |
| review valid evidence | human | import or choose another folder |
| import and project | MessageLens | automatic after authorization |
| show success | MessageLens | automatic when durable work succeeds |
| manage imported source | human | deliberately request removal flow |
| confirm removal | human | destructive decision |
| remove and reproject | MessageLens | automatic after confirmation |
| retry a retryable failure | human | explicit fresh command |
| reveal diagnostics | human | optional disclosure |

No automatic transition may begin a fresh historical import. Import always
requires a fresh explicit human command.

## Low-Fidelity Textual Mockups

### No source

```text
Historical Archives

Add an older Messages archive to extend your history.

[ Choose Messages Folder... ]

Details
```

### Inspecting

```text
Historical Archives

Let's see what's in this Messages folder.

MESSAGES ARCHIVE
  Inspecting archive source                         working

Details
```

### Ready for decision

```text
Historical Archives

Good. This archive can extend your history back to July 2012.

MESSAGES ARCHIVE
  Messages database                                    found
  Messages                                              8,882
  Dates                                    Jul 2012 - Jun 2017
  New to MessageLens                                    2,369
  Already represented                                  6,513

[ Import Archive ]    Choose Another Folder

Details
```

### Running

```text
Historical Archives

Adding this archive to MessageLens.

ARCHIVE IMPORT
  Archive source checked                                done
  Adding archive to MessageLens                      working

Details
```

### Completed

```text
Historical Archives

Done. Your MessageLens history now reaches back to July 2012.

  Messages imported                                     8,882
  Archive range                             Jul 2012 - Jun 2017
  Conversation browsing                                 ready

[ Browse Messages ]    Add Another Archive

Details
```

### Retryable failure

```text
Historical Archives

MessageLens couldn't finish this archive yet.

ARCHIVE IMPORT
  Archive source checked                                done
  Adding archive messages                             failed

No source files were changed. You can try this operation again.

[ Retry ]    Choose Another Folder    Details
```

### Removal decision

```text
Historical Archives

Remove Messages_2012-IMPORT_SOURCE from MessageLens?

  Archive range                             Jul 2012 - Jun 2017
  Imported source messages                              8,882

The original Messages folder and current Messages history will not be changed.

[ Remove Archive ]    Cancel    Details
```

## Reuse And Presentation Debt

### Reuse

- `HistoricalArchivesWorkflow` remains the execution-facing workflow owner.
- Folder chooser and action provider remain valid interaction seams.
- `ArchiveSourceInspection` and `ArchiveSourceDryRunEstimate` provide truthful
  preflight evidence.
- Import and removal result objects provide completion evidence.
- Mutation coordinator state provides real availability/busy evidence.
- Historical source overlay metadata remains the known-source persistence
  boundary.
- Existing source-protection, authorization, and confirmation behavior remains.

### Presentation debt to retire or replace

- `_ShellHeroCard` repeats state instead of narrating the current boundary.
- The permanent Execution Gate and Preflight tiles expose machinery when
  normal.
- `_ShellSectionCard` makes every category look equally important.
- `_MetadataLine` flattens identity, evidence, and diagnostics into one list.
- `_StatusCallout`, `_LogRow`, and `_PhaseRow` preserve the control-panel model.
- `preflightSummaryLines`, `dryRunSummaryLines`,
  `importSafetySummaryLines`, and `resultSummaryLines` are preformatted prose;
  the new composition should prefer typed facts where already available.
- The permanent activity log and seven-row phase list should leave the primary
  journey.
- Current running-phase helpers mark multiple stages running or waiting without
  receiving live service observations. They must not be treated as a truthful
  real-time contract.

These elements may remain temporarily during slicing, but they are not the
target grammar.

## Truthful Real-Time Instrumentation Constraint

There is one concrete architectural obstacle to rich live instrumentation.

The workflow currently observes:

```text
before await importAndProject()
after await importAndProject()
```

The import service internally performs registration, several source imports,
text enrichment, and several graph projectors in sequence, but publishes no
stage observations while they run. Removal similarly exposes one awaited
operation and one final result. Preflight returns all resolved facts together.

Therefore:

- preflight can truthfully show one active inspection row, then resolved rows;
- import can truthfully show one coarse active operation, then completion;
- removal can truthfully show one coarse active operation, then completion;
- the current presentation cannot truthfully animate each internal substage in
  real time.

If later review requires live transitions such as `Adding messages` ->
`Preparing conversations` -> `Updating search and heatmap`, the owning
application services must expose immutable progress observations at actual
stage boundaries. Presentation must consume those observations; it must not
reconstruct them from timers or parallel guesses. This would be an
observability addition, not a change to execution ownership.

## Smallest Safe Implementation Slices

### Slice 1 - State composition and replacement shell

- Introduce a Historical Archives presentation-state projection over the
  existing workflow facts.
- Replace the permanent hero/control-panel hierarchy with page identity,
  Narrator statement, current tableau, current decision, and collapsed Details.
- Keep all actions and execution calls unchanged.
- Initially use only state boundaries the workflow already exposes.

### Slice 2 - No-source, inspection, and ready journey

- Implement no-folder selection, inspection, failed inspection, and ready
  compositions.
- Use `ArchiveSourceInspection` and dry-run facts directly.
- Move paths, chat/handle counts, missing-GUID diagnostics, and methodology into
  Details.
- Verify no wizard-style advancement is introduced.

### Slice 3 - Import running and completion

- Replace the current phase/activity/result stack with one coarse truthful
  running tableau and an above-fold completion surface.
- Use returned import/projection results for completion evidence.
- Do not simulate internal live progress.
- Separately decide whether actual stage observations have earned a bounded
  application-service seam.

### Slice 4 - Imported-source and removal journey

- Define the already-imported composition and deliberate removal confirmation.
- Implement coarse truthful removal work and unmistakable removal completion.
- Reset the primary presentation to a fresh no-selection state after completion
  without initiating import.
- Make persisted known-source status truthful after removal using existing
  metadata where possible; stop if that requires an unapproved persistence
  change.

### Slice 5 - Details and debt removal

- Consolidate diagnostic facts and activity history behind Details.
- Remove obsolete permanent cards and duplicate summary strings.
- Retain developer-only evidence only in developer diagnostics.
- Update tests around state-specific hierarchy and action visibility.

This sequence changes presentation before adding any progress-observation
capability. It keeps each slice reviewable against the already validated
execution semantics.

## Explicit Non-Goals

This design does not:

- change import, removal, registration, projection, or overlap semantics;
- change source-scoped identity or mutation authority;
- change `DateConverter` or permit another timestamp conversion;
- change attachment archival or preservation policy;
- change Onboarding or Environment Readiness;
- change database schema or archive data;
- introduce generic Presence, wizard, progress, or workflow infrastructure;
- introduce fake percentages or timer-derived progress;
- authorize cancellation where the operation does not support it;
- publish final marketing copy;
- make removal available outside its current policy;
- perform any archive mutation or GUI operation.

## Acceptance Standard For The Later Redesign

At every state, a user should be able to answer without scrolling:

1. What does this moment mean?
2. What real work or evidence is relevant now?
3. Is MessageLens waiting for me, or is it moving on its own?
4. If it is waiting for me, what genuine decision do I own?
5. Did the operation finish successfully?

If the page cannot answer those questions, it has reverted to a control panel
rather than Narrator + Directed Instrumentation.
