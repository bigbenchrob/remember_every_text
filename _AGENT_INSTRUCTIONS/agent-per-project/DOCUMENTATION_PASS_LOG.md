---
tier: project
scope: documentation-pass
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: doc
links:
  - ./README.md
  - ./01-PROJECT/05-CURRENT-STATE.md
tests: []
---

# Documentation Pass Log

Date: 2026-07-09

Scope: Autonomous maintenance pass confined to
`_AGENT_INSTRUCTIONS/agent-per-project/`.

## Summary

This pass updated the project documentation to reflect the current graph-era
and UI-walk state of MessageLens. It focused on correcting stale active
ownership claims, clarifying the current product/release phase, adding a
current-state orientation document, and improving discoverability of the large
RIO migration-history folder.

No application source code, tests, configs, generated files, database files, or
assets were modified as part of this documentation pass.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `README.md` | Updated `last_reviewed`; added current project phase quick fact; linked current-state, Essentials, Conversations, UI-walk, and release-exit docs; updated RIO description. | The top-level index still emphasized graph migration and did not orient future agents to the current product/UI-walk phase or the new Conversations feature boundary. |
| `01-PROJECT/05-CURRENT-STATE.md` | Created current-state snapshot. | Future agents need a concise answer to "what is current now?" without reading the entire graph migration history. |
| `01-PROJECT/02-architecture-overview.md` | Updated active feature list; added `features/conversations` ownership; clarified boundaries among Conversations, Messages, Search, and `essentials/conversation_graph`; linked current-state/release docs. | The architecture overview still listed `chats` as active and did not reflect the Conversation ownership repair. |
| `30-ESSENTIALS/README.md` | Updated current `ViewSpec` list to include `ViewSpec.conversations` and `ViewSpec.settings`; removed the stale active `ViewSpec.import` claim; clarified sidebar-independent system specs. | The active navigation model now routes Conversation specs through the Conversations feature; the old import spec wording was stale. |
| `40-FEATURES/README.md` | Updated `last_reviewed`; marked `chats/` as historical; added `conversations/`; corrected current code module inventory; removed stale active `reactions` module claim. | The code tree now has `features/conversations` and no active `features/chats` or `features/reactions` module. |
| `40-FEATURES/conversations/README.md` | Created canonical Conversations feature boundary document. | Conversation presentation was previously documented indirectly through UI-walk and migration notes; it now has a discoverable feature-owned home. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/README.md` | Added current-status guidance, navigation guide, and `85-RELEASE-EXIT-PLAN.md` to reading flow. | The folder accumulated many specialized numbered docs; a clearer index was lower-risk than physically moving historical documents. |
| `95-WALK-UI-TREE/README.md` | Added note that the UI walk is the active product-improvement phase and should not expand into unrelated hardening. | Aligns UI work with Document 85's release-first rule. |
| `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` | Updated from the earlier rigid four-band/AppPanelBandColumn framing to the current title/context/content-start band model and sidebar content-start seam. | The code now includes `TitleColumnBand` and `ContextColumnBand`; the old README text was stale and over-rigid. |
| `DOCUMENTATION_PASS_LOG.md` | Created this log. | Required by the documentation-pass request. |

## Structure Decisions

The `55-READERS-INTEGRATORS-ORCHESTRATORS/` folder was not physically
reorganized during this pass.

Reason:

- Many files are historical but still useful as audit evidence.
- Moving them would risk breaking existing links and obscuring their chronology.
- A current-status guide and reading categorization solves the immediate
  discoverability problem with less churn.

The `40-FEATURES/chats/` folder was not deleted or moved.

Reason:

- It remains useful historical context for older chat terminology.
- The active docs now explicitly state that current user-facing Conversation
  ownership belongs to `features/conversations`.

## Important Concepts Clarified

- The current project phase is product release and UI/UX walk, not continuing
  graph migration as an end in itself.
- The ordinary data spine is graph-first:
  `chat.db / AddressBook -> macos_import_ss.db -> working_ss.db -> graph read models -> Message Evidence Spine -> overlay intent`.
- Retired `macos_import.db` and `working.db` are cleanup/diagnostic inventory,
  not ordinary app authorities.
- `features/conversations` owns user-facing Conversation identity
  presentation.
- `features/messages` owns message evidence surfaces, not Conversation cards,
  glyphs, favourites, or excerpt panel structure.
- `essentials/conversation_graph` owns graph facts and projection/build
  behavior, not user-facing Conversation widgets.
- Search requests Conversation excerpts; Conversations renders the Conversation
  lens; Messages renders the message evidence rows.
- X-column layout currently uses a title band and context band, with content
  beginning after the context band.

## Needs Verification / Human Review

- The documentation says no active `lib/features/chats` or
  `lib/features/reactions` module was present in the July 2026 code inventory.
  Re-check if either module is deliberately reintroduced later.
- Some historical `42-SPEC-SYSTEM/REFERENCE/` documents still mention older
  `ViewSpec.chats` and `ViewSpec.import` examples. They were left unchanged
  because they live under `REFERENCE/`; future agents should not treat them as
  current implementation guidance.
- The exact release readiness status for onboarding, archival import, and final
  smoke testing remains governed by `55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md`
  and should be verified against the current app before release decisions.
- The X-column layout implementation is active UI-walk work. The docs now
  describe the current direction, but visual tuning remains a design/review
  matter rather than a completed universal layout standard.

---

# Documentation Information Architecture Pass

Date: 2026-07-09

Scope: Structural and navigational review confined to
`_AGENT_INSTRUCTIONS/agent-per-project/`.

## Summary

This pass treated the documentation as a navigation product. It improved
discoverability and current-vs-history signaling without moving large
historical folders or rewriting technical content.

No application source code, tests, configs, generated files, database files, or
assets were modified as part of this IA pass.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `00-START-HERE.md` | Created cold-start orientation page. | New readers needed one short entry point that distinguishes current mode, canonical owners, and historical reference areas. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md` | Created topic-based index. | The folder combines durable invariants with numbered graph-migration history; topic navigation is safer than physical reorganization. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Created staging/history index. | The folder contains active planning, migrated guidance, and historical proposals; readers need to verify currency before implementing. |
| `45-NEW-FEATURE-ADDITION/README.md` | Linked `INDEX.md`; clarified active/planning table wording; updated review date. | The README previously implied the folder was mainly active work; it now flags the mixed staging/history role. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/README.md` | Linked `TOPIC_INDEX.md` from Current Status. | Future readers should not infer document currency from file number alone. |
| `README.md` | Linked `00-START-HERE.md` from the opening section and frontmatter; added a Large Folder Navigation section for `45` and `55` indexes. | The top-level index now has a clearer first-read path and makes the large-folder navigation aids discoverable. |
| `DOCUMENTATION_INFORMATION_ARCHITECTURE_REPORT.md` | Created IA report. | Required deliverable documenting strengths, weaknesses, structural changes, unchanged folders, and recommendations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this IA-pass section. | Required change log for documentation maintenance. |

## Structure Decisions

The pass intentionally avoided moving large historical folder trees.

Reason:

- Existing links and chronological evidence are valuable.
- The main problem was navigation, not missing content.
- Index files reduce confusion without creating link churn.

## Needs Verification / Human Review

- Confirm whether `45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/`,
  `archive-canonical-attachments/`, and `ephemeral-sidebar-projection/` remain
  the intended active/planning feature folders.
- Consider a later archive taxonomy for `45-NEW-FEATURE-ADDITION/` only after
  the current release/UI-walk phase.

---

# Documentation Ownership Audit

Date: 2026-07-09

Scope: Analytical ownership audit confined to
`_AGENT_INSTRUCTIONS/agent-per-project/`.

## Summary

This pass examined how major architectural and product concepts are distributed
across the documentation. It identified canonical owners, secondary references,
duplicate explanations, historical/evolutionary documents, and ownership gaps.

No documentation content was consolidated, no files were moved, and no
application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `DOCUMENTATION_OWNERSHIP_AUDIT.md` | Created ownership audit report. | Required deliverable identifying canonical owners, secondary references, duplicate explanations, conflicts, and future documentation-improvement recommendations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this ownership-audit log entry. | Required by the documentation ownership audit request. |

## Major Concepts Audited

- Current project phase
- Architectural Constitution
- DDD feature ownership
- Essentials ownership
- Provider conventions and public seams
- Database ownership and physical DB access
- Overlay database and overlay independence
- Source-scoped import and graph projection
- Conversation Graph
- Conversations and the One Conversation principle
- Message Evidence Spine
- Messages and message evidence presentation
- Contacts and contact identity
- Search
- Discovery, Organize By, and Conversation Lenses
- ViewSpecs and panel architecture
- Sidebar architecture and cassette system
- X-column layout grammar
- Readers, Integrators, and Orchestrators
- Onboarding
- Archive/recovery and attachment reachability
- Retired databases and retained storage
- UI Walk process
- Feature planning/history
- Build/release/FDA continuity

## Needs Verification / Human Review

- Consider creating a current `40-FEATURES/contacts/README.md` if the Contacts
  UI/UX walk expands, because contact identity is well documented but the
  user-facing Contacts feature lacks a single current owner comparable to
  Conversations.
- Consider creating a focused current Search owner document under
  `30-ESSENTIALS/` or the UI-walk Search area once the Search/All Messages
  walkthrough settles.
- When active sidebar content-seam work stabilizes, promote the durable outcome
  from `45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/` into the
  canonical sidebar/layout documentation.

---

# Developer Guide Creation

Date: 2026-07-09

Scope: Created a cohesive first-read developer guide and made it discoverable
from the project documentation entry points.

## Summary

This pass synthesized the current canonical MessageLens documentation into a
senior-engineer orientation guide. It explains the product purpose, mental
model, architectural philosophy, feature ownership, data flow, UI philosophy,
common mistakes, and how to read the rest of the documentation.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `DEVELOPER_GUIDE.md` | Created new developer guide. | Required deliverable; gives future developers and fresh agents a coherent mental model before reading detailed reference documentation. |
| `00-START-HERE.md` | Added `DEVELOPER_GUIDE.md` as the first Fast Path item. | The guide is intended to be the recommended first document for new contributors. |
| `README.md` | Added entry-point wording and Large Folder Navigation link for `DEVELOPER_GUIDE.md`. | Makes the guide discoverable from the main per-project index. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Required change log for documentation work. |

## Needs Verification / Human Review

- The guide is intentionally narrative rather than exhaustive. If future work
  changes the current phase, Conversation ownership, Message Evidence Spine, or
  retired database policy, update the guide rather than letting it drift into
  historical guidance.

---

# Conversations Architectural Walkthrough

Date: 2026-07-09

Scope: Performed an architectural walkthrough of the Conversations feature as a
user-facing journey and ownership boundary.

## Summary

This pass reviewed the Conversations feature against the Developer Guide,
current-state documentation, Architectural Constitution, Conversation feature
boundary documentation, and UI Walk principles. It evaluated the user journey
from Conversations entry through Favourites/Browse, Conversation selection,
message evidence, in-conversation search, Search -> Conversation excerpt
navigation, and Favourite state.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `CONVERSATIONS_ARCHITECTURAL_WALKTHROUGH.md` | Created architectural walkthrough report. | Required deliverable; records strengths, opportunities, architectural drift risks, UX drift risks, scalability concerns, and release-oriented recommendations for Conversations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this walkthrough log entry. | Required by the walkthrough request. |

## Needs Verification / Human Review

- Decide during the UI Walk whether the Conversations metadata search field
  should be removed, renamed, or retained with clearer scope.
- Before expanding beyond Core Favourites, review whether favourite overlay
  provider ownership should remain in `essentials/conversation_graph` or move
  to a Conversations/overlay-intent boundary.
- Promote the durable X-column/sidebar content seam rules into canonical UI
  documentation once that active layout work stabilizes.

---

# Conversation Tags Feature Package

Date: 2026-07-09

Scope: Created an exploratory feature work package for Conversation Tags under
`45-NEW-FEATURE-ADDITION/`.

## Summary

This pass created the canonical exploratory work package for durable
Conversation Tags. It defines tags as user-created semantic labels attached to
canonical Conversation identity, stored as overlay/user intent, and designed to
support future retrieval and discovery without becoming folders.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Created package overview. | Provides entry point, principles, package contents, and exploratory status. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/PROPOSAL.md` | Created proposal. | Defines purpose, rationale, product philosophy, architectural direction, relationships to Favourites/Working Sets/Search/Discovery, non-goals, and open questions. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/DESIGN_NOTES.md` | Created design notes. | Records storage, overlay, identity, UX, scalability, sync/export, AI-assistance, and anti-pattern considerations. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/CHECKLIST.md` | Created phased checklist. | Records planning, product decisions, architecture plan, minimal slice, cross-lens integration, management/scale, and completion criteria. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/TESTS.md` | Created future validation plan. | Captures product, architectural, functional, UX, cross-feature, and data-integrity validation expectations for future implementation. |
| `45-NEW-FEATURE-ADDITION/README.md` | Added Conversation Tags to active/planning table. | Makes the new package discoverable as exploratory planning work. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added Conversation Tags to active/potentially active planning folders. | Prevents the package from becoming orphaned and clarifies that it is not implementation guidance yet. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this feature-package log entry. | Required by the feature package request. |

## Needs Verification / Human Review

- Decide whether Conversation Tags should move from exploratory package to
  active implementation.
- Decide whether first version includes tag color.
- Decide whether Core Favourites should remain separate from tag
  infrastructure or eventually share overlay primitives.

---

# Conversation Intent Architecture Package

Date: 2026-07-09

Scope: Created an exploratory architecture work package for Conversation Intent
under `45-NEW-FEATURE-ADDITION/` and lightly amended the Conversation Tags
package to reference the broader seam.

## Summary

This pass defined Conversation Intent as user-authored or user-confirmed
metadata attached to stable Conversation identity. The package positions
Favourites, Tags, Working Sets, Hidden state, Notes, saved investigations, and
future confirmed AI classifications as user intent attached to the one
canonical Conversation rather than separate containers or sidebar-owned list
types.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/README.md` | Created package overview. | Provides entry point, package contents, governing idea, and relationship to Conversation Tags. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/PROPOSAL.md` | Created architecture proposal. | Defines Conversation Intent, conceptual model, ownership, product philosophy, relationship to Tags, non-goals, open questions, and acceptance criteria. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/DESIGN_NOTES.md` | Created design notes. | Records ownership, retrieval implications, relationships to existing concepts, UX implications, overlay considerations, lifetimes, and anti-patterns. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/CHECKLIST.md` | Created architecture checklist. | Records concept approval, existing-intent audit, shared model, Tags-on-intent, retrieval, and completion criteria phases. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/TESTS.md` | Created validation plan. | Captures future product, architectural, regression, tags-on-intent, retrieval, AI suggestion, and data-integrity validation. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Added Conversation Intent relationship. | Clarifies that Tags are one durable form of broader Conversation Intent while the Tags package remains focused. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/PROPOSAL.md` | Added Conversation Intent relationship section. | Positions Tags as a feature built on the broader intent seam rather than a tag-only special case. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/DESIGN_NOTES.md` | Added Conversation Intent design note. | Clarifies the general seam without expanding tag-specific design scope. |
| `45-NEW-FEATURE-ADDITION/README.md` | Added Conversation Intent package to active/planning table. | Makes the architecture package discoverable. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added Conversation Intent package to active/potentially active planning folders. | Prevents the package from becoming orphaned and clarifies exploratory status. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this architecture-package log entry. | Required by the work package request. |

