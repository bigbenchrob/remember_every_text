---
tier: project
scope: message-history-coverage
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: audit-record
---

# Message History Coverage Semantics And Architecture Audit

## Decision

**NOT SAFE TO POLISH.**

The current report cannot prove its central product claim. It compares every
row in the current Mac's `chat.db.message` table with every message row in the
multi-source conversation graph. It does not join source records to graph
records by identity and it does not restrict graph evidence to the live
Messages source.

This produces a demonstrated false-complete path:

1. Historical Archives adds non-current source rows to the graph.
2. The graph total exceeds the current Mac denominator.
3. `missingCount` clamps the negative difference to zero.
4. classification returns `complete`.
5. presentation says **Fully Accounted For** and **Every message on this Mac
   has been accounted for.**

The defect is mathematical and architectural, not presentational. It must be
corrected before the feature is treated as trustworthy product evidence.

## Audit Method And Limits

This was a read-only audit. No application code, schema, database, source
identity, or product behavior was changed.

The audit used:

- implementation and test inspection;
- immutable/read-only inspection of the disposable Feature 26 staging archive;
- SQLite query-plan inspection;
- bounded timing of the current graph query;
- comparison with an equivalent set-based read-only query.

The shell process did not have Full Disk Access to the live
`~/Library/Messages/chat.db`, so no production source counts were collected.
That limitation does not affect the source-contamination proof: the disposable
staging archive contains canonical source registry, import-ledger, and graph
evidence for both source 1 and historical source 3.

## 1. Current Feature Architecture

The current execution path is:

```text
Settings sidebar selection
    -> SidebarFlowState persistent Settings context
    -> SettingsViewSpec.messageHistoryCoverageReport
    -> MessageHistoryCoverageReportPanel
    -> messageHistoryCoveragePanelModelProvider
    -> messageHistoryCoverageReportProvider
    -> messageHistoryCoverageRepositoryProvider
    -> central conversation-graph database provider
    -> MessageHistoryCoverageRepository
         -> direct read-only chat.db summary
         -> conversation-graph summary
    -> status and presentation classification
```

The major ownership pieces are:

- Navigation/ViewSpec owns effective panel selection.
- Settings owns report orchestration, report entities, classification, sidebar
  copy, view model, and presentation.
- The central database provider admits and opens `working_ss.db`.
- A Settings infrastructure repository directly opens `chat.db` read-only and
  directly queries the graph database.

The one-off `chat.db` open is read-only, sets `query_only`, uses a busy timeout,
and closes in `finally`. That part follows the permitted source-probe pattern.
The broader semantic ownership is still too local to Settings; see Section 14.

## 2. Authoritative Denominator In The Current Code

The current denominator is exactly:

```sql
SELECT
  COUNT(*) AS total_count,
  MIN(CASE WHEN date IS NOT NULL AND date != 0 THEN date END) AS first_date,
  MAX(CASE WHEN date IS NOT NULL AND date != 0 THEN date END) AS last_date
FROM message
```

Therefore **messages on this Mac currently means every physical row in the
live `chat.db.message` table**.

The count:

- is not `COUNT(DISTINCT guid)`;
- does not require a non-null or non-empty GUID;
- does not apply a message-like predicate;
- does not deduplicate duplicate GUIDs;
- does not exclude reactions, tapbacks, service events, deleted/unsent rows,
  sparse rows, malformed rows, or rows with no conversation;
- does not exclude zero/null dates from the count.

Only date-range calculation excludes `NULL` and zero dates.

This row-level denominator is a defensible choice because MessageLens's import
identity is source row identity and the record-fidelity rule requires every
source record to remain observable. It must, however, be declared explicitly
and reconciled by the same row identity. The current report does not do that.

## 3. Current Category Definitions

### Conversation-linked

Current query meaning:

```sql
COUNT(graph.messages m)
WHERE EXISTS chat_to_message edge for m.ss_id
```

This means **a graph message row with at least one projected conversation
edge**. It does not prove that the row belongs to the current Mac source, nor
does it prove visibility on every MessageLens timeline surface.

