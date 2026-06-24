---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-06-14
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ../10-DATABASES/01-db-import.md
---

# Rust Message Text Extractor

## Purpose
- Decode the binary `attributedBody` column from macOS `chat.db` so that messages missing plain `text` still display content.
- Decode stored `attributed_body_blob` values during source-scoped rich-text
  enrichment without rescanning all of `chat.db` for each live update.
- Keep the standalone native binary (`extract_messages_limited`) available for
  retained full-scan/diagnostic paths that still need a helper process.
- Without the Rust decoder many messages land with empty bodies, weakening
  search and UI rendering.

## Component Map
- Blob decoder: `rust_api.decodeTypedstreamBlob(...)` exposed through
  `flutter_rust_bridge`.
- Helper binary: `target/release/extract_messages_limited` (also searched for
  next to `Platform.resolvedExecutable` when the macOS app is bundled).
- Rust crate: `rust/rust/attributed-string-decoder/` (Cargo project that
  produces the binary and flutter_rust_bridge bindings).
- Flutter adapter:
  `lib/essentials/source_scoped_import/infrastructure/extraction/rust_message_extractor.dart`
  implements `MessageExtractorPort`.
- Provider wiring: `lib/essentials/source_scoped_import/feature_level_providers.dart` exposes `sourceScopedMessageExtractorProvider`.
- Source-scoped enrichment consumer: `lib/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart`.
- Database sink: source-scoped enrichment updates `macos_import_ss.db.messages.text` from the stored `attributed_body_blob`.

## Runtime Flow (Source-Scoped Enrichment)

1. Message import preserves source facts, including `attributed_body_blob`, in `macos_import_ss.db`.
2. `MessageRichTextEnricher` finds rows where `text` is missing and `attributed_body_blob` exists.
3. The enricher passes those stored blobs to `extractMessageTextsFromBlobs(...)`
   for the specific missing-text rows.
4. Successful decoded text updates `macos_import_ss.db.messages.text`.
5. Graph projection then copies the enriched text into `working_ss.db.messages`.

Do not merge this enrichment into the main message importer. Import preserves source facts; enrichment derives app-usable text; projection moves enriched evidence into the graph.

Live graph updates should use the blob-based enrichment path. Do not reintroduce
the old pattern where a single new message causes the extractor to scan every
row in `chat.db`.

## Retired Ledger Import

The old `macos_import.db` rich-text importer has been removed from the
active app path. Historical retired files may still contain decoded text from
older runs, but new text enrichment belongs to the source-scoped import stage.

## Decoder Interfaces

### Blob Interface

```dart
Future<Map<int, String>> extractMessageTextsFromBlobs(
  Map<int, Uint8List> attributedBodyBlobsByRowId,
);
```

- Keys are source row IDs used only to correlate extractor output back to import
  ledger rows.
- Values come from `macos_import_ss.db.messages.attributed_body_blob`.
- This is the source-scoped enrichment path for ordinary live updates and
  archive imports.
- Availability is checked through `isBlobExtractionAvailable()`, which runs a
  small in-process smoke decode.

### Helper Binary Interface

```
./extract_messages_limited [limit] [chat.db path]
```
- `limit` (optional) caps how many rows the extractor processes (Flutter default: `rustExtractionLimit = 200000`).
- `chat.db path` points to the Messages database copy to scan; defaults to the working directory when omitted.
- Exit code `0` -> success with JSON on stdout. Any non-zero exit code is treated as failure and the pipeline falls back to empty text.
- This interface is retained for full-scan/diagnostic compatibility. It is not
  the live-update enrichment path.

## Building & Packaging
1. `cd rust/rust/attributed-string-decoder`
2. `cargo build --release --bin extract_messages_limited`
3. Copy the result to the location the Flutter app expects:
   ```bash
   cp target/release/extract_messages_limited ../../../target/release/
   ```
4. Ensure the binary is executable (`chmod 755 target/release/extract_messages_limited`).
5. For bundled macOS builds, the Xcode "Bundle Rust Message Extractor" phase
   copies `target/release/extract_messages_limited` into
   `MessageLens.app/Contents/MacOS/extract_messages_limited`.

### Production Packaging Playbook (macOS App Bundle)
- The checked-in Xcode project contains a "Bundle Rust Message Extractor" shell
  phase after the Rust FFI framework phase.
- Input:
  `${SRCROOT}/../target/release/extract_messages_limited`
- Output:
  `${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/extract_messages_limited`
- The phase copies the binary, sets mode `755`, and prints a warning if the
  binary is missing.
- Do not add a second manual post-build copy path unless the Xcode phase is
  intentionally removed.
- Codesign the binary alongside the app (`codesign --force --options runtime --sign "$IDENTITY" Contents/MacOS/extract_messages_limited`). Missing codesign causes Gatekeeper to quarantine the helper.
- Rebuild whenever the extractor CLI schema changes to avoid protocol mismatches between Dart and Rust.

## Logging & Failure Modes
- The extractor now writes structured diagnostics through `AppLogger` with source `RustMessageExtractor`.
- Logged context includes:
  - resolved `extractorPath`
  - current working directory
  - `chat.db` path passed to the helper
  - extraction limit
  - availability result
  - exit code, stderr, and decoded message count
- Blob decoder unavailable -> enrichment records the candidates as missing
  extractions and the graph build still succeeds structurally.
- Per-row blob decode failure logs the source row ID and skips only that row.
- Missing binary or unreadable helper affects only callers using the helper
  binary full-scan interface.
- Non-zero helper exit codes bubble up as exceptions in
  `extractAllMessageTexts`; callers of that retained interface must record the
  failure and continue without rich text.
- In graph live sync, watch the Conversation Graph status panel stage timings and text-enrichment counts.

## Validation Checklist
- `target/release/extract_messages_limited` exists and is executable.
- Running `./target/release/extract_messages_limited 5 /Users/rob/sqlite_rmc/messages/chat.db` emits JSON with `rowid` / `text` pairs.
- After source-scoped enrichment, `macos_import_ss.db.messages.text` is populated for rows that previously had only `attributed_body_blob`.

## Related References
- `../10-DATABASES/10-group-import-working.md` (contract binding import and projection).
- `./20-migration-orchestrator.md` (downstream projection responsibilities).
