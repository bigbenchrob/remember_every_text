# Tests: Message History Coverage Refactor

## Phase 1: Durable Routing

### Settings Menu Semantics

- Verify `Message history coverage…` dispatches durable settings selection rather than transient action transport.
- Verify `sendLogs` and `resetMessageData` remain transient.

### Stable Sidebar Topology

- Verify durable settings context `messageHistoryCoverage` reconstructs the Message History Coverage sidebar child.
- Verify transient settings actions still do not appear as durable stable children.

### Derived Center Panel

- Verify settings-mode effective center-panel state derives `ViewSpec.settings(SettingsViewSpec.messageHistoryCoverageReport())` when durable context is selected.
- Verify clearing or changing durable settings context removes the derived Message History Coverage center-panel route.
- Verify settings-mode center panel host renders the settings feature coordinator output for the derived coverage spec.

### Dispatcher

- Verify dispatching `SettingsPersistentContextChosen(actionId: messageHistoryCoverage)` updates flow state and stable sidebar cascade.
- Verify the same dispatch does not rely on ephemeral settings projection.

## Phase 2: Presentation Shaping

- Verify complete state produces a reassuring headline.
- Verify overlap state keeps the headline complete and emits a small overlap note instead of foregrounding `accounted > total`.
- Verify incomplete import makes `missing` visible and changes the headline accordingly.
- Verify incomplete source history emphasizes local-source limits rather than app loss.
- Verify unknown state preserves export availability and explanatory copy.
- Verify zero-message and null-date states remain valid.

## Phase 3: Rich Panel Rendering

- Verify the accounting bar never exceeds 100% total width.
- Verify the missing segment is omitted or minimized when missing is zero.
- Verify the timeline coverage strip shows earliest and latest labels clearly.
- Verify recovered-message explanation does not describe recovered rows as lost.

## Manual Validation

### Complete Coverage

- Open Settings -> Message History Coverage.
- Confirm the sidebar selection persists as durable settings context.
- Confirm the center panel opens automatically.
- Confirm the panel communicates that every message on this Mac has been accounted for.

### Incomplete Import

- Validate the center panel says some source messages could not be accounted for.
- Confirm missing count is visible and not drowned out by other counts.

### Incomplete Source History

- Confirm the panel communicates that MessageLens accounted for all messages available on this Mac while making it clear the Mac's history starts later than expected.
- Confirm troubleshooting guidance points users to other devices / sync checks, not destructive actions.

### Unknown / FDA Blocked

- Confirm the panel fails gracefully and still offers the approved export or follow-up path.

## Regression Checks

- Existing coverage report logic and export tests continue to pass or are updated intentionally.
- Existing settings-sidebar transient action behavior remains correct for `sendLogs` and `resetMessageData`.
- No widgets perform direct database access.