The label `Visible in timelines` is broader than the predicate. Global Message
Evidence reads all graph messages, including messages without a
`chat_to_message` edge. Conversation-oriented views use the edge.

### Recovered/orphan

Current query meaning:

```sql
COUNT(graph.messages m)
WHERE NOT EXISTS chat_to_message edge for m.ss_id
```

This means **a graph message row with no projected conversation edge**. It is
the same topology used by the Recovered Messages evidence repository, although
that repository also currently has no source filter.

It does not mean Unknown Sources. Unknown Sources concerns participant/handle
identity and review state. It also does not, by itself, prove that a deleted
message was recovered. `Recovered` is the product name for graph-orphan
evidence.

### Missing/unaccounted

Current calculation:

```text
delta = chat.db row count - (all linked graph rows + all orphan graph rows)
missing = max(delta, 0)
```

There is no direct missing-record query and no identity comparison. The value
is only a scalar difference between incompatible sets.

## 4. Arithmetic Invariants

The linked and orphan categories are mutually exclusive and exhaustive **over
all graph message rows** because they are complementary `EXISTS` and
`NOT EXISTS` predicates. Multiple conversation edges do not double-count a
message.

They are not a partition of the current `chat.db` denominator.

Current invariant results:

| Invariant | Result |
| --- | --- |
| Each graph row is linked or orphan | Holds |
| Categories contain current-source rows only | Fails |
| Every denominator row maps to at most one category | Not proven |
| Every denominator row maps to at least one category | Not proven |
| Category sum cannot exceed denominator | Fails |
| Missing count cannot be negative | Hidden by clamping |
| Terminal categories sum to denominator | Fails |
| Equal totals prove equal membership | False |

`classifyMessageHistoryCoverageReport` returns `complete` whenever
`accountedCount >= sourceCount`, except for the separate recent-history
heuristic when counts are exactly equal. The view model then detects excess
graph rows as a "small overlap," compresses segment fractions to fit the bar,
and explicitly says the overlap does not indicate missing data.

That is not harmless normalization. It converts contradictory evidence into a
reassuring result. Impossible arithmetic must be rejected mechanically.

## 5. Identity And Join Semantics

The canonical live-source identity chain is:

```text
chat.db.message.ROWID
    + liveChatDbSourceId (1)
    -> SourceScopedRowKey.pack(sourceId: 1, sourceRowId: ROWID)
    -> import-ledger messages.ss_id
    -> graph messages.ss_id
```

`SourceScopedRowKey` is reversible. `liveChatSourceRowIdForGraphId` already
provides a canonical graph-to-live-source boundary.

GUID is imported as evidence but is not the canonical occurrence identity.
Duplicate GUID rows remain distinct source occurrences.

The coverage report performs none of these joins. It does not compare:

- live `ROWID` to source-1 ledger `source_rowid`;
- packed source-1 identity to graph `ss_id`;
- GUID membership;
- import-ledger membership to graph membership.

It compares scalar totals only. Equal totals could therefore hide both missing
source rows and unrelated extra graph rows.

## 6. Current-Mac Source Filtering

There is no source filter in the graph query.

Canonical source constants already exist:

```text
source 1: live-chat-db / live_chat_db
source 2: live-address-book / live_address_book
source 3+: historical_messages_archive
```

Immutable staging evidence:

| Graph evidence | Count |
| --- | ---: |
| All graph messages | 146,222 |
| All conversation-linked | 125,449 |
| All orphan | 20,773 |
| Source 1 total | 137,340 |
| Source 1 linked | 116,589 |
| Source 1 orphan | 20,751 |
| Historical source 3 total | 8,882 |

The import ledger independently records 137,340 source-1 messages and 8,882
source-3 messages. The exact 8,882 historical rows are included in the current
coverage numerator.

Historical Archives therefore demonstrably contaminates the report.

