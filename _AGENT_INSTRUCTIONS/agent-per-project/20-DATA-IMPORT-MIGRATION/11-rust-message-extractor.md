---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-06-05
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ../10-DATABASES/01-db-import.md
---

# Rust Message Text Extractor

## Purpose
- Decode the binary `attributedBody` column from macOS `chat.db` so that messages missing plain `text` still display content.
- Run as a standalone native binary (`extract_messages_limited`) used by both retained legacy rich-text import and source-scoped rich-text enrichment.
- Without this binary many messages land with empty bodies, weakening search and UI rendering.

## Component Map
- Binary: `target/release/extract_messages_limited` (also searched for next to `Platform.resolvedExecutable` when the macOS app is bundled).
- Rust crate: `rust/rust/attributed-string-decoder/` (Cargo project that produces the binary and flutter_rust_bridge bindings).
- Flutter adapter: `lib/essentials/db_importers/infrastructure/extraction/rust_message_extractor.dart` implements `MessageExtractorPort`.
- Provider wiring: `lib/essentials/db_importers/feature_level_providers.dart` exposes `dbImportMessageExtractorProvider` for orchestrators.
- Retained import consumer: `lib/essentials/db_importers/application/importers/message_rich_text_importer.dart`.
- Source-scoped enrichment consumer: `lib/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart`.
- Database sink: retained import writes decoded bodies into `macos_import.db`; source-scoped enrichment updates `macos_import_ss.db.messages.text` from the stored `attributed_body_blob`.

## Runtime Flow (Source-Scoped Enrichment)

1. Message import preserves source facts, including `attributed_body_blob`, in `macos_import_ss.db`.
2. `MessageRichTextEnricher` finds rows where `text` is missing and `attributed_body_blob` exists.
3. The enricher invokes the extractor for the specific missing-text rows.
4. Successful decoded text updates `macos_import_ss.db.messages.text`.
5. Graph projection then copies the enriched text into `working_ss.db.messages`.

Do not merge this enrichment into the main message importer. Import preserves source facts; enrichment derives app-usable text; projection moves enriched evidence into the graph.

## Runtime Flow (Retained Legacy Ledger Import)
1. `MessagesImporter` stages extraction candidates where `message.text` is empty and `message.attributedBody` is a non-null blob.
2. `MessageRichTextImporter` checks `extract_messages_limited` availability via `MessageExtractorPort.isAvailable()` (toggled by `importDebugSettingsProvider`).
3. On success the service invokes `extractAllMessageTexts(limit: rustExtractionLimit, dbPath: messagesDbPath)`.
4. The adapter shells out with `Process.run(extractorPath, args)` and expects JSON shaped like:
   ```json
   {"messages":[{"rowid":123,"text":"..."}]}
   ```
5. `SqfliteImportDatabase.updateMessageText` trims each string, writes it to `messages.text`, and promotes misclassified text-bearing rows from `attachment-only` / `unknown` / `balloon` to `text` while preserving meaningful types like `reaction-carrier`.
6. The orchestrated importer persists scratchpad stats (`messages.richTextApplied`) so retained migration and telemetry can confirm the extractor ran.

## Binary Interface
```
./extract_messages_limited [limit] [chat.db path]
```
- `limit` (optional) caps how many rows the extractor processes (Flutter default: `rustExtractionLimit = 200000`).
- `chat.db path` points to the Messages database copy to scan; defaults to the working directory when omitted.
- Exit code `0` -> success with JSON on stdout. Any non-zero exit code is treated as failure and the pipeline falls back to empty text.

## Building & Packaging
1. `cd rust/rust/attributed-string-decoder`
2. `cargo build --release --bin extract_messages_limited`
3. Copy the result to the location the Flutter app expects:
   ```bash
   cp target/release/extract_messages_limited ../../../target/release/
   ```
4. Ensure the binary is executable (`chmod 755 target/release/extract_messages_limited`).
5. For bundled macOS builds, place the binary next to the Flutter executable so `RustMessageExtractor.extractorPath` resolves it.

### Production Packaging Playbook (macOS App Bundle)
- Flutter copies everything under `macos/Runner/` when registered as a resource or Copy Files build phase. Keep the Rust binary under source control at `macos/Runner/Resources/extract_messages_limited`.
- In Xcode, add the binary to the "Copy Files" build phase targeting `Contents/MacOS`. This ensures the release bundle contains `MessageLens.app/Contents/MacOS/extract_messages_limited`, the first lookup location used by `RustMessageExtractor`.
- After `flutter build macos`, run a post-build script (e.g., `_scripts/package_rust_extractor.sh`) that copies the binary into the bundle and sets executable bits:
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail

  APP_ROOT="build/macos/Build/Products/Release/MessageLens.app"
  DEST="$APP_ROOT/Contents/MacOS/extract_messages_limited"
  SRC="target/release/extract_messages_limited"

  if [[ ! -f "$SRC" ]]; then
    echo "Rust extractor missing at $SRC" >&2
    exit 1
  fi

  cp "$SRC" "$DEST"
  chmod 755 "$DEST"
  echo "Packaged Rust extractor -> $DEST"
  ```
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
- Missing binary or unreadable helper -> the importer logs extractor unavailability, writes `messages.richTextApplied = 0`, and the run still succeeds structurally with mostly blank message text.
- Non-zero exit codes bubble up as exceptions in `extractAllMessageTexts`; the rich-text importer catches the exception, records the failure in import logs, and continues without rich text.
- In graph live sync, watch the Conversation Graph status panel stage timings and text-enrichment counts.
- In retained legacy import, watch both `messages.richTextApplied` and message text counts in `import_log`.

## Validation Checklist
- `target/release/extract_messages_limited` exists and is executable.
- Running `./target/release/extract_messages_limited 5 /Users/rob/sqlite_rmc/messages/chat.db` emits JSON with `rowid` / `text` pairs.
- After source-scoped enrichment, `macos_import_ss.db.messages.text` is populated for rows that previously had only `attributed_body_blob`.
- After retained legacy import, `macos_import.db.messages.text` is populated for rows that previously had only `attributedBody`.

## Related References
- `../10-DATABASES/10-group-import-working.md` (contract binding import and projection).
- `./20-migration-orchestrator.md` (downstream projection responsibilities).