## Needs Verification / Human Review

- Confirm that "Conversation Intent" is the preferred durable term.
- Decide whether existing Core Favourites should eventually migrate onto shared
  intent primitives or remain separate until Tags prove the need.
- Decide whether Working Sets are durable intent, session intent, or both.

---

# Structured Conversation Retrieval Work Package

Date: 2026-07-11

Scope: Created an exploratory work package for Structured Conversation
Retrieval under `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/`.

## Summary

This pass defined Structured Conversation Retrieval as a product and
architectural model for retrieving Conversations through structured tokens over
Conversation identity, metadata, and Conversation Intent. It explicitly
distinguishes Conversation Retrieval from All Messages Search: retrieval answers
"Which Conversation am I trying to work with?", while message search answers
"Where was this said?"

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md` | Created package overview. | Provides entry point, package contents, core distinction, relationship to Conversation Intent, and exploratory status. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/PROPOSAL.md` | Created proposal. | Defines purpose, product philosophy, tokenized retrieval model, relationships to Intent/Lenses/Search, architectural direction, non-goals, and acceptance criteria. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/DESIGN_NOTES.md` | Created design notes. | Records token semantics, candidate sources, retrieval semantics, UX risks, ownership boundaries, and minimal first-slice direction. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/CHECKLIST.md` | Created phased checklist. | Records concept approval, token model, ownership planning, UI walk planning, future implementation slices, and completion criteria. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/TESTS.md` | Created future validation plan. | Captures product, interaction, retrieval, ownership, lens, regression, and non-goal validation expectations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this work-package log entry. | Required by the work package request. |

## Needs Verification / Human Review

- Decide final user-facing label for Structured Conversation Retrieval.
- Decide first-slice token types.
- Decide whether first-slice token combination is AND-only.
- Decide whether this should replace the current Conversation metadata search
  field during the UI walk.
- Return to the Conversation Intent open-question cycle and link
  `05-categories-of-conversation-intent.md` from the main Intent package after
  the current interruption is resolved.

## Follow-Up Edit

Date: 2026-07-11

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/PROPOSAL.md` | Added the sentence "Structured Conversation Retrieval is not a query language. It is a language for describing remembered context." | Captures the intended product philosophy more precisely. |
| `DOCUMENTATION_PASS_LOG.md` | Logged this follow-up edit. | Maintains documentation pass traceability. |

