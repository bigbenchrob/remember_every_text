---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: doc
links:
  - 03-HISTORICAL-MESSAGES-2012-2016-INGESTION-AUDIT.md
  - 04-HISTORICAL-IMPORT-MAINTENANCE-LOCK-CORRECTION.md
  - ../../10-DATABASES/13-apple-timestamp-conversion.md
  - 06-HISTORICAL-IMPORT-POST-CORRECTION-VERIFICATION.md
tests:
  - test/core/util/date_converter_test.dart
  - test/essentials/source_scoped_import/application/messages/message_importer_test.dart
  - test/features/settings/infrastructure/repositories/archive_source_inspection_repository_test.dart
---

# Historical Apple Timestamp Normalization Correction

## Observed staging defect

The first successful Historical Archives import on the disposable development
staging clone inserted and projected exactly 8,882 donor messages. Their text
and source identity reached normal MessageLens surfaces, but their timestamps
appeared at approximately 2001-01-01.

Immutable inspection established:

- donor `message.date` range: `364929382` through `518890287`;
- correct Apple-seconds range: 2012-07-25 through 2017-06-11;
- source-3 ledger range after import: 2001-01-01T00:00:00Z through
  approximately one second later; and
- graph source-3 rows faithfully reproduced those incorrect ledger values.

The donor uses Apple-epoch seconds. The importer called `DateConverter`, but
that utility then assumed every Apple value was nanoseconds. Integer rounding
therefore collapsed the historical values to zero or one second after the
Apple epoch.

## Why preflight was correct

Archive preflight contained a private magnitude-aware conversion formula. It
recognized old seconds and modern nanoseconds, so it reported the correct donor
range. That duplicated authority allowed preflight and import to disagree.

## Correction

`DateConverter` now owns normalization of both supported Apple timestamp
representations. Preflight's private formula was removed and both preflight and
source import use the same utility.

The correction is source-format aware but not source-specific. It contains no
folder, donor, or date-range exception. Modern nanosecond values remain
unchanged before conversion.

An architecture tripwire now rejects Apple epoch arithmetic outside
`DateConverter`, and the mandatory database instructions make this authority
explicit.

## Staging reset disposition

Do not patch the bad source-3 timestamps in place. Use the existing
source-scoped Historical Archives removal operation, which deletes source-3
facts and topology, retains the registered source identity for deterministic
reuse, clears derived graph projection rows, and reprojects the remaining
sources. Verify source-3 import and graph counts are zero before reimport.

If that owned removal operation fails or cannot establish those postconditions,
discard and recreate the disposable staging clone from the frozen snapshot.
Do not improvise manual SQL cleanup.

The application did not rerun the GUI import as part of the code correction.
The user subsequently completed the removal/reimport rehearsal manually. The
immutable post-import result is recorded in
`06-HISTORICAL-IMPORT-POST-CORRECTION-VERIFICATION.md` and confirms this
correction end-to-end.

## Separate observed UX issue

Clicking **Begin Import** temporarily presented Onboarding while the historical
import ran. This is a real staging observation but is not part of timestamp
correctness and remains deliberately unfixed in this task.
