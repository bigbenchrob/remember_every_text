---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-03-20
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./CHECKLIST.md
  - ./SIDEBAR_GEOMETRY_CONTRACT.md
  - ./seed.txt
tests: []
---

# Tests and Verification - Sidebar Cassette Role System

## Automated Tests To Add

### Role Mapping Tests

- verify each supported cassette resolver returns exactly one `SidebarCassetteRole`
- verify current messages/contacts cassettes are classified into the expected semantic roles
- verify no cassette can omit role assignment after the role contract lands

### Section Derivation Tests

- verify an ordered sequence of resolved cassette roles produces the expected section grouping
- verify grouping preserves rack order within each derived section
- verify contiguous context cassettes remain grouped together
- verify filters and actions do not collapse into the same derived section

### Layout Ownership Tests

- verify section spacing is driven centrally rather than by cassette-local top spacing
- verify role-driven section wrappers apply the expected structural spacing rules
- verify legacy layout escape hatches do not override section boundaries in unsupported ways

### Geometry Contract Tests

- verify approved placement modes map to the expected sidebar-owned horizontal constraints
- verify `insetWithTrailingGutter` reserves trailing gutter width for approved affordances only
- verify constrained textual content and control content render within the selected content envelope without overflow at the real sidebar width
- verify changing centrally owned geometry token values propagates through both shells and feature-facing geometry constraints
- verify feature-owned widget builders receive the expected geometry constraints for their selected placement mode

## Manual Verification

### Scenario 1: Messages Sidebar Hierarchy

1. Open the messages sidebar flow.
2. Choose a contact.
3. Confirm the top menu reads as an app-level control separated from the rest of the branch.
4. Confirm the contact hero and related informational/reset cassette read as one context group.
5. Confirm the message-scope toggle and handle filter read as one filter group.
6. Confirm the heat map reads as the action-oriented exploration group.

### Scenario 2: Recovered Branch Layout

1. Choose a contact.
2. Switch to the recovered or deleted-message branch.
3. Confirm the context group remains stable.
4. Confirm the recovered-specific action cassette still appears in the action area rather than visually collapsing into filters or context.

### Scenario 3: Settings Or Non-Messages Sidebar Branch

1. Navigate to a non-messages sidebar branch that still uses cassettes.
2. Confirm every rendered cassette still receives a coherent layout classification.
3. Confirm role-driven grouping does not assume the messages investigative branch only.

### Scenario 4: Regression Against Ad Hoc Spacing

1. Compare current cassette group edges and inter-group spacing across the main investigative branch.
2. Confirm left and right rails are consistent within each section.
3. Confirm no single cassette still appears visually offset only because of a bespoke local spacing tweak.

### Scenario 5: Gutter Ownership

1. Open a cassette list with trailing dismiss or row action affordances.
2. Confirm row text aligns to the shared content lane rather than to the window edge.
3. Confirm trailing actions occupy the reserved gutter rather than forcing a competing width model for the whole list.

### Scenario 6: New Cassette Fit Test

1. Add or temporarily simulate a cassette in an existing branch with a valid semantic role.
2. Assign it an approved placement mode.
3. Confirm it lands in a coherent section without requiring a new one-off width or top-spacing override.

## Verification Results

No verification results recorded yet.

## Notes

- The key regression to guard against is not a crash. It is a return to emergent layout driven by cassette-local exceptions.
- If role-driven grouping still requires routine per-cassette spacing negotiation, the feature is incomplete.