---

# Conversation Intent Consolidation Pass

Date: 2026-07-11

Scope: Consolidated the approved Conversation Intent open-question decisions
into the canonical package documents under
`45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/`.

## Summary

This pass updated the Conversation Intent package from exploratory proposal
language into an approved architectural reference. The evaluation documents in
`01-OPEN-QUESTION-EVALUATION/` remain untouched as the decision record. The
canonical package now reflects the settled decisions for Core Favourites,
intent lifetimes, Working Sets, Suppressed visibility state, categories of
Conversation Intent, and Conversation Notes. Saved Investigations are now
explicitly identified as a separate future workspace architecture outside this
package.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/README.md` | Updated status and package overview; added settled decisions and decision-record links. | Makes the package read as the canonical architecture while preserving evaluation documents as rationale. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/PROPOSAL.md` | Consolidated approved decisions on categories, lifetimes, Tags, Favourites, Suppressed state, Working Sets, Notes, and Saved Investigations. | Removes resolved questions from proposal framing and records the resulting architecture. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/DESIGN_NOTES.md` | Replaced speculative sections with approved behavior and terminology; narrowed remaining design questions. | Keeps design notes focused on current architecture and unresolved implementation-level choices. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/CHECKLIST.md` | Marked concept decisions as approved and retained implementation/audit items as future work. | Separates settled architecture from pending implementation planning. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/TESTS.md` | Updated validation language for Suppressed state, Conversation Notes, and note-presence retrieval. | Aligns future validation strategy with approved architecture. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this consolidation entry. | Required by the consolidation request. |

## Needs Verification / Human Review

- Confirm whether the remaining design questions in `DESIGN_NOTES.md` are the
  correct ones to leave open before implementation planning.
- Decide when to convert the approved architecture into a concrete
  implementation slice.

---

# Conversation Tags Consolidation Pass

Date: 2026-07-11

Scope: Consolidated the Conversation Tags work package under
`45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/` after Conversation Intent became
the canonical architecture for user-authored Conversation meaning.

## Summary

This pass refocused Conversation Tags as a tag-specific product and UX package.
The package now treats Tags as durable Meaning intent built on Conversation
Intent, references Structured Conversation Retrieval where tags may later be
consumed as remembered-context tokens, and avoids re-explaining the broader
intent architecture.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Updated status, links, package framing, and governing principles. | Makes the package a focused tag feature specification rather than a duplicate architecture package. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/PROPOSAL.md` | Reframed the core model as tag-specific; delegated storage/identity/overlay ownership to Conversation Intent; revised retrieval/search relationship; narrowed open questions. | Keeps architecture in Conversation Intent and leaves only tag-specific product questions open. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/DESIGN_NOTES.md` | Collapsed duplicated architecture into an inherited-architecture summary; focused notes on tag UX, presentation, editing, scaling, and tag-specific questions. | Preserves useful tag design guidance while avoiding redefinition of the approved Conversation Intent seam. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/CHECKLIST.md` | Updated statuses, phase names, product decisions, and cross-lens items. | Separates settled Conversation Intent architecture from remaining tag implementation decisions. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/TESTS.md` | Reframed validation as tag-specific and linked to Conversation Intent validation for general architecture. | Prevents duplicate validation ownership and adds tag-specific UX/retrieval checks. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this consolidation entry. | Required by the redirection request. |

## Needs Verification / Human Review

- Confirm whether the remaining tag-specific open questions are the right set
  before implementation planning.
- Decide whether the first implementation slice should include retrieval by tag
  or only tag creation/assignment/display.

---

# Conversation Tags Open Question Evaluation: Tag Creation Workflow

Date: 2026-07-11

Scope: Added a tag-specific product decision record under
`45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/`.

## Summary

This pass evaluated the correct workflow for creating, editing, and managing
Conversation Tags. The recommendation is Conversation-first tagging: users
should create and apply tags while looking at a Conversation, with a secondary
Tag Manager reserved for cleanup, rename, deletion, and scale.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/07-tag-creation-and-management-workflow.md` | Created evaluation document. | Records the recommendation for Conversation-first tag creation, secondary tag management, duplicate prevention, card presentation, retrieval relationship, UX risks, and first-slice direction. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this evaluation entry. | Required by the open-question evaluation request. |

## Needs Verification / Human Review

- Confirm whether the first implementation slice should include only
  create/apply/remove/display, or also a minimal secondary rename/delete
  management surface.

## Follow-Up Refinement

Date: 2026-07-11

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/07-tag-creation-and-management-workflow.md` | Added the governing product principle that Tags should be discovered through use, refined the secondary management role, and documented authoring/retrieval symmetry. | Strengthens the product rationale without reopening the Conversation-first recommendation. |
| `DOCUMENTATION_PASS_LOG.md` | Logged this follow-up refinement. | Maintains documentation pass traceability. |

---

# Conversation Tags Implementation Readiness Audit

Date: 2026-07-11

Scope: Repository-aware implementation readiness audit for Conversation Tags,
confined to `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/`.

## Summary

This pass inspected current Core Favourites persistence, overlay database
conventions, canonical Conversation identity, Conversation read models,
Conversation card surfaces, action/provider boundaries, and test infrastructure.
It concluded that Tags are ready for a narrow first implementation slice, but
should not begin with a broad generic Conversation Intent framework.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/IMPLEMENTATION_READINESS_AUDIT.md` | Created repository-aware readiness audit and first-slice plan. | Maps the settled tag product direction onto the current codebase before implementation begins. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Linked the readiness audit from package contents. | Makes the implementation planning document discoverable. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation pass traceability. |

## Needs Verification / Human Review

- Confirm the recommended first implementation surface: Conversations sidebar
  card first, then Contact By Conversation and right Conversation excerpt panel.
- Confirm that first-slice tag storage should use first-class overlay tables
  rather than an overlay settings JSON blob.

---

# Conversation Tags First Slice Implementation Plan

Date: 2026-07-12

Scope: Added the concrete first vertical-slice implementation plan for
Conversation Tags under
`45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/`.

## Summary

This pass translated the approved Conversation Intent architecture, Conversation
Tags package, and implementation readiness audit into a narrow implementation
plan. The slice proves one complete workflow: create a Tag in Conversation
context, attach it to the canonical Conversation, persist it in overlay storage,
merge it into Conversation read models, display it in canonical Conversation
presentation, and preserve it across restart.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/FIRST_SLICE_IMPLEMENTATION_PLAN.md` | Created first-slice implementation plan. | Defines affected features, overlay additions, providers/actions, read-model changes, UI changes, test strategy, migration considerations, implementation order, and explicit non-goals. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Linked the first-slice plan from package contents. | Makes the implementation plan discoverable before coding begins. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation pass traceability. |

## Needs Verification / Human Review

- Approve or revise the plan assumptions before implementation:
  Conversations sidebar as first surface, first-class overlay tables, separate
  tag definitions/assignments, and no global Tag Manager in the first slice.

---

# Conversation Tags First Vertical Slice Implementation Documentation

Date: 2026-07-12

Scope: Updated the Conversation Tags work package to reflect the implemented
first vertical slice.

## Summary

The first Conversation Tags slice now supports creating/applying/removing tags
from a Conversation in the Conversations sidebar, persisting tags in overlay
storage, merging tag state into Conversation signature display models, and
displaying tag labels on the canonical Conversation card for the first surface.

Application code, tests, generated files, and overlay schema were changed as
part of the implementation. This log entry records only the documentation
updates made after implementation.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Marked first slice implemented and summarized implemented/deferred scope. | Keeps the package entry point current without claiming full tag feature completion. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/CHECKLIST.md` | Checked off completed planning, first-slice, overlay, identity, and display items. | Distinguishes implemented first-slice behavior from future tag management/retrieval work. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/TESTS.md` | Added implemented first-slice test coverage summary. | Records what is currently proven by tests versus future validation needs. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/FIRST_SLICE_IMPLEMENTATION_PLAN.md` | Marked plan implemented and added outcome/deferred sections. | Preserves the plan as historical implementation context. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this implementation documentation entry. | Maintains traceability for documentation changes. |

## Needs Verification / Human Review

- Manual app verification: create a tag on a Conversation in the Conversations
  sidebar, restart the app, and confirm the tag remains visible on that card.
- Architecture test still reports one unrelated pre-existing layout debug color
  literal in `lib/config/theme/widgets/layout/vertical_column_bands.dart`.

---

# Conversation Tags Post-Implementation Architectural Review

