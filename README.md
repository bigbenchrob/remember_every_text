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
