---
tier: project
scope: architecture
owner: agent-per-project
last_reviewed: 2026-04-21
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
- Durable user intent is overlay data, not working projection data.

## Current Domain Terms

| Term | Current meaning |
| --- | --- |
| Chat | Conversation context projected into `db-working.chats`. |
| Message | Communication record projected into `db-working.messages`, or into `recovered_unlinked_messages` when source rows are not linked through normal chat joins. |
| Handle | Communication endpoint from Messages, imported through `db-import.handles` and canonicalized into `handles_canonical`. |
| Participant | Projected AddressBook contact in `db-working.participants`. Drift class name: `WorkingParticipants`. |
| Contact | Feature/domain term for human-facing contact behavior; backed by participants, overlay overrides, and feature providers. |
| Attachment | Message-associated file metadata in import/working DBs plus optional archive metadata in overlay. |
| Reaction | Tapback/reaction data projected into `reactions` and `reaction_counts`. |
| Overlay | Durable user intent in `user_overlays.db`, merged with working data at read time. |

## Boundary Rules

1. Import preserves source-derived facts in `macos_import.db`.
2. Migration projects source-derived data into `working.db`.
3. Overlay services write durable user intent to `user_overlays.db`.
4. Providers and resolvers merge projection + overlay data for display.
5. Features do not own app-level orchestration, global flow state, panel stacks,
   sidebar topology, or shared chrome.
6. Specs and surface orchestration follow `../42-SPEC-SYSTEM/`.

## Chat Boundary

Current projection:

- `db-working.chats`
- `db-working.chat_to_handle`
- related indexes and derived chat metadata

Chat data is projection-owned. Full migration can rebuild it; incremental
migration can update it through migrator-specific semantics. Durable user
preferences such as custom names, favorites, visibility, and similar user intent
belong in overlay tables or feature-owned overlay services, not in source
projection rows.

Chat-related UI/content lives primarily under `lib/features/chats`,
`lib/features/messages`, and essentials navigation/sidebar infrastructure.
Essentials owns the panel/sidebar routing policy around chat/message surfaces.

## Message Boundary

Current projection:

- `db-working.messages`
- `db-working.recovered_unlinked_messages`
- `db-working.global_message_index`
- `db-working.message_index`
- `db-working.contact_message_index`
- `db-working.message_read_marks`
- `db-working.read_state`

Messages must remain source-traceable by ID/GUID/ROWID. Source rows that are not
linked through normal chat-message joins are not suppressed; they use the
recovered-unlinked path documented in `../20-DATA-IMPORT-MIGRATION/`.

User-saved state, tags, notes, and similar durable user metadata belong in
overlay (`message_user_flags`, `message_user_tags`, `message_annotations`) and
are merged at read time.

## Contact / Participant / Handle Boundary

Current projection:

- `db-import.contacts`
- `db-import.contact_phone_email`
- `db-import.contact_to_chat_handle`
- `db-working.participants`
- `db-working.handles_canonical`
- `db-working.handles_canonical_to_alias`
- `db-working.handle_to_participant`

AddressBook `Z_PK` values become `participants.id`. Handles are canonicalized
through `MigrationContext.handleIdCanonicalMap`; every raw source handle variant
should remain traceable through `handles_canonical_to_alias`.

Manual handle links, virtual participants, dismissed handles, visibility
overrides, and favorite/recents state are overlay-owned user intent.

## Attachment Boundary

Current data spans:

- import attachment tables and normal/recovered attachment joins
- working `attachments` and `recovered_unlinked_attachments`
- overlay `archived_attachments`
- filesystem archive under the app support directory

The attachment feature owns archive service, resolution, and deterministic
recovery. Import/migration own source-derived attachment projection. MessageLens
never writes recovered or archived files back into Apple's Messages Attachments
folder.

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
