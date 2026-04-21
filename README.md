# Remember Every Text

A macOS-native Flutter application that imports and manages Messages and AddressBook data from the system databases.

## Project Overview

This application provides:

- **Messages Import**: Complete import of iMessage and SMS data from macOS Messages app
- **AddressBook Integration**: Contact information from macOS Contacts app
- **Rich Text Extraction**: Rust-powered extraction from attributed message bodies
- **Database Management**: Import and working databases with full referential integrity

## Architecture

- **Domain Driven Development (DDD)** structure
- **Riverpod** for state management (hooks_riverpod)
- **Drift** for database operations
- **macOS UI** components for native feel
- **Rust FFI** for high-performance text extraction

## Rust Message Extractor

### Overview

The Rust extractor is **critical** for proper message text extraction. Without it, ~90% of messages will appear empty because macOS stores the actual message content in binary `attributedBody` fields rather than plain `text` fields.

### Binary Location

```
target/release/extract_messages_limited
```

### Source Code Location

```
rust/
├── rust/
│   └── attributed-string-decoder/
│       ├── Cargo.toml
│       ├── src/
│       │   ├── lib.rs
│       │   ├── api.rs
│       │   └── frb_generated.rs
│       └── target/
│           └── release/
│               └── extract_messages_limited
```

### Building from Source

If the binary is missing, build it with:

```bash
cd rust/rust/attributed-string-decoder
cargo build --release --bin extract_messages_limited
cp target/release/extract_messages_limited ../../../target/release/
```

### Verification

The app will automatically check for the extractor on startup:

```
🔍 Checking Rust extractor availability at: target/release/extract_messages_limited
📁 File exists: true
📊 File mode: 100755
```

If the extractor is missing, imports will still work but message text will be largely empty.

## Getting Started

### Prerequisites

- macOS (required for Messages/Contacts database access)
- Flutter SDK
- Rust toolchain (for building extractor)

### Setup

1. Clone the repository
2. Run `flutter pub get`
3. Ensure Rust extractor binary exists (see above)
4. Run `flutter run -d macos`

### First Import

1. Grant Full Disk Access to the app when prompted
2. Navigate to Import section
3. Select Messages and AddressBook import
4. Wait for completion (typically 1-2 minutes)

## Development

See `_AGENT_CONTEXT/AGENT_CONTEXT.md` for comprehensive development guidelines and architecture documentation.

## macOS Distribution Builds

For anything that will be distributed outside your machine, the default build path is:

```bash
./tool/build_and_notarize.sh
```

That script performs the full distribution pipeline: release build, re-signing, DMG packaging, notarization, stapling, and final verification.

Its default output artifact is a notarized DMG placed at `~/Desktop/MessageLens.dmg`.

Use `flutter build macos --release` only for local release verification or as an intermediate step inside the notarized distribution pipeline. By itself, it is not the repo's default distribution artifact.

## Release Versioning

MessageLens should use Flutter's standard version format in `pubspec.yaml`:

- `x.y.z` is the user-visible semantic version.
- `+build` is the monotonically increasing build number.

For this repo, keep the release process simple:

- `pubspec.yaml` is the source of truth for the current app version.
- `CHANGELOG.md` records all significant user-facing and tester-facing changes.
- Any significant change should include both a version bump and a new changelog entry in the same change.

Recommended solo workflow:

- Housekeeping, maintenance, and small bug fixes that do not merit a version bump may be committed directly to `main`.
- Feature additions and other release-worthy changes should be developed on a feature branch.
- Release-worthy changes should open a non-draft pull request before merging to `main` so the GitHub checks run and the final diff can be reviewed in one place.
- Before merging a release-worthy change, update both `pubspec.yaml` and `CHANGELOG.md`.

GitHub can validate this policy, but it should not replace the in-repo source of truth. This repo now includes a pull request check that requires both `pubspec.yaml` and `CHANGELOG.md` to change whenever a non-draft PR touches core app surfaces, unless the PR explicitly marks itself as internal-only.

If a PR is truly internal-only and does not need release metadata, use the internal-only override checkbox in the PR template.
