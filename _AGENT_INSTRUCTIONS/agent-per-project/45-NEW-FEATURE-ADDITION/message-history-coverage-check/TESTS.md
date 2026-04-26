# Tests: Message History Coverage Check

## Phase 1 Unit Coverage

### Report Classification

- Verify `complete` when source total equals accounted total and earliest date is not suspiciously recent.
- Verify `incomplete_import` when source total is greater than accounted total.
- Verify `incomplete_source_history` when totals match and earliest source date crosses the suspiciously-recent threshold.
- Verify `unknown` when source totals cannot be read safely.

### Report Serialization

- Verify the report entity serializes JSON with the expected coverage fields.
- Verify null date handling in JSON output.

### Report Formatting

- Verify summary text includes source total, visible total, recovered total, accounted total, missing count, and date range.
- Verify the interpretation block matches the computed status.

## Phase 1 Manual Verification

### 1. Settings Entry

- Open Settings.
- Check that `Message history coverage...` appears under Troubleshooting.
- Click it.
- Check that a transient self-contained coverage cassette appears.

### 2. Complete Local Coverage

- Run against a state where source total matches visible plus recovered totals.
- Check that the cassette says MessageLens has accounted for all messages currently available on this Mac.
- Check that the summary block values add up correctly.

### 3. Incomplete Import

- Run against a state where source total is higher than accounted total.
- Check that the cassette reports incomplete import rather than incomplete source history.
- Check that `Missing` is a positive number.

### 4. Incomplete Source History

- Run against a state where totals match but the earliest source date is suspiciously recent.
- Check that the cassette says MessageLens imported all messages available on this Mac and that older messages may exist elsewhere.
- Check that inline troubleshooting guidance appears in the same cassette.
- Check that the guidance tells the user to verify older conversations locally and check another signed-in device.

### 5. Unreadable Or FDA-Blocked Source

- Run when FDA is not granted or `chat.db` is unavailable.
- Check that the feature returns an `unknown` style result instead of crashing.
- Check that copy stays calm and explanatory.

## Phase 2 Manual Verification

### Export JSON

- Export the report.
- Verify the JSON fields match the displayed summary.
- Verify unknown-state export remains valid and readable.
- Verify the file is revealed in Finder after export.

## Regression Checks

- Verify the settings top-menu placeholder and transient semantics still behave correctly.
- Verify entering and leaving the Message History Coverage flow does not persist the menu label as a stable settings context.
- Verify the feature performs no writes to `working.db`, `import.db`, or overlay tables.
