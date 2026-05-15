# Shadow incremental-update endurance log

- started_at: 2026-05-14T10:46:52.685330
- source: dev status panel polling


## Polling sample 1

- captured_at: 2026-05-14T10:46:52.687886
- note: polling started
- polling_status: active
- last_refresh: not observed
- last_transition: not observed

### Shadow import

- ImportDecision: ImportDecision.considerIncrementalImport
- MessageSyncState: MessageSyncState.sourceAheadOfLedger
- rowIdDelta: 4
- messageCountDelta: 4

### Shadow migration

- MigrationDecision: MigrationDecision.considerShadowMigration
- MessageMigrationState: MessageMigrationState.ledgerAheadOfProjection
- messageIdDelta: 8
- messageCountDelta: 8

### Comparative validation

- Import comparison: PHASE SKEW: legacy=incremental import not required; shadow=incremental import required; reason=shadow ledger lagging live source by 4 message(s); production ledger already caught up
- Migration comparison: PHASE SKEW: legacy=projection current; shadow=migration required; reason=shadow projection lagging import by 8 message(s); production projection already caught up

## Polling sample 2

- captured_at: 2026-05-14T10:47:08.578955
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:47:08.578375
- last_transition: 2026-05-14T10:47:08.578716

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: MATCH: legacy=incremental import not required; shadow=incremental import not required
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 3

- captured_at: 2026-05-14T10:47:23.991735
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:47:23.988404
- last_transition: 2026-05-14T10:47:23.988220

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: PHASE SKEW: legacy=incremental import required; shadow=incremental import not required; reason=production ledger lagging live source by 2 message(s); shadow ledger already caught up
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 4

- captured_at: 2026-05-14T10:47:38.470030
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:47:38.469993
- last_transition: 2026-05-14T10:47:38.469825

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: MATCH: legacy=incremental import not required; shadow=incremental import not required
- Migration comparison: PHASE SKEW: legacy=migration required; shadow=projection current; reason=production projection lagging import by 2 message(s); shadow projection already caught up

## Polling sample 5

- captured_at: 2026-05-14T10:47:52.841754
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:47:52.841717
- last_transition: 2026-05-14T10:47:52.841574

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: MATCH: legacy=incremental import not required; shadow=incremental import not required
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 6

- captured_at: 2026-05-14T10:48:08.623923
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:48:08.623882
- last_transition: 2026-05-14T10:48:08.623717

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: PHASE SKEW: legacy=incremental import required; shadow=incremental import not required; reason=production ledger lagging live source by 2 message(s); shadow ledger already caught up
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 7

- captured_at: 2026-05-14T10:48:24.579039
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:48:24.577114
- last_transition: 2026-05-14T10:48:08.623717

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: PHASE SKEW: legacy=incremental import required; shadow=incremental import not required; reason=production ledger lagging live source by 2 message(s); shadow ledger already caught up
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 8

- captured_at: 2026-05-14T10:48:38.325861
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:48:38.325827
- last_transition: 2026-05-14T10:48:38.325642

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: MATCH: legacy=incremental import not required; shadow=incremental import not required
- Migration comparison: PHASE SKEW: legacy=migration required; shadow=projection current; reason=production projection lagging import by 4 message(s); shadow projection already caught up

## Polling sample 9

- captured_at: 2026-05-14T10:48:54.131563
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:48:54.131531
- last_transition: 2026-05-14T10:48:54.131364

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: MATCH: legacy=incremental import not required; shadow=incremental import not required
- Migration comparison: PHASE SKEW: legacy=migration required; shadow=projection current; reason=production projection lagging import by 2 message(s); shadow projection already caught up

## Polling sample 10

- captured_at: 2026-05-14T10:49:08.929367
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-14T10:49:08.929333
- last_transition: 2026-05-14T10:49:08.929184

### Shadow import

- ImportDecision: ImportDecision.doNothing
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- messageCountDelta: 0

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: MATCH: legacy=incremental import not required; shadow=incremental import not required
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling stopped

- stopped_at: 2026-05-14T10:49:11.093329
