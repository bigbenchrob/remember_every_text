Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation. Begin with the required removal execution/progress audit, then proceed directly with the bounded implementation below unless truthful finer removal progress would require materially changing database algorithms or execution ownership.

If finer removal progress is unavailable without architectural/performance harm, implement the Narrator lifecycle, stable Narrator Track, and terminal-perception corrections anyway and report the progress limitation.

Suggested prompt name:

`prompts/38-STABLE-NARRATOR-TRACK-REMOVAL-JOURNEY-AND-TERMINAL-PERCEPTION.MD`

# Purpose

Manual staging review has exposed the next refinement of the emerging:

**Narrator + Directed Instrumentation**

interaction grammar.

The import journey is now substantially more informative, but the removal journey remains behind it, and both journeys expose a spatial/perceptual issue.

Three related corrections are required:

1. Narrator needs a stable fixed vertical presentation Track so commentary can appear, change, or disappear without moving Directed Instrumentation.

2. Removal needs phase-specific Narrator lifecycle and, where truthfully possible, finer real progress evidence.

3. Terminal verification/completion needs to remain perceptible long enough for the human to register it.

Do not redesign the Historical Archives sidebar, source semantics, mutation authority, or MessageLens-folder arm.

# Manual findings

## Removal

During removal, the center panel currently leaves essentially one Narrator statement visible:

**Removing this folder from MessageLens.**

That statement remains throughout several distinct long-running stages.

The removal instrumentation contains approximately:

- Removing messages added from this folder
- Updating your MessageLens history
- Checking that removal finished

Each can remain active for a substantial interval.

The first two in particular may present little more than:

label + spinner

for long enough that the user again wonders whether useful progress is occurring.

The static Narrator line also gradually becomes a page heading rather than an interpretation of the current phase.

## Import

Prompt 37 corrected stale combined-history Narrator semantics by making final verification Narrator-silent.

That is conceptually correct.

However, removing Narrator content entirely can cause the instrumentation beneath it to move vertically.

This weakens visual continuity.

The user is following an instrument panel over time. Its location should not jump merely because Narrator has become silent.

## Terminal verification

The final:

`Checking that import finished`

or equivalent removal verification stage is perceptible only briefly.

The user may notice the row but not have enough time to take in:

- that final checking occurred;
- that it completed;
- that all stages are now Done.

The operation then resolves into the hub/modal too quickly.

# Emerging reusable grammar

Codify this interaction model:

> Narrator has a stable spatial Track but not a requirement to speak.

> Narrator commentary appears only while its interpretation applies.

> Narrator may change or become silent without moving Directed Instrumentation.

> Directed Instrumentation occupies a stable factual region throughout the operation.

> Terminal truth remains visible long enough for the human to perceive it, without pretending execution took longer than it did.

This is a reusable Presence/Narrator principle, not merely a Historical Archives workaround.

# Part 1 — Stable Narrator Track

Introduce/reuse a stable vertical presentation band for Narrator within the Historical Archives operation center panel.

The goal is:

NARRATOR TRACK
fixed vertical extent

DIRECTED INSTRUMENTATION
stable Y position below it

Narrator content may be:

- source-addition commentary;
- combined-history commentary;
- removal-phase commentary;
- empty/silent.

But the Directed Instrumentation block below must not jump vertically when Narrator changes or disappears.

## Use Tracks, not arbitrary padding

MessageLens already has a Track/band architecture.

Use or narrowly extend that architecture.

Do not solve this with:

- a magic `SizedBox(height: 84)`;
- arbitrary top padding;
- per-state hand-tuned offsets.

The Narrator region should have named structural responsibility.

If the current Historical Archives center composition already has a natural shared band that can own Narrator, use it.

If a narrow feature-level Narrator Track is needed, implement it consistently with existing Track conventions.

Do not redesign the global Track system.

## Narrator Track height

The Narrator Track should be sized for the normal intended Narrator grammar:

approximately one to two lines of concise commentary at the established center-panel width.

Do not make it dynamically grow for arbitrary prose.

Narrator copy should be constrained by the Track.

