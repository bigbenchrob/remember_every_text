# Shadow incremental-update endurance log

- started_at: 2026-05-18T17:15:34.739865
- source: dev status panel polling


## Polling sample 1

- captured_at: 2026-05-18T17:15:34.749184
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
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: not observed

### Shadow chats

- ChatImportDecision: ChatImportDecision.doNothing
- ChatSyncState: ChatSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- chatCountDelta: 0

### Shadow handles

- HandleImportDecision: HandleImportDecision.doNothing
- HandleSyncState: HandleSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- handleCountDelta: 0

### Shadow import

- ImportDecision: ImportDecision.considerIncrementalImport
- Prerequisite-aware message import decision: PrerequisiteAwareMessageImportDecision.considerIncrementalImport
- Message import prerequisite assessment: satisfied
- Message import prerequisite blockers: []
- MessageSyncState: MessageSyncState.sourceAheadOfLedger
- Message cursor state: source ahead of ledger
- cursor_rowIdDelta: 13
- diagnostic_messageCountDelta: 9
- count divergence: source ahead by 9 row(s); diagnostic only

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: PHASE SKEW: legacy=incremental import not required; shadow=incremental import required; reason=shadow ledger lagging live source by 13 message(s); production ledger already caught up
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 2

- captured_at: 2026-05-18T17:16:04.745657
- event: poll tick skipped: refresh in flight

## Polling sample 3

- captured_at: 2026-05-18T17:16:19.746009
- event: poll tick skipped: refresh in flight

## Polling sample 4

- captured_at: 2026-05-18T17:16:21.305540
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-18T17:16:21.304336
- last_transition: 2026-05-18T17:16:21.304463

## Tick Events

- tick started
- handle observation boundary invalidated
- handle delta observed: rowIdDelta=0, handleCountDelta=0
- handle import decision observed: HandleImportDecision.doNothing
- shadow handle import skipped: decision doNothing
- chat observation boundary invalidated
- chat delta observed: rowIdDelta=0, chatCountDelta=0
- chat import decision observed: ChatImportDecision.doNothing
- shadow chat import skipped: decision doNothing
- reader refresh started
- import observation boundary invalidated
- import delta observed: rowIdDelta=13, messageCountDelta=9
- import decision observed: ImportDecision.considerIncrementalImport
- prerequisite assessment observed: satisfied blockers=[]
- prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.considerIncrementalImport
- shadow import executed: insertedMessageCount=13, lastImportedSourceRowId=148550
- topology observation boundary invalidated
- topology delta observed: rowIdDelta=127892, joinCountDelta=111727, messageRowIdDelta=148550, chatRowIdDelta=372
- topology import decision observed: ChatMessageJoinImportDecision.considerTopologyImport
- shadow topology import executed: insertedJoinCount=111727, lastImportedSourceRowId=127892
- migration reader refresh started
- migration delta observed: messageIdDelta=13, messageCountDelta=13
- migration decision observed: MigrationDecision.considerShadowMigration
- shadow migration executed: insertedMessageCount=13
- comparison observed: import=MATCH legacy=incremental import not required shadow=incremental import not required, migration=MATCH legacy=projection current shadow=projection current

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 46557ms
- shadow_import_ticks_to_convergence: 3
- shadow_migration_convergence_duration: 712ms
- shadow_migration_ticks_to_convergence: 0
- shadow_total_convergence_duration: 46557ms
- shadow_total_ticks_to_convergence: 3
- production_convergence_pending: false
- production_pending_duration: not observed
- last_production_convergence_duration: not observed

### Shadow chats

- ChatImportDecision: ChatImportDecision.doNothing
- ChatSyncState: ChatSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- chatCountDelta: 0

### Shadow handles

- HandleImportDecision: HandleImportDecision.doNothing
- HandleSyncState: HandleSyncState.sourceAndLedgerCursorsMatch
- rowIdDelta: 0
- handleCountDelta: 0

### Shadow import

- ImportDecision: ImportDecision.doNothing
- Prerequisite-aware message import decision: PrerequisiteAwareMessageImportDecision.doNothing
- Message import prerequisite assessment: satisfied
- Message import prerequisite blockers: []
- MessageSyncState: MessageSyncState.sourceAndLedgerCursorsMatch
- Message cursor state: current
- cursor_rowIdDelta: 0
- diagnostic_messageCountDelta: -4
- count divergence: ledger ahead by 4 row(s); diagnostic only

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: MATCH: legacy=incremental import not required; shadow=incremental import not required
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling stopped

- stopped_at: 2026-05-18T17:16:25.711534
