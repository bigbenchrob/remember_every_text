---
tier: project
scope: source-scoped-graph-migration
status: interim-report
last_reviewed: 2026-06-06
depends_on:
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - 78-GRAPH-MIGRATION-PAUSE-AND-REMAINING-WORK.md
  - 79-INDEPENDENT-ARCHITECTURAL-REVIEW-OF-GRAPH-MIGRATION-STATE.md
---

# 80 - Graph Migration Interim Progress Report

## Purpose

This report records progress made after the June 2 pause/review documents:

- `78-GRAPH-MIGRATION-PAUSE-AND-REMAINING-WORK.md`
- `79-INDEPENDENT-ARCHITECTURAL-REVIEW-OF-GRAPH-MIGRATION-STATE.md`

Those documents marked the transition from architectural proof to production
ownership. Since then, work has focused on retiring compatibility paths,
making graph lifecycle behavior production-owned, confirming live incremental
updates, and aligning stale documentation with the graph-era architecture.

## Executive Summary

The graph migration has advanced from "mostly proven" to "ordinary production
path." The main app-facing surfaces now operate from:

```text
chat.db / AddressBook
→ macos_import_ss.db
→ working_ss.db
→ graph read models
→ Message Evidence Spine
→ shared presentation
```

The retained legacy import/projection/database systems are no longer ordinary
UI data owners. Their remaining role is compatibility, archive/recovery
support, diagnostics, historical storage, or test context.

The most important practical milestone is that live `chat.db` polling now
updates the source-scoped graph directly. Recent real-data testing confirmed
that single-message intake is fast, graph-backed search finds newly sent
messages, contact/conversation views update from graph data, and `working.db`
is no longer modified by the live update path.

## Major Completed Work Since Document 78/79

### 1. Live Update Lifecycle Moved to the Graph

The live `chat.db` monitor no longer runs the retained legacy import/migration
tail after a graph build.

The live update path now performs:

1. source change detection
2. source-scoped import
3. graph projection
4. graph attachment archive by source-row range
5. graph freshness cursor advancement
6. shared message-evidence invalidation

The old `LegacyCompatibilityMaintenanceService` was removed. Live update
diagnostics now show graph build status, build owner, imported/projected graph
message counts, monitor cursor rowid, last change detected, build duration,
and per-stage timings.

### 2. Manual/Onboarding Lifecycle Now Builds the Graph Directly

First-run onboarding and settings-triggered reimport now call the central graph
build controller after derived-data reset. They no longer drive setup through
the old import-control view model's import/migration path.

The onboarding progress and readiness surfaces now speak in graph setup terms:

- source probes
- source-scoped import readiness
- graph build/readiness
- persisted overlay failure summaries
- maintenance lock state

Legacy import/migration progress models were removed from onboarding-facing
code. Backward-compatible persisted failure keys remain where necessary, but
they are mapped at the read boundary into graph setup language.

### 3. Retained Projection Was Renamed, Bounded, Then Retired

During the migration, the old presentation-owned migration entry points were
first replaced with an explicit retained compatibility boundary:

```text
RetainedLegacyArchivePipeline.rebuildLegacyProjectionAndGraph(...)
```

That name was intentionally narrow. It meant:

- retained projection could be used only for archive/recovery compatibility.
- it is not the ordinary app data path.
- it should not be called from live polling.
- it should not be used as a feature-level read shortcut.

That execution path has since been retired from production code after
Historical Archives import/removal moved to source-scoped archive graph
services. Retained `macos_import.db` / `working.db` references now mean storage,
metadata, read-only diagnostics, reset cleanup, or compatibility-key lookup, not
a retained import/projection fallback.

The graph status panel is now graph import/reset diagnostics. It no longer
presents migration as a normal user-facing setup mode.

### 4. Ordinary Reads No Longer Open Legacy Working/Import Providers

The June 4 dependency scan found no ordinary user-facing feature/read surface
opening:

- `driftWorkingDatabaseProvider`
- `sqfliteImportDatabaseProvider`

Remaining direct legacy provider access is classified as:

