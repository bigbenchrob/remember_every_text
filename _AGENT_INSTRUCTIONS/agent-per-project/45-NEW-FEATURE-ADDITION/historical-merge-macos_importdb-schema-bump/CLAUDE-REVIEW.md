Historical Archive Import — Architecture & Implementation Audit
Read-only assessment. No code is proposed. References are to current implementation files.

1. Architectural Assessment
   Strong / future-proof

Single ingestion point. All sources funnel through sqflite_import_database.dart and orchestrated_ledger_import_service.dart. Eliminating a parallel "archive DB" removes the worst class of past defects (divergent schemas, ad-hoc merge code, mixed-source row leakage).
Provenance-by-construction. ledger_sources + import_batches + source_id/batch_id on every major row means no row exists without a knowable origin. This is the right invariant and unlocks per-source delete, audit, and re-import.
Surrogate IDs at the boundary. Detaching ledger PKs from Apple ROWID is correct: it stops cross-source ID collisions and makes batch_id deletion FK-safe.
Projection model. Treating working.db as a pure projection of the ledger (and rebuilding it deterministically) matches the codebase's broader "user-intent in overlay, derived facts in working" rule. It makes recovery easy: nuke working.db, replay.
GUID-as-identity. Using UNIQUE(guid) + INSERT OR REPLACE aligns dedup with Apple's own message identity, which is the only stable cross-source key available.
Fragile / risky

INSERT OR REPLACE is silent overwrite, not merge. When the same GUID arrives from a second source (e.g., archive after current_mac), the prior row's source_id/batch_id is replaced, not preserved as multi-provenance. Provenance after a re-import is "last writer wins" — the system can no longer tell that two sources both observed the same message. There is no message_observations join table.
stable_key = filesystem path. ledger_sources.stable_key = normalizedMessagesDbPath means moving or renaming the archive folder creates a new ledger_source for byte-identical content. Conversely, two unrelated archives that happen to share a path (after one is deleted) collide.
Two parallel timestamp encodings in the ledger row. import_batches stores both ISO TEXT (started_at_utc) and INTEGER ms (started_at). Two sources of truth for the same fact is a classic drift hazard.
Three independent Apple→Unix conversion sites (preflight UI, ledger insertion via strftime, working.db conversion via strftime). Any future change risks one path drifting from the others — and the recurring "Jan 2001 / epoch 0" symptoms suggest at least one path NULL-coerces silently.
Hidden coupling between migration ordering and importer order. The migration topological sort assumes ledger has a complete, consistent snapshot. If a future importer is added that violates an FK invariant only mid-batch, no migrator will catch it — they'll happily project bad rows.
Re-entrant ImportExecutionGate keyed by string owner. Re-entrancy by string identity is fragile; if any caller forgets to release, the gate is wedged until app restart with no observable diagnostic. 2. Pipeline Analysis
source → ledger → migration → working.db

Determinism

Ledger insertion: deterministic given input file content (modulo INSERT OR REPLACE clobbering provenance noted above).
Migration: deterministic given ledger state — full-rebuild path (incrementalMode=false) wipes targets via DELETE FROM then re-copies. This is the right default for an archive merge; incremental mode is the riskier path.
Index/search rebuild: deterministic but opaque.
Atomicity

