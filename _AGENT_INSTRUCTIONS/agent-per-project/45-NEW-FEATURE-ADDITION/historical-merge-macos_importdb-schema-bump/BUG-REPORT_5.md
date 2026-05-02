CRITICAL: Cancelled Archive Migration Leaves App in Broken State

Observed behavior

After running archive import:

1. Deleted imported archive records.
2. Started archive import.
3. Migration stalled at ~109,000 messages.
4. Canceled/terminated after ~8 minutes.
5. Tried to send logs from the modal, but the button was unresponsive.
6. Switched to Messages.
7. Contact picker showed only one contact.
8. Quit and relaunched.
9. Contact picker still showed only one contact.
10. Send logs button remained inoperative.

Immediate conclusion

This is no longer just “identify the stalled chunk.”

The app is leaving working.db or provider state in a broken/incomplete projection after canceled archive migration, and the support/report path is also becoming unavailable.

Required priority

Stop investigating chunk performance until recovery is fixed.

The app must never remain usable-but-corrupt after a canceled or failed migration.

Required diagnostic questions

Answer these before modifying broadly:

1. After cancellation, is working.db.projection_state.completion_status = incomplete?
2. On startup, does the app detect that incomplete projection state?
3. If yes, why does it still allow Messages/contact picker to read the incomplete working.db?
4. Why does the contact picker show only one contact instead of blocking behind Environment Readiness / rebuild required?
5. Why is Send Logs unavailable or unresponsive after this state?
6. Is the migration clearing/rebuilding contact/index tables before failing, leaving partial app-facing tables persisted?

Required fix direction

If working.db is marked incomplete/suspect:

- normal Messages views must not read it as if valid
- contact picker must not show partial data
- the app should route to a recovery/error surface
- recovery should offer Retry Import and Migration / Rebuild Working Data
- Send Report must remain available from that recovery surface

Non-goals

- Do not optimize the stalled chunk yet.
- Do not change archive import semantics.
- Do not hide the issue by repopulating contact picker from stale cache.
- Do not allow providers to read incomplete working.db.

Acceptance criteria

After canceling or failing archive migration:

- working.db is marked incomplete
- app restart detects incomplete working projection
- Messages/contact picker does not show partial data
- user sees a clear recovery state
- Send Report works
- user can retry/rebuild without manually deleting DB files

Notes

The chunk logs are still useful, but secondary. First priority is preventing the app from presenting corrupted partial working data as normal app state.
