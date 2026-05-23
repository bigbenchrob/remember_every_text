# Constitutional Audit: `lib/essentials/conversation_graph/`

Date: 2026-05-23

Scope:

- `lib/essentials/conversation_graph/`
- Architectural evaluation only
- No implementation changes authorized by this document

Governing documents:

- `_AGENT_INSTRUCTIONS/agent-per-project/00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/20-COMMON-DRIFT-PATTERNS.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/30-IMPLEMENTATION-CHECKLIST.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/40-ARCHITECTURAL-REVIEW-PROTOCOL.md`

## Executive Assessment

`lib/essentials/conversation_graph/` is architecturally directionally correct: it expresses source-scoped graph identity, materializes explicit graph edges, keeps most read-side SQL in infrastructure repositories, and avoids presentation-layer rendering or imperative UI repair. The main constitutional problem is on the projection/mutation side: multiple application-layer projector classes directly depend on `sqflite`, import/working database wrappers, transactions, inserts, updates, deletes, and row-level query mechanics. That is an architectural defect under the DDD and RIO rules, even though the feature currently works. The second major pressure is graph semantic duplication: conversation summary, contact graph, and conversation repository queries repeat participant-count, participant-label, latest-message, attachment-count, and text-search traversal semantics in several places. This is currently functional, but it risks hidden divergence as the graph grows. The repair path should preserve the strong source-scoped graph spine while moving persistence mechanics behind infrastructure repositories, making projection semantics explicit through application-level services/integrators, and consolidating reusable graph traversal semantics.

## Constitutional Baseline

The relevant constitutional invariants are:

- SQL and SQLite mechanics belong only in infrastructure.
- Application owns orchestration, semantic interpretation, graph traversal coordination, and projection composition, but not raw persistence implementation.
- Readers observe facts; integrators derive meaning; orchestrators coordinate action.
- Visible UI must be derived from semantic state, not repaired imperatively.
- Source-scoped identity is foundational and must not be bypassed by GUID shortcuts or hidden deduplication.
- Conversations are first-class graph projections; conversation reconstruction chains should not reappear locally.
- Semantic preservation is not field preservation.

## Findings

### Finding 1: Application projectors directly own SQLite persistence mechanics

Classification: ARCHITECTURAL DEFECT

Constitutional Section:

- Domain-Driven Design: Application layer must not own raw SQL, SQLite mechanics, or persistence implementation.
- Common Drift Pattern: SQL Leaking Into Application Layer.
- RIO: orchestrators/projectors must not collapse into persistence mechanics.

Current behavior:

Several `application/` projectors import `package:sqflite/sqflite.dart`, hold `ImportDatabase` and `WorkingDatabase`, read rows from import tables, open transactions, and insert/update/delete working rows directly. Examples:

- `lib/essentials/conversation_graph/application/messages/message_projector.dart:1`
- `lib/essentials/conversation_graph/application/messages/message_projector.dart:22`
- `lib/essentials/conversation_graph/application/messages/message_projector.dart:26`
- `lib/essentials/conversation_graph/application/messages/message_projector.dart:49`
- `lib/essentials/conversation_graph/application/messages/message_projector.dart:73`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:1`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:27`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:34`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart:1`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart:26`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart:33`
- `lib/essentials/conversation_graph/application/contacts/contact_projector.dart:1`
- `lib/essentials/conversation_graph/application/contacts/contact_projector.dart:28`
- `lib/essentials/conversation_graph/application/attachments/attachment_projector.dart:1`
- `lib/essentials/conversation_graph/application/attachments/attachment_projector.dart:26`
- `lib/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projector.dart:1`
- `lib/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart:1`
- `lib/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projector.dart:1`

Why this is dangerous:

The application layer now knows table names, column names, transaction mechanics, conflict algorithms, and row materialization details. That makes projection rules hard to reason about separately from persistence, encourages future semantic fixes to be patched inside row loops, and weakens the architecture's ability to evolve the graph schema without application churn.

Architectural entropy risk:

- Authority leakage
- Layer collapse
- Hidden coupling
- Shortcut-driven persistence patches
- Projection semantics embedded in database loops

Correct architectural direction:

Application projectors should describe semantic projection intent and call repository abstractions. Infrastructure should own row selection, transactions, inserts, updates, deletes, conflict handling, and schema-specific mechanics.

Proposed repair strategy:

1. Introduce application-level repository interfaces for each projection concern, or one narrowly scoped projection repository per aggregate-like graph surface.
2. Move all `sqflite`, `ImportDatabase`, `WorkingDatabase`, `Transaction`, `ConflictAlgorithm`, and table/column mechanics into infrastructure implementations.
3. Keep application projectors as use-case coordinators/integrators that return explicit projection reports.
4. Add tests at the application boundary using fake repositories, and keep schema/persistence tests against infrastructure.

Files likely requiring modification:

- `lib/essentials/conversation_graph/application/messages/message_projector.dart`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart`
- `lib/essentials/conversation_graph/application/contacts/contact_projector.dart`
- `lib/essentials/conversation_graph/application/attachments/attachment_projector.dart`
- `lib/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projector.dart`
- `lib/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart`
- `lib/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projector.dart`
- Corresponding provider files under `application/**`
- New infrastructure repository files under `lib/essentials/conversation_graph/infrastructure/repositories/`

### Finding 2: Projection providers act as composition roots but live in application and bind directly to infrastructure

Classification: ARCHITECTURAL RISK

Constitutional Section:

- DDD: application layer depends on abstractions, not DB mechanics.
- Common Drift Pattern: Repository Placed Beside Caller.

Current behavior:

Application providers instantiate projectors by watching infrastructure database providers and passing concrete database wrappers into application classes. Examples:

- `lib/essentials/conversation_graph/application/messages/message_projector_provider.dart:11`
- `lib/essentials/conversation_graph/application/messages/message_projector_provider.dart:12`
- `lib/essentials/conversation_graph/application/chats/chat_projector_provider.dart:11`
- `lib/essentials/conversation_graph/application/contacts/contact_projector_provider.dart:11`
- `lib/essentials/conversation_graph/application/chat_summaries/chat_summary_provider.dart:14`
- `lib/essentials/conversation_graph/application/chat_summaries/chat_summary_provider.dart:16`
- `lib/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart:13`
- `lib/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart:15`

Why this is dangerous:

The provider layer is becoming an implicit composition root without an explicit architectural rule. For read providers, the repository abstraction boundary is mostly intact. For projector providers, concrete database dependencies leak directly into application constructors. If this pattern spreads, application providers become a sanctioned bypass around DDD boundaries.

Architectural entropy risk:

- Ambiguous ownership
- Infrastructure/application coupling
- Local composition shortcuts
- Future difficulty replacing persistence implementations

Correct architectural direction:

Provider wiring may act as a composition root only if it preserves the dependency rule: application services receive abstractions, while infrastructure providers create concrete implementations. The composition-root pattern should be explicit and consistent.

Proposed repair strategy:

1. After projector persistence is moved behind interfaces, have application providers depend on repository/provider abstractions rather than database wrappers.
2. Consider moving concrete repository binding providers to infrastructure, with application providers watching abstracted service providers.
3. Document the approved composition-root pattern for essentials spines.

Files likely requiring modification:

- `lib/essentials/conversation_graph/application/*/*_provider.dart`
- `lib/essentials/conversation_graph/application/conversation_graph_build_service_provider.dart`
- New or adjusted infrastructure repository provider files

### Finding 3: Handle canonicalization is embedded inside the persistence projector

Classification: ARCHITECTURAL RISK

Constitutional Section:

- RIO: integrators derive meaning; projectors/orchestrators coordinate action.
- DDD: semantic interpretation must not be buried in persistence mechanics.
- Source-scoped graph architecture: semantic layers may interpret the graph but must not destabilize occurrence identity.

Current behavior:

`HandleProjector` both writes handles and derives canonical handle groups/aliases in the same class. It reads working handles, groups by normalized identifier, scores canonical preference, deletes alias tables, and rewrites canonical alias rows:

- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:45`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:54`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:60`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:73`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:77`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:130`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart:139`

Why this is dangerous:

Canonical handle policy is important semantic graph logic. Keeping it as private helper logic inside a database-writing projector makes it harder to test as a semantic rule, harder to explain, and easier for future contact/profile logic to bypass or duplicate.

Architectural entropy risk:

- Hidden semantic policy
- Duplicated canonicalization logic
- Graph traversal ambiguity
- Contact identity drift

Correct architectural direction:

Handle canonicalization should be a named semantic integrator or service. Persistence should store the resulting canonical-handle projection; the rule itself should be testable without SQLite.

