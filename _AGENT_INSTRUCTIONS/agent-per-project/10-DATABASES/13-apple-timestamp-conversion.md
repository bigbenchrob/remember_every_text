---
tier: project
scope: apple-timestamp-conversion
owner: 10-DATABASES
last_reviewed: 2026-08-16
source_of_truth: doc
links:
  - ./04-db-chat.md
  - ./INVIOLATE_RULES.md
tests:
  - test/core/util/date_converter_test.dart
  - test/architecture/apple_timestamp_conversion_authority_test.dart
---

# Apple Timestamp Conversion Authority

> 🔥 **All Apple timestamp conversion belongs to
> `lib/core/util/date_converter.dart`. Always use `DateConverter`. Never invent
> or repeat a conversion scheme elsewhere.**

## Why this rule exists

Apple source databases do not all use the same timestamp resolution.
MessageLens has encountered both:

- Apple-epoch seconds in older Messages databases; and
- Apple-epoch nanoseconds in modern Messages databases.

A historical import once treated second-resolution values as nanoseconds. All
8,882 records reached the source-scoped ledger and graph, but their dates
collapsed to approximately 2001-01-01. A separate preflight formula happened
to recognize both magnitudes, so preflight reported the correct historical
range while import persisted the wrong dates.

The defect was not missing data. It was competing timestamp authorities.

## The contract

`DateConverter` is the sole authority for:

- recognizing supported Apple timestamp representations;
- normalizing them to the canonical Apple nanosecond representation;
- converting them to Dart, Unix, `DateTime`, or ISO-8601 UTC values; and
- defining the Apple epoch offset and unit arithmetic.

Every importer, source preflight, repository, diagnostic, provider, and UI
consumer must call `DateConverter`. No other file may contain its own Apple
epoch offset, magnitude threshold, division/multiplication scheme, or SQLite
`unixepoch` conversion.

## When a new format appears

1. Preserve the raw source value for investigation.
2. Add representative focused tests to `date_converter_test.dart`.
3. Extend `DateConverter` once.
4. Keep all consumers ignorant of the source encoding.

Do not special-case a folder, donor, date range, feature, or workflow.

## Mechanical protection

`test/architecture/apple_timestamp_conversion_authority_test.dart` rejects
Apple epoch arithmetic outside `DateConverter`. This does not replace code
review, but it prevents the known parallel-conversion failure from quietly
returning.
