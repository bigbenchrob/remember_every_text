---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-08-24
source_of_truth: doc
links:
  - ./01-db-import.md
  - ./02-db-working.md
  - ./05-db-overlay.md
  - ./10-group-import-working.md
  - ./11-contact-to-chat-linking.md
  - ../15-MACOS-SOURCE-DATABASES/00-overview.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../40-FEATURES/README.md
  - ../40-FEATURES/contact-names/VIRTUAL_PARTICIPANTS.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/00-overview.md
tests: []
---

# Identity Model: Contacts, Handles, Participants, and Graph Identity

> Current conformance note (2026-06-05): identity resolution is semantic, not relational. The resolver answers "what should the user see?", not "which database row owns this information?" Ordinary app surfaces now use graph-backed contact/handle/conversation identity plus overlay user intent.

## TL;DR

- Apple has handles: raw communication identifiers such as phone numbers and email addresses.
- MessageLens uses graph contact/conversation/handle topology plus display identity resolution once identity has been resolved.
- Contacts are source metadata and enrichment. They can seed graph contact identity, but they do not by themselves define identity.
- Overlay DB provides user-controlled identity refinement: display-name overrides, favorites, visibility/dismissal state, manual handle links, and virtual participants.

Do not reduce identity to strings. Identity is layered: source handles and AddressBook records are imported, source-scoped graph projection creates canonical handles/contact topology, and overlay merges user intent at read time.

## Identity Authority Rule

Identity meaning must be derived from the graph identity/display resolver model, not from isolated rows.

- Handles are identifiers, not identity.
- Contacts are metadata, not identity.
- Overlay refines identity, but does not define base identity.
- UI must operate on typed graph/display identity read models, not raw handles, raw contact records, or rendered labels.

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

### Source handle identity is not semantic normalization

A handle's source identity is its source ROWID within an admitted source,
represented in MessageLens by the canonical source-scoped row key. Phone/email
normalization is optional semantic interpretation above that identity.

When a nonempty source handle cannot be truthfully interpreted as a phone or
email, import and graph projection preserve:

- source ID and source ROWID;
- source-scoped handle ID;
- raw source value and service metadata;
- chat membership and message sender relationships.

That preserved unnormalized handle does not enter canonical alias grouping,
normalization-based deduplication, or normalization-based contact matching. Two
opaque source rows remain distinct even when their raw strings are equal. No
raw-text hash or fallback grouping key may masquerade as canonical semantics.

Structural identity failure remains fatal when source identity or required
relationships cannot be represented truthfully. See the Feature 28 handle
anomaly implementation record for the dependency audit and typed accounting.

Identity resolution happens during source-scoped graph projection and overlay merge, not by mutating the source-derived import ledger.

## 3. Graph Working Database Model

`working_ss.db` is the production source-scoped graph projection used by ordinary providers, search, message evidence, and UI data access.

Core graph identity/topology tables:

| Graph table | Purpose |
| --- | --- |
| `handles` / canonical aliases | Canonical communication endpoints. Multiple raw source handle variants can collapse to one canonical handle. |
| `contacts` | Graph contact identity projected from AddressBook facts. |
| `contact_to_handle` | Graph links from contacts to canonical handles. |
| `chat_to_handle` | Conversation participant topology. |
| `messages.sender_handle_ss_id` | Sender endpoint identity for message evidence. |

Graph contact identity is the canonical app identity unit for known people/organizations. Canonical handles remain first-class endpoint identities for explicit handle-focused workflows and unknown/unlinked senders.

A participant may represent:

- one canonical handle
- multiple canonical handles for the same person or organization
- an AddressBook-derived person or organization with zero currently linked handles

Retired-file detail: old `working.participants.id` rows preserved
AddressBook `Z_PK`. That may help interpret old retired files, but it is not
the production identity authority for graph-era app behavior.

Canonical handles remain first-class endpoint identities. Unlinked handles may exist without a contact identity. UI and feature code must route identity through display identity read models when operating on people, and through canonical handles only when the workflow is explicitly handle-focused.

### Local account handles

Source-scoped handle rows may record whether an endpoint belongs to the local
Messages account. This is imported source evidence, not user intent. The live
source scan derives it from account identities such as `chat.account_login`
and incoming `message.destination_caller_id`; `message.is_from_me` constrains
direction but does not by itself establish identity.

