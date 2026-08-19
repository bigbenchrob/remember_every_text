# Historical Archive Cartouche Metadata Cleanup Implementation

## Status

Implemented on `Ftr.archive-recovery`.

## Human Responsibility

A cartouche under **Folders Already Added** identifies one archive that current
source-scoped import data proves is part of MessageLens. Its primary
presentation now answers only:

- what archive this is;
- what historical period it covers, when known;
- how many imported messages it currently contributes;
- when its most recently recorded successful import completed, when known.

The cartouche is not an activity log. Dry-run counts, duplicate estimates,
preflight results, mutation state, and execution diagnostics remain outside its
primary presentation.

## Membership And Count Authority

The source-scoped import ledger remains the membership authority. A remembered
overlay record is not enough to place a source under **Folders Already Added**.
The source must resolve by canonical source key to a positive imported-message
count. That same ledger count supplies the human message total.

## Imported-On Authority

The optional **Imported on** value comes from
`HistoricalArchiveSourceMetadata.lastImportFinishedAtUtc` only when
`lastImportSuccess == true`.

That combination is trustworthy because the workflow writes it only after:

1. `ArchiveGraphImportService.importAndProject` returns successfully;
2. the message-data version is advanced;
3. post-import source inspection and preflight complete; and
4. the source metadata is persisted with `lastImportSuccess: true`.

The failure path may also write `lastImportFinishedAtUtc`, but pairs it with
`lastImportSuccess: false`. The cartouche therefore never treats a failure time
as an import date. Preflight time, dry-run time, source registration time,
generic metadata update time, filesystem time, and database modification time
are not eligible.

The displayed date uses the existing human date convention `MMM d, y` in local
time. The exact persisted UTC timestamp remains available to diagnostic
surfaces that already consume the metadata.

## Truthful Fallback

When the successful completion flag is absent or false, the timestamp is
missing, or the timestamp cannot be parsed, the **Imported on** line is omitted.
The UI does not say `unknown`, `not recorded`, or `not yet imported`.

Likewise, a missing or incomplete historical range is omitted rather than
rendered as `unavailable`.

## Presentation Changes

The ordinary cartouche now presents representative content in this form:

```text
Messages_2012-IMPORT_SOURCE

Date range: Jul 2012 – Jun 2017
Messages: 8,882
Imported on: Aug 16, 2026
```

`lastRunSummaryLabel` and `lastImportedLabel` were removed from the cartouche
payload. They were replaced by one nullable `importedOnLabel`. Existing
selection, orange correspondence, pulse occurrence, navigation, and source
membership behavior were not changed.

## Persistence

No schema, JSON format, source identity, import/removal behavior,
mutation-authority rule, or database semantics changed. Existing dry-run and
operational metadata remains persisted for diagnostics; it is simply no longer
projected into the primary cartouche.

## Verification

- focused cartouche provider/resolver/widget tests: 20 passed;
- complete Settings tests: 99 passed;
- architecture tripwires: 374 passed;
- `flutter analyze`: no issues;
- formatting: clean;
- `git diff --check`: clean.

## Manual Review

1. Open **Settings > Historical Archives** with an imported archive present.
2. Confirm the cartouche shows its archive label, calm month/year range, grouped
   message count, and a human **Imported on** date when available.
3. Confirm no `Last dry run`, duplicate count, `Last imported`, or `not yet
   imported` wording appears.
4. Select the cartouche and confirm blue selection and center-panel navigation
   are unchanged.
5. Trigger a duplicate-folder recognition and confirm the established orange
   correspondence behavior is unchanged.