MessageLens attachment-recovery donors do not contribute message rows and do
not contaminate this count. They are ephemeral payload donors, not durable
message sources. Recovered/orphan rows may belong to any durable message source
under the current query.

## 7. Graph And Projection Dependency

Coverage depends on these `working_ss.db` tables:

- `messages`;
- `chat_to_message`.

The report does not consult:

- source-scoped import-ledger membership;
- graph-build generation/version;
- graph readiness;
- projection watermark;
- source freshness.

It can therefore compare source evidence and graph evidence from different
logical instants. A stable but stale graph can be reported as missing or
complete without the report knowing which is true.

The correct report must use one coherent evidence snapshot or carry enough
watermark/generation evidence to reject an incoherent comparison.

## 8. Maintenance And Readiness Behavior

The central graph provider correctly asks `ArchiveMutationCoordinator` for
permission to open `working_ss.db`. If maintenance blocks the caller, the
provider observes `dbMaintenanceLockProvider`, refuses the open, and throws a
typed-in-practice `StateError` message.

Message History Coverage does not model that state:

- it does not watch the maintenance signal;
- it requests the graph-backed repository before entering its graph-read
  `try/catch`;
- a blocked repository construction can therefore reach the panel's generic
  provider error branch;
- an already-created report does not invalidate merely because maintenance or
  graph evidence changes;
- a repository holding a connection that is closed for maintenance can fail
  later and becomes `unknown`, not `temporarilyUnavailable`.

The feature itself contains no direct command that opens Onboarding. The audit
found no direct provider cycle. The central admission boundary prevents an
unrelated new graph open during maintenance, but the report does not turn that
truth into an honest product state.

## 9. DateConverter Audit

Date conversion is correct in this feature.

`MessageHistoryCoverageRepository` delegates source `date` values to:

```dart
DateConverter.appleToDateTime(...)
```

Presentation receives `DateTime` values and only formats them with `intl`.
There is no private Apple epoch arithmetic, magnitude heuristic, or duplicate
conversion scheme.

This invariant must remain mandatory: all Apple Messages timestamp conversion
uses `lib/core/util/date_converter.dart`.

## 10. Performance Trace

### Current source read

The repository opens `chat.db` once, executes one aggregate scan, and closes it.
There is no per-message Dart loop. The synchronous `sqlite3` call executes on
the caller isolate, so it can still block first paint while SQLite scans the
source table for count/min/max. This should be measured after correctness is
restored, but it is not the dominant observed defect.

### Graph read

The current graph SQL contains two correlated subqueries. SQLite reports:

```text
SCAN messages
  CORRELATED SCALAR SUBQUERY
    SCAN chat_to_message
SCAN messages
  CORRELATED SCALAR SUBQUERY
    SCAN chat_to_message
```

`chat_to_message` has only its primary-key index in
`(chat_ss_id, message_ss_id)` order. That index cannot efficiently answer the
correlated lookup by `message_ss_id` alone.

On the 146,222-message staging graph, the exact current query did not complete
within a bounded approximately 30-second observation. A read-only set-based
equivalent that materialized distinct linked message IDs and joined once
completed in approximately **0.09 seconds** on the same database.

The prolonged Loading state is therefore explained by a concrete SQL-plan
defect, not by UI rendering or a provider dependency cycle. The Drift graph
connection uses `NativeDatabase.createInBackground`, so graph SQL is off the UI
isolate, but the user still waits for its inefficient completion.

There are no repeated database opens or application-level N-by-M loops in the
current path. The N-by-M behavior is inside SQLite's correlated execution plan.

## 11. Provider And Navigation Lifecycle

The report and panel-model providers are auto-disposed. Ordinary navigation
away removes the active panel listener; returning after disposal recomputes the
report. The ViewSpec/flow-state compatibility system prevents a late result
from becoming a different Settings panel.

Important limitations remain:

- the synchronous source query cannot be cancelled once started;
- the graph query can continue until its database operation resolves;
- while the report remains mounted, graph/source changes do not invalidate it;
- `generatedAt` is captured before evidence reads begin, not when the coherent
  report has been generated;
