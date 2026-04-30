Needed Testing Control: Clear Imported Archive Rows

The current “Clear Selected Folder” action only resets the UI selection. That is useful, but it does not solve the testing problem.

Because the archive GUIDs are already present in working.db, preflight correctly reports:

- Likely duplicates: 8882
- Likely new rows: 0

That means we cannot test the archive import flow end-to-end unless we can remove the previously imported archive-derived rows from the canonical import ledger and rebuild working.db.

Please add a developer/testing-only control or clearly labeled destructive archive-management action:

Clear Imported Archive Data for This Source

This action should:

1. Remove archive-derived rows for the selected source/batch from the canonical import ledger (db-import)
2. Trigger a full canonical migration/rebuild
3. Leave live current_mac data untouched
4. Leave overlay/user-intent data untouched
5. Return the workflow to a state where preflight can report the archive rows as “new” again

Do not delete or modify the source archive folder.

Do not treat this as “Clear Selected Folder.” These are different operations.

Suggested UI distinction:

- Clear Selected Folder
  Clears the current folder choice only.
- Remove Imported Archive Data
  Deletes previously imported archive records from MessageLens for this archive source, then rebuilds the app timeline.

For now, this can be dev-only or guarded by confirmation text.
