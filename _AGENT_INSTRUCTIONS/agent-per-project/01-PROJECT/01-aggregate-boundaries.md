---
tier: project
scope: architecture
owner: agent-per-project
last_reviewed: 2026-06-20
source_of_truth: doc
links:
  - ./02-architecture-overview.md
  - ../10-DATABASES/10-group-import-working.md
  - ../10-DATABASES/11-contact-to-chat-linking.md
  - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../40-FEATURES/README.md
tests: []
---

# Aggregate Boundaries And Domain Contracts

This document defines the current domain language at project level. It is not a
complete entity/repository inventory. Current code and the database/spec-system
docs win when lower-level details differ.

## TL;DR

- Messages and chats are the core message-history concepts.
- Contacts/participants are imported reference data used for identity, search,
  display, and linking.
- Handles are technical communication endpoints that can be canonicalized and
  linked to participants.
- Attachments and reactions are message-adjacent data, not app-level
  orchestration owners.
- Durable user intent is overlay data, not graph or retired projection data.

## Current Domain Terms

| Term | Current meaning |
| --- | --- |
| Chat / conversation | Conversation context projected into the source-scoped graph (`working_ss.db.chats`) with canonical topology edges. |
| Message | Communication record projected into `working_ss.db.messages`; source rows without current conversation topology are preserved as graph orphan/recovered evidence, not suppressed. |
| Handle | Communication endpoint from Messages, imported as source facts and projected into graph handle/canonical-handle topology. |
| Participant / contact | Human-facing identity resolved from graph contact facts plus overlay user intent. Legacy participants in retired storage are historical reference data, not current UI authority. |
| Contact | Feature/domain term for human-facing contact behavior; backed by graph contact/handle topology, overlay overrides, and feature providers. |
| Attachment | Message-associated file metadata in source-scoped import/graph projection plus optional archive metadata in overlay. |
| Reaction | Tapback/reaction data projected into `reactions` and `reaction_counts`. |
| Overlay | Durable user intent in `user_overlays.db`, merged with working data at read time. |

## Boundary Rules

1. Source-scoped import preserves source-derived facts in `macos_import_ss.db`.
2. Graph projection writes app-facing source-derived data into `working_ss.db`.
3. Overlay services write durable user intent to `user_overlays.db`.
4. Providers and resolvers merge projection + overlay data for display.
5. Features do not own app-level orchestration, global flow state, panel stacks,
   sidebar topology, or shared chrome.
6. Specs and surface orchestration follow `../42-SPEC-SYSTEM/`.

## Chat Boundary

Current graph projection:

- `working_ss.db.chats`
- `working_ss.db.chat_to_message`
- `working_ss.db.chat_to_handle`
- related indexes and derived chat metadata

Chat/conversation data is graph-projection-owned. Graph rebuilds may recreate
it from source-scoped facts. Durable user preferences such as custom names,
favourites, visibility, and similar user intent belong in overlay tables or
feature-owned overlay services, not in source projection rows.

Chat-related UI/content lives primarily under `lib/features/chats`,
`lib/features/messages`, and essentials navigation/sidebar infrastructure.
Essentials owns the panel/sidebar routing policy around chat/message surfaces.

## Message Boundary

Current graph projection:

- `working_ss.db.messages`
- `working_ss.db.chat_to_message`
- `working_ss.db.message_to_attachment`
- graph evidence skeletons and hydrated evidence rows

Messages must remain source-traceable through `ss_id`, source id, source rowid,
and source metadata. Source rows that are not linked through current
chat-message joins are not suppressed; they remain visible as graph
orphan/recovered evidence through the documented evidence spine.

User-saved state, tags, notes, and similar durable user metadata belong in
overlay (`message_user_flags`, `message_user_tags`, `message_annotations`) and
are merged at read time.

## Contact / Participant / Handle Boundary

Current graph projection:

- `macos_import_ss.db.contacts`
- `macos_import_ss.db.contact_channels`
- `working_ss.db.contacts`
- `working_ss.db.handles`
- `working_ss.db.handles_canonical`
- `working_ss.db.handles_canonical_to_alias`
- `working_ss.db.contact_to_handle`

AddressBook facts are imported as source facts and projected into graph contact
identity. Handles are canonicalized in the graph while every raw source handle
variant remains traceable through `handles_canonical_to_alias`.

Manual handle links, virtual participants, dismissed handles, visibility
overrides, and favorite/recents state are overlay-owned user intent.

## Attachment Boundary

Current data spans:

- source-scoped import attachment tables and message/attachment joins
- graph `attachments` and `message_to_attachment` edges
- overlay `archived_attachments`
- filesystem archive under the app support directory

The attachment feature owns archive service, resolution, and deterministic
recovery. Source-scoped import and graph projection own source-derived
attachment facts. Retired attachment projection data remains only as cleanup or
diagnostic reference where archive/recovery compatibility still requires it.
MessageLens never writes recovered or archived files back into Apple's Messages
Attachments folder.

## Cross-Surface Boundary

Domain data placement is separate from surface orchestration.

The current surface pipeline is:

```text
Spec → Coordinator → Resolver → Payload / ViewModel → Rendering
```

Feature code may resolve and render approved feature content. Essentials owns
top-level specs, global flow state, panel stacks, sidebar rack topology, and
cross-surface reconciliation.

## Historical Note

Older versions of this document described aspirational repositories, domain
events, and generic DDD examples that are not current code contracts. Treat
those older patterns as historical context only. For current implementation
placement, use this document plus:

- `../30-ESSENTIALS/README.md`
- `../40-FEATURES/README.md`
- `../42-SPEC-SYSTEM/README.md`
- `../10-DATABASES/10-group-import-working.md`