- no source watermark or graph generation proves freshness.

No mutable global report state or arbitrary delay was found.

## 12. Completed Report Critique

The completed center panel currently presents:

1. hero card with status badge, headline, summary, and generation time;
2. Message Accounting segmented bar and legend;
3. Reconciliation metrics;
4. Timeline Coverage date range;
5. Recovered Messages explanation;
6. optional Notes.

### Evidence strength

The strongest visual claims are the least justified:

- `Fully Accounted For`;
- `Every message on this Mac has been accounted for.`;
- `All ... messages on this Mac are accounted for.`;
- `Result: fully reconciled`;
- `0 missing`;
- primary-accent complete status.

The panel explicitly normalizes excess counts to fit the accounting bar. That
makes the graphic visually coherent while its evidence is not.

### User value

- The source count and exact reconciliation outcome are primary evidence once
  computed correctly.
- Conversation-linked, orphan, and unaccounted counts are useful if they are a
  true partition of current-source identities.
- Date range is useful orientation but does not belong in coverage status.
- Generated time is useful only if it marks a coherent completed snapshot.
- Raw overlap prose is diagnostic detail and should never normalize an invalid
  report.
- The recovered explanation currently overstates that those graph rows are
  present in this Mac's Messages database.

The presentation is card-heavy for an operational report, but visual redesign
must wait. Semantic correction has priority.

## 13. Sidebar Copy Accuracy

Current sidebar claims are not literally true.

> MessageLens compares the messages stored in your Mac's Messages database
> with the messages it has imported and organized.

Only scalar counts are compared. Record identity and import-ledger membership
are not compared, and historical graph sources are included.

> This report shows whether everything on this Mac has been accounted for.

The current implementation cannot prove that.

> Messages visible in your chat timelines

The predicate is conversation-edge membership, while at least the global
Message Evidence timeline can show graph rows without those edges.

> If no messages are missing, then MessageLens has successfully accounted for
> everything available on this Mac.

`missing == 0` can result from unrelated historical rows outnumbering missing
current rows. The claim is unsafe.

Do not revise the copy in isolation. It should be rewritten only after the
semantic model is implemented.

## 14. Relationship To Adjacent Features

### Recovered Messages

This is the closest existing category owner. It defines recovered evidence as
graph messages lacking conversation edges. The coverage feature should consume
or share a named canonical topology query rather than privately restating the
predicate. Coverage additionally needs a live-source restriction.

### Unknown Sources

Unknown Sources does not own this category. Its concern is unresolved source
identity/handle review, not graph-message coverage.

### Conversations

Conversation linkage supplies one topology classification. It is not by itself
proof of visibility on every presentation surface.

### Historical Archives

Historical Archives is a durable, source-scoped contributor to the shared
graph. Its rows must remain visible in normal MessageLens browsing but must be
excluded from a current-Mac-only coverage denominator and terminal categories.

### Current-source import/migration

The source-scoped import ledger owns the canonical relation between live
`chat.db.ROWID` and source-1 imported occurrence. Coverage currently bypasses
that evidence.

### Message Evidence spine

Global Message Evidence reads graph messages regardless of conversation-edge
membership. Coverage should not call an edge-bearing row universally visible
or an orphan universally invisible.

## 15. Architecture Ownership And Violations

Recommended dependency direction:

```text
Settings coverage composition
    -> current-source coverage evidence port
         -> source-scoped import owns source/import identity
    -> current-source graph classification port
         -> conversation graph / recovered evidence owns topology
    -> typed coverage reconciliation
    -> Settings presentation
```

Settings may own the report ViewSpec and presentation. It should orchestrate;
source-scoped import and graph modules should know their own identity and
topology rules.

### Findings by severity

**Critical — false complete result**

Multi-source graph totals are compared with a current-source denominator, and
negative differences are clamped to zero.

**High — no identity reconciliation**

Counts can match while membership differs. The report does not prove that any
specific current source row is present in import or graph evidence.

