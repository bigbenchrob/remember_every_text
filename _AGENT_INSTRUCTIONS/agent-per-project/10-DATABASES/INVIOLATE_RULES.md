---
tier: project
scope: inviolate-rules
owner: 10-DATABASES
last_reviewed: 2026-06-20
source_of_truth: doc
tests: []
---

# 🔥 INVIOLATE RULES — Data Integrity & Database Contracts

These rules are **absolute constraints**. They apply to every agent, every session, and every code change — regardless of convenience, velocity, or apparent benefit. Violating any rule below is a **hard failure** equivalent to data corruption.

---

## Rule 1: Overlay / Working DB Separation

> **Canonical doc:** [`07-overlay-database-independence.md`](07-overlay-database-independence.md)

- User intent → overlay DB **ONLY**
- Source-scoped import → `macos_import_ss.db` **ONLY**
- Graph projection → `working_ss.db` **ONLY**
- Archive-source metadata → overlay DB **ONLY**
- Retired `working.db` → historical file/schema inventory only; no ordinary
  app provider remains
- Providers merge at read time; overlay wins on conflict
- ❌ NEVER dual-write to both overlay AND graph/retired cleanup inventory
- ❌ NEVER have graph projection or import read or consult overlay DB
- ❌ NEVER feed overlay-owned archive-source metadata back into graph
  projection/import semantics
- ❌ NEVER snapshot overlay before projection/import/metadata maintenance then
  restore into graph/retired cleanup inventory
- ❌ NEVER store user-intent flags on graph/retired cleanup tables rebuilt from source
  data

---

## Rule 2: Record-Level Data Fidelity — NO Suppression of Anomalous Records

> **This is a data-integrity firewall. It exists because an agent once attempted to hide empty-text messages with `SizedBox.shrink()` instead of investigating the root cause. That instinct — "the data looks wrong, let me hide it" — is the single most dangerous thing an agent can do in this codebase.**

### The Contract

**Every record that exists in a source database MUST be faithfully imported, projected, and rendered.** No record may be silently dropped, filtered, hidden, collapsed, or replaced with a placeholder at any layer of the system — import, graph projection, explicit recovery/diagnostic tooling, provider, or UI — unless the user has explicitly requested that specific filtering behaviour through a dedicated, visible user-facing control.

### What This Means In Practice

1. **Import pipeline**: If a row exists in macOS `chat.db` or the AddressBook, it MUST appear in source-scoped import on either the normal path or a documented recovery/orphan path. The importer may flag it, annotate it, or log a warning — but it MUST NOT skip it silently.

2. **Projection pipeline**: If a row exists in source-scoped import, it MUST appear in graph projection or a documented recovery/orphan graph path (subject only to documented, intentional JOIN semantics). A projector may add metadata columns to describe anomalies — but it MUST NOT filter the row out.

3. **Retired cleanup/diagnostic files**: Old retired `macos_import.db` / `working.db`
   pairs must remain interpretable for recovery, audit, and diagnostic tooling.
   Do not silently discard rows when writing explicit retired-file inspection
   or recovery utilities. Do not reintroduce retired projection as an ordinary
   app path.

4. **UI / Presentation layer**: If a record exists in graph projection and falls within the user's current query scope, it MUST be rendered visibly. The widget may render it with a fallback appearance (e.g., a muted "no text content" indicator) — but it MUST NOT return `SizedBox.shrink()`, an empty container, zero-height box, or any construct that makes the record invisible.

5. **Providers / data layer**: A provider may enrich, merge, or annotate records — but it MUST NOT silently exclude records that the underlying query returned.

### Forbidden Patterns

| Layer | ❌ Forbidden | ✅ Required Instead |
|-------|-------------|-------------------|
| Importer | `if (text == null) continue;` | Import the row; log that text is null |
| Projector/migrator | `WHERE text IS NOT NULL` filter | Project all rows; add audit/status entry for null-text count |
| Widget | `if (message.text.isEmpty) return SizedBox.shrink();` | Render a visible indicator: *"(no text content)"* or similar |
| Provider | Filtering out "empty" records before returning list | Return all records; let UI decide how to present them |
| Any layer | Silently swallowing exceptions during record processing | Log the exception and include the record with error metadata |

