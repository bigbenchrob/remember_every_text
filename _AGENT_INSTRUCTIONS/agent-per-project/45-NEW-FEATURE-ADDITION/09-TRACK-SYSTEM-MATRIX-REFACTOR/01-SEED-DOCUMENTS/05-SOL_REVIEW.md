I understand the proposed refactor as replacing a one-dimensional height calculator with an authoritative two-dimensional page composition.

**The problem**

The current system has two separate truths:

```text
search_page_track_plan.dart
    knows which Track each occupant contributes height to

distributed widget trees
    know which column renders the content and how it is aligned
```

The occupant list can resolve:

```text
Track C = max(requirements assigned to Track C)
```

But it cannot answer:

```text
What occupies C2?
What occupies C3?
How is each cell aligned?
Which renderer presents each occupant?
```

That information is scattered between the Search-page resolver, sidebar cassette rendering, Messages header, Conversation panel, and alignment wrappers. Moving one item therefore requires coordinated edits in several places.

The proposed matrix fixes this by making the complete cell coordinate authoritative:

| Track | Column 1 | Column 2              | Column 3            |
| ----- | -------- | --------------------- | ------------------- |
| A     | Top menu | All messages          | Conversation        |
| B     | empty    | result metadata       | empty               |
| C     | empty    | search controls       | Conversation Card   |
| D     | empty    | search explanation    | excerpt explanation |
| E     | empty    | fixed-height occupant | empty               |

The matrix records occupancy and alignment. Tracks themselves remain ordinal geometry with no semantic meaning.

**The proposed architecture**

The intended chain is:

```text
Search-page composition
    creates PageTrackLayoutMatrix
        containing MatrixCells
            containing placement-independent TrackOccupants
                producing OccupantDimensionalClaims

Page resolves matrix
    -> ResolvedTrackLayoutMatrix

Distributed render locations identify themselves by CellId
    -> read occupant, height, and alignment
    -> render the feature-owned presentation
```

This corrects several weaknesses at once:

- Complete `CellId` replaces row-only identity.
- Occupants stop carrying hidden `TrackId` placement.
- Cell alignment moves into page composition.
- The unordered occupant bag disappears.
- `additionalOccupants` disappears.
- Renderers stop accepting independently chosen Track IDs and local placement decisions.
- The intended Column 3 composition can be known from page state before the end panel renders.
- Moving something from C2 to D2 becomes one matrix edit.

The four seeds have distinct roles and should remain separate:

1. Current-system diagnosis and migration direction.
2. Canonical target architecture.
3. Phased migration plan.
4. Implementation record and completion authority.

I would create one coherent package around those four documents rather than a separate forest of plans for each. Document 03 should own the executable slices; Document 04 should become the living implementation record.

**What I would adjust**

The first correction concerns the stated lifecycle defect. The current code already reads `effectiveRightPanelSpecProvider` in `WorkspaceLayout`, independently of whether the right widget has mounted. The more precise current failure appears to be:

```text
right-panel intent is known
but Conversation presentation data may still be loading
and the center and end-panel trees resolve separate plans
```

The Conversation Card occupant is currently omitted when its signature provider has not produced data. Therefore, a matrix alone will not eliminate geometry changes unless it represents the intended cell even during loading. We should distinguish widget-mount dependence from asynchronous presentation-data availability.

Second, dimensional claims need a constraint contract. Natural height is sometimes width-dependent. A wrapped label or card cannot truthfully declare its height without knowing the width available to that cell. I would explicitly define:

```text
occupant + cell constraints
    -> OccupantDimensionalClaim
```

The constraint input should include the relevant column width, text scaling, direction, and locale. The current global `availableWidth: double.infinity` must not quietly survive into the final architecture.

Third, I would initially keep `OccupantDimensionalClaim` limited to demonstrated requirements. `naturalHeight` is essential. `preferredWidth` and `minimumWidth` should be added only where the current canonical Conversation Card contract actually consumes them. Otherwise they risk becoming declared but unenforced metadata.

Fourth, the ownership wording needs one refinement:

```text
Feature presentation owns the widget definition.
TrackOccupant owns dimensional calculation and delegates construction
of that feature-owned presentation.
Matrix owns placement.
Resolver owns geometry.
Cell renderer consumes the resolved cell.
```

That prevents the generic track infrastructure from becoming a warehouse for Search, Messages, Conversation, or sidebar widget construction.

Finally, I would slightly reshape the migration boundaries. Phase 2 cannot truthfully call the matrix authoritative while the old widget trees remain authoritative for placement. I would make the transition explicit:

1. Add `TrackColumnId`, `CellId`, matrix types, and validation.
2. Build the Search matrix and derive the existing row-height plan from it as a short-lived compatibility bridge.
3. Make occupants placement-independent and introduce dimensional claims.
4. Resolve the complete matrix and migrate renderers to `CellId`.
5. Make one page-state-derived resolved matrix available to both Flutter subtrees.
6. Remove the old bag, `additionalOccupants`, row-only lookups, fallbacks, and duplicate alignment declarations.

Overall, I strongly agree with the direction. The matrix is the missing composition authority. Before implementation, I would tighten the lifecycle diagnosis, define how cell constraints reach dimensional claims, and make the brief compatibility period explicit. Those changes preserve the proposal while removing the two places most likely to produce another hidden layout dependency.