If future commentary becomes paragraph-length, the correct response should normally be to shorten the commentary rather than make the operation UI vertically unstable.

Determine the appropriate existing typography/line-height and Track dimension from the current composition.

Do not hard-code a pixel value without reference to design-system geometry.

## Empty Narrator state

When Narrator is silent:

- the Narrator Track remains structurally present;
- it contains no visible placeholder;
- Directed Instrumentation remains at the same vertical coordinate.

Do not render:

- blank cards;
- “…”;
- hidden explanatory labels;
- placeholder text.

The empty Track itself is the structural state.

# Part 2 — Removal Narrator lifecycle

Removal should use the same lifecycle principle now established for import.

Do not leave:

**Removing this folder from MessageLens.**

up throughout the entire operation.

Audit the actual typed removal progress boundaries and map Narrator only where interpretation is useful.

## Phase A — source contribution removal

While the real removal stage corresponding to removing this source's imported contribution is current, use concise commentary.

Representative wording:

**Removing the messages added from this folder.**

or another concise equivalent grounded in actual semantics.

This should make clear that MessageLens is removing the folder's contribution from MessageLens, not modifying the original folder.

Do not repeat the confirmation-modal safety essay.

## Phase B — remaining/combined MessageLens history update

When source removal has completed and MessageLens begins rebuilding/preparing the remaining combined history, Narrator should change.

Representative meaning:

**Those messages are removed. Now I’m updating your remaining MessageLens history so everything stays together.**

Final wording should be concise and natural.

The important semantic transition is:

selected source contribution
→ remaining combined MessageLens history.

This is analogous to the import transition:

selected source
→ combined history.

Narrator earns an intervention because scope has changed.

## Phase C — final removal verification

When:

`Checking that removal finished`

becomes current:

Narrator should become silent.

The instrumentation is self-explanatory.

Do not add:

“I’m checking that removal finished.”

Narrator would merely paraphrase the instrument.

The fixed Narrator Track remains empty, so instrumentation does not move.

# Part 3 — Audit removal for real finer progress

The removal journey currently has long spinner-only periods.

Audit the exact implementations behind at least:

- Removing messages added from this folder
- Updating your MessageLens history

Determine whether either contains:

- known row counts;
- known batch counts;
- repository loops;
- graph projector units;
- existing progress callbacks;
- real monotonic numerator/denominator pairs.

Use the import progress work as precedent.

Do not assume removal is symmetrical with import.

Trace the actual removal code.

## Source-removal stage

Determine exactly what is being removed.

If the operation processes a known number of source-scoped message facts and already knows the total, investigate whether truthful changing evidence can be exposed.

For example only if true:

`Removing messages added from this folder    4,250 / 8,882`

But do not assume 8,882 is the removal workload merely because that is the source's message count.

Use the actual rows/work units touched by the removal implementation.

## History-update stage

Determine whether removal uses graph projectors analogous to import.

If it already executes meaningful real units such as:

- Participants
- Conversations
- Messages
- Attachments
- Relationships

or another sequence, expose those only if they genuinely correspond to removal/reprojection work.

If the same graph projector infrastructure is reused, prefer reusing the existing typed observation mechanism rather than creating duplicate telemetry.

If numerical progress already exists or can be reused truthfully for Conversations/Messages/Attachments, expose it.

## No progress theater

Do not:

- derive progress from elapsed time;
- invent percentages;
- animate fake counters;
- assume source count equals graph workload;
- split one SQL statement into row-by-row Dart work merely to animate it;
- make efficient database algorithms slower for presentation.

If a long removal operation is one efficient SQLite statement without incremental progress support, leave it coarse and document the limitation.

# Part 4 — Removal Directed Instrumentation hierarchy

If the audit finds useful finer progress, present removal with the same hierarchy principles as import.

Conceptually, if truthful:

Removing messages added from this folder
[real count if available]

Updating your MessageLens history
Participants
Conversations
Messages
Attachments
Relationships

Checking that removal finished

Do not force this exact shape.

Use actual execution boundaries.

Narrator explains the scope transition.

Directed Instrumentation proves the work.

# Part 5 — Terminal verification perception