Date: 2026-07-12

Scope: Reviewed the implemented first Conversation Tags vertical slice against
the approved Conversation Intent architecture, Conversation Tags package,
Structured Conversation Retrieval package, readiness audit, and first-slice
implementation plan.

## Summary

The review concluded that the first Conversation Tags vertical slice validates
the approved architecture. Tags are persisted as overlay-owned Conversation
Intent, graph projection remains untouched, Conversation-owned read/action
providers merge tags at read time, and the canonical Conversation Card remains
pure presentation. No code changes were recommended before the next slice.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/POST_IMPLEMENTATION_ARCHITECTURAL_REVIEW.md` | Created post-implementation architectural review. | Records architectural validation, implementation observations, deviations, debt, lessons, and next-slice recommendations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Manually verify the first slice in the running app: create a tag, apply it to
  a Conversation, remove it, restart, and confirm persistence.
- Choose the second implementation slice explicitly before expanding tag
  display, retrieval, or management behavior.

---

# Structured Conversation Retrieval Tag Token Slice

Date: 2026-07-12

Scope: Implemented and documented the first Structured Conversation Retrieval
vertical slice: Tag tokens in the Conversations sidebar Browse list.

## Summary

The Conversations Browse retrieval field now consumes existing Conversation
Tags. Typing a partial Tag name suggests known Tags, accepting a suggestion
creates a visible token, and selected Tag tokens filter Conversation signatures
with simple AND semantics. The slice does not search message bodies and does not
own Tag definitions or assignments.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md` | Marked the Tag-token vertical slice implemented and recorded implemented/deferred scope. | Keeps the package entry point current. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/PROPOSAL.md` | Added implemented first-slice section. | Records that Tag-token retrieval now proves the model without implementing other token types. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/DESIGN_NOTES.md` | Updated minimal first-slice direction and open questions. | Distinguishes implemented Tag-token behavior from future retrieval work. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/CHECKLIST.md` | Checked off approved/implemented first-slice items. | Tracks implementation progress while preserving future phases. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/TESTS.md` | Added implemented test coverage summary. | Records focused validation for known Tag suggestions and AND filtering. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Noted that Structured Conversation Retrieval consumes existing Tags as tokens. | Clarifies ownership: Tags remain Conversation Intent; retrieval consumes them. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Verification

- `flutter test test/features/conversations/application/conversation_retrieval/conversation_retrieval_tag_token_test.dart test/features/conversations/application/conversation_signatures/conversation_signature_display_provider_test.dart --reporter expanded`
- `flutter analyze`

## Needs Verification / Human Review

- Manual app verification: create two Tags, tag several Conversations, type a
  partial Tag, accept the suggestion, add a second Tag token, remove a token,
  and confirm the Conversation list updates immediately.

---

# Tag Visibility Policy Work Package

Date: 2026-07-12

Scope: Created a new feature-planning package for Tag Visibility Policy using
`04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/08-tag-visibility-policy.md`
as the seed.

## Summary

The new package records the approved direction that Conversation visibility is
best modeled as policy attached to Tag definitions rather than as a separate
Conversation-level suppression mechanism. It preserves the key behavior:
ordinary Browse can exclude low-value classes of Conversations, while explicit
Structured Conversation Retrieval by Tag still returns those Conversations.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/README.md` | Created package overview. | Establishes the package, governing principles, and relationship to Tags, Conversation Intent, and retrieval. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/PROPOSAL.md` | Created feature proposal. | Defines product rationale, core model, ownership, first-slice direction, and non-goals. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/DESIGN_NOTES.md` | Created design notes. | Captures UX language, browse-vs-retrieval semantics, conflict cases, and first-slice UI considerations. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/CHECKLIST.md` | Created phased checklist. | Provides a future implementation and validation sequence without starting code work. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/TESTS.md` | Created validation strategy. | Records persistence, read-model, UI, architecture, and manual verification expectations. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added `06-STRUCTURED-CONVERSATION-RETRIEVAL/` and `07-TAG-VISIBILITY-POLICY/` to active planning folders. | Keeps the feature-planning index discoverable and current. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Confirm first implementation slice before code changes.
- Decide final user-facing language for the visibility action: for example,
  "Suppress from Browse", "Hide Conversations with this Tag", or "Show only
  when requested".

---

# Tag Visibility Policy First Slice

Date: 2026-07-12

Scope: Implemented and documented the first Tag Visibility Policy vertical
slice.

## Summary

Conversation Tag definitions now carry an overlay-owned visibility policy.
Tags default to ordinary visibility, can be marked as suppressing ordinary
Browse from the existing Conversation Tag editor, and are merged into
Conversation read models at read time. Default Conversations Browse excludes
Conversations carrying suppressing Tags, while explicit Structured Conversation
Retrieval by that Tag still returns them.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/README.md` | Marked the first slice implemented and summarized actual behavior. | Keeps the package entry point current. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/PROPOSAL.md` | Recorded the implemented first-slice shape. | Distinguishes approved architecture from deferred feature expansion. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/DESIGN_NOTES.md` | Added implemented first-slice answers. | Captures the current UI and behavior without closing future wording questions. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/CHECKLIST.md` | Checked off completed first-slice items. | Tracks implementation progress. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/TESTS.md` | Added implemented focused verification coverage. | Records how the slice is validated. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Verification

- `flutter test test/essentials/db/infrastructure/data_sources/local/overlay/overlay_database_test.dart test/features/conversations/infrastructure/repositories/overlay_conversation_tag_repository_test.dart test/features/conversations/application/conversation_tags/conversation_tag_actions_provider_test.dart test/features/conversations/application/conversation_signatures/conversation_signature_display_provider_test.dart test/features/conversations/application/conversation_retrieval/conversation_retrieval_tag_token_test.dart test/features/conversations/presentation/widgets/conversation_signature_card_test.dart --reporter compact`
- `flutter analyze`

## Needs Verification / Human Review

- Manual app verification: mark a low-value Tag as suppressed from Browse,
  confirm default Browse excludes matching Conversations, then retrieve that
  Tag explicitly and confirm the Conversations return.

---

# Contact-Backed Conversation Tags Linkage

Date: 2026-07-13

Scope: Linked the deferred Contact Tags evaluation from higher-order planning
documents without changing implementation scope.

## Summary

The Contact Tags evaluation identifies a likely future need for
Contact-backed Conversation Tags: identity-backed retrieval coordinates that
refer to canonical Contact identity instead of copied display text. This pass
made that evaluation discoverable from the Conversation Tags, Conversation
Intent, Structured Conversation Retrieval, and feature-planning index entry
points while preserving it as deferred work.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Added the Contact Tags evaluation to links, package contents, deferred scope, and a short deferred section. | Makes the concept discoverable from the Tag package without implying implementation approval. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/README.md` | Linked the Contact Tags evaluation as related deferred Conversation Intent work. | Records that Contact-backed tags relate to intent/retrieval but are not part of the current slice. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md` | Added a deferred Contact retrieval coordinate section. | Ensures future Contact-token work finds the Contact Tags reasoning. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Updated the Conversation Tags row to mention deferred Contact-backed Conversation Tags. | Improves top-level retrieval. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- None. This was linkage only; implementation remains deferred.

---

# Conversation Card Chat Hook Evaluation

Date: 2026-07-13

Scope: Created a UI/UX evaluation for optionally showing formatted chat hooks
on one-to-one Conversation Cards.

## Summary

The evaluation records a future refinement for Conversation Cards: one-to-one
cards may need a quiet secondary `via ...` line to distinguish multiple
canonical Conversations that resolve to the same Contact display name. The
document keeps this independent from Contact-backed Conversation Tags:
Contact-backed Tags are retrieval coordinates, while formatted chat hooks are
visual disambiguation metadata.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/conversation-card-chat-hook.md` | Created UI/UX evaluation. | Captures rationale, proposed behavior, one-to-one-only scope, relationship to Contact Tags, risks, and recommendation without implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- None. This is an evaluation document only; implementation remains deferred.

---

# Conversation Card Chat Hook Presentation Evaluation

Date: 2026-07-13

Scope: Added a follow-up UI/UX evaluation for the visual presentation of the
one-to-one Conversation Card chat hook after real-data use.

## Summary

The evaluation records that the chat hook is not ordinary metadata; it is an
identity qualifier explaining why multiple one-to-one Conversations can share
the same Contact display name. The recommendation is to evaluate a future
refinement where hooks are shown conditionally for duplicate display identities,
drop the `via` prefix, and render as a smaller near-title line within the
Conversation identity block.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/conversation-card-chat-hook-presentation.md` | Created UI/UX evaluation. | Captures visual hierarchy, typography, conditional display, relationship to glyphs and Contact Tags, risks, and a future implementation-slice recommendation. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- None. This is an evaluation document only; no implementation was performed.

---

# Cross-Column Layout Canonical Documentation

