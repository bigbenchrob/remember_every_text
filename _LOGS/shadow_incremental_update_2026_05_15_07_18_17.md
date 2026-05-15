# Shadow incremental-update endurance log

- started_at: 2026-05-15T07:18:17.715611
- source: dev status panel polling


## Polling sample 1

- captured_at: 2026-05-15T07:18:17.718720
- note: polling started
- polling_status: active
- last_refresh: not observed
- last_transition: not observed

## Tick Events

- no tick events recorded

### Behavioral assessment

- shadow_convergence_completed: false
- shadow_import_convergence_duration: 0ms
- shadow_import_ticks_to_convergence: 0
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: 0ms
- shadow_total_ticks_to_convergence: 0
- production_convergence_pending: true
- production_pending_duration: 0ms
- last_production_convergence_duration: not observed

### Shadow import

- ImportDecision: ImportDecision.considerIncrementalImport
- MessageSyncState: MessageSyncState.sourceAheadOfLedger
- rowIdDelta: 5
- messageCountDelta: 5

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: MATCH: legacy=incremental import required; shadow=incremental import required
- Migration comparison: PHASE SKEW: legacy=migration required; shadow=projection current; reason=production projection lagging import by 1 message(s); shadow projection already caught up

## Polling sample 2

- captured_at: 2026-05-15T07:18:33.599661
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T07:18:33.598778
- last_transition: 2026-05-15T07:18:33.598938

## Tick Events

- tick started
- reader refresh started
- import observation boundary invalidated
- import delta observed: rowIdDelta=9, messageCountDelta=9
- import decision observed: ImportDecision.considerIncrementalImport
- shadow import executed: insertedMessageCount=9, lastImportedSourceRowId=136044
- migration reader refresh started
- migration delta observed: messageIdDelta=9, messageCountDelta=9
- migration decision observed: MigrationDecision.considerShadowMigration
- shadow migration executed: insertedMessageCount=9
- comparison observed: import=PHASE SKEW legacy=incremental import required shadow=incremental import not required reason=production ledger lagging live source by 2 message(s); shadow ledger already caught up, migration=MATCH legacy=projection current shadow=projection current

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 15881ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: 15881ms
- shadow_total_ticks_to_convergence: 1
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: 15881ms

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

## Polling sample 3

- captured_at: 2026-05-15T07:18:48.003436
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T07:18:48.003369
- last_transition: 2026-05-15T07:18:48.003210

## Tick Events

- tick started
- reader refresh started
- import observation boundary invalidated
- import delta observed: rowIdDelta=0, messageCountDelta=0
- import decision observed: ImportDecision.doNothing
- shadow import skipped: decision doNothing
- migration reader refresh started
- migration delta observed: messageIdDelta=0, messageCountDelta=0
- migration decision observed: MigrationDecision.doNothing
- shadow migration skipped: decision doNothing
- comparison observed: import=MATCH legacy=incremental import not required shadow=incremental import not required, migration=PHASE SKEW legacy=migration required shadow=projection current reason=production projection lagging import by 2 message(s); shadow projection already caught up

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 15881ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: 15881ms
- shadow_total_ticks_to_convergence: 1
- production_convergence_pending: true
- production_pending_duration: 0ms
- last_production_convergence_duration: 15881ms

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

## Polling sample 4

- captured_at: 2026-05-15T07:19:02.871962
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T07:19:02.871889
- last_transition: 2026-05-15T07:19:02.871732

## Tick Events

- tick started
- reader refresh started
- import observation boundary invalidated
- import delta observed: rowIdDelta=0, messageCountDelta=0
- import decision observed: ImportDecision.doNothing
- shadow import skipped: decision doNothing
- migration reader refresh started
- migration delta observed: messageIdDelta=0, messageCountDelta=0
- migration decision observed: MigrationDecision.doNothing
- shadow migration skipped: decision doNothing
- comparison observed: import=MATCH legacy=incremental import not required shadow=incremental import not required, migration=MATCH legacy=projection current shadow=projection current

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 15881ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: 15881ms
- shadow_total_ticks_to_convergence: 1
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: 14868ms

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

## Polling sample 5

- captured_at: 2026-05-15T07:19:17.911060
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-15T07:19:17.910994
- last_transition: 2026-05-15T07:19:02.871732

## Tick Events

- tick started
- reader refresh started
- import observation boundary invalidated
- import delta observed: rowIdDelta=0, messageCountDelta=0
- import decision observed: ImportDecision.doNothing
- shadow import skipped: decision doNothing
- migration reader refresh started
- migration delta observed: messageIdDelta=0, messageCountDelta=0
- migration decision observed: MigrationDecision.doNothing
- shadow migration skipped: decision doNothing
- comparison observed: import=MATCH legacy=incremental import not required shadow=incremental import not required, migration=MATCH legacy=projection current shadow=projection current

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 15881ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: not observed
- shadow_migration_ticks_to_convergence: not observed
- shadow_total_convergence_duration: 15881ms
- shadow_total_ticks_to_convergence: 1
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: 14868ms

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

- stopped_at: 2026-05-15T07:19:21.802301
