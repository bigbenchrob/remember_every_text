# Post-Implementation Architectural Review

## TrackOccupant First Vertical Slice

The first TrackOccupant vertical slice has now been implemented for Search-page Track A and Track B.
The app layout appears visually intact.
Before introducing further Tracks or more complex occupants, perform a focused repository-aware architectural review of the implemented slice.
This is primarily a review task.
Do not expand the feature.
Do not introduce Track C.
Do not implement Conversation Card or Conversation glyph occupants.
Do not migrate other pages.
Only make source changes if the review finds a clear defect, architectural violation, duplicated source of truth, or test gap that can be corrected safely within the existing Track A/Track B scope.
Create:
`TRACK_OCCUPANT_POST_IMPLEMENTATION_REVIEW.md`
inside:
`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/`
Append all work to `DOCUMENTATION_PASS_LOG.md`.

---

# Review Objective

Determine whether the implemented TrackOccupant slice validates the approved architecture:

```text
prepared presentation data
    -> TrackOccupant
        -> TrackRequirement
        -> presentation Widget
    -> page resolves ResolvedTrackPlan
    -> columns render inside resolved allocations

The review should answer:

Did TrackOccupant make ownership cleaner without changing product behavior or introducing hidden coupling?

⸻

Files And Surfaces To Inspect

Inspect all implementation files changed for this slice, including the uploaded/current versions of:

* cross_column_track_plan.dart
* search_page_track_plan.dart
* top_chat_menu_widget.dart
* message_evidence_header.dart
* conversation_excerpt_panel_view.dart
* workspace_layout.dart
* sidebar_utilities_cassette_body_builder.dart

Also inspect:

* focused Track tests;
* relevant wrapper code;
* Track diagnostics;
* Cross-Column Layout Tracks documentation;
* any new generic or feature-specific TrackOccupant types.

Trace actual dependency direction rather than relying only on file names.

⸻

Questions To Answer

1. Generic Track Layer

Verify that generic Track infrastructure knows only about concepts such as:

* TrackId
* TrackRequirement
* TrackRequirementContext
* TrackOccupant
* ResolvedTrackPlan
* ResolvedTrackAllocation
* requirement resolution

It must not know about:

* Search;
* top menus;
* message evidence;
* Conversations;
* Conversation Cards;
* glyphs;
* sidebar cassettes.

Identify any feature knowledge that leaked into the generic layer.

⸻

2. Coordinator Purity

Verify that the coordinator remains limited to:

collect occupant requirements
group by Track
resolve maximum height
build ResolvedTrackPlan

It should not:

* branch by occupant class;
* branch by feature;
* calculate text height itself;
* know control constants;
* know which column contains which feature;
* insert page-level spacing.

Confirm whether constant and calculated occupants are treated identically by the coordinator.

⸻

3. TrackOccupant Contract

Review the final API.

Determine whether it cleanly separates:

* requirement calculation;
* presentation construction;
* resolved allocation.

Confirm that requirement calculation does not depend directly on:

* providers;
* repositories;
* mutable feature state;
* database access;
* sibling columns;
* post-frame widget size.

Confirm whether taking or avoiding BuildContext in requirement calculation was handled appropriately.

Record the final API and any deviations from the approved analysis.

⸻

4. TextTrackOccupant

Verify that title and metadata occupants calculate height from the same presentation contract used to render them.

Check parity for:

* exact text;
* exact TextStyle;
* TextScaler;
* text direction;
* locale where applicable;
* max lines;
* wrapping;
* overflow.

Confirm that:

* there are no copied line-height estimates;
* there are no character-count estimates;
* text measurement uses Flutter typography correctly;
* no discretionary vertical spacing is included.

Identify any risk of measurement/rendering drift.

⸻

5. Top Menu Occupant

Verify that the sidebar Top Menu is an ordinary TrackOccupant.

The page/coordinator must not special-case it.

Confirm that its constant natural height comes from one shared presentation source of truth used by both:

* the rendered control;
* the occupant requirement.

Check for:

* duplicated constants;
* page-owned magic numbers;
* control chrome excluded from the declared outer height;
* hidden padding treated as page geometry.

State exactly where the authoritative Top Menu height now lives.

⸻

6. Empty Cells

Verify that empty Track B cells are represented by absence of an occupant.

Confirm that no unnecessary EmptyTrackOccupant or zero-height placeholder abstraction was introduced.

⸻

7. Content-Tight Invariant

Verify the implemented rule:

Occupied Tracks contain no discretionary vertical spacing. Their height is the maximum natural requirement declared by their occupants. All intentional cross-column spacing is represented by explicit empty Tracks.

Audit Track A and Track B for:

* vertical wrapper padding;
* hidden minimum heights;
* legacy band allowances;
* arbitrary requirement inflation;
* local offsets;
* transforms;
* negative margins;
* unrelated SizedBox spacing inside occupied Tracks.

Distinguish genuine intrinsic control geometry from page spacing.

⸻

8. Presentation Ownership

Confirm that:

* Search composition selects occupants;
* generic Track infrastructure resolves requirements;
* feature presentation owns feature-specific occupants;
* underlying widgets remain pure presentation;
* no widget learned about sibling columns;
* no feature learned about another feature merely to support alignment.

Specifically evaluate dependency boundaries among:

* Essentials/navigation;
* Messages presentation;
* Conversations presentation;
* sidebar presentation;
* generic layout infrastructure.

Answer:

Did any feature boundary become cleaner or dirtier?

⸻

9. Search Ownership

Determine whether Search now owns only page composition appropriate to its role, or whether it has accumulated presentation details that belong elsewhere.

Check whether:

* Search instantiates generic/feature occupants without owning their internal metrics;
* Message Evidence owns its title/metadata presentation contract;
* Conversations owns its panel-title presentation contract;
* sidebar/top-menu presentation owns its fixed control contract.

Recommend corrections only where ownership is clearly wrong.

⸻

10. Wrapper Compatibility

Review how the existing generic track-cell wrapper participates.

Confirm that wrappers:

* consume the resolved plan;
* do not recalculate requirements;
* do not add hidden vertical geometry;
* remain compatibility renderers rather than alternate authorities.

Identify whether the wrapper system now contains duplicated or conflicting sources of truth.

Do not retire wrappers in this task.

⸻

11. Requirement Recalculation

Trace how requirements update when relevant inputs change:

* window width;
* text scale;
* theme/typography;
* locale/text direction;
* right panel presence;
* Search state or metadata text.

Confirm that recomputation occurs declaratively during normal build and does not depend on repair loops.

⸻

12. Testing Adequacy

Review the focused tests and identify whether they prove:

* constant and calculated occupants share the same interface;
* resolver chooses the tallest requirement;
* no occupant contributes nothing;
* text requirement matches its rendering contract;
* text scaling affects requirements correctly;
* wrapping affects requirements correctly where allowed;
* Top Menu requirement matches its presentation metric;
* page-owned magic Track A/B heights are gone;
* Track A and Track B remain content-tight;
* right-panel absence does not break resolution.

Add narrowly scoped tests only if an important approved invariant is currently unprotected.

Do not broaden into full-app testing.

Run focused tests and flutter analyze if source or tests are changed.

⸻

13. Code Complexity

Evaluate whether the first slice introduced unnecessary abstraction.

Look for:

* excessive generic layers;
* occupant factories that obscure simple construction;
* duplicated adapters;
* objects that exist only to forward values;
* premature support for future min/max/compact/overflow behavior;
* overly broad shared helpers.

The first slice should remain the smallest honest implementation.

Recommend simplification if the architecture is correct but the implementation is more elaborate than required.

⸻

14. Documentation Accuracy

Compare implementation against:

* TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md
* package README
* proposal
* design notes
* checklist
* tests document

Correct documentation where the actual implementation legitimately differs.

Do not rewrite settled rationale merely to mirror incidental code structure.

⸻

Deliverable

The review document should include:

1. Executive conclusion:
    * validated;
    * validated with minor corrections;
    * or architectural concerns remain.
2. Final implemented flow.
3. Final generic TrackOccupant API.
4. Dependency and ownership findings.
5. Source-of-truth findings for:
    * text metrics;
    * Top Menu height;
    * Track resolution.
6. Content-tight invariant review.
7. Test coverage review.
8. Complexity/debt findings.
9. Deviations from the approved analysis.
10. Recommended next slice.

⸻

Next-Slice Recommendation

Do not implement the next slice.

Recommend one of these, with rationale:

* add the first explicit fixed-height spacing occupant in a chosen track cell;
* introduce the next simple text/control Track;
* extract shared glyph metrics before a glyph occupant;
* extract Conversation Card metrics before a card occupant;
* migrate Track A/B to another page;
* pause for a correction if the first slice exposed architectural problems.

Base the recommendation on the implementation, not on architectural completeness.

⸻

Success Criterion

A future developer should be able to read the review and know:

* whether TrackOccupant genuinely improved ownership;
* whether the generic layer remained feature-neutral;
* whether requirement and rendering contracts are synchronized;
* whether hidden page geometry has been eliminated;
* whether the code is ready for the next incremental Track slice.

```
