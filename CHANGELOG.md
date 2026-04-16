# Changelog

All notable changes to MessageLens will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

`pubspec.yaml` is the source of truth for the app version. Significant user-facing or tester-facing changes must include both a version bump and a changelog entry in the same change.

## [Unreleased]

- No unreleased changes yet.

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