Proposed repair strategy:

1. Extract handle parsing, grouping, scoring, and display-handle selection into an application/domain semantic component.
2. Keep occurrence-preserving handle rows stable.
3. Have an infrastructure repository persist canonical handle rows and alias rows from explicit semantic results.
4. Add tests that document canonicalization invariants independent of database mutation.

Files likely requiring modification:

- `lib/essentials/conversation_graph/application/handles/handle_projector.dart`
- New `application/handles/*canonical*` integrator/service files
- New infrastructure persistence repository for handle alias projection
- Existing handle projector tests

### Finding 4: Chat group semantics depend on projection order and working topology availability

Classification: ARCHITECTURAL RISK

Constitutional Section:

- Projection architecture: invalid states must be unrepresentable.
- RIO: semantic derivation should be explicit.
- Graph semantics: relationships are primary.

Current behavior:

`ChatProjector` derives `is_group` by querying `chat_to_handle` in the working database during chat projection:

- `lib/essentials/conversation_graph/application/chats/chat_projector.dart:35`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart:36`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart:41`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart:56`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart:57`

The current orchestrator runs `projectChatHandleEdges` before `projectChats`, so the behavior works:

- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart:106`
- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart:109`

Why this is dangerous:

The semantic rule is correct in spirit, but the dependency is implicit. If another caller runs `projectChats()` independently, or if ordering changes, group semantics can silently become wrong. This makes an invalid graph projection representable.

Architectural entropy risk:

- Ordering dependence
- Hidden projection prerequisite
- Topology instability
- Stale semantic fields

Correct architectural direction:

Group status should be derived either as a read-time graph semantic or as a projection stage with an explicit prerequisite/report. It should not be a hidden side effect of a low-level projector that assumes prior edge projection.

Proposed repair strategy:

1. Make chat semantic projection prerequisites explicit in the graph build report or stage model.
2. Consider deriving `is_group` in read queries from `chat_to_handle` rather than storing it, unless storage is intentionally needed for performance.
3. If stored, split chat base projection from chat semantic enrichment and make the latter depend explicitly on projected participant edges.

Files likely requiring modification:

- `lib/essentials/conversation_graph/application/chats/chat_projector.dart`
- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart`
- `lib/essentials/conversation_graph/infrastructure/working_database_provider.dart`
- Chat projection tests

### Finding 5: Conversation traversal semantics are duplicated across repositories

Classification: ARCHITECTURAL SMELL

Constitutional Section:

- Graph Semantics: conversations are first-class graph projections.
- Common Drift Pattern: feature-local relationship logic.
- RIO: readers observe reality; semantic interpretation should be coherent.

Current behavior:

Several infrastructure repositories repeat similar traversal rules:

- participant count via `COUNT(DISTINCT COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id))`
- participant handle labels via `COALESCE(ch.display_handle, h.id)`
- latest text-bearing message subqueries
- attachment counts through `message_to_attachment`
- chat/message/handle joins

Examples:

- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:28`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:31`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:35`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:407`
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart:12`
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart:16`
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart:22`
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart:163`
- `lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart:25`
- `lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart:29`
- `lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart:35`
- `lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart:159`

Why this is dangerous:

Duplicated traversal SQL can drift: one surface may count canonical participants while another counts aliases; one may skip empty text while another does not; one may include attachments differently. That weakens the "one communication graph" model and risks fragmenting conversation semantics by feature.

Architectural entropy risk:

- Graph traversal collapse
- Semantic ambiguity
- Hidden coupling
- Projection incoherence
- Feature-local graph semantics

Correct architectural direction:

The graph should expose reusable, named traversal concepts: conversation overview, participant labels, contact-conversation membership, latest evidence, text-match overlay, attachment availability. SQL may remain in infrastructure, but graph semantics should be centralized enough that surfaces do not independently define what a conversation means.

Proposed repair strategy:

1. Extract shared infrastructure query helpers or repository methods for participant labels/counts and conversation overview materialization.
2. Consider a canonical conversation overview repository used by chat summaries, conversations, and contact graph projections.
3. Add tests that assert equivalent participant and message counts across the surfaces.

Files likely requiring modification:

- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart`
- Application repository interfaces under `application/chat_summaries`, `application/conversations`, and `application/contacts`

### Finding 6: Attachment archive lookup still uses legacy GUID identity as a bridge