Per-batch ledger import is NOT atomic. Each importer commits its own writes; a crash mid-import leaves a partial batch with status='running'. There is no batch-level wrapping transaction (the whole archive insert is too large for a single sqflite transaction in practice, but there's also no compensating "abandon on failure" cleanup).
Migration is per-table, not per-run. Each migrator's copy phase is its own unit. A failure in messages_migrator after chats_migrator succeeded leaves working.db in a half-projected state — readable but inconsistent until the next full rebuild.
Deletion IS atomic (deleteBatchLedgerData wraps everything in db.transaction). This is the only stage with proper atomic guarantees.
Visibility

Ledger: row-level visibility only for messages_importer.
Migration: row-level visibility only for messages_migrator. ~15 other migrators emit started/succeeded only.
Index rebuild & FTS rebuild: zero visibility.
Net: the user sees ~10% of the actually-running work.
Failure handling

Importers and migrators surface exceptions as failed events, but import_batches.status='failed' rows are not auto-cleaned, and a failed migration leaves working.db in an indeterminate state. Recovery is "user clicks Remove Imported Archive Data and tries again."
Cancellation only checked between chunks; a stuck SQLite statement can't be interrupted.
Weakest stage: the migration orchestrator's post-import full rebuild — longest, least observable, partially atomic, and the place where ledger schema/working schema drift will surface as silent data loss rather than loud failure.

Most likely silent invariant breaks:

GUID collision across sources overwrites provenance.
A migrator's INSERT OR REPLACE masks an upstream FK gap.
Timestamps NULL-coerced to epoch 0 in one of three conversion sites.
An importer added in future that doesn't set batch_id — nothing structurally enforces it at the application layer. 3. Migration Design Critique
"Build working messages" should be — and now partially is — chunked. messages_migrator.dart uses RowProgressReporter with 1000-row chunks. This is the correct shape. The problem is that it is the only migrator doing this. ~15 sibling migrators (handles, participants, chats, attachments, reactions, message_attachments, etc.) are structurally chunkable — they each SELECT FROM ledger.X / INSERT INTO working.X — but report only phase boundaries.
Aggregations (reaction_counts, read_state) are inherently single-shot SQL; phase-level reporting is appropriate, but they should be labelled as such in the UI rather than rendered with the same "indeterminate bar" affordance as a chunkable step.
Index & FTS rebuild is the second-largest opaque block. It runs after the orchestrator and emits no events at all. For a large archive this can dominate wall-clock time and looks identical to a hang.
Full rebuild vs incremental: for archive merges the full rebuild is correct — incremental projection of an arbitrarily-old archive against an existing working.db is a much harder correctness problem (which dependent rows must be invalidated?). The current decision to force incrementalMode=false post-archive-import is sound. Incremental mode should be considered an optimization for the steady-state current_mac path only, not for archive merges.
Conceptually, where progress reporting must exist:
Every copy phase that has a known SELECT COUNT(\*) upstream (i.e., almost all of them).
The index rebuild, broken into per-index phases.
The FTS rebuild, broken into "scan / write / optimize."
Where the current design hides signals:
Migrators that don't mix in RowProgressReporter cannot emit row events even if the orchestrator wanted to render them.
The orchestrator emits phase granularity, not migrator-step granularity, so even fast successive phases collapse to a single UI flash. 4. UI / Workflow Model Critique
The 3-step model (choose → preflight → import) is structurally sound — separating the read-only preview from the destructive run is the right user contract.

Still confusing

"Dry run" terminology in preflight conflates two distinct facts: "how many of these GUIDs already exist in working.db" and "how many already exist in import.db". Users have no mental model for why both numbers exist or which one matters. The right user-level question is "how many new messages will I gain?" — a single number.
"Already projected" is a developer phrase leaked into UI. Users don't know what projection is.
Modal phases are mixed-language. Some are user-facing ("Preparing archive"), some are developer-facing ("Build working messages", "validatePrereqs", "postValidate"). Inconsistent register breaks trust.
Sequential single-running invariant is now correct in code but the cost is that the user sees a long list of upcoming steps with no time estimates — the modal feels long because it looks long.
Misleading

Indeterminate bars on countable steps are a lie of omission — they communicate "we don't know" when in fact the system does know total but isn't passing it through. This is the single biggest trust killer in the current modal.
"Rebuilding indexes" is a single line for what is actually 5–10 distinct sub-operations.
Should be removed / collapsed

Internal phase names (validatePrereqs/postValidate) shouldn't reach the user as visible rows. They are bookkeeping; collapse them into the parent migrator phase.
The activity log and the phase list duplicate information — one should be primary, the other a disclosure.
Should be added at the design level

A single-number summary in preflight ("This will add N new messages from M new chats") is the only number that matches the user's intent.
An end-of-run summary ("Imported N new messages, deduplicated D, failed F") closes the loop the modal currently leaves open. 5. Progress & Observability
This is the area with the largest gap between current and correct.

Inherently measurable (must be exact X / Y):

All copy phases that have a corresponding SELECT COUNT(\*) from the ledger source — i.e., handles, participants, chats, chat_to_handle, messages, attachments, message_attachments, reactions, message_read_marks, recovered_unlinked_messages, recovered_unlinked_attachments.
Per-index rebuild (each CREATE INDEX is one unit).
FTS document insertion (one per message).
Inherently estimation / phase-based:

Aggregation migrators (reaction_counts, read_state) — short, opaque, phase-based is acceptable if labelled as such.
validatePrereqs and postValidate phases — phase-based, and ideally hidden from the user.
Time-based fallback only justified for:

FTS OPTIMIZE if it runs as a single SQLite operation.
macOS file picker / folder validation.
Why indeterminate progress is harmful here

The user has just told the system "this is a multi-gigabyte historical merge of years of data." Their default prior is "this will take a while." An indeterminate bar in that context is indistinguishable from a hang and forces the watchdog (60s/3min) to do the job that the progress reporter should be doing.
Indeterminate bars destroy the value of the cancellation button: the user doesn't know whether to cancel because they don't know whether progress is being made.
They obscure performance regressions: a migrator that becomes 10× slower will look identical to one that is healthy.
A correct conceptual observability model

Every phase declares its measurability up-front ("countable / aggregating / opaque") so the UI can choose the right affordance and never lie.
Two-level progress: overall (which migrator of N) + inner (rows of total in this migrator). Today the modal collapses both to a single bar.
A structured event stream is the source of truth, not the UI state. The orchestrator already emits events; the gap is that most migrators have nothing meaningful to put in them. Fix at the source, not at the renderer.
Persist the last successful run's per-step durations. On the next run, those durations become the basis for an informed fallback estimate when a step is genuinely opaque.
End-state reconciliation: after the run, surface counts (rows imported / migrated / deduped / failed) per migrator. This is the single most trust-restoring artifact and the system already collects most of it (rows_seen, rows_inserted, rows_deduplicated, rows_failed on import_batches) but does not display it. 6. Data Lifecycle & Cleanup
Currently strong

deleteBatchLedgerData is transactional, FK-ordered, and complete. This is the one stage with proper atomicity in the entire pipeline.
Batches carry status (running/succeeded/failed/cancelled), which gives a basis for "show me failed batches."
historical_archive_sources retains last-import metadata so the UI can show a meaningful "you imported this on date X" without re-scanning.
Missing

No automatic cleanup of failed/cancelled batches. They accumulate as ledger noise. There is no "garbage collect failed batches older than N days."
No "abandon batch in flight" semantics. A crash mid-import leaves status='running' permanently — there is no startup sweep that promotes orphan running rows to failed.
No re-import safety net. A user who re-imports the same archive folder gets a new import_batch row, an INSERT OR REPLACE storm against unchanged GUIDs, and silently overwritten provenance. The user has no way to ask "did this re-import actually change anything?"
No content fingerprint. Same archive at a different path = treated as new source. Different archives at same path (after delete/replace) = treated as same source.
Working.db has no drop-and-skip-rebuild path. "Just delete this archive's projection" requires a full re-projection of everything, because working.db rows don't carry source_id/batch_id for selective deletion. This may be intentional (working.db as pure projection) but it makes "remove one archive" an expensive operation.
Could become dangerous over time

Accumulated failed batches with dangling running status will eventually confuse status displays and operators.
INSERT OR REPLACE-style re-import will silently lose the fact that "this message was first seen on date X via source Y" once a second source observes the same GUID.
No retention policy on import_batches history — it grows unbounded. 7. Top 5 Risks
Provenance erosion via INSERT OR REPLACE on shared GUIDs.
Why it matters: the entire provenance model exists to answer "where did this row come from?" The current dedup strategy actively destroys that answer whenever two sources see the same message. Manifests as: user imports an archive, then later the live current_mac import re-observes the same message, and provenance flips to current_mac. The archive batch now appears to "have imported" rows that are no longer attributed to it. Per-source delete becomes lossy.

Silent partial state after a mid-run failure.
Why it matters: a crash, OOM, or SIGKILL during migration leaves working.db in a half-projected state and the batch in status='running' forever. There is no boot-time sweep, no "this projection is incomplete" marker. The app will start up and serve queries against inconsistent data. Manifests as: missing chats, orphan attachments, search results that point to nonexistent messages.

Opaque long-running steps that look identical to hangs.
Why it matters: the watchdog (60s/3min) is doing the job that progress reporting should be doing. Real users on real archives will hit "may be stuck" warnings on healthy runs and either cancel valid imports or ignore the warning on genuine hangs. This is a trust- and data-integrity problem, not just a UX issue.

Three divergent timestamp conversion sites.
Why it matters: the recurring "Jan 2001" / epoch-0 symptom indicates at least one path NULL-coerces silently. Each conversion site can drift independently across future changes. Manifests as: heatmap clusters at 2001-01-01, ordering anomalies, search-by-date returning nonsense, and — worst — silent mis-ordering of messages within a thread.

stable_key = filesystem path coupling.
Why it matters: user moves their archive to an external drive → re-import creates a duplicate ledger_source, doubles the batch history, and either silently dedups via GUID (best case) or surfaces both sources in any per-source UI (worst case). User has no way to merge the two sources. Long-term this turns the provenance table into noise.

8. High-Level Improvement Plan
   Architecture-level only. Sequenced for stabilization first, then trust, then evolution.

Tier 1 — Stabilize (must precede everything else)

Boot-time batch reconciliation. On app start, any import_batches.status='running' with no live owner is promoted to failed with a recorded reason. Closes the orphan-batch hole.
Single canonical timestamp converter. Reduce the three Apple/Unix conversion sites to one well-tested utility used by preflight, importers, and migrators alike. The recurring epoch-0 symptom should be diagnosed against this single point.
Migration completion marker on working.db. A simple projection_state row recording (last successful migration ID, ledger snapshot fingerprint, completion timestamp). On startup, mismatch ⇒ working.db is treated as suspect and a rebuild is offered.
Tier 2 — Observability (the user-trust layer)

Every migrator declares its measurability. Each migrator self-classifies as countable | aggregating | opaque and exposes a total accessor where countable. The orchestrator can then route events to the right UI affordance with no per-migrator UI code.
Adopt the chunked-progress pattern uniformly. Bring the remaining ~15 chunkable migrators in line with messages_migrator's pattern. This is mechanical, not architectural — but the decision to do it everywhere is architectural.
Make the index/FTS rebuild a first-class orchestrator phase, not a post-orchestrator black box. It's the longest opaque block left.
End-of-run reconciliation surface. Display the rows_seen / inserted / updated / deduplicated / failed already collected on import_batches. Closes the loop the modal currently leaves open.
Tier 3 — Workflow & Terminology

Single-number preflight summary ("This will add N new messages from M new chats") with the dual GUID-overlap counts available behind a "details" disclosure.
Strip developer terminology from user-visible phase names. Hide validatePrereqs/postValidate from the user; they're internal bookkeeping.
Two-level progress UI (overall step N of M + inner row count) replacing the single-bar collapse.
Tier 4 — Data model evolution (do not start until Tier 1–2 are stable)

Replace INSERT OR REPLACE on shared GUIDs with an additive observation model. Conceptually: rows have multiple observations (source_id × batch_id) without losing earlier ones. This is a real schema change and should not be undertaken until provenance accuracy is demonstrably needed in production.
Content-addressable stable_key. A cheap fingerprint (e.g., chat.db size + earliest/latest message timestamps + message count) decoupled from filesystem path. Backwards-compatible: keep path as source_label, use fingerprint as stable_key.
Retention / GC policy for import_batches. Old failed/cancelled rows should age out on a documented schedule.
Explicitly out of scope

Rewriting the orchestrator. Topological sort + per-phase events is the right shape.
Replacing working.db as a projection. The "pure projection" model is correct; the issues are at the edges, not in the model.
Making projection incremental for archive merges. Full rebuild is the right default; incremental is a future optimization for the steady-state path only.
