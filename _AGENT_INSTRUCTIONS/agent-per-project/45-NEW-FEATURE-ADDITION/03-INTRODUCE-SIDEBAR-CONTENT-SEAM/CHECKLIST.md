---
tier: project
scope: implementation-checklist
owner: agent-per-project
last_reviewed: 2026-07-07
source_of_truth: draft
status: proposed
---

# Sidebar Content Seam Checklist

## Planning

- [x] Identify seam between X-column layout and sidebar cassette system.
- [x] Confirm first slice avoids dynamic height measurement.
- [x] Document ownership rules.
- [x] Confirm naming for content-start hint.
- [x] Confirm Search All Messages as the first prototype surface.

## Slice 1: Inert Cassette Layout Hint

- [x] Add a sidebar-local layout-anchor enum.
- [x] Add inert layout-anchor metadata to cassette payloads.
- [x] Default all existing cassettes to no content-start anchor.
- [x] Mark the Search All Messages heatmap payload as a preferred content-start
      candidate.
- [x] Do not alter visual rendering yet beyond the layout seam.

## Slice 2: Sidebar Stack Seam Support

- [x] Add an optional content-start layout contract to the left sidebar surface.
- [x] Keep app-control/top-menu cassettes pinned as the panel identity row.
- [x] Insert spacer before the first preferred content-start cassette when a
      page-level content-start anchor is supplied.
- [x] Preserve existing cassette ordering and grouping after the seam.
- [x] Preserve existing behavior when no seam contract is supplied.

## Slice 3: Search Page Prototype

- [x] Supply the X-column content-start anchor to the Search All Messages
      sidebar.
- [ ] Verify the top selector remains aligned with center/right panel identity.
- [ ] Verify the heatmap starts at the shared content-start anchor.
- [ ] Verify the info cassette remains between the selector and heatmap.
- [ ] Verify ordinary sidebar scrolling still works.

## Slice 4: Documentation And Standards

- [ ] Update the X-column layout documentation with the sidebar seam rule.
- [ ] Update sidebar/cassette documentation with the content-start hint.
- [ ] Document the deferred autonomous fitting behavior.

## Verification

- [x] Run `flutter analyze`.
- [ ] Run relevant architecture/import tests.
- [ ] Manually verify Search All Messages.
- [ ] Manually verify Contacts sidebar is not regressed.
- [ ] Manually verify Conversations sidebar is not regressed.
- [ ] Manually verify unfamiliar sources sidebar is not regressed.
