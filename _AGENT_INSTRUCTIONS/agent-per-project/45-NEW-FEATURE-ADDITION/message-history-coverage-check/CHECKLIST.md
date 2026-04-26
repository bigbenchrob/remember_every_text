# Checklist: Message History Coverage Check

## Phase 1: Core Coverage Report

- [x] Add a new transient Settings troubleshooting action for `Message history coverage...`.
- [x] Add a new settings cassette spec and coordinator route for the coverage flow.
- [x] Define a pure coverage report entity and status enum for whole-library coverage.
- [x] Implement a resolver that reads `chat.db` and `working.db` through approved access paths.
- [x] Compute source total, visible total, recovered total, total accounted, missing count, and source date range.
- [x] Classify `complete`, `incomplete_import`, `incomplete_source_history`, and `unknown` using a conservative heuristic.
- [x] Render the computed report as a self-contained transient settings cassette with a title and explanatory body text.
- [x] Verify the feature remains read-only and does not modify import, migration, or overlay state.

## Phase 2: Export Report

- [x] Add an explicit export path for the coverage report as JSON.
- [x] Reuse an existing export/presentation path where practical without escalating to a full support bundle.
- [x] Ensure exported JSON contains `chatDbTotal`, `visible`, `recovered`, `missing`, `earliest`, `latest`, and `status`.
- [x] Verify export behavior when the report is `unknown`.

## Phase 3: Troubleshooting Guidance

- [x] Add user-facing troubleshooting guidance for partial local source history.
- [x] Decide whether troubleshooting guidance lives inline in the same cassette or behind a follow-up transient settings action.
- [x] Ensure the guidance does not imply that MessageLens lost data when coverage is locally complete.

## Phase 4: Validation And Polish

- [x] Add unit coverage for report classification and formatting helpers.
- [ ] Add manual validation steps for complete coverage, incomplete import, incomplete source history, and unreadable/FDA-blocked states.
- [x] Validate that settings-menu semantics remain correct for this transient action.
- [ ] Review report copy for trust-building tone and clarity.

## Current Implementation Target

- [x] Phase 1 only: add the transient settings entry and computed report cassette.
- [x] Defer export and troubleshooting follow-up actions until after the first slice is working.
