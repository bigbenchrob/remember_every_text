Work on the current Feature 27 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for implementation.

Feature 27’s initial audit established that **Message History Coverage is not safe to polish yet** because its current arithmetic compares different universes and can falsely report complete coverage.

This task fixes the semantic and query architecture first.

Do NOT redesign the final UI yet.

Do NOT add Narrator/Tracks except where a minimal honest unavailable/loading state is required to support the corrected model.

Suggested prompt name:

`02-MESSAGE-HISTORY-COVERAGE-CORRECTNESS-AND-QUERY-ARCHITECTURE.MD`

## Audit findings to treat as authoritative

The current report uses:

- denominator: every physical row in current Mac `chat.db.message`;
- numerator/categories: graph messages with conversation edges plus graph messages without conversation edges;
- no current-source filter;
- no canonical identity reconciliation.

Historical Archives therefore contaminates the graph-side counts.

In the staging graph, all **8,882** historical archive messages enter the numerator even though they do not belong to the current Mac `chat.db` denominator.

Current logic then clamps negative missing arithmetic to zero, allowing a false:

**Fully Accounted For**

result.

The audit also found:

- current graph query uses correlated full scans;
- bounded observation exceeded 30 seconds;
- set-based equivalent completed in roughly 0.09 seconds;
- maintenance admission remains protected;
- the report lacks an honest `temporarilyUnavailable` state.

These are correctness defects, not presentation issues.

## Governing semantic rule

The report must answer one precise question:

> For every physical message row currently present in this Mac’s authoritative `chat.db.message`, can MessageLens identify what happened to that exact current-source row?

Everything in the report must partition that one denominator.

Historical-source messages must not affect current-Mac coverage.

## Canonical denominator

Preserve the audit’s denominator unless code proves a necessary canonical refinement:

> every physical row in the current Mac’s `chat.db.message`.

Do not silently switch to:

- distinct GUIDs;
- graph message count;
- visible messages only;
- source-scoped historical rows.

If any physical `chat.db.message` rows must be excluded for a documented reason, STOP and report before changing the denominator.

## Canonical identity reconciliation

Use current-source row identity.

Trace the established source-scoping model and define the canonical mapping:

current `chat.db.message.ROWID`
→ current-source MessageLens identity
→ graph/working evidence.

Do not compare gross counts.

Do not compare raw scoped IDs from unrelated sources.

Use canonical `SourceScopedRowKey` / source identity authorities already established by the project.

No local bit arithmetic.

## Required terminal categories

Implement a typed coverage classification in which every denominator row belongs to exactly one terminal category.

At minimum preserve the audit’s conceptual distinction:

### Accounted for in conversation graph

The current-source row exists in MessageLens and has a valid conversation edge / normal conversation placement.

### Accounted for but unlinked/recovered

The current-source row exists in MessageLens but is not linked into a normal conversation and instead belongs to the established recovered/unlinked path.

Use the actual canonical feature/domain ownership for this category.

### Unaccounted

The current `chat.db` row cannot be reconciled to either accounted-for category.

Do not define this by clamping arithmetic.

Prefer direct set difference or equivalent typed classification.

If the audit identified more precise existing category names, use those.

## Mutually exclusive partition invariant

Mechanically enforce:

`conversationAccounted + recoveredUnlinked + unaccounted = totalCurrentChatDbRows`

and:

- every count >= 0;
- no category > total;
- no row appears in more than one terminal category;
- no current-source row disappears from the classification.

Do not use `max(0, ...)` or equivalent defensive clamps.

Impossible arithmetic must fail tests/diagnostics rather than be hidden.

## Historical source contamination

Add explicit filtering/identity logic proving that:

- Mac Messages Historical Archives imports do not enlarge the denominator;
- historical source-scoped rows do not enter any current-source category;
- MessageLens attachment-recovery donors do not affect this report at all.

Use the 8,882 historical-row scenario as regression evidence.

A graph with current source + 8,882 historical rows must produce the same current-Mac coverage result as the graph without those 8,882 rows.

## Query architecture

Replace the pathological correlated scan design with a set-based/indexed implementation.

The audit observed:

- current query >30 seconds;
- set-based equivalent ~0.09 seconds.

Use the smallest canonical repository/query architecture that achieves the same correct classification.

Do not optimize by duplicating SQL in presentation code.

Prefer one authoritative coverage query/service.

## Query shape

The implementation should conceptually:

1. enumerate current `chat.db.message.ROWID` denominator;
2. derive canonical current-source MessageLens identity;
3. join/set-match against graph/working evidence;
4. determine conversation-edge status;
5. determine recovered/unlinked status through canonical ownership;
6. classify remaining rows as unaccounted.

Do not literally loop per row if SQL/set operations can classify in bulk.

Avoid N×M or correlated subqueries.

## Identity over GUID

GUID may remain diagnostic/supporting evidence, but the report’s core question is current-source row accounting.

Do not reintroduce distinct-GUID arithmetic unless the audit specifically requires it for one sub-check.

This feature is not the Historical Archives overlap report.

## Typed report model

Introduce/refine a typed model such as conceptually:

`MessageHistoryCoverageReport`

containing:

- totalCurrentMessages;
- accountedInConversations;
- recoveredUnlinked;
- unaccounted;
- status;
- optional diagnostics/evidence timestamp.