Date: 2026-07-14

Scope: Created a top-level canonical documentation folder for page-level
cross-column vertical alignment and linked it from the relevant documentation
indexes.

## Summary

The vertical alignment work for MessageLens had become hard to find because its
mechanics were spread across active UI-walk notes, Conversation ownership
documents, and the sidebar content-seam work package. This pass created
`09-CROSS-COLUMN-LAYOUT/` as the durable documentation home for the mechanical
contract: title/context column bands, content-start alignment, wrapper behavior,
and the sidebar cassette content-start seam.

The UI-walk and feature-package documents remain valuable design history. The
new folder is now the place to look when a future developer or agent needs to
understand how left, center, and right panels line up across the window.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/README.md` | Created canonical folder overview. | Establishes this folder as the source of truth for cross-column layout mechanics. |
| `09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md` | Created durable alignment contract. | Defines the title band, context band, content-start invariant, ownership rules, and current band heights. |
| `09-CROSS-COLUMN-LAYOUT/01-column-band-wrappers.md` | Created wrapper mechanics reference. | Documents `TitleColumnBand`, `ContextColumnBand`, child placement, debug margins, and the relationship to older `app_panel_bands.dart` support primitives. |
| `09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md` | Created sidebar seam reference. | Documents how the cassette system participates through `SidebarCassetteLayoutAnchor.preferredContentStart` without surrendering sidebar ownership. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Created current applied Search-page note. | Captures the present left/center/right mapping and known tuning issue around search-control placement. |
| `09-CROSS-COLUMN-LAYOUT/04-design-history-and-cross-references.md` | Created history/cross-reference guide. | Links the canonical contract back to UI-walk history, sidebar seam design notes, and Conversation ownership repair documents. |
| `README.md` | Added `09-CROSS-COLUMN-LAYOUT/` to the canonical map and clarified that `95-WALK-UI-TREE/` now contains historical layout review notes. | Makes the new canonical layout home discoverable from the project index. |
| `00-START-HERE.md` | Added cross-column vertical alignment to canonical owners. | Gives cold-start readers an obvious destination for layout alignment questions. |
| `07-CENTER-PANEL-LAYOUTS/README.md` | Added cross-column alignment to out-of-scope concerns. | Clarifies that center-panel layout does not own page-wide alignment. |
| `08-SIDEBAR-LAYOUTS/README.md` | Added cross-column alignment/content-start seams to out-of-scope concerns. | Clarifies that sidebar layout does not own peer-panel alignment. |
| `95-WALK-UI-TREE/README.md` | Pointed cross-column mechanics to `09-CROSS-COLUMN-LAYOUT/`. | Separates active UI review/history from durable layout mechanics. |
| `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` | Added a notice that canonical mechanics now live in `09-CROSS-COLUMN-LAYOUT/`. | Preserves the old folder as design history while preventing future agents from treating it as the only source of truth. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Review whether the current band heights documented here (`TitleColumnBand` 72,
  `ContextColumnBand` 166) should be treated as stable tokens or still as
  Search-page-specific provisional values.
- Review the known Search-page tuning issue: the search controls may still sit
  too close to the content below. The new docs record where that should be
  solved, not the final visual tuning.

---

# Cross-Column Layout Terminology Rename

Date: 2026-07-14

Scope: Renamed the cross-column alignment vocabulary from earlier geometric
band names to title/context bands in code and documentation.

## Summary

The previous labels described geometry but not the role of each aligned region.
This pass renamed the public wrapper classes and related implementation
terminology to `TitleColumnBand` and `ContextColumnBand` so future agents can
reason about the bands by purpose: the title band owns panel identity, and the
context band owns pre-content scope, controls, or object context.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Renamed the public wrapper classes to `TitleColumnBand` and `ContextColumnBand`. | Aligns code entities with the durable cross-column layout vocabulary. |
| `lib/config/theme/widgets/layout/app_panel_bands.dart` | Renamed transitional frame constants/parameters to title/context wording. | Prevents older support primitives from preserving stale terminology. |
| `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart` | Updated wrapper usage and renamed the internal evidence context-band helper. | Keeps message evidence header implementation aligned with the shared layout contract. |
| `lib/features/conversations/presentation/view/conversation_excerpt_panel_view.dart` | Updated wrapper usage and renamed title/context frame parameters and helper. | Keeps the conversation excerpt panel aligned with the shared layout contract. |
| `lib/essentials/navigation/application/panel_widget_providers.dart` | Updated wrapper usage and renamed sidebar seam internals to context-zone wording. | Keeps the cassette content-start seam vocabulary consistent with the shared contract. |
| `09-CROSS-COLUMN-LAYOUT/` | Updated canonical layout documentation to title/context terminology. | Makes this folder the clear source for current naming and mechanics. |
| `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` | Updated historical UI-walk bridge terminology. | Preserves historical context while pointing to current names. |
| `README.md` | Updated canonical-map wording. | Keeps the project index aligned with current layout language. |
| `DOCUMENTATION_PASS_LOG.md` | Updated the immediately preceding cross-column entry and appended this rename entry. | Maintains traceability for the terminology change. |

## Needs Verification / Human Review

- None beyond normal UI review of the existing cross-column layout tuning. This pass is a terminology and symbol rename, not a layout behavior change.

---

# Cross-Column Layout Tracks Work Package

Date: 2026-07-14

Scope: Created a new exploratory feature work package for a potential successor
to the current fixed title/context band cross-column layout model.

## Summary

The current cross-column layout contract in `09-CROSS-COLUMN-LAYOUT/` remains
the canonical implemented model. This pass created
`45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/` to explore a more
general track-based model before any implementation work begins.

The package records the proposed direction: columns declare preferred heights
for shared horizontal layout tracks, the page resolves each track by maximum
required height, and each participating column renders inside the resolved
track plan. The first future implementation slice is explicitly limited to the
Search page, with only the sidebar top menu participating in Track A.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Created package overview. | Establishes status, scope, relationship to the current canonical layout docs, and first-slice limits. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Created proposal. | Defines layout tracks, height resolution, ownership, non-goals, and Search-page-first success criteria. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Created design notes. | Captures product rationale, architectural rationale, variable-content handling, sidebar participation, migration strategy, risks, and open questions. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Created phased checklist. | Records decision gates and a conservative implementation path without approving implementation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Created validation strategy. | Defines future unit, widget, regression, and manual tests for a track-based implementation. |
| `45-NEW-FEATURE-ADDITION/README.md` | Added active/planning rows for `06`, `07`, and `08`, and updated review date. | Keeps the workflow README aligned with the current numbered planning folders. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added `08-CROSS-COLUMN-LAYOUT-TRACKS/` to the active/planning table and updated review date. | Makes the new package discoverable while clarifying that `09-CROSS-COLUMN-LAYOUT/` remains the implemented reference. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Review whether the track concept should use semantic names such as
  `identity/context/content` or ordinal names such as `Track A/Track B`.
- Review whether preferred heights should be declared by models, widgets, or
  layout adapters before implementation begins.
- Confirm that the first implementation slice should remain Search-page-only
  and should not solve autonomous sidebar cassette placement.

---

# Cross-Column Layout Tracks Flutter Investigation

Date: 2026-07-14

Scope: Added a Flutter implementation investigation to the Cross-Column Layout
Tracks work package.

## Summary

This pass evaluated which Flutter layout mechanisms best fit the approved
layout-track architecture. The recommendation is to start with ordinary widget
composition plus explicit, model-published layout requirements. The page should
resolve a shared track plan and pass resolved heights into compatibility
wrappers, rather than using post-frame measurement, `CustomMultiChildLayout`, or
custom render objects in the first slice.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/FLUTTER_IMPLEMENTATION_INVESTIGATION.md` | Created Flutter implementation investigation. | Evaluates ordinary composition, `LayoutBuilder`, inherited plans, provider-driven models, `CustomMultiChildLayout`, `MultiChildRenderObjectWidget`, and custom `RenderBox`; recommends model-published requirements for the first Search-page slice. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added the investigation to package contents. | Makes the new implementation guidance discoverable. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Confirm whether first-slice requirements should be computed locally in the
  Search page or exposed through a narrowly scoped page-level provider.
- Confirm whether track IDs should remain ordinal (`Track A`, `Track B`) during
  the prototype or become semantic names before implementation.

---

# Cross-Column Layout Tracks Terminology Refinement

Date: 2026-07-14

Scope: Refined terminology in the Cross-Column Layout Tracks work package so
the package describes declarative track requirements rather than preferred
widget heights.

## Summary

This pass updated the package language from the older height-centered framing to
the settled track-centered model. The recommended terms are now `TrackId`,
`TrackRequirement`, and `ResolvedTrackPlan`. The documentation now emphasizes
that the page does not ask widgets how tall they are after layout. Instead,
participating columns or layout adapters declare what each Track requires, the
page resolves a shared TrackPlan, and columns render within that resolved plan.

