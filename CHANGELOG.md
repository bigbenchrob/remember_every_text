# Changelog

All notable changes to MessageLens will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

`pubspec.yaml` is the source of truth for the app version. Significant user-facing or tester-facing changes must include both a version bump and a changelog entry in the same change.

## [Unreleased]

- No unreleased changes yet.

## [0.1.28] — 2026-04-28

### Fixed

- Historical archive projection now suspends the live `global_message_index`, `message_index`, and `contact_message_index` triggers before bulk archive inserts, matching the normal migration path and preventing archive merge from spending the write transaction rebuilding those index tables once per inserted message.
- If archive projection throws after trigger suspension, MessageLens now restores the message-index triggers and rebuilds the affected index tables before surfacing the failure, so a failed archive merge is less likely to leave app-facing timeline indexes in a broken state.

## [0.1.27] — 2026-04-28

### Fixed

- `ChatDbChangeMonitor` now stays idle while onboarding recovery or any DB maintenance lock is active, preventing startup auto-import from racing database reset flows and surfacing `DatabaseException(error database_closed)` under execution owner `chat-db-monitor`.
- Auto-sync monitoring now resumes only after onboarding has resolved to the normal app state, so failed onboarding recovery no longer collides with background incremental import on restart.

## [0.1.26] — 2026-04-28

### Fixed

- Historical archive projection now preloads existing working-message GUIDs and chat GUID mappings before entering the archive write transaction, removing thousands of per-row existence queries that previously left the merge stuck in the `projection-transaction-starting` phase while the contact picker stayed empty.
- Archive checkpoint notes now distinguish the preloaded working GUID/chat counts from the later commit phase, making the next live archive run easier to diagnose if another phase still stalls.

## [0.1.25] — 2026-04-28

### Fixed

- Manual historical archive projection now writes explicit per-phase checkpoints into `historical_archive_import.db.import_batches.notes`, so a stuck merge shows whether it halted during staged-row loading, transaction commit, or one of the app-facing index rebuild steps.
- Successful manual archive projection now bumps the shared message-data version signal, so contact and timeline providers refresh when the archive merge finishes instead of waiting for a later unrelated rebuild.

## [0.1.24] — 2026-04-28

### Fixed

- Manual historical archive merge now acquires the same import execution gate used by the auto-import pipeline, preventing archive projection from colliding with background import or migration work and failing with `database is locked` during working-db writes.
- If another pipeline task already owns that gate, the archive sidebar now resolves to a failure result immediately instead of hanging in a partial merge state.
- Migration preflight now materializes attached `import_preflight` verification into a temp table and clears that probe before `DETACH`, fixing the `IMPORT_DB_LOCKED` failure where `DETACH DATABASE import_preflight` ran while SQLite still considered the attached database in use.

## [0.1.23] — 2026-04-28

### Fixed

- Historical archive merge now switches the Settings sidebar into an explicit in-progress cassette immediately instead of leaving the user staring at stale preflight copy while projection is still running.
- Archive projection now holds the app's maintenance lock for the duration of the long-running merge step, so contact and timeline surfaces stop silently stalling on the same working-db connection and instead stay consistently unavailable until projection finishes.

## [0.1.22] — 2026-04-28

### Fixed

- Historical archive merge is now single-flight, so repeated clicks on `Merge Into Timeline` reuse the active import instead of spawning overlapping unfinished archive batches against the same databases.
- Import sidebar actions now enter a visible local working state while their async handler runs, making the first click visibly register and preventing repeat taps from fanning out duplicate archive work.

## [0.1.21] — 2026-04-28

### Fixed

- Historical archive results now distinguish staged archive rows from rows actually projected into `working.db`, and MessageLens only claims archive messages are available in the app when projection into the live timeline succeeded.
- Historical archive merge now logs explicit staging and projection counts plus projection failures, so live archive imports no longer collapse all post-staging failures into the misleading message that staging itself failed.

## [0.1.20] — 2026-04-28

### Fixed

- Historical archive replay now tolerates duplicate live `handles_canonical` rows by choosing a deterministic existing handle match instead of assuming uniqueness and aborting the whole archive projection transaction.

## [0.1.19] — 2026-04-28

### Added

- Historical archive preflight now offers a destructive `Clear Archive Cache` action above `Merge Into Timeline`, allowing testers to wipe the dedicated `historical_archive_import.db` ledger and restage the same archive cleanly without touching `working.db`.

## [0.1.18] — 2026-04-28

### Fixed

- Historical archive merge now normalizes legacy second-resolution Apple timestamps from older `chat.db` files, so 2012-era archive rows no longer collapse to `2001-01-01` during staging and can be re-imported into the visible timeline with their correct dates.

