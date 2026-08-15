The architecture investigation is complete.

Please implement the first explicit idle target for the Unknown Sources center presentation.

Do not introduce minimum Track heights, filler occupants, or page-level padding to preserve geometry.

The Track system is already behaving correctly. The missing piece is a total presentation projection for an active investigation.

---

# Governing Principle

While an investigation is active, its center presentation is never absent.

The current investigation target determines which truthful presentation is shown.

For Unknown Sources:

    active investigation
        → idle target
        or
        → selected-source target

Idle means:

    Unknown Sources investigation is active
    and
    no compatible source target is selected

Do not add an independent boolean `isIdle`.

---

# ViewSpec Direction

Keep one Messages-owned outer ViewSpec.

Do not create a second feature-owned ViewSpec for the idle state.

Evolve the current handle-lens presentation so the durable intent is the investigation, while the selected source is an optional target within it.

Conceptually:

    MessagesSpec.handleInvestigation(
        investigation identity,
        investigation kind,
        target: idle | selected source
    )

Use repository naming and existing union/spec conventions rather than this literal API.

The existing selected-source presentation may replace or subsume `MessagesSpec.handleLens` if that produces a cleaner model.

Avoid a broad rename unless it is genuinely required for a truthful type.

---

# Ownership

Preserve these boundaries:

- Sidebar Flow owns the active investigation identity and current target.
- Handles owns the meaning of Identify Sources, Numeric IDs, source classifications, and review actions.
- Messages owns the complete center-panel ViewSpec presentation.
- Navigation projects flow state into the Messages ViewSpec.
- Navigation owns Matrix placement.
- Tracks resolve truthful geometry only.

The center presentation must not infer the investigation kind from rendered cassette widgets.

If the authoritative flow state does not currently carry enough investigation information, add the smallest Handles-owned opaque descriptor or kind needed so sidebar and center projections derive from the same source.

Do not move Handles semantics into Navigation or Messages.

---

# Projection Change

The current failure path returns `null` for the entire Unknown Sources center branch when no source is selected.

Replace that partial projection with a total one.

Conceptually:

    Unknown Sources active + selected compatible source
        → selected-source Messages spec

    Unknown Sources active + no selected compatible source
        → idle Messages spec

    Unknown Sources inactive
        → no Unknown Sources center spec

Navigating away may still make the presentation absent or incompatible. Remaining in the investigation without a selected source must not.

---

# Idle Presentation

Implement a quiet Messages-owned idle presentation.

It should truthfully communicate:

- the current investigation remains active;
- no source is selected;
- the user may select an item from the sidebar to inspect its messages.

The wording may vary by investigation kind.

For example:

Identify:

    Identify unknown sources

    Select a phone number, email address,
    or business to review its messages.

Numeric IDs:

    Numeric sender IDs

    Select an ID to review its messages.

Treat these as working examples, not mandatory copy.

Use Handles-owned investigation facts or presentation labels where appropriate. Messages owns typography, layout, and final composition.

Do not expose implementation terms such as “idle target” in the UI.

---

# Track Occupants

Make occupant preparation total for every active Unknown Sources spec.

Selected-source target:

- preserve the existing title;
- source identity;
- metrics;
- search controls;
- actions;
- message evidence.

Idle target:

- prepare real title/orientation occupants;
- prepare quiet guidance occupants;
- omit source-specific controls that would be dishonest without a source.

Loading and error remain provider/resolver states beneath the active spec. Do not add them as ViewSpec variants unless existing architecture already requires that.

Do not use dummy invisible occupants simply to hold space.

---

# Matrix Behaviour

Keep the existing Unknown Sources matrix.

Use real occupants in its existing cells wherever they naturally belong.

Do not:

- add arbitrary minimumReservedHeight values;
- insert blank fixed-height occupants merely to imitate selected geometry;
- add padding around page sections;
- create a separate idle-only matrix unless the existing matrix cannot truthfully represent both states.

Some remaining height change is acceptable if it reflects genuinely different content.

The goal is to eliminate the severe collapse caused by an absent center presentation, not to guarantee pixel-identical geometry at all costs.

---

# State Transitions To Support

Implement and test at least these transitions:

## Initial entry with no selected source

    open From unfamiliar sources
    → current investigation is active
    → center renders idle presentation
    → center stack is not empty

## Select source

    idle investigation
    → select source
    → selected-source presentation replaces idle presentation
    → existing evidence and actions work

## Clear selection

    selected source
    → clear or invalidate selected source
    → investigation remains active
    → center returns to idle presentation
    → it does not become an empty stack

## Change endpoint filter

    selected source becomes incompatible with Phone / Email / Business filter
    → selection clears
    → idle Identify presentation remains

## Switch investigation

    Identify
    → Numeric IDs
    → incompatible selected Identify source clears
    → Numeric IDs idle presentation appears

and the reverse transition.

## Dismiss selected source

    selected source
    → Dismiss
    → source leaves active projection
    → investigation remains active
    → center resolves to idle or the existing approved next-selection behaviour

Do not leave stale source evidence visible.

## Navigate away and return

Confirm the behaviour follows existing flow policy:

- unchanged compatible selection may restore if currently intended;
- no selection restores the appropriate idle presentation.

---

# Tests

Add focused coverage at the projection, spec, occupant, and widget levels.

At minimum verify:

1. An active Unknown Sources investigation never projects `null` merely because selection is absent.

2. Idle and selected-source targets remain variants of one Messages-owned presentation.

3. No independent `isIdle` state exists.

4. Sidebar and center use the same authoritative investigation kind.

5. Occupant preparation returns truthful idle occupants.

6. The effective center stack remains populated during no-selection states.

7. Clearing selection no longer causes the major sidebar Track collapse.

8. No minimum-height or filler workaround was introduced.

9. Existing selected-source rendering and actions remain unchanged.

---

# Documentation

Document the general rule:

> While an investigation is active, its center presentation is never absent. The current investigation target determines which truthful presentation is shown.

Also document the distinction:

- idle and selected source are navigation-significant targets;
- loading, empty evidence, and error are resolver states beneath the current spec.

Update the Unknown Sources working documentation and the relevant ViewSpec/navigation architecture documentation.

---

# Scope

Do not:

- redesign the Unknown Sources sidebar;
- change Identify/Numeric IDs naming;
- alter source classification;
- change dismissal semantics;
- redesign the Track Matrix;
- add speculative general investigation infrastructure for unrelated pages.

Implement the narrow Unknown Sources idle-target slice, but choose names that could generalize naturally later.

---

# Completion Report

At completion report:

- final spec shape;
- where investigation identity and kind are owned;
- how idle is derived without a boolean flag;
- projection changes;
- idle occupant composition;
- whether the existing matrix was reused unchanged;
- any remaining truthful geometry change;
- files changed;
- tests added or updated;
- architecture-tripwire results;
- analyzer result;
- manual verification of:
  - initial idle;
  - select;
  - clear selection;
  - filter change;
  - Identify ↔ Numeric IDs;
  - Dismiss;
  - navigate away and return.
