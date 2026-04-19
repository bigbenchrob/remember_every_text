# Changelog

All notable changes to MessageLens will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

`pubspec.yaml` is the source of truth for the app version. Significant user-facing or tester-facing changes must include both a version bump and a changelog entry in the same change.

## [Unreleased]

- No unreleased changes yet.

## [0.1.6] — 2026-04-19

### Changed
- The settings sidebar now separates stable durable projection from ephemeral temporary flows, so one-off actions like `Send logs…` and `Reset message data…` no longer persist as if they were durable settings context.
- Durable settings context now rebuilds from flow state through local stable topology decisions, keeping `Text size…` and `Image size…` as persistent settings choices while temporary settings actions stay out of stable settings reconstruction.
- Sidebar topology and tests now enforce the stable-first then ephemeral-second projection model, including replace-only ephemeral settings flows and stable reconstruction from durable state.

## [0.1.5] — 2026-04-17

### Changed
- Settings now uses a single flat top menu with inert section headers and direct action choices instead of the previous nested submenu structure.
- Settings troubleshooting now routes through dedicated settings-owned cassettes, including a guided `Send logs…` flow and a `Reset message data…` flow that preserves user preferences and quits after reset.

### Added
- Appearance placeholders for `Text size…` and `Image size…` are now available from the flat settings top menu as direct action selections.

## [0.1.4] — 2026-04-17

### Added
- Diagnostic export now produces a support bundle that can include a privacy-safe `database_health.json` structural audit of the app-owned databases.

### Changed
- “Send Logs” and onboarding failure report flows now reveal or attach the support bundle instead of only a standalone diagnostic log file.

## [0.1.3] — 2026-04-16

### Added
- Holding Option at launch on macOS now opens a startup recovery dialog before normal app flow continues.
- The startup recovery dialog can export a diagnostic email draft with the app log plus import and migration audit logs when present.

## [0.1.2] — 2026-04-15

### Fixed
- macOS release builds now bundle and sign the Rust message-text extractor so fresh imports can decode `attributedBody` content instead of leaving nearly all messages blank.
- URL preview cards now receive the decoded message text they depend on, preventing false "Message does not contain a URL" placeholder errors after a clean import.

## [0.1.1] — 2026-04-15

### Fixed
- Handle canonicalization now uses a shared normalization contract across import and migration so the same real-world participant does not split into separate canonical handles.
- Onboarding now detects stale partial app-database state and automatically resets incomplete app databases before asking the user to retry setup.

## [0.1.0] — 2026-03-12

First build sent to testers.

### Added
- Full Disk Access gate — app detects missing FDA on first launch and walks the user through granting it in System Settings
- Data import onboarding — imports Messages and AddressBook databases on first run with progress overlay
- Reimport from Settings — "Reimport Data" action in Settings sidebar re-runs the full import pipeline
- Abort import — user can cancel an in-progress import
- Sidebar navigation with Messages, Contacts, and Settings modes
- Contact list with display name overlay merging (working DB + user overlays)
- Chat message viewer
- Dark mode support with semantic color tokens
- Developer panel for onboarding diagnostics
- Notarized and stapled DMG distribution via `tool/build_and_notarize.sh`
