---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-09
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./06-addressbook-path-resolution.md
  - ./00-all-databases-accessed.md
  - ./10-group-import-working.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# `db-address-book` — macOS Contacts Source (`AddressBook-v22.abcddb`)

`db-address-book` is the live macOS AddressBook database shipped with the operating system. It is the canonical source of truth for contact facts that are imported into the source-scoped ledger and projected into graph contact/handle identity.

- **Alias**: `db-address-book`
- **Physical File**: `AddressBook-v22.abcddb` inside the most recent `~/Library/Application Support/AddressBook/Sources/<UUID>/` folder
- **Primary Consumer**: Source-scoped import infrastructure (read-only)

## Resolution & Location

| Item | Value |
| --- | --- |
| Resolution | `getFolderAggregateEitherProvider` → `AddressBookFolderAggregate.mostRecentFolderPath` |
| Runtime storage | Resolved dynamically at import time |
| Requires | Full Disk Access (macOS security)

Never hardcode the path. Apple maintains multiple historical bundles and only one contains the active data. See `06-addressbook-path-resolution.md` for the provider chain that locates the live bundle.

## Provider Access Pattern

- **Riverpod entry point**: `getFolderAggregateEitherProvider`
- **Location**: `lib/features/address_book_folders/application/get_folder_aggregate_either_provider.dart`
- **Return type**: `Future<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>`

Usage template:

```dart
final aggregateEither = await ref.read(
  getFolderAggregateEitherProvider.future,
);

final aggregate = aggregateEither.getOrElse(
  (failure) => throw Exception('AddressBook resolution failed: ${failure.message}'),
);

final activePath = aggregate.mostRecentFolderPath.value;
```

Only source-scoped import infrastructure should open the sqlite file. Application code interacts with projected contact/identity data through graph readers plus overlay display-identity resolution.

## Key Tables Consumed During Import

| Table | Purpose |
| --- | --- |
| `ZABCDRECORD` | Primary contact records (names, organization flags). |
| `ZABCDPHONENUMBER` / `ZABCDEMAILADDRESS` | Phone and email handles associated with contacts. |
| `ZABCDEINTERNALMETADATA` | Provider metadata (used for deduplication diagnostics). |
| `ZABCDCONTACTINDEX` | Search metadata leveraged during import health checks. |

The source-scoped import pipeline copies this data into contact and channel facts while preserving source identifiers. Graph projection turns those facts into app-facing contact/handle relationships; user-authored display identity remains in overlay.

## Usage Rules

1. **Read-only access**: Never modify the macOS AddressBook; treat it as an immutable source.
2. **Resolve paths at runtime**: Always go through the provider chain—user systems may surface different bundle IDs.
3. **Validate record counts**: Importers verify that the active database contains a reasonable number of contacts (>10). Abort if validation fails to avoid ingesting archived bundles.
4. **Provide overrides in tests**: Flutter tests cannot rely on `path_provider`. Override `getFolderAggregateEitherProvider` with deterministic paths when testing import logic.

## Cross-References

- `06-addressbook-path-resolution.md` — Full provider chain and testing guidance.
- `00-all-databases-accessed.md` — Current source-scoped import and graph database entry points.
- `10-group-import-working.md` — Historical retained identity contract; do not use it for new graph-era contact work.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Ledger table definitions referencing AddressBook data.