Height remains the first requirement supported by the proposed architecture, but
the wording now leaves room for future requirements such as minimum height,
compact variants, alignment preferences, and overflow policy.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Reframed the package overview around declared track requirements and a shared `ResolvedTrackPlan`. | Clarifies that tracks, not preferred heights, are the architectural abstraction. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Replaced height-centered language with `TrackRequirement` / `ResolvedTrackPlan` terminology and added explicit declarative architecture wording. | Records the governing model: columns declare requirements; the page resolves and distributes the plan. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Updated ownership and variable-content language to center on `TrackRequirement` values. | Keeps design notes aligned with the broader requirement model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Updated future implementation checklist entries to use `TrackRequirement` and `ResolvedTrackPlan`. | Ensures a future implementation starts with the current naming. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/FLUTTER_IMPLEMENTATION_INVESTIGATION.md` | Replaced `LayoutTrackRequirement`, `ResolvedLayoutTrackPlan`, and preferred-height wording with `TrackRequirement`, `ResolvedTrackPlan`, and declarative requirement language. | Keeps Flutter implementation guidance consistent with the approved terminology. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Updated validation wording from preferred heights to declared height requirements. | Aligns future tests with the track requirement model. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Confirm final code symbol names during implementation. The package now
  recommends `TrackId`, `TrackRequirement`, and `ResolvedTrackPlan`, but no code
  has been changed in this documentation-only pass.

---

# Cross-Column Layout Tracks Track A Implementation

Date: 2026-07-14

Scope: Implemented the first vertical slice of the Cross-Column Layout Tracks
architecture for Search-page Track A only.

## Summary

This pass proves the declarative track model without expanding into Track B,
sidebar cassette placement, or broad page migration. The Search page now scopes
a resolved Track A plan when `Search all messages` is active. The existing
`TitleColumnBand` compatibility wrapper consumes that resolved height, so the
sidebar top menu, center title, and right Conversation title share the same
page-owned identity-track allocation.

The existing wrapper system remains in place. `ContextColumnBand`, sidebar
cassette flow, Contacts, Conversations, and other pages were not migrated.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Added `TrackId`, `TrackRequirement`, `ResolvedTrackPlan`, `ResolvedTrackPlanScope`, and the Search-page Track A plan. | Provides the minimal feature-neutral track model for the first slice. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Let `TitleColumnBand` consume a resolved Track A height while preserving existing fallback behavior. | Keeps the existing wrapper system while moving Track A height ownership to the page plan. |
| `lib/essentials/navigation/presentation/view/workspace_layout.dart` | Scoped the left/center workspace with the Search-page Track A plan only when Search all messages is active. | Limits the first slice to the Search page and avoids affecting other sidebar modes. |
| `lib/essentials/navigation/presentation/view/macos_app_shell.dart` | Scoped the right panel with the same Search-page Track A plan when Search all messages is active. | Lets the Conversation right panel participate in Track A without moving ownership into Search widgets. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Added focused tests for track resolution and `TitleColumnBand` resolved/default height behavior. | Verifies the Track A proof slice independently of the full Search page tree. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Marked Track A as first-slice implemented and recorded deferred work. | Keeps the work package current. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Added implementation status. | Separates proven Track A behavior from future architecture. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Updated migration strategy with completed Track A steps. | Records actual implementation progress without treating Track B as done. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Checked off Track A-only implementation items and left Track B/sidebar work deferred. | Maintains planning accuracy. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added implemented Track A test coverage. | Makes the validation path discoverable. |

## Verification

- `flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact`
- `flutter analyze`

## Deferred

- Track B negotiation.
- Sidebar cassette participation beyond the top menu.
- Contacts / Conversations page migration.
- Wrapper retirement.
- Search-page visual retuning beyond Track A ownership.

---

# Cross-Column Layout Tracks Track B Implementation

Date: 2026-07-14

Scope: Implemented the second vertical slice of the Cross-Column Layout Tracks
architecture for Search-page Track B only.

## Summary

This pass proves that additional tracks can be added incrementally. Track B is
the supporting identity track for the Search page. Only the center message
evidence metadata subheader renders visible content in Track B. The sidebar and
right panel declare empty Track B participation and receive the same resolved
allocation.

Track B was refined to be tight to the metadata line rather than functioning as
a general spacing band. Search-scope explanatory text remains below Track B
with the search controls instead of being clipped inside the metadata track.

Search controls, sidebar orientation text, Conversation Cards, excerpt
descriptions, and cassette placement were deliberately left outside Track B.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Added `TrackId.trackB` and changed the Search page plan to include Track A and a tight Track B requirement. | Proves multi-track resolution and empty peer participation without using Track B as hidden spacing. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Let `ContextColumnBand` consume a resolved Track B height while preserving fallback behavior. | Keeps the compatibility wrapper while moving Track B height ownership to the page plan. |
| `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart` | Split the fixed-frame Search-page header so metadata occupies Track B, while search-scope text and search/actions remain below it when a track plan is present. | Ensures Track B contains only supporting identity metadata and can remain tight. |
| `lib/features/conversations/presentation/view/conversation_excerpt_panel_view.dart` | Added an empty Track B allocation before the existing Conversation Card/excerpt block when a track plan is present. | Keeps right-panel Track B empty without moving Conversation Card content into Track B. |
| `lib/essentials/navigation/application/panel_widget_providers.dart` | Changed the Search sidebar seam to render an empty Track B allocation, then continue the existing cassette chain below it. | Keeps sidebar Track B empty and avoids automatic cassette placement. |
| `lib/essentials/navigation/presentation/view/workspace_layout.dart` | Updated the Search page to use the Track A/Track B plan. | Applies the second slice without changing non-Search surfaces. |
| `lib/essentials/navigation/presentation/view/macos_app_shell.dart` | Updated the right panel to use the Track A/Track B plan. | Applies empty right-panel Track B participation for Search. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Added Track B resolution and `ContextColumnBand` resolved/default behavior coverage. | Verifies the Track B proof slice independently of the full Search page tree. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Marked Track B as implemented and documented empty participation. | Keeps the work package current. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated implementation status and Track B examples. | Clarifies that Track B is metadata-only in this slice. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Updated sidebar participation and migration notes. | Records the implemented empty-track behavior. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Checked off Track B-only implementation items and left later tracks deferred. | Maintains planning accuracy. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added Track B validation notes. | Makes the new test expectations discoverable. |

## Verification

- `flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact`
- `flutter analyze`

## Deferred

- Track C or later tracks.
- Search controls migration.
- Conversation Card / excerpt description migration.
- Sidebar cassette participation beyond empty Track B.
- Contacts / Conversations page migration.
- Wrapper retirement.

---

# Cross-Column Layout Tracks Content-Tight Occupied Tracks

Date: 2026-07-14

Scope: Tightened the Search-page Track A/Track B implementation and updated the
Cross-Column Layout Tracks package.

## Summary

Colored track diagnostics showed that occupied tracks were still preserving
hidden slack from old compatibility-wrapper padding and broad fixed requirement
values. This pass records and implements the stricter invariant: occupied
tracks are exactly as tall as their tallest natural occupant; intentional
spacing belongs in explicit empty tracks.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Replaced broad Search-page Track A/Track B requirements with named natural occupant contracts for the sidebar top menu trigger, panel title line, and metadata line. | Prevents old spacing constants from functioning as hidden track height. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Removed top/bottom compatibility-wrapper padding whenever a resolved track is present. | Ensures resolved occupied tracks contain content only, not discretionary vertical spacing. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Updated resolved Track A/Track B expectations to use the named natural occupant contracts. | Keeps the track proof tests aligned with the content-tight invariant. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added the content-tight occupied-track rule and explicit empty-track spacing principle. | Makes the current layout rule discoverable. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Clarified that occupied track height resolves from natural occupant requirements and excludes breathing room. | Prevents future track slices from reintroducing hidden spacing. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Added wrapper guidance for resolved tracks. | Documents the compatibility-wrapper constraint. |

---

# Cross-Column Layout Tracks Flush Track A Start

Date: 2026-07-14

Scope: Removed the Search-page page-top inset from the resolved track plan.

## Summary

Visual review confirmed Track A and Track B were content-tight, but Track A was
still separated from the top of the page content surface by a page-top inset.
This pass sets the Search-page inset to zero so Track A starts flush. Any future
separation above Track A should be represented by an explicit shim track rather
than an implicit inset.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Set the Search-page `pageTopInset` requirement to `0`. | Removes hidden space above Track A. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Updated the Search-page Track A test to assert no hidden top inset. | Protects the flush-start contract. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Documented that Search Track A starts flush with the content surface. | Keeps implementation notes current. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Replaced page-top inset language with explicit flush-start language. | Prevents future confusion between track height and page spacing. |

---

# Cross-Column Layout Tracks Track A Geometry Correction

Date: 2026-07-14

Scope: Refined the Search-page Track A implementation so the page-top inset is
separate from the resolved Track A height.

## Summary

The second-slice visual check showed that Track B was correctly narrow, but the
metadata still started too low because Track A was preserving the old 72-pixel
title-wrapper allocation. This pass separates page top inset from Track A
height. Track A is now resolved from actual occupant requirements, while the
page-top inset is represented as its own page-owned value in the resolved track
plan.

This avoids hiding vertical spacing inside Track A and keeps the sequence:

```text
page top inset
Track A: selector / title / title
Track B: empty / metadata / empty
```

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Added `pageTopInset` to `ResolvedTrackPlan` and reduced Search-page Track A requirements to occupant-sized values. | Separates page inset from Track A allocation. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | When a resolved Track A plan is present, renders the page-top inset outside the Track A band and removes embedded top padding from the band itself. | Prevents legacy wrapper padding from becoming hidden track height. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Added coverage proving page-top inset is added outside resolved Track A height. | Protects the corrected geometry. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Documented page-top inset as separate from Track A. | Keeps the work package aligned with the implementation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Added architectural note that page insets are not track requirements. | Prevents future confusion between insets and tracks. |

## Verification

- `flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact`
- `flutter analyze`

---

# TrackOccupant Architecture Analysis

Date: 2026-07-15

Scope: Added an exploratory architecture analysis for a future TrackOccupant
seam in the Cross-Column Layout Tracks package.

## Summary

The first layout-track slices proved Track A and Track B negotiation, but the
current implementation still uses page-level numeric requirements for title,
metadata, and top-menu occupants. This documentation pass analyzes a
`TrackOccupant` model that would let presentation contracts declare track
requirements without querying rendered widgets or using post-frame measurement.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Added a full architecture analysis covering definition, API shape, requirement context, text/control/glyph/card handling, alternatives, risks, testing, and first implementation candidate. | Gives the proposed TrackOccupant seam a single discoverable planning document before any implementation work. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Linked the new TrackOccupant analysis from package contents. | Keeps the work package index current. |

---

# TrackOccupant Implementation-Plan Constraint Refinement

Date: 2026-07-15

Scope: Incorporated implementation-plan decisions into the TrackOccupant
architecture analysis.

## Summary

The TrackOccupant analysis now records the settled constraints for a future
first-slice implementation plan: all visible track content uses occupants,
empty cells have no occupant, constant and calculated requirements share the
same abstraction, shim tracks are ordinary fixed-height occupants, and the
coordinator remains feature-blind.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Added implementation-plan constraints and refined sections on empty cells, shim tracks, constant requirements, calculated requirements, coordinator responsibility, and first-slice scope. | Ensures the future implementation plan follows the revised architecture without implying implementation approval. |

---

# TrackOccupant Presentation Construction Wording

Date: 2026-07-15

Scope: Refined TrackOccupant terminology in the Cross-Column Layout Tracks
package.

## Summary

Replaced Flutter-specific "widget construction" phrasing with presentation
construction language. The architecture now reads as requirement calculation
plus construction of the presentation widget, which better captures the
conceptual boundary while preserving the concrete Flutter implementation shape.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Reworded TrackOccupant ownership and API sections from "widget construction" to "construction of the presentation widget" / "presentation construction." | Keeps the architecture concept durable while still acknowledging the current Flutter implementation. |

---

# TrackOccupant First Implementation Slice

Date: 2026-07-15

Scope: Updated the Cross-Column Layout Tracks work package after implementing
the first Search-page TrackOccupant slice.

## Summary

Search-page Track A/B requirements are now derived from declarative occupants
instead of page-owned numeric declarations. The documentation now records that
the first occupant slice is implemented while preserving the deferred scope for
future tracks, sidebar cassette participation, Conversation Cards, glyphs, and
Contacts migration.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Updated status and implemented-slice notes to describe occupant-derived Track A/B requirements and empty cells as omitted occupants. | Keeps the package narrative aligned with the implementation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added Phase 4A for the first TrackOccupant slice and marked focused occupant tests complete. | Makes remaining layout-track work discoverable without implying broader migration is done. |

---

# TrackOccupant Implementation Audit

Date: 2026-07-15

Scope: Verified the first TrackOccupant implementation slice against the
approved implementation seed.

## Summary

The audit found the first TrackOccupant slice architecturally sound. Search
Track A/B requirements are occupant-derived, empty cells contribute no
requirements, and the implementation remains within the approved first-slice
scope. The report records two caveats for future slices: finite-width
requirement contexts are still deferred, and the Track B plan currently uses a
representative metadata string because Track B is a single-line height track.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT/IMPLEMENT_TRACK_OCCUPANT_AUDIT.md` | Added implementation audit and verification report. | Provides the requested analysis report in the new TrackOccupant folder. |

