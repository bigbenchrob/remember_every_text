# Checkpoint And Recovery Report

Date: 2026-07-27

Disposable archive tests verify:

- complete checkpoint creation into a new destination;
- versioned manifest, identity, inventory, sizes, and hashes;
- SQLite integrity checks and sidecar-aware copying;
- restore into a separate absent disposable root;
- restored archive equivalence;
- refusal of incomplete or changed source evidence;
- refusal to overwrite an existing archive or restore destination.

`tool/archive_checkpoint.dart` exposes only offline `create` and
`restore-verify` operations. It never restores over an existing archive.

No production checkpoint or restore was performed.
