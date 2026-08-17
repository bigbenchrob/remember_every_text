---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: verification
links:
  - 03-HISTORICAL-MESSAGES-2012-2016-INGESTION-AUDIT.md
  - 04-HISTORICAL-IMPORT-MAINTENANCE-LOCK-CORRECTION.md
  - 05-HISTORICAL-APPLE-TIMESTAMP-NORMALIZATION-CORRECTION.md
  - ../../10-DATABASES/13-apple-timestamp-conversion.md
tests:
  - test/core/util/date_converter_test.dart
  - test/architecture/apple_timestamp_conversion_authority_test.dart
---

# Historical Import Post-Correction Verification

## Conclusion

The disposable staging rehearsal confirms the `DateConverter` correction
end-to-end. The existing Historical Archives path imported and projected all
8,882 donor messages with their correct 2012-07-25 through 2017-06-11 range.
No historical message remains collapsed to the Apple epoch.

The user also confirmed manually that:

- the heatmap now begins in July 2012;
- 2012 and 2013 show plausible monthly activity;
- representative historical message text appears correct; and
- the previous December 2000 / January 2001 presentation is absent.

This was a bounded post-import verification. MessageLens Development was
stopped before immutable inspection. No import, removal, reset, database write,
payload write, or production operation ran.

## Verified source identity and counts

Source `3` is registered exactly once:

```text
source_id:   3
source_kind: historical_messages_archive
source_key:  historical-messages-archive:/Volumes/WD_ELEMENTS/
             ARCHIVE_INGESTION_TRIAL/Messages_2012-IMPORT_SOURCE/chat.db
```

The source-scoped import ledger contains:

| Source-3 fact | Count |
|---|---:|
| messages | 8,882 |
| distinct message `ss_id` values | 8,882 |
| distinct message GUIDs | 8,882 |
| chats | 86 |
| handles | 77 |
| attachment metadata rows | 773 |
| chat/message edges | 8,889 |
| chat/handle edges | 104 |
| message/attachment edges | 808 |

These counts exactly match the donor audit.

## Timestamp verification

Ledger and graph independently report:

```text
earliest: 2012-07-25T17:16:22.000Z
latest:   2017-06-11T16:11:27.000Z
```

Rows at `2000-12-31` or `2001-01-01`: **0**.

Representative donor, ledger, and graph values agree:

| Donor row | Raw Apple value | Ledger UTC | Graph UTC |
|---:|---:|---|---|
| 1 | 364929382 | 2012-07-25T17:16:22.000Z | 2012-07-25T17:16:22.000Z |
| 4444 | 483426581 | 2016-04-27T05:09:41.000Z | 2016-04-27T05:09:41.000Z |
| 8884 | 518890287 | 2017-06-11T16:11:27.000Z | 2017-06-11T16:11:27.000Z |

The per-year ledger distribution also exactly reproduces the donor audit:

```text
2012   493
2013   859
2014    47
2015  1601
2016  3667
2017  2215
```

All Apple timestamp semantics remain owned by
`lib/core/util/date_converter.dart`. No private Apple epoch conversion was
introduced.

## Graph and live-source preservation

The graph contains 8,882 source-3 messages with 8,882 distinct source-scoped
identities and GUIDs. A full source-3 ledger-to-graph comparison found zero
missing or differing GUID/date rows in either direction.

Source `1` contains 136,943 messages in both ledger and graph, with 136,943
distinct GUIDs in each. This is one later live message than the recorded
136,942 staging baseline. Its timestamp is later than the historical import
and represents ordinary live-source catch-up; source-1 ledger and graph remain
matched and intact.

## Preservation and Overlay observations

The historical source had no attachment payload folder, so no source-3 payload
was available for preservation. Its 773 attachment rows are source metadata
only, and no historical-source payload write was identified during the import.

The attachment tree was not globally static during the wider manual session:
one ordinary live-source payload was archived after historical import. Its
record points to `~/Library/Messages/Attachments/...`, not the historical
source. This is normal live attachment preservation and must not be described
as historical payload ingestion.

No user-intent table recorded a create/update timestamp at or after the
historical import began. The legitimate
`overlay_settings['historical_archive_sources/v1']` record reports the selected
source, correct date range, and successful completion at
`2026-08-16T21:39:53.843076Z`. Other operational settings may continue to
change through normal app activity; no unexpected user-intent mutation was
found.

## Integrity

Immutable `quick_check` and `integrity_check` both returned `ok` for:

- `macos_import_ss.db`;
- `working_ss.db`;
- `user_overlays.db`;
- `presence.db`; and
- the disposable standalone source `chat.db`.

## Next Feature 26 concern: UX and lifecycle

The successful import exposed a separate cluster of production-shaped UX and
lifecycle defects. They are recorded here but were not investigated or fixed:

- archive import, removal, or reimport can unexpectedly redirect into
  Onboarding;
- Environment Readiness can temporarily show alarming setup retry/failure
  state during archive maintenance and later clear itself;
- Historical Archives state transitions feel flaky and difficult to
  understand;
- the interface is one long control panel extending well beyond the visible
  window;
- the user had difficulty determining which action was currently expected;
  and
- the underlying archive import ultimately succeeded despite those confusing
  transitions.

The next Feature 26 work should investigate those lifecycle and presentation
boundaries. This verification authorizes no UX redesign and no production
historical import.