- central provider construction
- retained archive/import execution
- onboarding reset/maintenance
- database health/support-bundle diagnostics
- historical archive settings workflows
- retained `db_migrate` compatibility internals/tests

This satisfies the central ordinary-read migration goal: ordinary evidence,
search, contact identity, conversation, and handle surfaces are graph-backed.

### 5. Message Evidence Spine Became the App-Facing Presentation Path

Message-bearing surfaces now converge through the graph-backed Message
Evidence Spine rather than source-specific renderers.

Confirmed ordinary paths include:

- contact all messages
- contact handle-filtered messages
- contact by conversation
- conversation messages
- unfamiliar sources / handle evidence
- recovered deleted messages
- recovered no-handle messages
- global/search contexts

The important invariant remains:

```text
source-specific scopes are allowed;
source-specific evidence presentation is not.
```

Timeline-like scopes preserve a full logical skeleton for heatmap and jump
coordination. Hydration and media loading are windowed, but the selected
message universe is not capped to the latest-N messages.

### 6. Contact and Handle Identity Were Graph-Native

Contact/handle identity reads now come from graph facts plus overlay intent.

Current display rules are:

1. user display-name override wins
2. known graph/imported contact identity follows
3. raw handle appears only as fallback or explicit handle-scope metadata

The old short-name/nickname display precedence has been deprecated. Manual
handle links write overlay-only intent and are read through graph/overlay
identity bridges rather than legacy participant reconstruction.

### 7. Search Is Graph-Native

Search now selects graph message evidence directly.

The active search spine is:

```text
SearchService
→ GraphSearchRepository
→ message_ss_id evidence scopes
→ Message Evidence Spine
```

Retained `working.db` FTS/index rebuild mechanics are not the ordinary search
path. Graph-backed search was manually verified with a newly sent unique
string, which appeared and highlighted correctly in both conversation and
contact heatmap/evidence views.

### 8. Recovered Message Presentation Cut Over to Graph Evidence

Recovered deleted/no-handle message views now route through graph-backed
recovered/orphan evidence and the shared Message Evidence Spine.

The retained legacy recovered repository and parity diagnostic were used as
cutover gates and then retired from production presentation. Legacy recovered
tables may remain as historical storage until broader legacy database
retirement, but they are not the active evidence source.

### 9. Incremental Rich-Text Enrichment Was Optimized

Single-message graph intake was initially slowed by rich-text enrichment.
That path was corrected so new-message enrichment uses the imported
`attributed_body_blob` and processes only the relevant rows.

Current observed behavior:

- single-message intake is fast.
- message bodies are restored correctly when text lives in attributed body.
- `stage_enrich_missing_text` is no longer a graph-lifecycle bottleneck.

### 10. New-Message UX Was Restored

The graph evidence surface initially redrew and scrolled to the bottom on
updates, which lost user context. The current behavior restores the better
legacy interaction:

- if the viewport is already at the bottom, new messages appear naturally.
- if the user is mid-list, the app does not force-scroll.
- a blue bottom glow indicates new evidence is waiting.
- heatmap and evidence surfaces no longer disappear into full reload spinners
  during normal graph invalidation.

### 11. Presentation and Terminology Were Cleaned Up

User-facing and diagnostic wording was updated so ordinary app surfaces no
longer describe graph work as "migration" or "working.db" activity.

Examples:

- onboarding speaks of graph build/projection.
- pipeline incidents label retained projection explicitly.
- graph health/status surfaces show physical DB names only where useful.
- retained projection terminology is preserved only for old compatibility
  reports, not current execution.
- archived/recovered flows are labeled by evidence behavior, not by old
  implementation tables.

### 12. Large Amounts of Dead Legacy Shell Code Were Retired

Retirement work removed or demoted unused shells and placeholders including:

- obsolete import/migration panel routes and modes
- obsolete import status precheck services
- dead `db_migrate` scaffolding
- unused contact aggregates with pinned terminology
- unused manual handle-link domain entity
- empty repository-interface placeholders
- unused reactions feature shell
- placeholder attachment/chat/handle "coming soon" shells
- superseded handle settings and placeholder cassette branches
- duplicate chat heatmap timeline model
- unused generic attachment model
- duplicate settings/info resolver
- unused AddressBook presentation/candidate-selection shells