## [0.1.17] — 2026-04-28

### Added

- Historical archive imports now reconstruct archive sender handles and chat participants from `chat.db` relationships, so replayed archive messages keep their conversation context instead of appearing as bare text rows without trustworthy sender metadata.
- Working message projections now carry explicit `source_provenance` and `import_batch_id` fields, allowing archive-replayed rows to remain distinguishable from `current_mac` projections for later diagnostics, filtering, and export work.

### Fixed

- Startup import monitoring now repairs missing projected relationship tables when joinable ledger data already exists, restoring contact-based pickers even when no new source messages have arrived to trigger a normal incremental migration.
- Historical archive import no longer treats the dedicated archive staging database as a canonical duplicate source, so previously staged archive GUIDs can be re-imported into `working.db` after the live projection has been reset or lost.
- Choosing a contact from the messages sidebar now waits for the contact heatmap and timeline prewarm path before switching the selected-contact branch, avoiding the cold-selection spinner that could replace the lower contact section immediately after a tap.

## [0.1.16] — 2026-04-27

### Changed

- Settings now uses clearer subsection styling in the top menu, making grouped actions and persistent settings easier to scan in one flat list.
- The chosen-contact messages sidebar now reads as a calmer sequence of selection, context, explanation, controls, and visualization, with shared spacing and grouped-control chrome instead of feature-local layout tweaks.
- Support and Send Logs email drafts now target `messagelens@gmail.com`, keeping tester feedback routed to the shared project inbox.

### Fixed

- Window size now stays stable when moving MessageLens between monitors, instead of snapping to a smaller preset-looking frame on one display and expanding again on the other.
- Window placement restore now persists the intended size across sessions, preventing relaunches from restoring the old top-left position with an unexpectedly oversized window.

## [0.1.15] — 2026-04-26

### Added

- Settings now includes a Message History Coverage report with a durable sidebar selection and a derived center-panel report so testers can review coverage status in a stronger, more readable report surface.

### Fixed

- Transient Settings actions such as `Send logs…` and `Reset message data…` now fully replace the visible Settings child flow and no longer restore an older durable Settings child after switching away from Settings and back.

## [0.1.14] — 2026-04-25

### Added

- MessageLens now records structured import and migration pipeline incidents in a dedicated diagnostic layer, exports them with support bundles, and can show a direct center-panel failure page with a one-click “Send Report To Developer” action when a blocking pipeline failure occurs.

### Fixed

- Automatic import and migration diagnostics now surface post-onboarding pipeline failures inside the app instead of relying on users to navigate to the sidebar troubleshooting flow before sending logs.

## [0.1.13] — 2026-04-24

### Fixed

- Reset Message Data now refreshes onboarding after the completion dialog so testers are guided back into the reimport flow instead of being left on the settings reset panel.
- macOS startup no longer blocks the app shell on a redundant window-state load that could leave VS Code debug launches stuck on a black screen.

### Added

- Support bundles now include targeted reset-to-onboarding diagnostics so tester logs show when the databases were deleted, when the onboarding gate reclassified the environment, and when the readiness panel was shown.

## [0.1.12] — 2026-04-23

### Added

- Added a standalone MessageLens tester portal foundation under `web/tester-portal/` with centralized CSS palette tokens and shell styling for navigation, cards, links, buttons, and footer surfaces.

## [0.1.11] — 2026-04-22

### Fixed

- `chat_to_handle` migration validation now counts distinct final canonical memberships after handle alias collapse, so datasets with normalized handle variants like `citycenter` and `city center` no longer fail onboarding just because multiple source handles project to one canonical chat membership.

## [0.1.10] — 2026-04-19

### Changed

- Reset Message Data no longer quits the app after clearing the MessageLens databases. After the reset completes, the final dialog now dismisses back to the onboarding reimport panel already shown underneath.

## [0.1.9] — 2026-04-19

### Changed

- Reset Message Data now uses a two-dialog flow: the settings cassette shows only the destructive reset action, a pre-reset confirmation explains exactly what will and will not be deleted, and a final quit dialog appears only after the MessageLens databases have been cleared.

## [0.1.8] — 2026-04-19

### Changed

- Reset Message Data now shows a final completion dialog after the derived databases are deleted and waits for an explicit `OK` before quitting, making the forced quit and first-launch-style reimport path explicit.

## [0.1.7] — 2026-04-19

### Fixed

- Incremental message migrations now preserve declared migrator order for equally ready steps, preventing failed later migrators from leaving `chat_to_handle` empty and contact timelines stuck behind the latest imported messages.

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
