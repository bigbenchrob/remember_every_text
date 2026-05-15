# Shadow incremental-update endurance log

- started_at: 2026-05-15T06:11:27.765126
- source: dev status panel polling


## Polling sample 1

- captured_at: 2026-05-15T06:11:27.777162
- note: polling started
- polling_status: active
- last_refresh: not observed
- last_transition: not observed

### Behavioral assessment

- shadow_convergence_completed: false
- shadow_import_convergence_duration: 0ms
- shadow_import_ticks_to_convergence: 0
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: 0ms
- shadow_total_ticks_to_convergence: 0
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: not observed

### Shadow import

- ImportDecision: ImportDecision.considerIncrementalImport
- MessageSyncState: MessageSyncState.sourceAheadOfLedger
- rowIdDelta: 18
- messageCountDelta: 18

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: PHASE SKEW: legacy=incremental import not required; shadow=incremental import required; reason=shadow ledger lagging live source by 18 message(s); production ledger already caught up
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 2

- captured_at: 2026-05-15T06:11:43.783162
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T06:11:43.782731
- last_transition: 2026-05-15T06:11:43.782870

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 16007ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: 16007ms
- shadow_total_ticks_to_convergence: 1
- production_convergence_pending: true
- production_pending_duration: 0ms
- last_production_convergence_duration: not observed

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

## Polling sample 3

- captured_at: 2026-05-15T06:11:57.972944
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T06:11:57.972797
- last_transition: 2026-05-15T06:11:57.972640

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 16007ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: 16007ms
- shadow_total_ticks_to_convergence: 1
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: 14189ms

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

- stopped_at: 2026-05-15T06:12:02.104941
