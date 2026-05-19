# Shadow incremental-update endurance log

- started_at: 2026-05-19T04:54:50.871939
- source: dev status panel polling


## Polling sample 1

- captured_at: 2026-05-19T04:54:50.880599
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
- cursor_rowIdDelta: 1
- diagnostic_messageCountDelta: -3
- count divergence: ledger ahead by 3 row(s); diagnostic only

### Shadow migration

- MigrationDecision: MigrationDecision.doNothing
- MessageMigrationState: MessageMigrationState.projectionCaughtUp
- messageIdDelta: 0
- messageCountDelta: 0

### Comparative validation

- Import comparison: PHASE SKEW: legacy=incremental import not required; shadow=incremental import required; reason=shadow ledger lagging live source by 1 message(s); production ledger already caught up
- Migration comparison: MATCH: legacy=projection current; shadow=projection current

## Polling sample 2

- captured_at: 2026-05-19T04:55:06.667425
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-19T04:55:06.638206
- last_transition: 2026-05-19T04:55:06.638344

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
- import delta observed: rowIdDelta=1, messageCountDelta=-3
- import decision observed: ImportDecision.considerIncrementalImport
- prerequisite assessment observed: satisfied blockers=[]
- prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.considerIncrementalImport
- shadow import executed: insertedMessageCount=1, lastImportedSourceRowId=148552
- topology observation boundary invalidated
- topology delta observed: rowIdDelta=1, joinCountDelta=1, messageRowIdDelta=1, chatRowIdDelta=0
- topology import decision observed: ChatMessageJoinImportDecision.considerTopologyImport
- shadow topology import executed: insertedJoinCount=1, lastImportedSourceRowId=127894
- migration reader refresh started
- migration delta observed: messageIdDelta=1, messageCountDelta=1
- migration decision observed: MigrationDecision.considerShadowMigration
- shadow migration executed: insertedMessageCount=1
- comparison observed: import=MATCH legacy=incremental import not required shadow=incremental import not required, migration=MATCH legacy=projection current shadow=projection current

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 15788ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: 425ms
- shadow_migration_ticks_to_convergence: 0
- shadow_total_convergence_duration: 15788ms
- shadow_total_ticks_to_convergence: 1
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

## Polling sample 3

- captured_at: 2026-05-19T04:55:21.091640
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-19T04:55:21.060781
- last_transition: 2026-05-19T04:55:20.972760

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
- import delta observed: rowIdDelta=0, messageCountDelta=-4
- import decision observed: ImportDecision.doNothing
- prerequisite assessment observed: satisfied blockers=[]
- prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.doNothing
- shadow import skipped: decision doNothing
- topology observation boundary invalidated
- topology delta observed: rowIdDelta=0, joinCountDelta=0, messageRowIdDelta=0, chatRowIdDelta=0
- topology import decision observed: ChatMessageJoinImportDecision.doNothing
- shadow topology import skipped: decision doNothing
- migration reader refresh started
- migration delta observed: messageIdDelta=0, messageCountDelta=0
- migration decision observed: MigrationDecision.doNothing
- shadow migration skipped: decision doNothing
- comparison observed: import=MATCH legacy=incremental import not required shadow=incremental import not required, migration=MATCH legacy=projection current shadow=projection current

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 15788ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: 425ms
- shadow_migration_ticks_to_convergence: 0
- shadow_total_convergence_duration: 15788ms
- shadow_total_ticks_to_convergence: 1
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

## Polling sample 4

- captured_at: 2026-05-19T04:55:36.236378
- note: poll tick completed
- polling_status: active
- last_refresh: 2026-05-19T04:55:36.203407
- last_transition: 2026-05-19T04:55:20.972760

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
- import delta observed: rowIdDelta=0, messageCountDelta=-4
- import decision observed: ImportDecision.doNothing
- prerequisite assessment observed: satisfied blockers=[]
- prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.doNothing
- shadow import skipped: decision doNothing
- topology observation boundary invalidated
- topology delta observed: rowIdDelta=0, joinCountDelta=0, messageRowIdDelta=0, chatRowIdDelta=0
- topology import decision observed: ChatMessageJoinImportDecision.doNothing
- shadow topology import skipped: decision doNothing
- migration reader refresh started
- migration delta observed: messageIdDelta=0, messageCountDelta=0
- migration decision observed: MigrationDecision.doNothing
- shadow migration skipped: decision doNothing
- comparison observed: import=MATCH legacy=incremental import not required shadow=incremental import not required, migration=MATCH legacy=projection current shadow=projection current

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 15788ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: 425ms
- shadow_migration_ticks_to_convergence: 0
- shadow_total_convergence_duration: 15788ms
- shadow_total_ticks_to_convergence: 1
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

- stopped_at: 2026-05-19T04:55:38.932737