Use repository style.

Avoid presentation code doing arithmetic.

## Honest report status

Add typed overall states:

### complete

All denominator rows are accounted for.

### incomplete

One or more denominator rows are unaccounted.

### temporarilyUnavailable

Coverage cannot be computed safely because required current/working evidence is under admitted maintenance/rebuild.

### failed

A real read/query/invariant failure occurred.

Do not collapse unavailable into failed.

Do not show stale “Fully Accounted For” while maintenance prevents a truthful report.

## Maintenance behavior

Reuse the established maintenance/readiness authority.

During admitted operations that protect relevant stores:

- do not open prohibited databases observationally;
- return `temporarilyUnavailable`;
- do not trigger Onboarding;
- do not infer missing messages from incomplete graph state.

Add regression coverage.

## Failure semantics

If category reconciliation violates invariants:

- return/raise a typed diagnostic failure;
- log technical details;
- do not clamp;
- do not present success.

Expected user-facing presentation can be handled in a later UI slice.

For now ensure the model is honest.

## Provider lifecycle

Refactor provider/application seams as needed so:

- coverage executes once per intended request;
- widget rebuild does not re-run the expensive query;
- stale async completion cannot overwrite a newer navigation/session;
- maintenance transition invalidates/recomputes truth appropriately.

Do not create a generic task framework.

## Performance target

The corrected set-based query should be fast enough that ordinary report generation is measured in sub-second or low-second territory on representative fixtures.

Do not add fake progress UI to compensate for a query that can be made fast.

Measure before/after.

If the corrected production query remains perceptibly slow, report exact phase timings for the next presentation slice.

## Tests — correctness

Add focused tests proving at minimum:

1. total denominator equals physical current `chat.db.message` rows;

2. current-source conversation-linked row classifies accounted;

3. current-source recovered/unlinked row classifies recovered/unlinked;

4. current-source row present in neither classifies unaccounted;

5. categories are mutually exclusive;

6. categories sum exactly to denominator;

7. no clamp exists;

8. negative/impossible arithmetic cannot be silently normalized;

9. historical source rows do not alter current-source counts;

10. 8,882 historical rows do not change coverage status;

11. MessageLens recovery donor semantics do not affect report;

12. source-scoped identities decode/use canonical authority.

## Tests — maintenance/status

13. maintenance returns temporarilyUnavailable;

14. temporarilyUnavailable does not open protected observational stores;

15. maintenance does not trigger Onboarding;

16. genuine query failure returns failed;

17. complete/incomplete derive only from reconciled terminal categories.

## Tests — performance/architecture

18. classification uses set-based/indexed query path;

19. no correlated per-row full scan remains;

20. provider rebuild does not duplicate query execution;

21. architecture tripwire prevents reintroduction of gross graph-count arithmetic;

22. architecture tripwire prevents `max(0, denominator - numerator)` style clamping.

Do not create one test per number mechanically.

## Preserve adjacent feature ownership

Do not rewrite:

- Recovered Messages;
- Unknown Sources;
- Conversations;
- Historical Archives;
- source-scoped import.

Reuse their canonical evidence seams where appropriate.

If current coverage logic duplicates one of their queries, replace duplication with the owned contract if safe.

## No UI redesign yet

Do not spend this task on:

- final card layout;
- colors;
- charts;
- Tracks;
- Narrator copy;
- action buttons.

Minimal state presentation changes are permitted only if necessary to avoid lying during `temporarilyUnavailable`/failed states.

The next slice will handle product presentation after truth is established.

## Documentation

Create the next Feature 27 implementation record:

`02-MESSAGE-HISTORY-COVERAGE-CORRECTNESS-AND-QUERY-ARCHITECTURE-IMPLEMENTATION.md`

Document:

- old false arithmetic;
- historical-source contamination;
- old query pathology;
- canonical denominator;
- canonical current-source identity;
- final terminal categories;
- exact invariants;
- report status model;
- maintenance behavior;
- new query architecture;
- before/after timing;
- tripwires.

Update canonical coverage/database documentation if an appropriate home exists.

Update Feature 27 index/documentation log.

Update version/changelog according to repository rules if application code changes.

## Verification

Run:

- Message History Coverage focused tests;
- source-scoping tests;
- recovered/unlinked-message tests;
- graph/database tests;
- maintenance/readiness tests;
- Settings tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

## Stop conditions

STOP if:

- denominator semantics in the audit cannot be implemented without a product decision;
- current-source identity is not recoverable canonically;
- recovered/unlinked ownership is ambiguous;
- fixing this requires schema migration;
- canonical repositories cannot expose needed evidence without redesign.

Do not paper over such gaps with count arithmetic.

## Final report

Report:

- exact denominator;
- exact terminal categories;
- identity reconciliation method;
- before/after query timing;
- historical-source contamination fix;
- final complete/incomplete/unavailable/failed semantics;
- invariant enforcement;
- provider lifecycle behavior;
- architecture tripwires;
- full verification results;
- commit hash;
- recommendation for proceeding to Feature 27 presentation/UX polish.

Acceptance standard:

> Message History Coverage must classify the same finite set of current `chat.db` rows from beginning to end. A message cannot become “accounted for” merely because unrelated Historical Archives rows inflated the graph, and impossible arithmetic must never be turned into reassurance by clamping.