### Why This Is Non-Negotiable

- **Data loss is invisible.** If 50,000 messages exist in macOS Messages but only 40,000 appear in the app, the user may never notice the discrepancy — until they search for a specific conversation and it's gone.
- **Anomalies are diagnostic signals.** A message with NULL text isn't broken — it may be an attachment-only message, a reaction carrier, a system event, or evidence of an import bug. Hiding it destroys the signal.
- **Suppression masks bugs.** The "empty bubble" that prompted this rule turned out to be a data pipeline issue where message text was being lost during migration. Hiding the symptom would have hidden the bug indefinitely.
- **Users trust completeness.** This application's core promise is that it faithfully preserves the user's messaging history. Silently dropping records breaks that promise.

### The Only Exceptions

1. **Explicit user-facing filter controls** (e.g., "Hide system messages" toggle) where the user consciously chooses to filter — and can reverse that choice.
2. **Pagination / lazy loading** where records exist but are not yet fetched — they MUST become visible when scrolled into view.
3. **Documented, intentional JOIN semantics** in projection where a record cannot be projected because a required foreign-key target does not exist — these MUST be counted in graph health/status or audit logs.

### When You Encounter Anomalous Data

The correct response is **always investigation, never concealment**:

1. **Log it** — Write a diagnostic entry to the audit log with full details
2. **Render it** — Show the record in the UI, even if imperfectly
3. **Flag it** — If possible, add visual indication that something is unusual
4. **Investigate it** — Trace the record back through graph projection → import → source to find where the anomaly originated
5. **Fix the root cause** — If the anomaly is a bug, fix the pipeline; don't paper over it in the UI

---

## Rule 3: Database Access Via Centralized Providers Only

- **Source-scoped import ledger**: physical database construction is
  `sourceScopedImportDatabaseProvider` in `essentials/db`, but ordinary source
  import semantics should consume
  `ref.watch(sourceScopedImportLedgerProvider.future)`. Direct use of the
  physical provider is limited to central DB construction, reset/diagnostic
  composition, graph projection repository composition, and archive attachment
  snapshot boundaries.
- **Working graph DB**: `ref.watch(driftConversationGraphDatabaseProvider.future)`
- **Archive-source metadata**: `ref.watch(overlayDatabaseProvider.future)` via
  named overlay-owned services
- **Retired import/working DBs**: no central app providers remain; use explicit
  read-only diagnostic boundaries only when retired-file inspection is
  deliberately required
- **Overlay DB**: `ref.watch(overlayDatabaseProvider.future)`
- ❌ NEVER instantiate database classes directly
- ✅ Infrastructure repositories may open source/probe SQLite files directly
  only for named one-off read-only queries, and must close/dispose the handle
  before returning
- ❌ NEVER turn a one-off source/probe open into a cached DB handle, hidden
  provider, or feature-level database shortcut
- **Reason**: Multiple connections to the same SQLite file cause locking failures

---

## Rule 4: Apple Timestamp Conversion Via `DateConverter` Only

> **Canonical doc:**
> [`13-apple-timestamp-conversion.md`](13-apple-timestamp-conversion.md)

- Every Apple timestamp must be normalized and converted by
  `lib/core/util/date_converter.dart`.
- Historical Messages databases may store Apple-epoch **seconds** while modern
  databases store Apple-epoch **nanoseconds**. `DateConverter` owns that
  distinction.
- Import, preflight, projection, diagnostics, providers, and presentation must
  not reproduce epoch offsets, unit thresholds, multiplication/division, or
  SQLite `unixepoch` formulas.
- If a new Apple encoding is discovered, extend `DateConverter` and its focused
  tests. Do not add a second conversion path.
- This rule is mechanically protected by
  `test/architecture/apple_timestamp_conversion_authority_test.dart`.

---

## Enforcement

These rules are enforced by:
- Code review (human and agent)
- Graph health/status reports and retired-file diagnostics compare source vs destination counts
- The anti-pattern lists in `.github/copilot-instructions.md` and `AGENTS.md`
- This document, which agents MUST read before modifying any database, import, migration, or data-rendering code
