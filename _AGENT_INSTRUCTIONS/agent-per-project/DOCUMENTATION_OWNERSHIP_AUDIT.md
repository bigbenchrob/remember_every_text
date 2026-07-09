---
tier: project
scope: documentation-ownership-audit
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: audit
links:
  - ./00-START-HERE.md
  - ./README.md
  - ./DOCUMENTATION_INFORMATION_ARCHITECTURE_REPORT.md
  - ./DOCUMENTATION_PASS_LOG.md
tests: []
---

# Documentation Ownership Audit

Date: 2026-07-09

Scope: `_AGENT_INSTRUCTIONS/agent-per-project/`

This audit treats the documentation as a knowledge system. It does not move,
delete, consolidate, or rewrite existing documentation. Its purpose is to
identify where major concepts are introduced, where they are fully explained,
where explanations are duplicated, and which document should be considered the
canonical owner for future maintenance.

## Executive Summary

The documentation has a generally sound ownership structure for the most
important architectural concepts. The strongest canonical owners are:

- `00-START-HERE.md` for cold-start orientation.
- `01-PROJECT/05-CURRENT-STATE.md` for the current project state and phase.
- `10-DATABASES/` for physical database access, overlay separation, and identity
  storage rules.
- `25-ONBOARDING-AND-ARCHIVE/` for onboarding and archive/recovery behavior.
- `40-FEATURES/conversations/README.md` for the user-facing Conversation
  feature boundary.
- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/` for ViewSpecs, panel coordination,
  sidebar cassettes, and cross-surface spec rules.
- `55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`
  for the Message Evidence Spine.
- `95-WALK-UI-TREE/` for current UI/UX walk process, standards, and design
  language.

The main risk is not lack of documentation. The risk is that many concepts were
documented repeatedly while they evolved. Historical planning documents remain
valuable, but readers need to know that current canonical ownership often lives
elsewhere. Future cleanup should add short "current owner" links to historical
documents rather than deleting historical material.

No current canonical documents appear to be in direct conceptual conflict. The
clearest ownership gaps are Contacts as a user-facing feature and Search as a
product surface: both have strong supporting documents, but neither has a single
current canonical feature-level owner comparable to Conversations.

## Ownership Categories Used

- **Canonical owner**: the definitive current explanation for a concept.
- **Secondary reference**: a summary, index, or applied example that should link
  to the canonical owner.
- **Historical/evolution document**: useful context for how a concept was
  developed, but not the current authority.
- **Duplicate explanation**: repeated explanation that may be acceptable if it is
  short, but should not drift from the canonical owner.
- **Conflict**: a current document that gives different active guidance from the
  canonical owner.

## Concept Ownership

### Cold-Start Orientation

Canonical owner:

- `00-START-HERE.md`

Secondary references:

- `README.md`
- `01-PROJECT/05-CURRENT-STATE.md`
- `DOCUMENTATION_INFORMATION_ARCHITECTURE_REPORT.md`

Duplicate explanations:

- `README.md` and `00-START-HERE.md` both orient new agents. This is appropriate:
  the README is the complete index; `00-START-HERE.md` is the short first-read
  path.

Conflicting explanations:

- None observed.

Recommendation:

- Keep `00-START-HERE.md` as the definitive first-stop document.
- Keep `README.md` as the larger index and ensure it links to `00-START-HERE.md`
  early.

### Current Project Phase

Canonical owner:

- `01-PROJECT/05-CURRENT-STATE.md`

Secondary references:

- `00-START-HERE.md`
- `README.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md`
- `95-WALK-UI-TREE/README.md`

Duplicate explanations:

- The "Ship MessageLens" / release-first rule appears in current-state, release
  exit planning, and UI-walk guidance.

Conflicting explanations:

- None in current documents. Older graph-migration documents still speak from
  the migration phase, but they are historical.

Recommendation:

- Treat `01-PROJECT/05-CURRENT-STATE.md` as the current phase owner.
- Treat `85-RELEASE-EXIT-PLAN.md` as the release execution owner.
- Leave historical graph-migration plans intact, but do not let them override
  the current product-first phase.

### Architectural Constitution

Canonical owner:

- `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md`
- `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md`

Secondary references:

- `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/20-COMMON-DRIFT-PATTERNS.md`
- `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/30-IMPLEMENTATION-CHECKLIST.md`
- `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/40-ARCHITECTURAL-REVIEW-PROTOCOL.md`
- `01-PROJECT/05-CURRENT-STATE.md`
- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md`