**High — pathological graph query**

The correlated query performs repeated full scans and can leave the report
loading for tens of seconds.

**High — contradictory evidence is normalized**

The view model compresses excess counts and labels the result fully reconciled.

**High — maintenance/readiness is not a product state**

Central admission is safe, but the feature can surface a generic error or stale
report rather than `temporarilyUnavailable`.

**Medium — Settings duplicates cross-domain database semantics**

Settings directly defines source denominator and graph topology SQL instead of
consuming named canonical evidence boundaries.

**Medium — no temporal coherence**

Source and graph reads have no shared generation/watermark contract.

**Medium — source-history heuristic is conflated with coverage**

An earliest date within five years becomes `incompleteSourceHistory`. That is
a source-retention caveat, not evidence that MessageLens failed to account for
available rows.

**Medium — stale report while mounted**

No maintenance, source, ledger, or graph generation invalidates the report.

**Low — synchronous source aggregate**

The direct `sqlite3` scan runs on the caller isolate.

**Correct — DateConverter authority**

The feature uses the canonical utility.

**Correct — central graph admission**

Settings does not create an unauthorized long-lived graph connection.

## 16. Proposed Typed Semantic Model

The denominator should remain explicit and row-based:

> Every physical row currently present in the live Mac's
> `chat.db.message` table, identified by live source `ROWID`.

For each denominator identity, derive exactly one terminal category:

```text
conversationLinked
    source-1 graph message exists and has at least one chat edge

recoveredUnlinked
    source-1 graph message exists and has no chat edge

unaccounted
    no corresponding source-1 graph message exists
```

Import-ledger membership should remain available as diagnostic staging evidence
so `unaccounted` can distinguish source-not-imported from imported-not-projected
without creating overlapping terminal categories.

A conceptual report:

```text
MessageHistoryCoverageReport
    status
    evidenceGeneratedAt
    sourceEvidence
        totalCurrentRows
        earliestCurrentDate
        latestCurrentDate
        sourceWatermark
    terminalCounts
        conversationLinked
        recoveredUnlinked
        unaccounted
    diagnostics
        sourceRowsAbsentFromImport
        importedRowsAbsentFromGraph
        unexpectedSource1GraphRows
        excludedNonCurrentGraphRows
        graphGeneration
```

Required invariants:

```text
conversationLinked >= 0
recoveredUnlinked >= 0
unaccounted >= 0

conversationLinked
  + recoveredUnlinked
  + unaccounted
  == totalCurrentRows

each current ROWID appears in exactly one terminal category
non-current source rows appear in no terminal category
impossible or incoherent evidence cannot produce complete
```

`unexpectedSource1GraphRows` is diagnostic evidence outside the denominator. It
must not be silently used to offset missing current rows.

## 17. Honest Product States

Recommended states:

### Complete

Every current source-row identity belongs to exactly one known terminal
category and evidence is coherent/current enough to make that claim.

### Partial

One or more current source rows are unaccounted for. Diagnostics identify the
pipeline boundary at which evidence is absent when possible.

### Inconsistent evidence

Reads succeeded, but extra/stale/contradictory source-1 evidence prevents a
trustworthy conclusion. This must never be normalized to complete.

### Temporarily unavailable

Maintenance, rebuild, or another admitted operation prevents a coherent safe
read. This is not failure and not partial coverage.

### Failed

Required evidence could not be read safely after admission was available.

The current `incompleteSourceHistory` state should become an orthogonal source
history note, not a coverage result.

## 18. Progress And Narrator Recommendation

Do not add Narrator or Directed Instrumentation to the current algorithm.

The measured set-based graph classification is subsecond at the staging scale.
The target implementation should provide immediate page identity and a simple
in-place pending state. After the correct source/import/graph reconciliation is
implemented, profile the complete path again.

Only if coherent identity reconciliation remains perceptibly long should it
publish truthful stages such as:

```text
Reading current Messages identities
Reading imported current-source identities
Classifying current-source graph evidence
Reconciling coverage
```

