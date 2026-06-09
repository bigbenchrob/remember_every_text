---
tier: project
scope: database-health-audit
owner: agent-per-project
last_reviewed: 2026-06-06
source_of_truth: code
links:
  - ./00-overview.md
  - ../25-ONBOARDING-AND-ARCHIVE/00-overview.md
tests: []
---

# Support Bundle Integration

This document describes how the implemented Phase 1 audit is integrated into the app's diagnostic export flow.

## Integration Goal

When the app prepares a developer-facing diagnostic export, it should generate a **support bundle** directory that includes:

- `diagnostic_report.log`
- `database_health.json` when audit generation succeeds

If the audit fails, the bundle should still be produced.

## Orchestration Boundary

Support-bundle assembly is owned by:

- `lib/essentials/logging/infrastructure/support_bundle_export_service.dart`

Database health generation is owned by:

- `lib/essentials/db/application/database_health_audit/database_health_audit_service.dart`

This keeps responsibilities separate:

- support-bundle code owns directory creation and artifact collation
- database-health code owns report generation and writing

## Export Path

High-level call chain:

1. user triggers an existing “send logs / diagnostic report” action
2. `diagnostic_report_actions.dart` resolves `DatabaseHealthAuditService`
3. it constructs `SupportBundleExportService`
4. `LogExportService.exportAndPresent(...)` calls `SupportBundleExportService.export(...)`
5. the support bundle is assembled on disk
6. the bundle contents are attached to email draft creation when possible
7. Finder reveals the bundle directory when manual attachment is needed

## Current Trigger Points

The support-bundle export path is currently reached from these existing actions:

- startup dialog “Export Logs” flow in `lib/main.dart`
- sidebar `SendLogsRequested` in `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`
- contacts settings “Send Logs…” button in `lib/features/contacts/presentation/cassettes/settings/send_logs_action_button.dart`
- onboarding failure “Send Report To Developer” action in `lib/essentials/onboarding/presentation/onboarding_overlay.dart`
- environment readiness “Send Report To Developer” action in `lib/features/environment_readiness/presentation/view/environment_readiness_panel_view.dart`

These actions were already part of the diagnostic export behavior; they now produce a support bundle rather than a standalone log file.

## Bundle Contents

Bundle directory name:

- `support_bundle_<timestamp>/`

Always included:

- `diagnostic_report.log`

Included when available:

- `import_log`
- `migrate_log`

These logs describe retained legacy import/projection runs when those compatibility paths are used. Source-scoped graph build health is represented in `database_health.json` and the conversation graph status surfaces, not in `migrate_log`.

Included when audit succeeds:

- `database_health.json`

Included when audit fails:

- `database_health_error.json`

The error file is deterministic and small. It records that support-bundle export continued even though audit generation failed.

## Failure Behavior

`SupportBundleExportService.export()` treats database health generation as best-effort:

- it attempts `DatabaseHealthAuditService.writePhase1Report(...)`
- if that throws, it writes `database_health_error.json`
- it still returns a completed support bundle

This ensures the diagnostic export path remains usable even when the audited database state is itself broken.

## Privacy Model

The support bundle remains privacy-safe because it contains only derived artifacts:

- aggregated log output
- Phase 1 structural database health report
- no raw SQLite files
- no Phase 2 row samples
- no Phase 3 relational snapshot

## Naming Note

Some user-facing code still uses earlier terminology such as:

- “Send Logs”
- “Diagnostic Report”

That is acceptable in the current implementation. The service-layer behavior underneath is now support-bundle assembly.

No broad UI renaming was performed as part of the implementation.