Classification: ACCEPTABLE TEMPORARY DEBT

Constitutional Section:

- Source-scoped Graph Architecture: GUID shortcuts must not replace occurrence identity.
- Semantic Preservation: source facts may be preserved, but identity must remain source-scoped.

Current behavior:

Attachment archive availability uses working message GUID plus unpacked attachment source row id to query legacy overlay archive records:

- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:364`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:365`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:378`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:381`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:383`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart:385`

Why acceptable for now:

The archive subsystem predates the source-scoped graph and appears to require `message_guid` plus legacy import attachment id to find current archive rows. The implementation is read-only and quarantined inside infrastructure. It does not replace `ss_id` as graph identity.

Why this is dangerous under future pressure:

If this becomes the long-term attachment identity strategy, it reintroduces GUID bridge semantics and archive lookup coupling. It also makes historical multi-source attachment recovery harder to reason about because archive identity is not fully source-scoped.

Architectural entropy risk:

- Provenance reconstruction burden
- Hidden GUID semantics
- Multi-source archive ambiguity
- Attachment graph identity drift

Correct architectural direction:

Archive records should eventually be addressable by source-scoped message and attachment identities, or by explicit source-scoped provenance columns that do not require GUID as identity.

Proposed repair strategy:

1. Keep the current lookup as a compatibility bridge.
2. Add an architecture note or TODO marking it as a legacy archive bridge, not a graph identity rule.
3. Plan a migration path for archive metadata keyed by `message_ss_id` and `attachment_ss_id`, or by source-scoped source identity.

Files likely requiring modification:

- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart`
- Overlay archive schema/repository files outside this audit scope
- Attachment archive design docs

### Finding 7: Contact page graph identity fallback is implicit and could hide identity mismatch

Classification: ARCHITECTURAL RISK

Constitutional Section:

- Source-scoped Graph Architecture: occurrence identity must remain explicit.
- Projection Architecture: invalid states must be unrepresentable.
- DDD: semantic identity adaptation should be explicit.

Current behavior:

`contactPageGraphSnapshot` maps a legacy contact id into a source-scoped AddressBook contact id, tries that graph id, then falls back to the original id if no graph data is found:

- `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart:31`
- `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart:36`
- `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart:40`
- `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart:46`
- `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart:49`
- `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart:55`

Why this is dangerous:

The fallback is useful during migration, but it means a contact page can be served by either source-scoped graph identity or legacy identity without the caller seeing which path won. This hides a major semantic transition behind provider logic.

Architectural entropy risk:

- Semantic ambiguity
- Hidden identity bridge
- Stale compatibility behavior
- Confusing graph/contact semantics

Correct architectural direction:

The legacy-to-graph identity bridge should be a named resolver with an explicit result: resolved graph id, fallback used, missing graph record, or legacy-only contact. The UI/application can then represent transitional states honestly.

Proposed repair strategy:

1. Extract `graphContactIdForContactPage` and fallback behavior into a named contact identity resolver.
2. Return an explicit resolution model rather than silently falling back.
3. Add tests documenting when fallback is allowed and when it should be considered a data gap.

Files likely requiring modification:

- `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart`
- Potential new `application/contacts/contact_graph_identity_resolver.dart`
- Contact page provider/tests outside this folder

### Finding 8: Projection reports are incomplete relative to the stage-report architecture

Classification: ARCHITECTURAL RISK

Constitutional Section:

- RIO: orchestration should return explicit execution reports.
- Architectural Review Protocol: observable semantic transitions prevent hidden coupling.

Current behavior:

`ConversationGraphBuildOrchestrator` runs a large ordered sequence and records stage names, but only retains result objects for message import, rich-text enrichment, and message projection:

- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart:12`
- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart:17`
- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart:24`
- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart:73`
- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart:100`
- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart:124`

Why this is dangerous:

The graph build process is now important enough that missing per-stage reports will make future convergence, idempotence, and data-drift issues harder to diagnose. This repeats a pressure already solved in the StageController/PipelineOrchestrator architecture.

Architectural entropy risk:

- Hidden orchestration state
- Poor observability
- Large orchestration class growth
- Future imperative debugging patches

Correct architectural direction:

Keep the manual ordered build loop for now, but have every import/projection stage return a narrow report. The build report should aggregate those reports without turning into a generic graph planner.

Proposed repair strategy:

1. Add projection/import result reporting for each graph stage.
2. Replace bare `GraphBuildStep` for meaningful stages with typed report steps.
3. Preserve manual ordering, but make the causal trace complete.

Files likely requiring modification:

- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart`
- `lib/essentials/conversation_graph/application/conversation_graph_build_service_provider.dart`
- Projector result classes and tests