Those stages would earn Directed Instrumentation only if they expose real
countable work. Narrator is not currently justified for a Settings report that
should be nearly instant.

## 19. Tracks And Layout Recommendation

Message History Coverage does not currently participate in a page-specific
shared Track matrix. Its loading text is centered in the entire center panel;
the completed report is a separately centered scroll view with a fixed maximum
width.

After semantics are corrected, introduce the smallest Settings composition
needed to align stable page identity across the sidebar and center panel. A
likely shape is:

```text
shared Track A
    first sidebar report-context cassette
    center report identity/title

then column-specific native flow
    remaining sidebar explanation cassettes
    center report sections
```

The exact matrix should follow the established Settings composition seam at
implementation time. Do not use Tracks to align every report card or reserve
loading space. The shared boundary should represent only a truthful
cross-column relationship.

## 20. Failure And Action Semantics

The current panel provides no direct corrective action. Export infrastructure
exists, but the report panel intentionally does not display an export button.

Do not send the user to Unknown Sources merely because a message is
unaccounted. Unknown Sources addresses a different problem.

Potential actions must follow proven diagnostics:

- source row absent from import: offer the existing current-source import or
  update operation only if that operation is safe and user-invocable;
- imported row absent from graph: offer the existing graph rebuild/repair path
  only if it owns that correction;
- graph-orphan row: allow navigation to Recovered Messages if a stable identity
  handoff can be made;
- maintenance: wait and recompute after admission is restored;
- failed evidence read: retry the report, without opening Onboarding.

Until those mappings are implemented, the report should state evidence without
inventing an action.

## Recommended Implementation Slices

### Slice 1 — semantic contract and regression proofs

- Adopt the row-level current-source denominator explicitly.
- Add tests proving historical sources are excluded.
- Add tests proving `accounted > denominator` cannot become complete.
- Add identity-membership tests where equal totals contain different rows.
- Separate source-history caveat from coverage state.

### Slice 2 — canonical evidence boundaries

- Add a source/import-owned current-source coverage evidence port.
- Add a graph-owned current-source topology classification port.
- Use `SourceScopedRowKey` / existing live graph identity helpers only.
- Keep Settings as report composer and presenter.

### Slice 3 — coherent set reconciliation

- Reconcile sorted/current source identities in linear or set-based work.
- Produce the terminal partition and diagnostics.
- Reject unexpected/contradictory evidence.
- Record evidence completion time and appropriate watermarks/generation.

### Slice 4 — maintenance and lifecycle

- Model maintenance/rebuild as `temporarilyUnavailable`.
- Recompute after the maintenance signal changes.
- Prevent stale mounted reports from surviving source/graph generation changes.
- Keep central database admission intact.

### Slice 5 — performance correction

- Replace the correlated graph scan with a canonical set-based query.
- Add query-plan/performance regression protection appropriate to repository
  conventions.
- Move or isolate the synchronous source scan if profiling still shows visible
  UI blocking.

### Slice 6 — truthful product presentation

- Rewrite sidebar and center copy from the implemented semantic model.
- Remove overlap normalization and overconfident complete claims.
- Present diagnostics progressively rather than as equal-weight cards.
- Add only actions supported by proven diagnostic ownership.

### Slice 7 — page composition

- Add the minimal shared Settings Track relationship.
- Keep report details in independent center flow.
- Verify loading, complete, partial, unavailable, inconsistent, and failed
  states at desktop window sizes.

## Final Conclusion

The current feature measures:

> all live `chat.db.message` rows minus all message rows in the entire
> multi-source graph, divided only by graph edge topology.

It does **not** currently measure:

> whether every message row on this Mac is represented in MessageLens.

Historical Archives data demonstrably contaminates the numerator, identity is
not reconciled, impossible arithmetic is normalized, and the graph query is
pathologically slow. Existing sidebar and completed-panel claims are therefore
not trustworthy.

Feature 27 should proceed with semantic and evidence-boundary correction. It is
not safe to begin visual polish.
