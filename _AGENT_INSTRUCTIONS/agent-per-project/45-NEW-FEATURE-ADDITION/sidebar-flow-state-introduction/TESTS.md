---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-03-19
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./CHECKLIST.md
tests: []
---

# Tests and Verification - Sidebar Flow State Introduction

## Automated Tests To Add

### Transition Tests

- verify `contactChosen(contactId)` sets the active contact and clears subordinate state that should reset
- verify `chooseAnotherContact()` clears contact-scoped state
- verify `handleSelected(handleId)` sets only the intended handle selection
- verify `allHandlesSelected()` clears `selectedHandleId`
- verify `messageScopeChanged(scope)` produces the expected state and reset behavior

### Projection Tests

- verify "no contact chosen" projects the contact-picker branch
- verify "contact chosen + all handles + regular scope" projects the expected cassette branch
- verify "contact chosen + deleted scope" projects the deleted-message branch
- verify handle selection changes the projected branch inputs without changing unrelated state

### Phase 1 Panel-Routing Tests

- verify each supported transition triggers the expected `ViewSpec` update for the targeted branch
- verify `chooseAnotherContact()` invalidates the old contact-scoped panel route
- verify message-scope transitions route to the correct panel path

## Manual Verification

## Verification Results

### 2026-03-19 Manual Pass

- Contact selection to regular messages worked: choosing a contact showed the expected contact hero state and opened that contact's regular messages in the center panel.
- Contact switch reset worked in the regular flow: after choosing another contact, the sidebar returned to the regular messages heatmap for the new contact and the center panel updated correctly.
- Handle filtering reset worked across contact changes: choosing a contact, narrowing to an email handle, then changing contact and choosing another handle updated correctly.
- Heatmap month-jump behavior worked in both regular and recovered flows.
- A sidebar projection defect was observed during recovered contact flow: the sidebar could show the recovered messages heatmap and the regular contact heatmap together.
- Follow-up patch applied after this pass: hide the conflicting regular contact heatmap cassette during contact-recovered flow and place the recovered contextual heatmap after the main cassette branch.
- Revalidation of the recovered contact sidebar projection is still pending after that follow-up patch.

### Scenario 1: Default Contact Flow

1. Open the top-level branch that leads to the contacts/messages flow.
2. Confirm the sidebar shows the picker state.
3. Choose a contact.
4. Confirm the sidebar projects the chosen-contact branch.
5. Confirm the center panel shows the default contact-scoped message view.

### Scenario 2: Handle Filtering

1. Choose a contact.
2. Select a specific handle.
3. Confirm the sidebar shows the handle-selected state.
4. Confirm the center panel reflects the handle-filtered view.
5. Switch back to all handles.
6. Confirm both sidebar and panel return to the all-handles state.

### Scenario 3: Deleted Or Recovered Scope

1. Choose a contact.
2. Switch the message scope to the deleted or recovered branch.
3. Confirm the sidebar projects the correct branch.
4. Confirm the center panel shows the corresponding message surface.

### Scenario 4: Choose Another Contact Reset

1. Choose a contact.
2. Switch to deleted or recovered scope.
3. Optionally select a specific handle.
4. Trigger `chooseAnotherContact()`.
5. Confirm `chosenContactId` is cleared.
6. Confirm handle-specific state is cleared.
7. Confirm message scope resets according to the agreed product rule.
8. Confirm no stale deleted-message or contact-specific content remains in the center panel.

### Scenario 5: Contact Switch Reset

1. Choose contact A.
2. Narrow to a non-default subordinate state.
3. Choose contact B.
4. Confirm subordinate state resets to the default contact-scoped path for contact B.
5. Confirm the panel content matches contact B rather than lingering on contact A.

## Phase 2 Verification Targets

These are not required for phase 1 delivery, but they define what later success should look like:

- a canonical investigation state containing `contactId`, `messageScope`, and `heatMapMonth` is sufficient to reconstruct the correct center-panel meaning
- saved investigation states reopen the same valid investigation context without stale or contradictory surface state

## Notes

- The key regression to guard against is not a crash. It is stale cross-surface meaning.
- If the sidebar and panel can still disagree after the transition rewrite, phase 1 is incomplete.