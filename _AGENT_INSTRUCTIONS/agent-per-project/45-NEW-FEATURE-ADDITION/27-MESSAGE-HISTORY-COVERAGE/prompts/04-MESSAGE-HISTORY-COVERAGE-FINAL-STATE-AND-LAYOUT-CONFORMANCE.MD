Work on the current Feature 27 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for implementation.

Feature 27 now has:

- corrected current-source coverage semantics;
- exact mutually exclusive categories;
- no Historical Archives contamination;
- fast set-based query architecture;
- honest complete/incomplete/temporarilyUnavailable/failed states;
- a substantially improved report presentation.

This task is the **final bounded UI/conformance pass** before deciding whether Feature 27 can be closed.

Do NOT redesign the feature broadly.

Do NOT change coverage semantics.

Suggested prompt name:

`04-MESSAGE-HISTORY-COVERAGE-FINAL-STATE-AND-LAYOUT-CONFORMANCE.MD`

## Current manual finding

The complete-state report now reads well and remains stable during window resize.

However, the center-panel title:

**Message History Coverage**

is visually hugging the left edge of the center panel.

The body content below uses a much more comfortable center-column inset.

The title therefore appears to belong to panel chrome rather than to the report content.

This should be corrected through the canonical Track/content-column architecture, not with a local magic offset.

## First: audit Track A/title ownership

The implementation currently uses shared Track A:

- Settings menu in A1;
- report title in A2.

Trace exactly how the A2 title is positioned.

Determine:

- whether Track A2 is using the center-panel outer boundary rather than the canonical content inset;
- whether its occupant bypasses the same `Center` / `ConstrainedBox` / content-column wrapper used below;
- whether another polished Settings page establishes the intended horizontal inset for center Track occupants.

Do not immediately add:

`Padding(left: N)`

or a one-off `SizedBox`.

The title should participate naturally in the same horizontal content system as the report.

## Desired title alignment

The title should visually align with the report body/content column beneath it.

It need not necessarily align with every nested card edge if canonical center layout uses a wider outer text column.

The important rule is:

> Track occupancy determines vertical alignment; canonical center-column geometry determines horizontal alignment.

Do not let Track A become a special horizontal layout system.

## Preserve resize stability

Manual testing already confirms the report stays put during window resize.

Any title correction must preserve:

- stable Track A geometry;
- body stability;
- no horizontal jumping;
- no state-specific title positioning.

Test narrow and wider window widths supported by current Settings layout.

## Review all four report states

Use deterministic fixture/test states rather than changing real data.

Review:

### Complete

Current real example:

- 137,315 total;
- 116,577 in conversations;
- 20,738 Recovered Messages;
- 0 unaccounted.

### Incomplete

Create/render a fixture with a small nonzero unaccounted population.

For example conceptually:

- 137,315 total;
- 116,570 in conversations;
- 20,738 recovered;
- 7 unaccounted.

Do not alter real databases.

Confirm the incomplete state:

- clearly names the exception;
- is not alarmist;
- does not use complete/reassuring language;
- keeps exact counts visible;
- preserves identical geometry.

### Temporarily unavailable

Confirm:

- calm explanation;
- no stale counts;
- no implied failure;
- Retry only if architecture requires it;
- geometry stable.

### Failed

Confirm:

- bounded failure language;
- Try Again action;
- Details/diagnostics;
- no giant technical panel;
- geometry stable.

## Complete badge review

The complete state currently shows:

- green check;
- green `Complete`;
- headline:
  **All messages on this Mac are accounted for**

Audit whether all three are necessary.

The headline already carries the semantic conclusion.

Ask:

> Does the `Complete` eyebrow add useful scannability/status information, or merely repeat the headline?

Possible outcomes:

### Keep both check + Complete

if this matches an established MessageLens status grammar and improves scanning.

### Keep check, remove Complete

if the check supplies status and the headline supplies meaning.

### Remove both

only if the page remains sufficiently scannable and canonical design does not require status iconography.

Do not remove mechanically.

Review comparable polished Settings status surfaces.

## Incomplete status treatment

If the complete state retains a status eyebrow/icon, incomplete should have an equivalent but appropriately restrained treatment.

Do not use destructive red unless canonical design semantics require it.

Possible warning/caution semantics should remain understandable without color.

## Count card review

The current card contains:

- Messages on this Mac;
- In conversations;
- Recovered Messages;
- Unaccounted.

Audit:

- row spacing;
- numeric alignment;
- emphasis hierarchy;
- separator placement;
- zero treatment.

Do not redesign if it already reads well.

Ensure `Unaccounted: 0` is subordinate in complete state but unmistakable when nonzero.

If this can be achieved with typography rather than state-specific layout changes, prefer that.

## Details redundancy audit

Current Details repeats the primary counts, then adds:

- total accounted;
- date range;
- checked time;
- Historical Archives scope note.

Determine whether repeating all four top-card counts in Details is useful or redundant.

Details should ideally provide **additional evidence**, not simply duplicate the card.

Possible simplification:

Primary card:

- total;
- in conversations;
- recovered;
- unaccounted.

Details:

- total accounted/reconciliation invariant;
- date range;
- checked time;
- Historical Archives scope;
- any diagnostic evidence.

Do not remove duplicated counts if they have a clear diagnostic purpose.

Use judgment.

## Sidebar hierarchy review

The sidebar currently has:

- Message History Coverage;
- How to read this report;
- About older messages.

This reads reasonably well.

Audit only:

- spacing between sections;
- whether `Message History Coverage` subheading is redundant beneath the Settings menu label `Message history coverage report`;
- whether the explanatory text can remain as-is.

Do not perform copy churn merely to make it different.

## Capitalization consistency

Current UI mixes:

- menu label: `Message history coverage report`
- center title: `Message History Coverage`
- sidebar subhead: `Message History Coverage`

Determine whether this follows established Settings conventions.

If the menu uses sentence case by design, leave it.

Do not normalize globally without evidence.

## Recovered Messages semantics

Preserve:

Recovered Messages are accounted-for.

Do not introduce warning iconography for their nonzero count.

If a canonical navigation action already exists and is exact, preserve/add it only if current Prompt 03 implementation already justified it.

Do not broaden into a new navigation feature here.

## Loading state

The query is ~0.10 seconds.

Ensure loading remains:

- minimal;
- no artificial delay;
- no Narrator;
- same stable title/layout skeleton.

If title currently appears before report body, that is fine.

Do not add progress rows.

## Temporarily unavailable refresh

Audit whether this state automatically resolves when maintenance ends.

If yes, confirm no user action is needed.

If not, ensure the existing Retry behavior is clear.

Do not add polling loops merely for convenience.

## Accessibility final pass

Check all four states.

At minimum:

- title semantics;
- headline/status semantics;
- count labels and values;
- complete/incomplete status not color-only;
- Details disclosure semantics;
- Retry/Try Again labels;
- loading semantics;
- warning/failure semantics.

Ensure screen readers do not hear confusing repetition such as:

“Complete, All messages ... accounted for, complete...”

if the badge/header combination creates redundancy.

This may influence the `Complete` badge decision.

## Architecture conformance

Perform a short bounded audit for Feature 27 only.

Confirm:

- Prompt 02 semantic model remains untouched;
- presentation performs no count arithmetic;
- no clamp reappeared;
- no historical source contamination;
- Track A remains the only intentionally shared Track if that is still correct;
- no magic title inset introduced;
- no Narrator/progress framework added;
- provider lifecycle remains safe;
- no schema changes.

## Fixture/state previews

Add or use focused widget fixtures/tests that exercise:

- complete;
- incomplete;
- temporarily unavailable;
- failed;
- loading.

If repository conventions support screenshot/golden inspection, use existing patterns.

Do not introduce a new golden-testing framework.

## Tests

Add/update focused tests proving:

1. title aligns through canonical center content geometry rather than a magic offset;

2. all report states use the same Track A skeleton;

3. resize does not alter structural alignment;

4. complete state retains correct semantics;

5. incomplete state shows exact nonzero unaccounted count;

6. complete-only language cannot appear in incomplete state;

7. temporarilyUnavailable and failed remain distinct;

8. count card values come directly from typed report;

9. no presentation arithmetic;

10. Details does not contradict the card;

11. status remains accessible without color;

12. no artificial loading delay.

## Documentation

Create:

`04-MESSAGE-HISTORY-COVERAGE-FINAL-STATE-AND-LAYOUT-CONFORMANCE-IMPLEMENTATION.md`

under Feature 27 responses.

Document:

- title alignment root cause;
- canonical horizontal alignment fix;
- complete badge decision;
- all four state reviews;
- Details decision;
- accessibility findings;
- final Track contract;
- confirmation that semantics were unchanged.

Update Feature 27 index/documentation log.

Update version/changelog according to repository rules if application code changes.

## Release-readiness decision

At the end, classify Feature 27 as:

### READY

or:

### READY WITH DEFERRED NON-BLOCKERS

or:

### NOT READY

Do not invent future work merely to avoid closing the feature.

If the only remaining idea is a future exact browser for unaccounted messages, and the current report truthfully reports their count without pretending an action exists, that can be a deferred enhancement rather than a blocker.

## Verification

Run:

- Message History Coverage focused tests;
- Settings layout/widget tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

## Stop conditions

STOP if:

- fixing horizontal title alignment requires global Track redesign;
- all-state review exposes a semantic contradiction;
- incomplete presentation requires a new evidence browser to be truthful;
- canonical accessibility conventions conflict with the current composition.

Do not hide such findings with local padding or copy.

## Final report

Report:

- title alignment root cause and fix;
- final complete-state status treatment;
- final incomplete-state treatment;
- temporarilyUnavailable/failed review;
- count-card changes, if any;
- Details changes, if any;
- accessibility findings;
- Track/layout behavior;
- full verification;
- readiness classification;
- commit hash;
- manual review instructions.

Acceptance standard:

> Message History Coverage should look like one stable, deliberate report in every state. Its title should belong to the same center content column as the report beneath it, complete and incomplete states should communicate meaning without redundant status chrome, and no visual refinement should weaken the exact coverage semantics established in Prompt 02.