Duplicate explanations:

- "Fix derivation, invalidation, ownership, or projection; do not add
  imperative repair" appears in the constitution-adjacent materials and current
  state docs. This duplication is useful because it is a core invariant.

Conflicting explanations:

- None observed.

Recommendation:

- Keep the constitution folder as the formal owner.
- Let other docs quote or summarize constitutional rules, but link back to the
  constitution for review decisions.

### DDD Feature Ownership

Canonical owner:

- `01-PROJECT/02-architecture-overview.md`
- `40-FEATURES/README.md`

Secondary references:

- `30-ESSENTIALS/README.md`
- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md`
- `40-FEATURES/conversations/README.md`

Duplicate explanations:

- Feature/essential separation is summarized in multiple indexes. This is
  appropriate, but the feature-specific ownership details should live in each
  feature's README when the feature is current.

Conflicting explanations:

- Older `40-FEATURES/chats/` documents use legacy terminology. Current docs
  already mark Conversations as canonical.

Recommendation:

- Keep `01-PROJECT/02-architecture-overview.md` as the broad owner.
- Keep `40-FEATURES/README.md` as the feature inventory owner.
- Future feature-level ownership should follow the Conversations pattern:
  create a current feature README rather than relying on historical planning
  documents.

### Essentials Ownership

Canonical owner:

- `30-ESSENTIALS/README.md`

Secondary references:

- `01-PROJECT/02-architecture-overview.md`
- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/00-overview.md`
- `10-DATABASES/00-all-databases-accessed.md`

Duplicate explanations:

- Essentials responsibilities are repeated in the architecture overview and spec
  system docs.

Conflicting explanations:

- None observed.

Recommendation:

- Keep `30-ESSENTIALS/README.md` as the canonical owner for module-level
  responsibilities.
- Use feature/architecture docs for summaries only.

### Provider Conventions and Public Seams

Canonical owner:

- `README.md` for top-level quick reference.
- `10-DATABASES/00-all-databases-accessed.md` for database provider seams.
- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md` for
  spec/provider boundary behavior.

Secondary references:

- `01-PROJECT/02-architecture-overview.md`
- `30-ESSENTIALS/README.md`
- `40-FEATURES/README.md`

Duplicate explanations:

- Public provider seam and self-barrel import rules appear in several high-level
  docs because they are operationally important.

Conflicting explanations:

- None observed in current docs.

Recommendation:

- The database-specific provider seam should remain in `10-DATABASES/00`.
- General feature/public seam rules should be gathered under project
  architecture or spec-system docs if they expand further.

### Database Ownership and Physical Database Access

Canonical owner:

- `10-DATABASES/00-all-databases-accessed.md`

Secondary references:

- `10-DATABASES/01-db-import.md`
- `10-DATABASES/02-db-working.md`
- `10-DATABASES/03-db-graph-working.md`
- `10-DATABASES/04-db-source-scoped-import.md`
- `10-DATABASES/05-db-overlay.md`
- `01-PROJECT/05-CURRENT-STATE.md`

Duplicate explanations:

- The top-level README and current-state docs summarize the graph-era data
  spine and retired database status.

Conflicting explanations:

- Some historical planning documents discuss `macos_import.db` and `working.db`
  as active migration components. Current database docs make clear that ordinary
  app behavior uses source-scoped import, graph working DB, and overlay.

Recommendation:

- Keep `10-DATABASES/00-all-databases-accessed.md` as the physical database
  access owner.
- Historical documents should link to the current database map before giving
  implementation guidance.

### Overlay Database and Overlay Independence

Canonical owner:

- `10-DATABASES/07-overlay-database-independence.md`

Secondary references:

- `10-DATABASES/05-db-overlay.md`
- `10-DATABASES/00-all-databases-accessed.md`
- `01-PROJECT/05-CURRENT-STATE.md`
- `25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md`

Duplicate explanations:

- Overlay independence is intentionally repeated because it is an inviolable
  boundary.

Conflicting explanations:

- None observed in current docs.

Recommendation:

- Keep `07-overlay-database-independence.md` as the full rule owner.
- Other docs should summarize: overlay stores user/app intent and archive
  metadata; graph/import projections do not consult overlay.

### Source-Scoped Import and Graph Projection

Canonical owner:

- `20-DATA-IMPORT-MIGRATION/01-overview.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`
  for row-key identity strategy.
- `55-READERS-INTEGRATORS-ORCHESTRATORS/60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md`
  for graph topology projection.

Secondary references:

- `01-PROJECT/05-CURRENT-STATE.md`
- `10-DATABASES/04-db-source-scoped-import.md`
- `10-DATABASES/03-db-graph-working.md`
- `30-ESSENTIALS/README.md`

Duplicate explanations:

- Source-scoped identity is explained across migration, database, and graph
  documents. This is expected because it touches import, storage, graph topology,
  and message evidence.

Conflicting explanations:

- None observed in current docs. Some historical files predate final graph
  migration and should be read as chronology.

Recommendation:

- Keep the database docs as physical storage owners.
- Keep `55` row-key/topology docs as semantic graph owners.
- Keep `20-DATA-IMPORT-MIGRATION/01-overview.md` as the operational import-flow
  overview.

### Conversation Graph

Canonical owner:

- `55-READERS-INTEGRATORS-ORCHESTRATORS/60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md`
- `30-ESSENTIALS/README.md` for the `essentials/conversation_graph` module
  boundary.

Secondary references:

- `40-FEATURES/conversations/README.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md`

Duplicate explanations:

- Graph migration documents repeat graph concepts as they matured.

Conflicting explanations:

- No current conflict. The main ambiguity is historical: earlier docs sometimes
  blend graph facts with user-facing Conversation presentation, while current
  ownership separates `essentials/conversation_graph` from
  `features/conversations`.

Recommendation:

- Keep graph topology/facts owned by `55` and `30`.
- Keep user-facing Conversation presentation owned by
  `40-FEATURES/conversations/README.md`.

### Conversations

Canonical owner:

- `40-FEATURES/conversations/README.md`

Secondary references:

- `01-PROJECT/05-CURRENT-STATE.md`
- `95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md`
- `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/*.md`
- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_AUDIT.md`
- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_REPAIR.md`

Duplicate explanations:

- The One Conversation principle appears in UX standards, current state, and the
  Conversations feature README. This is intentional, but the feature README
  should remain the implementation ownership authority.

Conflicting explanations:

- Older `40-FEATURES/chats/` and some `45` topology docs use older chat/convo
  terminology. They are historical, not current owners.

Recommendation:

- Keep `40-FEATURES/conversations/README.md` as the canonical owner for
  Conversation feature boundaries, cards, glyphs, favourites, collections, and
  excerpt panels.
- UI-walk documents should own presentation decisions for specific surfaces only.

### Conversation Identity and "One Conversation"

Canonical owner:

- `40-FEATURES/conversations/README.md`
- `95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md` for the UX principle wording.

Secondary references:

- `10-DATABASES/12-identity-model-contacts-handles-participants.md`
- `01-PROJECT/05-CURRENT-STATE.md`
- `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/README.md`

Duplicate explanations:

- Conversation identity appears in both architecture and UX language. This is
  appropriate: architecture owns the entity boundary; UX standards own the user
  perception rule.

Conflicting explanations:

- None observed.

Recommendation:

- Keep both owners, but distinguish their roles:
  - Feature README: which code owns Conversation presentation.
  - UX principles: what users should perceive.

### Message Evidence Spine

Canonical owner:

- `55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`

Secondary references:

- `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/README.md`
- `40-FEATURES/messages/MESSAGE-TIMELINE-PIPELINE.md`
- `01-PROJECT/05-CURRENT-STATE.md`
- `45-NEW-FEATURE-ADDITION/01-CONVERSATION-TOPOLOGY-PRESENTATION/GRAPH_MESSAGE_EVIDENCE_SPINE_AUDIT.md`

Duplicate explanations:

- The evidence spine is described in both migration-audit documents and current
  UI review docs.

Conflicting explanations:

- None observed in current docs. Older docs may use transitional names for row
  objects and message scopes.

Recommendation:

- Keep `55/69` as the spine invariant owner.
- UI-walk docs should own visual/presentation refinements only and link back to
  the spine for architecture.

### Messages and Message Evidence Presentation

Canonical owner:

- `40-FEATURES/messages/MESSAGE-TIMELINE-PIPELINE.md` for feature pipeline
  detail.
- `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/README.md`
  for current UI/UX review of the shared center-panel evidence surface.
- `55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`
  for architectural invariant.

Secondary references:

- `40-FEATURES/messages/CHARTER.md`
- `40-FEATURES/messages/message-display-flow-walkthrough.md`
- `45-NEW-FEATURE-ADDITION/01-CONVERSATION-TOPOLOGY-PRESENTATION/UNIFIED-MESSAGE-EVIDENCE-PRESENTATION.md`

Duplicate explanations:

- Message presentation appears in legacy feature docs, graph migration docs, and
  UI-walk docs.

Conflicting explanations:

- Historical documents may describe legacy paths that have been superseded by
  the spine. Current docs identify the shared evidence surface.

Recommendation:

- Use `55/69` for architecture, `95/.../Message-Evidence-Center-Panel` for UX,
  and treat older feature/planning walkthroughs as historical or diagnostic.

### Contacts and Contact Identity

Canonical owner:

- `10-DATABASES/12-identity-model-contacts-handles-participants.md` for identity
  model and display-name precedence.

Secondary references:

- `40-FEATURES/contact-names/DB_TABLES_FOR_CONTACTS.md`
- `40-FEATURES/contact-names/VIRTUAL_PARTICIPANTS.md`
- `45-NEW-FEATURE-ADDITION/02-UNIFIED-MESSAGE-EVIDENCE-HEADER/CONTACT_IDENTITY_DISPLAY_AUDIT.md`
- `45-NEW-FEATURE-ADDITION/02-UNIFIED-MESSAGE-EVIDENCE-HEADER/CONTACT-NAME-DISPLAY-AUDIT.md`
- `01-PROJECT/05-CURRENT-STATE.md`

Duplicate explanations:

- Contact name resolution and participant terminology are repeated in database,
  feature, and audit documents.

Conflicting explanations:

- Older docs may mention short-name/nickname paths. Current identity docs state
  that the only user-authored contact name override is the display-name override
  edited through the hero card.

Recommendation:

- Keep `10-DATABASES/12` as the identity owner.
- Consider creating a future `40-FEATURES/contacts/README.md` to own the
  user-facing Contacts feature, similar to Conversations. That would close the
  current feature-ownership gap without moving identity storage rules out of
  `10-DATABASES`.

### Search

Canonical owner:

- `30-ESSENTIALS/README.md` for search as an app-wide essential system.
- `95-WALK-UI-TREE/10-Messages-Sidebar/All-Messages/` for current UI-walk
  review items as they are created.

Secondary references:

- `40-FEATURES/search/*` historical feature docs.
- `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/search_input_box.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`

Duplicate explanations:

- Search appears in old feature docs, UI-walk docs, and evidence-spine
  architecture.

Conflicting explanations:

- No current conflict, but ownership is less explicit than Conversations.

Recommendation:

- Treat Search as an essential evidence-selection system unless a future
  first-class feature boundary is deliberately created.
- Add a dedicated current search owner document later if Search All Messages
  expands during the UI walk.

### Discovery, Organize By, and Conversation Lenses

Canonical owner:

- `95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md`

Secondary references:

- `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/sort_conversations_menu.md`
- `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/filter_sort_controls.md`
- `01-PROJECT/05-CURRENT-STATE.md`

Duplicate explanations:

- Conversation-lens concepts are discussed in the concrete Conversations sidebar
  review docs and then generalized in design-language notes.

Conflicting explanations:

- None observed.

Recommendation:

- Keep `DESIGN_LANGUAGE_NOTES.md` as the owner for internal terminology:
  Conversation Lens, Organize by, operational/exploratory lenses, orange
  comparison-value highlighting, and curiosity without confusion.
- Surface-specific reviews should reference the design-language owner when they
  apply the concept.

### ViewSpecs and Panel Architecture

Canonical owner:

- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`
- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md`

Secondary references:

- `42-SPEC-SYSTEM/README.md`
- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/00-overview.md`
- `30-ESSENTIALS/README.md`
- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_REPAIR.md`

Duplicate explanations:

- Panel routing is summarized in architecture overview, essentials, and UI-walk
  ownership repair docs.

Conflicting explanations:

- `42-SPEC-SYSTEM/REFERENCE/` may contain older synchronous widget-returning
  examples. The canonical architecture explicitly marks those as legacy/current
  migration boundaries, not approved new patterns.

Recommendation:

- Keep canonical ownership in `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE`.
- Historical reference docs should remain clearly subordinate.

### Sidebar Architecture and Cassette System

Canonical owner:

- `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`

Secondary references:

- `08-SIDEBAR-LAYOUTS/00-sidebar-cassettes-controls-and-info-cards.md`
- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md`
- `45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/*`

Duplicate explanations:

- Sidebar cassettes are documented in canonical architecture, layout rules,
  UI-walk X-column layout, and the active content-seam planning folder.

Conflicting explanations:

- No current conflict, but the content-seam work is still active and may shift
  implementation details.

Recommendation:

- Keep `42/.../20-sidebar-cassette-system.md` as the cassette owner.
- Let `95/.../15-X-COLUMN-LAYOUT` own the page-layout grammar.
- Treat `45/.../03-INTRODUCE-SIDEBAR-CONTENT-SEAM` as active planning until the
  seam is settled, then summarize into the canonical sidebar/layout docs.

### X-Column Layout Grammar

Canonical owner:

- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md`

Secondary references:

- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_AUDIT.md`
- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_REPAIR.md`
- `45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/*`

Duplicate explanations:

- The layout grammar appears in both UI-walk docs and current feature-addition
  planning for the sidebar content seam.

Conflicting explanations:

- Earlier band-model wording may exist in historical prompts/plans. The current
  `95` README is the active owner.

Recommendation:

- Keep X-column layout ownership under `95-WALK-UI-TREE`.
- When the sidebar content seam stabilizes, move only a concise durable summary
  into the canonical `95` layout README or `42` sidebar doc.

### Readers, Integrators, and Orchestrators

Canonical owner:

- `55-READERS-INTEGRATORS-ORCHESTRATORS/00-TERMINOLOGY.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/10-ARCHITECTURE-CONTRACT.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/20-ALLOWED-DEPENDENCIES.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/30-INVARIANTS.md`

Secondary references:

- `55-READERS-INTEGRATORS-ORCHESTRATORS/README.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md`
- Later numbered graph migration files.

Duplicate explanations:

- Many later numbered docs apply the RIO vocabulary to specific graph migration
  slices.

Conflicting explanations:

- None observed in current docs.

Recommendation:

- Keep `00` through `30` as durable RIO owners.
- Treat later numbered docs as applied/historical unless specifically listed in
  `TOPIC_INDEX.md` as current.

### Onboarding

Canonical owner:

- `25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md`
- `40-FEATURES/onboarding/*` for historical/current feature charter details.

Secondary references:

- `25-ONBOARDING-AND-ARCHIVE/README.md`
- `45-NEW-FEATURE-ADDITION/enhanced-onboarding-flow/*`
- `45-NEW-FEATURE-ADDITION/enhanced-onboarding-readiness-panel/*`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md`

Duplicate explanations:

- Onboarding is covered in feature docs, archive docs, and feature-addition
  proposals.

Conflicting explanations:

- Needs verification: feature-addition onboarding proposals may not fully match
  the final release behavior.

Recommendation:

- Keep `25-ONBOARDING-AND-ARCHIVE` as the release-facing onboarding owner.
- Future UI-walk onboarding review should link back to `25` rather than creating
  a parallel architecture.

### Archive and Recovery

Canonical owner:

- `25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md`
- `25-ONBOARDING-AND-ARCHIVE/50-deterministic-recovery.md`
- `25-ONBOARDING-AND-ARCHIVE/60-reimport-and-ongoing-sync.md`

Secondary references:

- `10-DATABASES/05-db-overlay.md`
- `10-DATABASES/07-overlay-database-independence.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/84-ATTACHMENT-REACHABILITY-AUDIT.md`
- `45-NEW-FEATURE-ADDITION/living-attachments-*`

Duplicate explanations:

- Archive/recovery was explored through several historical feature proposals and
  migration audits.

Conflicting explanations:

- A known caveat exists around attachment provenance naming
  (`imported_historical_snapshot` vs older strings). The current archive docs
  explicitly flag this.

Recommendation:

- Keep `25` as the current operational owner.
- Keep `55/84` as proof/audit evidence.
- Historical feature folders should eventually link to the `25` archive docs.

### Attachment Reachability

Canonical owner:

- `55-READERS-INTEGRATORS-ORCHESTRATORS/84-ATTACHMENT-REACHABILITY-AUDIT.md`
  for the audit/proof.
- `25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md` for operational archive
  behavior.
- `25-ONBOARDING-AND-ARCHIVE/50-deterministic-recovery.md` for recovery mapping.

Secondary references:

- `55-READERS-INTEGRATORS-ORCHESTRATORS/83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md`
- `10-DATABASES/07-overlay-database-independence.md`

Duplicate explanations:

- Reachability appears in retirement, archive, and recovery documents.

Conflicting explanations:

- None observed in current docs.

Recommendation:

- Treat `84` as the proof document and `25` as the operational owner.

### Retired Databases and Retained Storage

Canonical owner:

- `55-READERS-INTEGRATORS-ORCHESTRATORS/81-LEGACY-STORAGE-RETENTION-REGISTER.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md`

Secondary references:

- `10-DATABASES/00-all-databases-accessed.md`
- `10-DATABASES/02-db-working.md`
- `10-DATABASES/01-db-import.md`
- `01-PROJECT/05-CURRENT-STATE.md`

Duplicate explanations:

- Retired storage status appears in current state, database docs, and graph
  retirement docs.

Conflicting explanations:

- Historical docs may discuss `working.db` and `macos_import.db` as active; the
  current database docs classify them as retired cleanup/diagnostic files.

Recommendation:

- Keep `81` and `83` as retirement policy/proof owners.
- Keep database docs as the day-to-day access authority.

### UI Walk Process

Canonical owner:

- `95-WALK-UI-TREE/README.md`
- `95-WALK-UI-TREE/UI_REVIEW_PROCESS.md`
- `95-WALK-UI-TREE/REVIEW_TEMPLATE.md`
- `95-WALK-UI-TREE/ACTION_PLAN_TEMPLATE.md`

Secondary references:

- `01-PROJECT/05-CURRENT-STATE.md`
- `95-WALK-UI-TREE/00-Registers/README.md`
- `95-WALK-UI-TREE/99-IMPLEMENTED/README.md`

Duplicate explanations:

- The UI-walk process is summarized in current state and detailed in `95`.

Conflicting explanations:

- None observed.

Recommendation:

- Keep all UI-walk process ownership under `95-WALK-UI-TREE`.
- Do not let individual review documents become new architecture owners unless
  their conclusions are promoted into standards/registers.

### Feature Addition and Planning Archive

Canonical owner:

- `45-NEW-FEATURE-ADDITION/README.md`
- `45-NEW-FEATURE-ADDITION/INDEX.md`

Secondary references:

- Individual planning folders under `45-NEW-FEATURE-ADDITION/`.

Duplicate explanations:

- Many durable concepts are first explained in feature proposals and then later
  promoted elsewhere.

Conflicting explanations:

- Some older plans contain stale implementation assumptions by design.

Recommendation:

- Keep `45` as the staging/history owner, not as the canonical owner for settled
  concepts.
- Future consolidation should add "superseded by" links from important older
  plans to their current canonical owners.

### Build, Release, and FDA Continuity

Canonical owner:

- `60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`

Secondary references:

- `README.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md`

Duplicate explanations:

- Release/FDA guidance is only lightly duplicated in indexes.

Conflicting explanations:

- None observed.

Recommendation:

- Keep build/release technical constraints in `60-BUILD-CONSIDERATIONS`.
- Release planning should link there before production build work.

## Additional Ownership Gaps

### Contacts Feature Surface

Current state:

- Contact identity is well documented under `10-DATABASES/12`.
- Contact UI behavior is documented through historical feature docs and UI-walk
  fragments.
- There is no current `40-FEATURES/contacts/README.md` equivalent to the
  Conversations feature README.

Recommendation:

- Create a future Contacts feature owner document if the Contacts UI/UX walk
  expands. It should not duplicate identity storage rules; it should own
  user-facing Contacts behavior, hero card, contact picker, heatmap mode, handle
  filter, and contact-to-conversation navigation.

### Search Product Surface

Current state:

- Search is treated as an essential app-wide evidence-selection system.
- Historical `40-FEATURES/search` docs exist.
- Current UI-walk search concepts are developing under `95`.

Recommendation:

- If Search remains an essential rather than a feature, add a focused current
  search owner doc under `30-ESSENTIALS/` or a search section in
  `30-ESSENTIALS/README.md` once the UI walk settles.

### UI Layout Grammar

Current state:

- `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` owns the active layout grammar.
- `45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM` owns active
  planning for a sidebar seam that may later become canonical.

Recommendation:

- Keep active planning in `45/03` during implementation.
- Promote the final settled seam into `95` or `42` only after the behavior is
  verified.

## Historical / Evolutionary Documentation

The following documentation primarily exists because the project evolved over
time. These should remain available as historical references unless and until a
later consolidation pass explicitly replaces them with summaries and links.

### `45-NEW-FEATURE-ADDITION/`

Role:

- Feature proposals, design notes, checklists, tests, and active planning.

Why historical:

- Many folders document decisions before the graph migration, evidence spine,
  Conversations feature boundary, and UI-walk process settled.

Recommendation:

- Do not delete.
- Continue using `INDEX.md` to mark current vs historical.
- Add "current owner" links to high-value historical plans when revisited.

### `55-READERS-INTEGRATORS-ORCHESTRATORS/60-85`

Role:

- Graph migration audits, parity reports, checklists, retirement assessments,
  release exit plan.

Why historical:

- These documents record how the graph system became production infrastructure.

Recommendation:

- Preserve chronology.
- Use `TOPIC_INDEX.md` to identify which docs are current invariants vs
  migration record.

### `40-FEATURES/chats/`

Role:

- Historical chat feature terminology and early domain mapping.

Why historical:

- `features/conversations` is now the canonical user-facing Conversation
  boundary.

Recommendation:

- Keep as historical reference.
- Do not use as the owner for new Conversation work.

### `45-NEW-FEATURE-ADDITION/01-CONVERSATION-TOPOLOGY-PRESENTATION/`

Role:

- Historical bridge from conversation topology experiment to production
  Conversation UI.

Why historical:

- Its concepts have been promoted into `40-FEATURES/conversations`, `55/69`, and
  `95-WALK-UI-TREE`.

Recommendation:

- Preserve as design history.
- Link to current Conversation, evidence-spine, and UI-walk owners if revisited.

### `45-NEW-FEATURE-ADDITION/02-UNIFIED-MESSAGE-EVIDENCE-HEADER/`

Role:

- Historical implementation plan and audits for unified message headers and
  identity display.

Why historical:

- The shared message evidence surface is now reviewed under
  `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel`, while
  identity rules live in `10-DATABASES/12`.

Recommendation:

- Preserve as implementation history.
- Do not treat it as the current owner for message evidence or identity display.

### `42-SPEC-SYSTEM/REFERENCE/`

Role:

- Reference/history for spec system evolution.

Why historical:

- Canonical architecture now lives under
  `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/`.

Recommendation:

- Keep as reference.
- Do not use examples there as current implementation authority when they differ
  from canonical architecture.

## Cross-Document Maintenance Recommendations

1. **Add owner links when touching historical docs.**
   When a historical proposal is edited, add a short note pointing to the current
   canonical owner rather than rewriting the whole document.

2. **Do not eliminate useful repetition.**
   Critical invariants should be repeated in summary form. The risk is not
   repetition; the risk is full duplicate explanations drifting apart.

3. **Prefer one canonical owner plus many summaries.**
   If a concept needs full explanation in two places, decide whether one is
   architecture and the other is UX. Otherwise, one should become a link.

4. **Promote settled planning outcomes.**
   When active `45` planning work becomes production behavior, promote the
   durable rule into `01`, `10`, `25`, `40`, `42`, `55`, or `95` as appropriate.

5. **Keep historical sequence intact.**
   Migration, audit, and proposal documents are valuable evidence. Consolidation
   should not erase why decisions were made.

