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
| `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` | Updated from the earlier rigid four-band/AppPanelBandColumn framing to the current top/middle/content-start band model and sidebar content-start seam. | The code now includes `TopColumnBand` and `MiddleColumnBand`; the old README text was stale and over-rigid. |
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
- X-column layout currently uses a top identity band and middle context band,
  with content beginning after the middle band.

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