The current final checking stage disappears too quickly.

We need to distinguish three things:

1. actual execution duration;
2. active-stage presentation;
3. completed-state presentation.

Do NOT make the real final check artificially run longer.

Do NOT hold a spinner after the check has actually completed.

Instead:

real final check executes
→ real final check completes
→ final row becomes Done
→ all instrumentation is now visibly Done
→ preserve this fully resolved instrument panel for a bounded perceptual dwell
→ then proceed to terminal hub/modal behavior.

## Increase terminal all-Done dwell

The current 750 ms dwell is manually insufficient.

Use approximately **1.5 seconds** as the new starting value.

A reasonable bounded range is:

**1.25–1.75 seconds**

Choose a concrete value based on the existing animation/timing vocabulary.

Prefer **1500 ms** unless an established timing token suggests a nearby value.

This is not fake progress.

At this point:

- database work is complete;
- no spinner is active;
- every real stage says Done.

The UI is simply leaving the completed receipt visible long enough for the human to perceive it.

## Import success modal

Preserve the existing import success modal.

Sequence:

final check completes
→ all Done
→ ~1.5 s perceptual dwell
→ hub/cartouche finalized
→ success modal appears.

Do not show the modal before the all-Done state has been perceptible.

## Removal completion

Removal does not necessarily need a success modal unless one already exists or the current design requires it.

Preserve current removal terminal semantics unless manual/audit evidence supports a small analogous acknowledgement.

Do not add a new modal merely for symmetry in this task.

The important requirement is that the all-Done removal instrumentation is perceptible before the cartouche disappears and the hub returns.

# Part 6 — Stale Narrator prevention

Apply the lifecycle mechanically.

For import:

source stage current
→ source Narrator

graph stage current
→ combined-history Narrator

final verification current
→ Narrator silent

all Done dwell
→ Narrator silent

For removal:

source-removal stage current
→ source-removal Narrator

history-update stage current
→ remaining-history Narrator

final verification current
→ Narrator silent

all Done dwell
→ Narrator silent

No completed-state screen may retain commentary saying:

“Now I’m updating…”

after that update has already become Done.

# Part 7 — Typed ownership

Drive Narrator entirely from typed operation state.

Do not:

- use timers to decide when commentary expires;
- inspect displayed status strings;
- infer phase from progress counts;
- let individual widgets independently manage commentary lifecycle.

The all-Done dwell timer controls only terminal presentation lifetime.

It does not control Narrator semantic transitions.

# Part 8 — Stable instrumentation position

Add focused layout coverage proving that Directed Instrumentation begins at the same vertical position for:

- source Narrator;
- combined-history Narrator;
- silent final-verification Narrator;
- silent all-Done state.

Avoid brittle exact-screen-coordinate assertions if possible.

Prefer structural Track/band assertions.

The human acceptance criterion is:

> Narrator can speak, change, or become silent without the instrument panel jumping up and down.

# Part 9 — Failure semantics

Preserve truthful failure context.

## Import source failure

Source Narrator may remain as context.

## Import graph failure

Combined-history Narrator may remain because that is the scope in which failure occurred.

## Import final-verification failure

Narrator remains silent.

Do not resurrect combined-history commentary.

## Removal source-removal failure

Source-removal Narrator may remain.

## Removal history-update failure

Remaining-history Narrator may remain.

## Removal final-verification failure

Narrator remains silent.

Directed Instrumentation and Details own failure evidence.

# Part 10 — Preserve all validated behavior

Do not change:

- ready-state evidence;
- Add/Cancel ownership;
- chooser button interaction;
- Add button interaction;
- `endOfFrame` authorization boundary;
- import source counts;
- GUID comparison semantics;
- import graph denominators;
- import numerical progress;
- duplicate-folder orange behavior;
- successful-import no-orange behavior;
- invalid-folder modal;
- selected-source management;
- removal confirmation;
- source safety;
- DateConverter;
- mutation authority;
- maintenance suppression;
- busy timeout;
- Tracks A–E;
- sidebar spacing;
- MessageLens segment disabled state.

# Canonical design documentation

