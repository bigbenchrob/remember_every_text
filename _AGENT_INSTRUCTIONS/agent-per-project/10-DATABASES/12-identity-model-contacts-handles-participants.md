---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: doc
links:
  - ./01-db-import.md
  - ./02-db-working.md
  - ./05-db-overlay.md
  - ./10-group-import-working.md
  - ./11-contact-to-chat-linking.md
  - ../15-MACOS-SOURCE-DATABASES/00-overview.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../40-FEATURES/README.md
  - ../40-FEATURES/contact-names/VIRTUAL_PARTICIPANTS.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/00-overview.md
tests: []
---

# Identity Model: Contacts, Handles, Participants

## TL;DR

- Apple has handles: raw communication identifiers such as phone numbers and email addresses.
- MessageLens uses participants as the canonical UI identity unit once identity has been resolved.
- Contacts are source metadata and enrichment. They can seed participants, but they do not by themselves define identity.
- Overlay DB provides user-controlled identity refinement: display-name overrides, favorites, visibility/dismissal state, manual handle links, and virtual participants.

Do not reduce identity to strings. Identity is layered: source handles and AddressBook records are imported, migration projects canonical handles and participants, and overlay merges user intent at read time.

## Identity Authority Rule

Identity meaning must be derived only from the participant model.

- Handles are identifiers, not identity.
- Contacts are metadata, not identity.
- Overlay refines identity, but does not define base identity.
- UI must operate on participants, not handles or contact records.

## 1. Source Reality (Apple)

Apple Messages stores communication endpoints in `chat.db.handle`.

Source facts:

- `handle` rows are raw identifiers such as phone numbers, email addresses, or service-specific identifiers.
- `message` rows reference sender handles through source handle IDs.
- `chat_handle_join` links chats to handles.
- Apple `chat.db` does not contain MessageLens-style `participants`.
- AddressBook is a separate source database with contact records and contact channels.

Handles are not stable "people".

A single person may appear through:

- multiple phone numbers
- multiple emails
- SMS and iMessage variants
- stale or reformatted identifiers
- handles that never resolve to an AddressBook contact

AddressBook contact identity is also not the same thing as MessageLens identity. It is external metadata that may be incomplete, stale, duplicated, or absent.

## 2. Import Mapping

Import preserves source structure. It does not decide final app identity.

Relevant import tables:

| Import table | Purpose |
| --- | --- |
| `handles` | Raw Apple `chat.db.handle` rows with source IDs preserved. |
| `chat_to_handle` | Imported chat-to-handle membership from `chat_handle_join`. |
| `messages` / `recovered_unlinked_messages` | Imported messages with sender handle references where source data provides them. |
| `contacts` | Imported AddressBook contact rows, preserving `Z_PK`. |
| `contact_phone_email` | Imported contact channel values. |
| `contact_to_chat_handle` | Import-time matching evidence between contact channels and chat handles. |

Import rules:

- Preserve source IDs and source relationships.
- Preserve handle/contact matching evidence with confidence and provenance.
- Do not assume every handle maps to a contact.
- Do not assume every contact has a useful handle.
- Do not treat display names as identity keys.

Identity resolution happens during migration and overlay merge, not by mutating the source-derived import ledger.

## 3. Working Database Model

`working.db` is the runtime projection used by providers, search/index rebuilds, and UI data access.

Core identity tables:

| Working table | Purpose |
| --- | --- |
| `handles_canonical` | Canonical communication endpoints. Multiple raw source handle variants can collapse to one canonical handle. |
| `handles_canonical_to_alias` | Maps every raw source handle ID to its canonical handle ID and normalized identifier. |
| `participants` | App identity rows for resolved people/organizations. SQL table name is `participants`; Drift class name is `WorkingParticipants`. |
| `handle_to_participant` | Confidence-scored links from canonical handles to participants. |

Participants are the canonical identity unit for UI when identity is resolved.

A participant may represent:

