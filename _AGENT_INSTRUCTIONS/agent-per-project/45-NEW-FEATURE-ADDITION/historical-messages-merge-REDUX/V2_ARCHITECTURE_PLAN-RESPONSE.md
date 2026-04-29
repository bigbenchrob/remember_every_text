🔴 1. You MUST lock the schema decision

Right now it says:

may use existing import DB OR parallel archive-import DB

That is too open.

This is where the agent can botch things again.

You should force this decision:

👉 Use the existing import DB (db-import), not a parallel DB

Why:

- you already have a canonical ledger there
- migrators already expect that shape
- avoids cross-DB attach/detach complexity
- avoids replay coordination between two ledgers

Add this guardrail:

Archive rows must be written into the existing canonical import ledger with provenance metadata. A parallel archive-import database is not permitted in v2.

⸻

🔴 2. You must define the canonical timestamp type

Right now you say “numeric,” but that’s not enough.

The agent could still choose:

- Apple epoch
- Unix seconds
- milliseconds

You need one.

Recommendation:

👉 Use Unix epoch seconds (INTEGER)

Then:

- live import converts Apple → Unix once
- archive import converts Apple → Unix once
- everything downstream is consistent

Add this:

All timestamps in the canonical ledger must be stored as Unix epoch seconds (INTEGER). Source-specific timestamp formats must be normalized at import time.

⸻

🔴 3. You need an explicit dedupe contract

Right now it’s implied, but not formalized.

You need to say:

- dedupe key = message GUID
- dedupe happens at ledger insertion
- migrator does NOT dedupe again

Add this:

GUID-based deduplication must occur at the canonical ledger insertion boundary. Migration must treat the ledger as already deduplicated and must not reapply dedupe logic.

⸻

🔴 4. You need to forbid cross-DB reads during migration

This caused your SQLite issues.

Even though not explicitly stated, the plan still allows it implicitly.

Add this:

Migration must not read directly from external or attached databases. All source data must be fully materialized into the canonical ledger before migration begins.

⸻

🔴 5. You need a strict “no partial state” rule

This caused:

- stuck UI
- empty picker
- heatmap freeze

You mention it indirectly, but not as a rule.

Add:

At no point may partial ledger ingestion or partial migration leave the system in a state where providers read inconsistent working data. Migration must be atomic with respect to working.db visibility.

⸻

🔴 6. You need a clear “what triggers migration” rule

Right now it’s implied but not explicit.

Important question:

After archive import:

- does migration run immediately?
- or queued?
- or merged with live import?

Recommendation:

👉 Archive import triggers a full migration cycle

Add:

Archive import must trigger a full migration cycle through the canonical migration orchestrator. Archive rows must not be projected independently of the normal migration flow.
