The manual Search-page verification has exposed one remaining architectural problem.
I will provide screenshots showing the issue.
Before the end Conversation sidebar is present, optional cells contribute no height, so several center-column elements collapse into a tightly packed stack.
After a Conversation is opened, cells such as the Conversation Card and excerpt label begin contributing real dimensional claims. Their Tracks then expand dramatically, and the center-column layout changes from compressed to fully spaced.
The current behavior is technically reactive, but visually wrong.
The page should not behave like a deflated balloon that suddenly inflates when optional content appears.
Please introduce an explicit, page-owned minimum reservation mechanism for matrix cells.

# Governing Principle

A matrix cell may reserve a minimum amount of vertical space even when it currently has no live occupant.
This is scaffolding that prevents the shared Track from collapsing completely.
Use the term:

```text
minimumReservedHeight

Do not call this:

* a placeholder occupant;
* fake content;
* a shim Track;
* hidden padding;
* a fixed Track height;
* a compatibility allowance.

It is an explicit property of page composition.

Ownership

minimumReservedHeight belongs to MatrixCell.

It does not belong to:

* TrackOccupant;
* TrackId;
* ResolvedTrackLayoutMatrix;
* the presentation widget;
* the renderer.

The occupant continues to declare only its truthful live presentation dimensions.

The matrix cell declares the minimum geometry the page wishes to preserve at that coordinate when live content is absent or smaller.

Conceptually:

MatrixCell(
  id: CellId.d2,
  occupant: currentMetadataOccupant,
  minimumReservedHeight: oneLineMetadataHeight,
  alignment: TrackCellAlignment.top,
)

Resolution Rule

For each cell, calculate:

effectiveNaturalHeight =
  max(
    minimumReservedHeight,
    occupant?.dimensionalClaim.naturalHeight ?? 0,
  )

Then resolve the Track exactly as before:

resolved Track height =
  maximum effectiveNaturalHeight among all cells in that Track

Empty cells may therefore contribute either:

0

or:

minimumReservedHeight

depending on page composition.

No synthetic occupant should be manufactured.

Intended Search-Page Behavior

The initial Search-page matrix should reserve a stable resting geometry for cells that may later receive content.

At minimum, review and implement the appropriate reservations for cells such as:

D2
Search supporting metadata/context
Reserve the natural height of one line using the exact approved presentation contract.
A3
Conversation heading
Reserve the normal title-line height if this cell can exist before the right panel is visibly mounted.
C3
Conversation Card
Reserve the natural height of the smallest approved Conversation Card presentation.
D3
Conversation excerpt explanation
Reserve the natural height of one line using the exact approved presentation contract.

Use the actual current matrix and source ownership rather than assuming the coordinates above are all still correct.

B3 should remain unreserved if it is guaranteed never to receive content.

Apply the rule systematically:

Could this cell participate in the intended resting page composition even while its live content is absent?
Yes:
  assign an explicit minimumReservedHeight
No:
  leave minimumReservedHeight at zero

Source Of Truth

Do not introduce duplicated numeric magic values.

Every reservation must come from the same approved feature-owned presentation contract used by the eventual live occupant.

Examples:

* one-line text reservation derives from the exact text style, scaler, direction, locale, line contract, and width constraint;
* Conversation Card reservation derives from canonical Conversation Card presentation metrics;
* title reservation derives from the exact title presentation contract.

Where a representative minimum presentation is required, make that representation explicit and feature-owned.

Do not estimate from arbitrary constants if a shared presentation metric already exists or can be extracted honestly.

Width Constraints

Reservations for wrapping content must use truthful per-column presentation constraints.

Do not calculate one-line or minimum content against infinite width.

The same page-owned column-width inputs used for live occupant claims must also govern reserved-height calculation.

Important Distinction

This mechanism provides:

stable reactive geometry

not frozen geometry.

The expected behavior is:

initial page
  -> minimum reservations establish the intended resting layout
live one-line content appears
  -> no geometry jump if it fits within the reservation
larger card or wrapped text appears
  -> the affected Track expands only by the additional amount required
content disappears
  -> the Track contracts only to its reserved minimum, not to zero

Architectural Constraints

Preserve all existing approved matrix principles:

* one authoritative PageTrackLayoutMatrix;
* complete CellId placement;
* placement-independent occupants;
* truthful OccupantDimensionalClaim;
* page-owned alignment;
* one immutable ResolvedTrackLayoutMatrix;
* TrackCellView remains intentionally unintelligent;
* no post-frame measurement;
* no GlobalKey measurement;
* no hidden padding;
* no special semantic Track behavior.

minimumReservedHeight must remain ordinary cell geometry input.

Tests

Add focused coverage proving:

Cell model

* default minimumReservedHeight is zero;
* negative reservations are rejected;
* empty cells may reserve non-zero height;
* occupied cells may reserve height smaller than, equal to, or larger than the live claim.

Resolution

* effective cell height uses the maximum of reservation and live natural height;
* an absent occupant does not collapse below its reservation;
* live content larger than the reservation expands the Track;
* removing live content returns the Track to the reservation;
* peer cells receive the same resolved Track height;
* reservations do not affect alignment or occupant dimensional truth.

Search integration

* initial Search-page layout has the intended resting Track heights before the right sidebar appears;
* entering a one-line query does not cause a large layout jump;
* opening a Conversation Card causes only incremental expansion when its live height exceeds the reserved minimum;
* closing the right panel returns Tracks to their reserved resting geometry rather than collapsing;
* wrapped metadata expands correctly under truthful finite width;
* screenshots with and without the right panel show the same basic page rhythm.

Manual Verification

Use the screenshots I provide as the failure case.

Verify these states manually:

1. initial Search page with no query and no right panel;
2. active query with no right panel;
3. right panel open with a minimum-height Conversation Card;
4. right panel open with a taller Conversation Card;
5. long wrapped Search metadata;
6. close the right panel again;
7. resize narrow and wide.

The center-column layout should remain recognizably the same composition throughout.

Content may expand Tracks.

Tracks must not collapse to zero merely because an optional occupant is temporarily absent.

Documentation

Update the matrix architecture and implementation record to add the settled principle:

A MatrixCell may declare minimumReservedHeight to preserve the page’s intended resting geometry when live content is absent or smaller. Resolution uses the larger of the reservation and the live occupant’s truthful natural height.

Document clearly that this is:

* explicit page composition;
* not padding;
* not a placeholder occupant;
* not a semantic Track role;
* not frozen geometry.

Update:

* Document 02, if needed to record the architectural extension;
* Document 03, if needed to record the migration/verification requirement;
* Document 04 with implementation evidence;
* package README;
* DOCUMENTATION_PASS_LOG.md.

Completion

Do not mark manual Search-page verification complete until the screenshots confirm:

* the initial page is not vertically collapsed;
* optional Column 3 content does not transform the header from compressed to inflated;
* larger live content produces only truthful incremental expansion;
* the layout returns to its reserved resting geometry when optional content disappears.

Report:

* final MatrixCell API;
* reservation calculation sources for each Search cell;
* final Search-page reservations by CellId;
* resolver changes;
* tests and analyzer results;
* manual screenshot observations;
* documentation updates;
* any cells deliberately left with zero reservation and why.

```