---

# Cross-Column Track C Shim Slice

Date: 2026-07-15

Scope: Updated the Cross-Column Layout Tracks package after implementing the
first explicit Search-page shim track.

## Summary

Track C now models the first intentional cross-column spacing shim. The package
documents that empty spacing should be represented as an ordinary fixed-height
track occupant rather than as hidden padding inside Track A, Track B, or their
compatibility wrappers.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Updated package status and implemented-slice notes to include Track C as a fixed-height shim track. | Records that the Search page now separates metadata from supporting search content using an explicit empty track. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added Phase 4B for the Track C shim slice and focused shim validation. | Makes the next layout-track increment discoverable while preserving deferred scope for later tracks. |

---

# Track Cell And Shim Clarification

Date: 2026-07-15

Scope: Clarified Cross-Column Layout Tracks terminology and shim-track
ownership after the first Track C slice.

## Summary

The layout-track package now explicitly states that spacing shims are ordinary
tracks whose height is contributed by one `FixedHeightTrackOccupant` in one
cell. Peer cells honor the resolved allocation but do not contain duplicate
shim occupants. The package also now uses the `<Track letter><Column number>`
cell vocabulary, such as A1, B2, and C3.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added track-cell vocabulary and clarified the C1/C2/C3 Track C mapping. | Makes the current Search-page layout inspectable and prevents treating Track C as direct page-plan metadata. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Added shim-track and track-cell sections. | Records the settled architectural rule that spacing and content use the same occupant negotiation mechanism. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated older Track C examples so Track C is no longer described as primary content in the current Search-page implementation. | Removes stale terminology that conflicted with the implemented Track C shim. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added validation expectations for one C2 shim occupant and empty C1/C3 cells. | Ensures future tests protect against direct fixed-height track overrides or duplicate shim occupants. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Refined Track C checklist items around C2 ownership and empty C1/C3 cells. | Aligns implementation tracking with the settled cell vocabulary. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Updated the shim example to C1/C2/C3 and removed shim representation from open questions. | Marks the shim architecture as settled by implementation. |

---

# Track Semantic Neutrality Correction

Date: 2026-07-15

Scope: Corrected Cross-Column Layout Tracks terminology so tracks remain
ordinal geometric coordinates only.

## Summary

The previous Track C wording implied that a track could have an intrinsic role,
such as spacing or shim behavior. The corrected model is that tracks know only
their ordinal identity and resolved geometry. Meaning belongs to occupants and
to the page composition that places those occupants.

Current Search-page occupancy is documented as cell-specific:

