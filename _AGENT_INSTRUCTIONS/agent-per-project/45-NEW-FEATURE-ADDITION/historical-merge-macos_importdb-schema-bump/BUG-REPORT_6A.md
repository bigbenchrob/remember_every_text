Implement detection of missing macos_import.db in recovery state.

⸻

Goal

Ensure the app explicitly detects when macos_import.db is missing and treats this as a distinct recovery condition from a normal incomplete working projection.

⸻

Scope

- Only touch:
  - onboarding_environment_report_provider.dart
  - onboarding_environment_report.dart
  - onboarding_gate_provider.dart
- Extend the existing environment report to include:
  - import_db_exists: bool
- At startup:
  - Check whether macos_import.db file exists and is readable

⸻

Required behavior

Add a new classification:

Case A (existing behavior)

- working.db incomplete
- macos_import.db exists
  → normal incomplete projection recovery

Case B (new behavior)

- working.db incomplete
- macos_import.db missing
  → missing ledger recovery state

For Case B:

- Recovery must:
  - block normal app surfaces (already true)
  - explicitly classify this as “missing import database”
  - NOT assume migration can fix it

⸻

Non-goals (strict)

- Do NOT create or recreate macos_import.db automatically
- Do NOT trigger import or migration
- Do NOT modify import logic
- Do NOT change UI text yet (classification only)
- Do NOT modify working.db

⸻

Acceptance Criteria

- On startup, when macos_import.db is missing:
  - environment report includes import_db_exists = false
  - onboarding gate routes to recovery (already happens)
  - recovery classification distinguishes this from normal incomplete projection
- No changes to existing successful or incomplete-with-ledger flows

⸻

Notes

This slice is detection only, not recovery.

It prepares the next slice, which will:

- surface a user-facing explanation
- guide rebuild from source data