Update the appropriate shared Narrator / Directed Instrumentation / Presence design documentation with these reusable principles:

> Narrator owns a stable spatial Track even when silent.

> Narrator commentary is phase-scoped. It appears only while its interpretation describes the current human-visible state.

> Directed Instrumentation occupies a stable factual region and does not move when Narrator changes.

> Narrator explains semantic transitions; Directed Instrumentation demonstrates execution.

> Silence is a valid Narrator state.

> Terminal completed instrumentation may remain visible briefly after execution has completed so the human can perceive the result. This is presentation dwell, not simulated work.

These are important product-design rules.

Do not bury them only in Feature 26 implementation notes.

# Tests

Add/update the smallest clear focused test set covering:

## Narrator Track

1. operation composition contains a stable Narrator Track;

2. source Narrator occupies it;

3. combined-history Narrator occupies the same Track;

4. silent final verification preserves the Track;

5. Directed Instrumentation does not change vertical structural position when Narrator becomes silent;

6. Narrator Track does not render visible placeholder content when silent.

## Import lifecycle

7. source Narrator remains source-stage scoped;

8. combined-history Narrator remains graph-stage scoped;

9. final verification is Narrator-silent;

10. all-Done dwell is Narrator-silent;

11. no stale combined-history statement survives graph completion.

## Removal lifecycle

12. source-removal stage gets source-removal Narrator;

13. history-update stage gets remaining-history Narrator;

14. final removal verification is Narrator-silent;

15. removal all-Done dwell is Narrator-silent;

16. no generic removal Narrator persists through unrelated later phases.

## Removal progress

17. any added progress numerator derives from real completed work;

18. any denominator derives from real total work;

19. no timer advances progress;

20. no elapsed-time estimate is used;

21. no efficient database operation is degraded solely for UI progress;

22. any reused graph projector observations remain truthful in removal context.

## Terminal perception

23. final real check completes before dwell begins;

24. every stage is Done during dwell;

25. no spinner remains during dwell;

26. dwell is approximately 1.5 seconds;

27. dwell does not delay execution itself;

28. import success modal appears only after dwell;

29. removal hub transition occurs only after its completed state has been perceptible.

## Regression

30. import numerical progress remains unchanged;

31. ready-state stability remains unchanged;

32. button feedback remains unchanged;

33. success-modal behavior remains unchanged;

34. duplicate/invalid-folder behavior remains unchanged;

35. source-1 data remains protected;

36. admitted maintenance does not trigger Onboarding;

37. Tracks/sidebar layout remain unchanged.

Do not create one test method mechanically for every numbered item.

# Safety

Do not perform real GUI import/removal.

Use fixtures/temp databases for execution audit and automated verification.

Do not modify:

- production data;
- staging archive;
- donor folders;
- source `chat.db`;
- real Attachments payloads.

The human will perform manual staging validation.

# Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- stable Narrator Track implementation;
- Track sizing rationale;
- import Narrator lifecycle;
- removal Narrator lifecycle;
- removal progress audit;
- any finer removal progress introduced;
- any progress deliberately rejected and why;
- terminal dwell change;
- failure behavior;
- canonical shared-design documentation updates.

Update version/changelog according to repository rules.

# Verification

Run:

- focused Historical Archives import/removal/presentation tests;
- Narrator Track/layout tests;
- graph import/removal tests;
- Settings tests;
- maintenance/Onboarding regressions;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if required.

Commit and push if clean.

STOP after this slice.

Do not proceed into MessageLens-folder ingestion yet.

# Report back with

- exact Narrator Track implementation and dimension;
- final import Narrator lifecycle;
- final removal Narrator wording/lifecycle;
- exact removal execution units audited;
- any numerical removal progress added;
- any coarse stages retained and why;
- final terminal dwell duration;
- confirmation that instrumentation no longer jumps when Narrator becomes silent;
- canonical design rules updated;
- manual staging-review instructions.

Acceptance standard:

> Narrator may speak, change, or become silent while the instruments remain spatially stable; long removal work should expose real changing evidence wherever the execution truthfully permits it; and the completed instrument panel should remain visible long enough for the human to register that the operation actually finished.
