The archive import likely succeeded in terms of row counts, but the date projection is wrong.

The giveaway is:

Jan 2001 → May 2026

That usually means some imported/projected messages have timestamp 0 or an incorrectly converted Apple/Unix timestamp, and the heatmap interprets that as the Unix/Apple epoch baseline.

Tell the agent:

⸻

BUG: Archive import completes but heatmap starts at Jan 2001

Observed behavior

After importing the historical archive and restarting the app, the heatmap shows:

80,935 messages · Jan 2001 → May 2026

Expected earliest date should be around:

July 2012

The heatmap also shows empty years from 2001–2011.

Interpretation

Archive rows likely imported and migrated, but one or more projected message dates are wrong.

Most likely causes:

1. Some archive/import rows have date_utc = 0
2. Some date conversion path is treating Apple epoch seconds as Unix epoch seconds
3. Some migration path is converting null/missing dates to epoch zero
4. Heatmap query is including rows with placeholder/default dates
5. Integer timestamp conversion changed ledger dates but one importer/migrator still uses the wrong unit or fallback

Immediate database checks

Please inspect:

In macos_import.db:

- SELECT MIN(date_utc), MAX(date_utc), COUNT(\*) FROM messages;
- SELECT guid, text, date_utc, source_id FROM messages ORDER BY date_utc LIMIT 20;
- SELECT COUNT(\*) FROM messages WHERE date_utc <= 100000;

Also check:

- recovered_unlinked_messages
- working.db message/date tables used by heatmap

In working.db:

- Find the minimum projected message date used by the heatmap
- Inspect the first 20 rows by date
- Confirm whether the bad rows are from:
  - current_mac
  - historical_archive
  - recovered/unlinked path

Required fix

Do not patch the heatmap to hide 2001 rows.

Fix the source of bad dates in import/migration.

If source date is missing or invalid:

- do not coerce to epoch zero
- preserve null if allowed
- or classify row as failed/warned
- but do not insert Jan 2001 placeholder dates

Success criteria

After fix and rebuild:

- heatmap earliest date is July 2012, not Jan 2001
- no canonical ledger message rows have invalid placeholder timestamps
- no working projection rows have Jan 2001 dates unless the source actually contains Jan 2001 messages
- timeline/search/heatmap still work after restart