### Finding 9: Working database schema provider contains proof-stage destructive upgrade behavior

Classification: ACCEPTABLE TEMPORARY DEBT

Constitutional Section:

- Projection Architecture: working projection should be deterministic from source facts.
- Database rules: user intent must not be stored in rebuildable working tables.

Current behavior:

The working graph database provider owns schema creation and migrations. Some upgrades drop and recreate working tables:

- `lib/essentials/conversation_graph/infrastructure/working_database_provider.dart:46`
- `lib/essentials/conversation_graph/infrastructure/working_database_provider.dart:52`
- `lib/essentials/conversation_graph/infrastructure/working_database_provider.dart:58`
- `lib/essentials/conversation_graph/infrastructure/working_database_provider.dart:70`
- `lib/essentials/conversation_graph/infrastructure/working_database_provider.dart:71`

Why acceptable for now:

This database is a source-scoped working graph proof/projection and should be rebuildable from import/source facts. The destructive behavior is in infrastructure and does not appear to touch overlay/user-intent data.

Why this is dangerous under future pressure:

Once `working_ss.db` becomes production-critical, silent destructive upgrades can erase derived projection state unexpectedly, mask migration bugs, or normalize rebuilds as a repair tactic.

Architectural entropy risk:

- Imperative repair normalization
- Hidden data reset behavior
- Projection lifecycle ambiguity

Correct architectural direction:

Keep working projection rebuildable, but make rebuild/destructive repair explicit, observable, and separated from normal schema migration.

Proposed repair strategy:

1. Mark destructive proof migrations as temporary.
2. Before production adoption, replace drop/recreate upgrades with explicit projection rebuild commands or idempotent migrations.
3. Ensure overlay/user-intent data remains outside working graph tables.

Files likely requiring modification:

- `lib/essentials/conversation_graph/infrastructure/working_database_provider.dart`
- Database migration tests

### Finding 10: Read models live in application folders and may become durable domain semantics

Classification: ARCHITECTURAL SMELL

Constitutional Section:

- DDD: durable semantic concepts belong in domain; application models describe use-case/read projections.
- Semantic Preservation: distinguish source facts, semantic derivations, and UI/query projections.

Current behavior:

Graph read models are defined under application folders:

- `lib/essentials/conversation_graph/application/chat_summaries/chat_summary.dart`
- `lib/essentials/conversation_graph/application/conversations/conversation.dart`
- `lib/essentials/conversation_graph/application/contacts/contact_graph.dart`

Why this may be acceptable:

These currently behave as read/query projection DTOs rather than durable domain truth. They are not persistence implementations or UI widgets.

Why this is dangerous under future pressure:

Names like `ConversationOverview`, `ConversationMessage`, and `ContactGraphSnapshot` may become shared semantic currency across features. If that happens, leaving them as application-local models obscures whether they are durable graph semantics or query-specific projections.

Architectural entropy risk:

- Semantic ambiguity
- Feature-local projection models becoming global concepts
- Inconsistent graph vocabulary

Correct architectural direction:

Keep application-local read models only if they remain query-specific. Move durable graph semantics to a domain/model layer when they become foundational.

Proposed repair strategy:

1. Document which models are application read projections.
2. If multiple features depend on the same concepts, promote stable models to `domain/models` under the graph spine.
3. Avoid allowing presentation code to reinterpret these models as independent UI state.

Files likely requiring modification:

- `lib/essentials/conversation_graph/application/chat_summaries/chat_summary.dart`
- `lib/essentials/conversation_graph/application/conversations/conversation.dart`
- `lib/essentials/conversation_graph/application/contacts/contact_graph.dart`

## Prioritized Repair Roadmap

### Priority 1: Restore DDD boundary for projection/mutation

Move direct SQLite/database mechanics out of application projectors into infrastructure repositories. This is the highest-priority constitutional defect because it is a current invariant violation.

Suggested sequence:

1. Start with the simplest edge projectors: `chat_to_message`, `chat_to_handle`, `message_to_attachment`.
2. Then move entity projectors: `attachments`, `chats`, `messages`.
3. Leave `handles` and `contacts` until the semantic extraction pieces are planned, because they include canonicalization/matching rules.

### Priority 2: Extract handle canonicalization semantics

Promote handle grouping and alias policy out of the persistence projector into a named semantic component. Keep persistence as infrastructure.

### Priority 3: Make graph build reporting complete

Add per-stage reports for all import/projection steps and aggregate them in `ConversationGraphBuildReport`. Do this before adding more graph build complexity.

### Priority 4: Consolidate duplicated conversation traversal semantics

Centralize reusable participant, latest-message, attachment-count, and text-match traversal semantics so conversation read surfaces do not drift apart.

### Priority 5: Make transitional identity bridges explicit

Quarantine and name:

- legacy contact id -> source-scoped graph contact id fallback
- message GUID/archive compatibility lookup

Both may be temporarily necessary, but neither should become invisible architecture.

## Recommended Architectural Corrections

- Add projection repository interfaces in application and concrete SQLite implementations in infrastructure.
- Treat projectors as use-case services/integrators that call repositories and return reports, not as row-loop persistence classes.
- Extract handle canonicalization into a pure semantic component.
- Introduce a named contact identity resolver for legacy contact page IDs.
- Centralize reusable graph traversal semantics for conversation overview/participants/latest evidence.
- Expand graph build reports so each stage is observable.
- Keep compatibility bridges explicit and documented until replaced by source-scoped equivalents.

## Files Likely Requiring Modification

High-likelihood files:

- `lib/essentials/conversation_graph/application/messages/message_projector.dart`
- `lib/essentials/conversation_graph/application/handles/handle_projector.dart`
- `lib/essentials/conversation_graph/application/chats/chat_projector.dart`
- `lib/essentials/conversation_graph/application/contacts/contact_projector.dart`
- `lib/essentials/conversation_graph/application/attachments/attachment_projector.dart`
- `lib/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projector.dart`
- `lib/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart`
- `lib/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projector.dart`
- `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart`
- `lib/essentials/conversation_graph/application/conversation_graph_build_service_provider.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart`
- `lib/essentials/conversation_graph/infrastructure/working_database_provider.dart`

Likely new files:

- `lib/essentials/conversation_graph/application/*/*_projection_repository.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/*_projection_repository.dart`
- `lib/essentials/conversation_graph/application/handles/handle_canonicalization_integrator.dart`
- `lib/essentials/conversation_graph/application/contacts/contact_graph_identity_resolver.dart`
- Potential shared graph traversal repository/helper under infrastructure

## High-Danger Areas Likely To Drift Again

- Projection projectors: they are currently the easiest place to add "just one query" or "just one field" fixes.
- Handle/contact identity: canonical handles, aliases, contacts, and legacy contact IDs are a high-pressure semantic bridge.
- Attachment archive availability: GUID compatibility may quietly become treated as identity if not quarantined.
- Conversation overview queries: repeated traversal semantics can diverge by surface.
- Graph build orchestration: as more stages are added, incomplete reports and bare steps will invite debugging patches.
- Working database migration: proof-stage destructive migration behavior must not become production repair practice.

## Architecturally Strong Areas To Preserve

- Source-scoped identity is the working graph identity foundation.
- Working graph relationships use explicit `ss_id` endpoints, especially `chat_to_message`, `chat_to_handle`, and `message_to_attachment`.
- Read-side SQL for conversation/contact/chat summaries is mostly in infrastructure repositories, not widgets.
- Application readers depend on repository abstractions and are thin, especially `ConversationReader`, `ChatSummaryReader`, and `ContactGraphReader`.
- There is no presentation code inside `lib/essentials/conversation_graph/`.
- The graph model is traversal-oriented rather than legacy contact-first reconstruction.
- The build orchestrator currently owns sequencing without direct SQL, which is the right direction even though reporting should improve.

## Review Conclusion

Architectural review status: FAIL for current application-layer projection persistence boundaries; PASS with risks for the source-scoped graph model and read-side direction.

The feature works and demonstrates the desired graph architecture, but the projection/mutation implementation currently violates DDD boundary rules by placing SQLite mechanics in application projectors. The correct next step is not feature expansion; it is a boundary-restoration slice that preserves behavior while moving persistence mechanics into infrastructure and making semantic projection rules explicit.