- A1: Search top menu occupant.
- A2: "All messages" text occupant.
- A3: "Conversation" text occupant.
- B1: no occupant.
- B2: metadata text occupant.
- B3: no occupant.
- C1: no occupant.
- C2: `FixedHeightTrackOccupant(height: 8)`.
- C3: no occupant.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Replaced semantic track descriptions with Search-page cell occupancy. | Makes clear that Track A/B/C are coordinates, not roles. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Reframed examples around occupant placement rather than track meaning. | Prevents future implementations from teaching the coordinator semantic track roles. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Replaced shim-track terminology with fixed-height spacing occupant language. | Keeps spacing under the same occupant negotiation mechanism without assigning meaning to the track. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Renamed the implemented C2 slice around fixed-height occupant placement. | Keeps implementation tracking aligned with semantic-neutral track vocabulary. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Updated validation language to check C2 fixed-height occupant behavior rather than a shim track. | Ensures tests protect the generic track model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Updated empty-cell and spacing guidance to avoid semantic track roles. | Clarifies that spacing and content both use occupants. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT/IMPLEMENT_TRACK_OCCUPANT.md` | Updated the implementation seed language around fixed-height spacing occupants. | Prevents older seed text from reintroducing shim-track terminology. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT/IMPLEMENT_TRACK_OCCUPANT_AUDIT.md` | Replaced Track A/B summaries with A1/A2/A3 and B1/B2/B3 occupancy. | Aligns audit language with the corrected model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT/IMPLEMENT_TRACK_OCCUPANT_CHECK.md` | Updated the next-slice recommendation language. | Keeps future work framed around occupants, not semantic tracks. |
| `lib/essentials/navigation/presentation/layout/search_page_track_plan.dart` | Renamed the Search-page C2 height constant and updated occupancy comments. | Removes semantic track naming from code. |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Updated `FixedHeightTrackOccupant` comments. | Clarifies that fixed-height allocation belongs to the occupant. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Updated compatibility-wrapper comments. | Avoids implying fixed semantic meanings for Track A/B. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Updated fixed-height occupant test wording. | Keeps test intent aligned with semantic-neutral tracks. |

---

# Track Cell Alignment Principle

Date: 2026-07-15

Scope: Added Track Cell Alignment as a future Cross-Column Layout Tracks
architecture principle.

## Summary

The layout-track package now distinguishes three independent concepts:

- track geometry: the resolved height and position of a shared track;
- occupant requirement: the natural space requested by an occupant;
- track cell alignment: placement of an occupant inside an already-resolved
  cell allocation.

Track Cell Alignment belongs to page composition. It is not a property of the
track, the `TrackOccupant`, or the underlying presentation widget. Initial
alignment options should remain limited to top, center, and bottom. Alignment
must not alter track requirements, resolved track height, or negotiation, and
must not become hidden padding.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added Track Cell Alignment overview and clarified that designers may use semantic language while the layout engine records only geometry and occupancy. | Gives future readers the top-level mental model before implementation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Added architectural rule separating track geometry, requirements, and alignment. | Establishes page-composition ownership of cell placement. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Added detailed ownership, examples, and padding distinction for Track Cell Alignment. | Prevents alignment from becoming hidden spacing or occupant-owned behavior. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added a future Track Cell Alignment phase. | Records the implementation boundary without authorizing code changes. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added future alignment test expectations. | Ensures future implementation proves alignment does not affect negotiation. |

---

# Conversation Card TrackOccupant Natural Height

Date: 2026-07-15

Scope: Recorded the replacement of the temporary fixed Conversation Card track
requirement with a natural, width-aware `ConversationSignatureCardTrackOccupant`
requirement.

## Summary

The current Search-page composition may now place a Conversation Card occupant
in C3 when the right Conversation excerpt is visible. That occupant no longer
uses a fixed placeholder height. It derives its natural requirement from the
same `ConversationSignatureCardPresentationMetrics` used by the rendered
Conversation Card, so glyph row count, card chrome, finite width, hooks, and
tags are represented in the requirement without teaching the page coordinator
Conversation semantics.

Track C remains semantically neutral. The documentation records C3 occupancy,
not a Track C role.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Updated current Search-page occupancy so C3 may contain a `ConversationSignatureCardTrackOccupant`; documented variable-height negotiation. | Makes the implemented C3 slice discoverable while preserving track semantic neutrality. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Replaced stale C3-empty wording with optional Conversation Card occupancy and shared metrics guidance. | Records why the page no longer owns a Conversation Card height constant. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added Phase 4C and validation items for the C3 Conversation Card occupant. | Tracks the completed vertical slice and its boundaries. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added focused Conversation Card metric and occupant tests to the validation map. | Documents the tests proving width-aware natural height and rendered/calculated parity. |

---

# Canonical Conversation Card Width

Date: 2026-07-15

Scope: Codified canonical `ConversationSignatureCard` width as a presentation
contract shared by rendered cards and track-occupant requirement calculation.

## Summary

The Conversation Card width is now documented as part of canonical Conversation
Card presentation. Containers must accommodate the card and may place it inside
wider space, but they do not stretch it or redefine its glyph geometry. This
makes glyph row count and natural-height requirements deterministic across the
Conversations sidebar and right/end Conversation excerpt panel.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added the canonical card-width contract and authoritative metrics symbol. | Makes the top-level layout package explain why C3 card requirements do not depend on panel width. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated Search-page occupancy examples and added the stable card-width principle. | Prevents stale C3-empty language and records the presentation ownership boundary. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Clarified that canonical card width, not ambient container width, drives card glyph geometry. | Keeps the TrackOccupant model deterministic while preserving semantic-neutral tracks. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added completed canonical-width implementation and validation items. | Records the implementation boundary and expected checks. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added canonical-width test expectations. | Ensures future tests protect the single width source of truth. |

---

# End-Panel Conversation Card Centering

Date: 2026-07-15

Scope: Recorded the presentation refinement that centers the fixed-width
canonical Conversation Card in the right/end Conversation excerpt panel.

## Summary

The canonical Conversation Card width remains stable and owned by the
Conversation Card presentation contract. The right/end Conversation excerpt
panel may center that fixed-width card when the panel is wider than the card.
This is horizontal presentation placement, not Track Cell Alignment and not a
new Track abstraction.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Clarified that right/end panel card centering is presentation placement, not track-system behavior. | Prevents a small visual refinement from broadening Track Cell Alignment. |

---

# Search-Page C2 Search Controls Occupancy

Date: 2026-07-15

Scope: Recorded the Search-page layout-track update that places the Message
Evidence post-metadata support/search-control group in cell C2.

## Summary

The old fixed 8 px C2 spacing occupant has been replaced by a
Message-Evidence-owned post-metadata controls occupant. The track remains
semantically neutral: the current Search-page composition places the
support/search-control group in C2 and bottom-aligns it inside the resolved
allocation when another cell contributes a taller requirement.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Replaced stale C2 spacing language with C2 post-metadata controls occupancy. | Keeps the canonical layout-track overview aligned with the current Search-page composition. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated Search-page occupancy tables from an 8 px spacing occupant to the Message Evidence controls occupant. | Prevents Track C from being misread as a semantic shim track. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Documented C2 bottom alignment for the support/search-control group. | Records the page-composition placement rule without broadening the track model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Updated Phase 4B to describe the post-metadata controls occupant slice. | Keeps implementation checklist history current. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added expectations for the C2 controls occupant and bottom-aligned track cell behavior. | Documents the focused regression surface. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Rewrote a fixed-height spacing example to avoid naming current Search-page C2 as a spacing cell. | Preserves semantic-neutral track language after C2 gained visible controls. |

---

# Search-Page D-Track Supporting Text Occupancy

Date: 2026-07-15

Scope: Recorded the Search-page layout-track update that separates the Message
Evidence search controls from supporting context text, and places the right
Conversation excerpt label in the same ordinal track.

## Summary

The current Search-page composition now uses C2 for the Message Evidence search
controls, D2 for the Message Evidence supporting context line, and D3 for the
right Conversation excerpt label when the excerpt panel is visible. Tracks
remain semantically neutral; these cells record only current occupancy.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Updated the current occupancy example with C2, D2, and D3 occupants. | Keeps the overview aligned with the implemented Search-page composition. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated Search-page occupancy tables to include Track D cells. | Prevents stale combined C2 wording from obscuring the current composition. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Generalized the occupancy example so it describes occupied cells rather than a semantic track role. | Reinforces semantic-neutral track documentation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added D2 supporting-context occupant coverage to the test map. | Documents the focused regression surface for the new split. |

---

# Search-Page E-Track Fixed-Height Occupancy

Date: 2026-07-15

Scope: Recorded the Search-page layout-track update that adds an ordinal E
track with one fixed-height 16 px occupant.

## Summary

The current Search-page composition now includes an E track whose resolved
height is contributed by one ordinary `FixedHeightTrackOccupant(height: 16)`.
All three columns render the resolved E allocation before primary content.
Track E has no semantic meaning; it is only an ordinal coordinate with current
occupancy.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added current E occupancy and clarified that the layout engine records geometry and occupancy, not spacer semantics. | Keeps the overview aligned with the current Search-page composition. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Added E occupancy to the Search-page examples. | Makes the current ordinal track plan discoverable. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Added E occupancy to the current composition example. | Preserves the semantic-neutral track model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added Phase 4E for the fixed-height E occupant slice. | Records the implementation boundary and validation expectations. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added the E fixed-height occupant expectation to the test map. | Documents the focused regression surface. |

---

# Cross-Column Track Cell Rendering Anatomy

Date: 2026-07-16

Scope: Added a durable explanation of how Search-page track occupants,
requirements, resolved plans, scopes, and `TrackCellColumnBand` wrappers become
the Flutter widget tree.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/05-anatomy-of-track-cell-rendering.md` | Created a mechanical walkthrough of the rendering chain from page composition through `ResolvedTrackPlanScope` to track-cell rendering. | Gives future readers an obvious reference for how cross-column track coordination works in Flutter widget terms. |
| `09-CROSS-COLUMN-LAYOUT/README.md` | Added the anatomy document to the canonical reading order and link metadata. | Makes the new explanation discoverable from the durable cross-column layout index. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation addition. | Maintains the project documentation change log. |