Startup performs a metadata-only reconciliation across the complete historical
source. It updates existing source-scoped handle annotations and projects only
the changed `is_me` facts; it does not reimport messages. Handle comparison uses
the canonical endpoint grouping key, so equivalent North American forms such
as `+16046858506`, `tel:+16046858506`, and `(604) 685-8506` identify the same
local endpoint. Empty typed account values such as `E:` do not establish a
handle identity.

The live-change monitor requests this reconciliation through the Conversation
Graph build service and its existing execution gate. It does not reach into an
importer or projector directly. When reconciliation changes graph facts, the
normal message-data version boundary is advanced so read models refresh without
reopening database connections.

The fact is projected to graph handles and consumed by the shared display
identity resolver. A one-to-one Conversation whose endpoint is a local account
handle is a self-conversation. Presentation consumes that prepared fact rather
than comparing personal names or guessing from message direction.

Local-account identity outranks imported contact names, manual display-name
overrides, and raw endpoint labels in ordinary relationship presentation. The
first-person grammar is:

- `Me` in titles and participant lists;
- `me` inside prose-like message metadata;
- `self` for a relationship containing only the local user.

This grammar is resolved before widgets render. Conversation cards, Contact
summaries and profiles, handle-scoped evidence headers, sender identities, and
Conversation evidence titles must consume the same display identity result.
Raw local endpoints and imported personal names may remain visible as
provenance in explicit handle-management, source-inspection, or identity-editing
surfaces; they are not ordinary browsing labels.

## 4. Contacts vs Participants

This distinction is non-negotiable.

Contacts are external metadata from AddressBook.

Graph contacts/display identities are internal app identity units used by MessageLens surfaces. Retired participant terminology exists for legacy compatibility and overlay bridges.

Contacts can provide:

- names
- short names
- organizations
- phone/email channel data
- avatar/source metadata when present

Graph display identity provides:

- the app-level identity key used by contact-scoped UI
- a stable target for favorites, display overrides, message scopes, and search grouping
- the merge point for automatic AddressBook matching and user-controlled overlay refinements

A participant may:

- link to an AddressBook contact
- link to one or more canonical handles
- have no active handle linkage
- be represented by an overlay virtual participant rather than a graph contact row

A contact may:

- map to multiple handles
- map to no imported handles
- be incomplete or stale
- fail to project if it has no useful display data

Rule: contacts do not define identity by themselves. Graph display identity resolves what the user should see.

In current code, AddressBook contacts seed graph contacts. Older retired
`working.db` files may still contain historical participant rows, but they are
not the current app-facing identity authority. Overlay virtual participants
extend display identity without writing to `working_ss.db` or retired
`working.db`.

## 5. Overlay Model (User Control Layer)

`user_overlays.db` stores durable user intent. It refines presentation and grouping without changing source DBs, the source-scoped import ledger, the working graph, or retired files.

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

Overlay modifies presentation and grouping at provider merge time. It must not be copied into import, graph, or retired working tables during projection/migration.

## 6. Virtual Participants

Virtual participants are user-defined identity constructs stored in overlay only. The term remains for compatibility, but app-facing display should treat them as overlay-owned display identities.

They exist for cases where source data cannot provide the desired identity unit, such as:

- grouping one or more unlinked handles under a user-named identity
- representing a logical entity that is not in AddressBook
- labeling a useful handle without adding a macOS Contacts entry

Current storage:

- table: `virtual_participants`
- ID range: `id >= 1000000000`
- fields include `display_name`, schema-compatible `short_name`, optional `notes`, and audit timestamps
- manual links from canonical handles use `handle_to_participant_overrides.virtual_participant_id`

Virtual participants are not written to `working_ss.db` or retired
`working.db`. They still map into app UI through provider merge logic and
feature resolvers.

Do not treat virtual participants as AddressBook contacts. Do not expect them
in graph contact tables or old retired `working.participants` rows.

`virtual_participants.short_name` is not an app-facing identity field. It may remain physically present for schema compatibility, but display resolution must use `display_name` only.

## 7. Identity In The UI

UI surfaces operate on resolved graph/display identity models or explicit handle-focused specs, not raw source handles.

Sidebar:

- contact picker and contact cassettes use graph contact/display identity entries plus overlay virtual participants
- favorites and recents are overlay-backed participant state
- handle review/Handle Lens flows are explicitly handle-focused and may create or update overlay links

Message timelines:

- contact-scoped timelines use graph contact identity and the Message Evidence Spine
- sender display is resolved from handle, participant, contact, and overlay data
- recovered/unlinked message surfaces must preserve uncertain identity rather than inventing contact membership

Search:

- search consumes graph search/evidence scopes and provider-layer identity resolution
- result navigation should use stable identifiers such as graph contact ids, chat/conversation `ss_id`s, message `ss_id`s, or specs, not display-name strings

Display names may come from:

1. canonical local-account identity (`Me` / `me` / `self`, according to context)
2. overlay display-name override
3. overlay virtual contact/participant display name
4. graph contact/imported AddressBook display identity
5. stable conversation participant label
6. fallback canonical handle display or normalized identifier

Outside local-account identity, display name resolution order for known contact
UI is: user override -> graph/imported contact name -> fallback handle. Raw
handles should be primary only for unknown/unlinked handle workflows or
explicit handle scopes.

There is no separate user-facing short-name or nickname identity. The only user-authored contact name override is the name edited through the contact hero card and stored as `participant_overrides.display_name_override`.

Identity appears in spec payloads and resolved view models. It must not be reconstructed from rendered widgets.

Spec-driven surfaces must preserve the canonical pipeline:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

## 8. Failure Modes / Edge Cases

| Case | Handling |
| --- | --- |
| Multiple handles for one person | Canonical handle mapping and `contact_to_handle` can associate multiple endpoints with one graph contact/display identity. Overlay manual links can refine grouping. |
| No contact match | The handle remains a canonical handle without automatic contact linkage. Handle-focused UI can surface it for review or manual linking. |
| Conflicting contact data | Import preserves source evidence; working projection uses deterministic migration rules; overlay overrides provide user-controlled correction without mutating source/projection. |
| Stale or incorrect AddressBook entry | The participant may inherit stale source names, but overlay `participant_overrides` can change presentation. Source contact data remains traceable. |
| Orphaned handles | Unlinked canonical handles remain visible to handle-focused flows unless hidden/dismissed by overlay state. |
| User override conflicts with contact data | Overlay wins at provider merge/read time. The working graph remains source-derived and unchanged by user intent. |
| Virtual participant linked to handles | UI can show the virtual identity after overlay merge; graph contact tables and old retired `working.participants` rows will not contain that row. |
| Display names collide | Collision is allowed. Display names are labels, not identity keys. |

## 9. Non-Negotiable Rules

- Do not treat handles as people.
- Do not treat contacts as the app identity authority.
- Do not derive identity from display names, short names, nicknames, or search strings.
- Do not allow a personal contact name or user override to supersede canonical
  local-account identity in ordinary relationship presentation.
- Do not assume contact linkage exists for a handle.
- Do not assume one contact means one handle or one handle means one contact.
- Do not bypass graph/display identity read models in contact-scoped UI or features.
- Do not write manual identity refinements into `macos_import_ss.db`, `working_ss.db`, `macos_import.db`, or `working.db`.
- Do not store durable identity meaning in widgets or ephemeral UI state.
- Do not use raw Apple `handle.id` directly in UI unless the workflow is explicitly source-handle or handle-review oriented.
- Do not ignore overlay state when presenting names, favorites, hidden/dismissed handles, or manual links.

## 10. Current Caveats

Known current-state caveats:

- Old retired `working.participants` rows are AddressBook-derived and preserve
  `Z_PK`; virtual participants live only in overlay and appear through provider
  merge logic.
- Some older feature docs still use stale table names such as `working.handles`, `import_handles`, or `handle_overrides`. Current names are `handles_canonical`, `handles_canonical_to_alias`, `handles`, and `handle_to_participant_overrides`.
- `favorite_contacts` is keyed by real `participants.id`; virtual participant favorite behavior should be verified before adding new UI assumptions.
- Path location alone does not determine architectural ownership. Some contact-related logic is shared infrastructure while other contact-related logic remains feature-owned.

When these caveats matter, prefer current schema/code and the `10-DATABASES` docs over older feature scaffolds.

## References

- `./10-group-import-working.md` - retired import-to-working identity and ID preservation contract.
- `./11-contact-to-chat-linking.md` - contact-to-handle-to-chat walkthrough.
- `./05-db-overlay.md` - overlay identity and presentation tables.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` - retired import and working table names.
- `../40-FEATURES/contact-names/VIRTUAL_PARTICIPANTS.md` - virtual participant behavior.
- `../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/00-overview.md` - spec pipeline and rendering boundaries.