- one canonical handle
- multiple canonical handles for the same person or organization
- an AddressBook-derived person or organization with zero currently linked handles

Current implementation detail: real working `participants.id` preserves AddressBook `Z_PK`. That preserves traceability, but it does not mean AddressBook is the identity authority for all app behavior.

Canonical handles remain first-class endpoint identities. Unlinked handles may exist without a participant. UI and feature code must route identity through the participant model when operating on people, and through canonical handles only when the workflow is explicitly handle-focused.

## 4. Contacts vs Participants

This distinction is non-negotiable.

Contacts are external metadata from AddressBook.

Participants are internal app identity units used by MessageLens surfaces.

Contacts can provide:

- names
- short names
- organizations
- phone/email channel data
- avatar/source metadata when present

Participants provide:

- the app-level identity key used by contact-scoped UI
- a stable target for favorites, display overrides, message scopes, and search grouping
- the merge point for automatic AddressBook matching and user-controlled overlay refinements

A participant may:

- link to an AddressBook contact
- link to one or more canonical handles
- have no active handle linkage
- be represented by an overlay virtual participant rather than a working DB participant row

A contact may:

- map to multiple handles
- map to no imported handles
- be incomplete or stale
- fail to project if it has no useful display data

Rule: contacts do not define identity. Participants define identity.

In current code, AddressBook contacts seed real working participant rows. Overlay virtual participants extend the participant model without writing to `working.db`.

## 5. Overlay Model (User Control Layer)

`user_overlays.db` stores durable user intent. It refines presentation and grouping without changing source DB, import DB, or working DB structure.

Identity-related overlay tables:

| Overlay table | Purpose |
| --- | --- |
| `participant_overrides` | Participant display preference, currently the single user-authored `display_name_override`. Legacy `nickname` data has been removed and `name_mode` must not become a competing identity path. |
| `favorite_contacts` | Favorite/recent state keyed by `participants.id`. |
| `handle_to_participant_overrides` | Manual handle links to a real participant or virtual participant; a row with both participant IDs null means reviewed/dismissed. |
| `virtual_participants` | User-created participant-like identities stored only in overlay. |
| `handle_visibility_overrides` | User-controlled visibility and blacklist state keyed by canonical handle ID. |
| `dismissed_handles` | Dismissed handle identifiers keyed by normalized handle string so state survives handle-ID churn. |

`participant_overrides.display_name_override` is a presentation override. It does not rewrite the working `participants.display_name` column.

Overlay modifies presentation and grouping at provider merge time. It must not be copied into import or working tables during migration.

## 6. Virtual Participants

Virtual participants are user-defined identity constructs stored in overlay only.

They exist for cases where source data cannot provide the desired identity unit, such as:

- grouping one or more unlinked handles under a user-named identity
- representing a logical entity that is not in AddressBook
- labeling a useful handle without adding a macOS Contacts entry

Current storage:

- table: `virtual_participants`
- ID range: `id >= 1000000000`
- fields include `display_name`, schema-compatible `short_name`, optional `notes`, and audit timestamps
- manual links from canonical handles use `handle_to_participant_overrides.virtual_participant_id`

Virtual participants are not written to `working.db`. They still map into participant-based UI through provider merge logic and feature resolvers.

Do not treat virtual participants as AddressBook contacts. Do not expect them in `working.participants`.

`virtual_participants.short_name` is not an app-facing identity field. It may remain physically present for schema compatibility, but display resolution must use `display_name` only.

## 7. Identity In The UI

UI surfaces operate on resolved participants or explicit handle-focused specs, not raw source handles.

Sidebar:

- contact picker and contact cassettes use participant-like entries from working participants plus overlay virtual participants
- favorites and recents are overlay-backed participant state
- handle review/Handle Lens flows are explicitly handle-focused and may create or update overlay links

Message timelines:

- contact-scoped timelines use participant identity and `contact_message_index`
- sender display is resolved from handle, participant, contact, and overlay data
- recovered/unlinked message surfaces must preserve uncertain identity rather than inventing contact membership

