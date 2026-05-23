---
tier: project
scope: security
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: code
links:
  - ./03-data-locations.md
  - ../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
tests: []
---

# Environment And Secrets

Do not invent a `.env` workflow for this project. The current repo does not
define a committed `.env.example` or app-wide dotenv configuration.

## Current Reality

- Runtime database paths are derived from `path_provider` application support
  directories in `lib/essentials/db/feature_level_providers.dart`.
- macOS source paths are resolved through `PathsHelper` and
  `getFolderAggregateEitherProvider`.
- Full Disk Access is a user-granted macOS permission, not a checked-in secret.
- Production build identity and bundle ID are build/signing configuration; read
  `../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md` before changing
  them.
- Some working database tables retain Supabase sync state/log names, but this
  folder does not document an active secret-bearing Supabase runtime contract.

## Rules

- Never commit secrets, personal database exports, local backups, or private
  source database copies.
- If a future feature needs secrets, add an explicit secret-loading design and a
  non-secret example file in the same change.
- Do not mention `.env`, CI secret names, or external password managers as
  current setup unless corresponding project files or CI configuration exist.
- Do not store credentials in app support databases, overlay settings, or source
  fixture files.