AddressBook functional discovery and verification remain active. The removed
AddressBook pieces were unused candidate-selection/presentation layers, not the
runtime resolver needed by onboarding and source-scoped contact import.

### 13. Active Documentation Was Brought Into Alignment

After code migration, stale documentation became the main source of future
drift risk. A documentation cleanup pass updated active and historical docs to
distinguish:

- current source-scoped graph production path
- retained legacy archive/recovery compatibility
- historical planning records
- superseded `working.db`/participant/short-name mechanics

Updated areas include:

- messages feature docs
- search docs
- handle docs
- chat docs
- import/onboarding lifecycle docs
- database access docs
- overlay/database inviolate rules
- attachment archive/recovery docs
- historical merge/recovery/search plans
- contact menu/picker/virtual-contact planning docs
- root agent quick-reference files

The rule now repeated across docs is:

```text
preserve semantic intent;
do not recreate legacy schema or identity shape.
```

## Current State

### Production Path

The production path for ordinary app use is now graph-first:

- source-scoped import for source facts
- conversation graph projection for app facts
- overlay for user intent
- graph read repositories for feature data
- Message Evidence Spine for message surfaces
- shared header/row/media presentation for evidence

### Retained Storage And Compatibility Path

Retained database files and compatibility key readers are still present where
removal would risk data integrity:

- archive/recovery metadata and key compatibility
- historical retained storage
- support diagnostics
- reset/maintenance safety
- tests that exercise retained compatibility internals

They should remain named and bounded until their storage-retirement criteria are
explicitly closed. They should not be treated as an available retained
import/projection execution path.

### User-Visible Behavior

Recent manual checks confirmed:

- app still functions after cleanup.
- contacts and conversations remain graph-backed.
- contact picker/hero/favourites read overlay intent correctly.
- single-message polling imports and projects quickly.
- newly sent messages and attachments appear in graph evidence views.
- graph-backed search finds freshly sent terms.
- handle filtering and heatmap coordination work.
- recovered message views remain intact.

## Remaining Work

### 1. Final Legacy Storage Retirement Decision

The largest remaining question is not ordinary UI behavior. It is how and when
to retire or preserve the remaining legacy database files and historical
tables.

This should be conservative because retained storage still helps protect
archive/recovery history.

### 2. Archive/Recovery Completion

Attachment archive and historical recovery remain the most data-sensitive
systems. The current graph can represent attachments and recovered/orphan
evidence, but broader archive-source ingestion and final archive identity
cleanup should proceed only after explicit review.

### 3. Documentation Sweep Completion

Most high-risk active docs are now aligned. Some older feature-planning folders
may still contain stale examples. These are lower risk if they are historical,
but the safest practice is to keep adding clear current conformance notes when
such docs are encountered.

### 4. Final Dependency Scan and Retention Register

Before declaring graph migration complete, run a final dependency matrix update
that classifies every remaining legacy reference as:

- deleted
- active graph path
- retained archive/recovery compatibility
- diagnostic/support only
- historical documentation only

### 5. Release Readiness

Before a release-oriented merge/build, run:

- code generation check if needed
- full analyzer
- focused graph/search/contact/evidence/recovery tests
- manual smoke test of core surfaces
- data-folder backup guidance for archive-sensitive users
- changelog/version update if the work is release-bound

## Recommended Next Step

Pause aggressive deletion and perform a final retention-oriented dependency
scan. The ordinary graph path is functioning well; the next valuable work is to
confirm that every remaining legacy reference is either intentionally retained
or safely removable.

The highest-risk area remains archive/recovery storage, not ordinary
conversation/contact/search UI.

## Bottom Line

Since the last pause report, the migration has moved materially closer to
completion:

- graph lifecycle is now production-owned.
- live incremental updates are graph-first.
- ordinary reads are graph-backed.
- search/contact/recovered evidence are graph-native.
- message presentation is unified.
- dead legacy shells have been retired.
- stale docs now mostly point toward the current architecture.

The project is no longer proving the graph architecture. It is finishing the
last retention and archive/recovery decisions needed to retire the old system
without losing historical data-integrity protections.