Search:

- search consumes working indexes and provider-layer identity resolution
- result navigation should use stable identifiers such as participant IDs, chat IDs, message IDs/GUIDs, or specs, not display-name strings

Display names may come from:

1. overlay `display_name_override`
2. virtual participant fields
3. working participant fields derived from AddressBook
4. fallback canonical handle display or normalized identifier

Display name resolution order for real participant-backed UI is: overlay override -> contact/participant name -> fallback handle.

There is no separate user-facing short-name or nickname identity. The only user-authored contact name override is the name edited through the contact hero card and stored as `participant_overrides.display_name_override`.

Identity appears in spec payloads and resolved view models. It must not be reconstructed from rendered widgets.

Spec-driven surfaces must preserve the canonical pipeline:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

## 8. Failure Modes / Edge Cases

| Case | Handling |
| --- | --- |
| Multiple handles for one person | Canonical handle mapping and `handle_to_participant` can associate multiple endpoints with one participant. Overlay manual links can refine grouping. |
| No contact match | The handle remains a canonical handle without automatic participant linkage. Handle-focused UI can surface it for review or manual linking. |
| Conflicting contact data | Import preserves source evidence; working projection uses deterministic migration rules; overlay overrides provide user-controlled correction without mutating source/projection. |
| Stale or incorrect AddressBook entry | The participant may inherit stale source names, but overlay `participant_overrides` can change presentation. Source contact data remains traceable. |
| Orphaned handles | Unlinked canonical handles remain visible to handle-focused flows unless hidden/dismissed by overlay state. |
| User override conflicts with contact data | Overlay wins at provider merge/read time. The working DB remains unchanged. |
| Virtual participant linked to handles | UI can show the virtual identity after overlay merge; `working.participants` will not contain that row. |
| Display names collide | Collision is allowed. Display names are labels, not identity keys. |

## 9. Non-Negotiable Rules

- Do not treat handles as people.
- Do not treat contacts as the app identity authority.
- Do not derive identity from display names, short names, nicknames, or search strings.
- Do not assume contact linkage exists for a handle.
- Do not assume one contact means one handle or one handle means one contact.
- Do not bypass the participant model in contact-scoped UI or features.
- Do not write manual identity refinements into `macos_import.db` or `working.db`.
- Do not store durable identity meaning in widgets or ephemeral UI state.
- Do not use raw Apple `handle.id` directly in UI unless the workflow is explicitly source-handle or handle-review oriented.
- Do not ignore overlay state when presenting names, favorites, hidden/dismissed handles, or manual links.

## 10. Current Caveats

Known current-state caveats:

- Real `working.participants` rows are currently AddressBook-derived and preserve `Z_PK`; virtual participants live only in overlay and appear through provider merge logic.
- The Drift class for SQL table `participants` is `WorkingParticipants`.
- Some older feature docs still use stale table names such as `working.handles`, `import_handles`, or `handle_overrides`. Current names are `handles_canonical`, `handles_canonical_to_alias`, `handles`, and `handle_to_participant_overrides`.
- `favorite_contacts` is keyed by real `participants.id`; virtual participant favorite behavior should be verified before adding new UI assumptions.
- Path location alone does not determine architectural ownership. Some contact-related logic is shared infrastructure while other contact-related logic remains feature-owned.

When these caveats matter, prefer current schema/code and the `10-DATABASES` docs over older feature scaffolds.

## References

- `./10-group-import-working.md` - import-to-working identity and ID preservation contract.
- `./11-contact-to-chat-linking.md` - contact-to-handle-to-chat walkthrough.
- `./05-db-overlay.md` - overlay identity and presentation tables.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` - current import and working table names.
- `../40-FEATURES/contact-names/VIRTUAL_PARTICIPANTS.md` - virtual participant behavior.
- `../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/00-overview.md` - spec pipeline and rendering boundaries.
