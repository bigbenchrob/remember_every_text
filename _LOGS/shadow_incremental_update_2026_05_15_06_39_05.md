# Shadow incremental-update endurance log

- started_at: 2026-05-15T06:39:05.858335
- source: dev status panel polling


## Polling sample 1

- captured_at: 2026-05-15T06:39:05.860637
- note: polling started
- polling_status: active
- last_refresh: 2026-05-15T06:11:57.972797
- last_transition: 2026-05-15T06:11:57.972640

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: not observed
- shadow_import_ticks_to_convergence: not observed
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: not observed
- shadow_total_ticks_to_convergence: not observed
- production_convergence_pending: false
- production_pending_duration: not observed
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
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 2

- captured_at: 2026-05-15T06:39:21.684969
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T06:39:21.684908
- last_transition: 2026-05-15T06:39:21.684736

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: not observed
- shadow_import_ticks_to_convergence: not observed
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: not observed
- shadow_total_ticks_to_convergence: not observed
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

- captured_at: 2026-05-15T06:39:37.230574
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T06:39:37.230523
- last_transition: 2026-05-15T06:39:37.230378

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: not observed
- shadow_import_ticks_to_convergence: not observed
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: not observed
- shadow_total_ticks_to_convergence: not observed
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: 15545ms

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

## Polling sample 4

- captured_at: 2026-05-15T06:39:51.044621
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T06:39:51.044513
- last_transition: 2026-05-15T06:39:37.230378

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: not observed
- shadow_import_ticks_to_convergence: not observed
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: not observed
- shadow_total_ticks_to_convergence: not observed
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: 15545ms

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

- stopped_at: 2026-05-15T06:39:54.683571
