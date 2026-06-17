---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-06-10
depends_on:
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
---

# 74 - Overlay Identity Key Audit

## Purpose

This document defines the overlay identity migration target for the graph era.

User intent must remain overlay-only, but the identity keys used by overlay
tables must move toward stable graph identity wherever ordinary app behavior is
now graph-backed.

This is a bridge design document, not a schema-change directive.

## Current Implementation Snapshot

As of 2026-06-10, ordinary app evidence, contact, search, and conversation
surfaces are graph-backed. Active `lib/` code now avoids legacy-named concepts;
compatibility bridges are named for retained overlay keys, GUID-keyed rows, or
their current graph role rather than the old app spine. Retained-key bridges
remain compatibility boundaries, not retained database authority.

Intentional bridge locations:

- `lib/essentials/conversation_graph/application/identity/retained_overlay_identity_bridge.dart`
  translates retained overlay/contact/handle/message integer keys to
  source-scoped graph ids and back where necessary.
- `lib/features/messages/infrastructure/repositories/message_overlay_identity_bridge_repository.dart`
  dual-reads retained rowid annotation rows and GUID-keyed overlay rows but
  writes graph-native message intent keyed by `message_ss_id`.
- `lib/essentials/search/infrastructure/repositories/graph_search_repository.dart`
  reads GUID-keyed saved/tag rows only as an overlay compatibility bridge; it
  refuses ambiguous GUID matches.
- Contact/favourite/manual-link readers use graph facts plus overlay bridges;
  they must not reopen retained `working.db` as naming or identity authority.

These symbols should keep explicit retained/bridge terminology until older
overlay rows are either migrated or intentionally left as read-only historical
user intent. Do not rename them to hide the compatibility boundary.

## Core Rule

Overlay identity is user intent attached to semantic app entities.

The overlay layer should answer:

> What user intent applies to this entity?

It should not answer:

> Which retained database row happened to own this information?

## Current Overlay Identity Inventory

| Overlay surface | Current storage | Current key | Target graph-era key | Bridge needed | Notes |
| --- | --- | --- | --- | --- | --- |
| Participant display override | `participant_overrides` | retained `participant_id` | graph contact/person identity once finalized | yes | User override name remains authoritative. Do not duplicate into working DB. |
| Virtual participants | `virtual_participants` | overlay-local `id >= 1000000000` | overlay-local contact identity plus graph handle links | yes | `short_name` is deprecated and currently written empty for compatibility. |
| Contact favourites | `favorite_contacts` | retained `participant_id` | graph contact/person identity | yes | Distinct from conversation favourites. Needs migration before retiring retained participant identity. |
| Conversation favourites | `overlay_settings` key `conversation_favourites/core` | graph conversation `ss_id` list | graph conversation `ss_id` | no | Already graph-native enough for Core favourites. Future tags should use a real table. |
| Message annotations | `message_annotations` | retained `message_id` | `message_ss_id` | yes | Includes starred/archive/notes/priority/reminder style intent. |
| Message user flags | `message_user_flags` | `message_guid` | `message_ss_id` | yes | GUID is not canonical identity. Bridge through import graph while retained rows exist. |
| Message user tags | `message_user_tags` | `(message_guid, tag_normalized)` | `(message_ss_id, tag_normalized)` | yes | Current GUID uniqueness is not multi-source safe. |
| Handle-to-participant override | `handle_to_participant_overrides` | retained/canonical `handle_id` and participant ids | graph handle `ss_id` to graph contact/person identity | yes | This is a high-leverage bridge because manual linking affects identity resolution. |
| Handle visibility override | `handle_visibility_overrides` | normalized handle string | normalized handle plus source-aware handle identity where needed | maybe | Visibility by normalized handle may remain acceptable if intentionally semantic. Audit duplicate-source behavior before migration. |
| Dismissed handles | `dismissed_handles` | normalized handle string | normalized handle or graph handle `ss_id` depending product meaning | maybe | If dismissal means "this address is not interesting", normalized handle is semantic. If source occurrence matters, use `ss_id`. |
| Archived attachments | `archived_attachments` | `(message_guid, import_attachment_id)` | `(message_ss_id, attachment_ss_id)` | yes | Preserve current resolver bridge until archive/recovery identity migration. |
| Overlay settings | `overlay_settings` | string setting key | setting-specific | case-by-case | Preferences are not all entity overlays. Do not over-normalize. |

## Identity Forms

### Existing Forms

- retained `working.db` participant ids
- retained `working.db` message ids
- retained/canonical handle ids
- Apple message GUIDs
- normalized handle strings
- overlay-local virtual participant ids
- graph conversation `ss_id`
- graph message/handle/contact candidate `ss_id`
- attachment import ids

### Desired Forms

- `message_ss_id` for message-scoped user intent
- `conversation_ss_id` for conversation-scoped user intent
- `handle_ss_id` for source handle occurrence intent
- graph contact/person identity for person-scoped user intent
- normalized handle string only when the user intent is intentionally about the
  address itself rather than a source occurrence
- attachment `ss_id` plus parent `message_ss_id` for attachment-scoped user
  intent

## Bridge Strategy

### Bridge Classifications

1. **Read bridge**
   Retained-keyed overlay rows are read and translated to graph ids at read
   time.

2. **Dual-read, single-write bridge**
   Existing retained-keyed rows are still honored, but new writes use graph
   keys.

3. **Migration bridge**
   A one-time overlay migration copies or transforms retained-keyed rows to graph
   keys, preserving user intent.

4. **Semantic-retention bridge**
   A retained-looking key remains because it is the correct semantic key.
   Example: normalized handle string may remain valid for "dismiss this
   address".

### Required Bridge Rules

- Never write user intent to import or working graph tables.
- Never let import/projection consult overlay state.
- Never treat GUID as canonical message identity.
- Never silently drop overlay rows that cannot be resolved to graph identity.
- Unresolved overlay rows must remain visible to diagnostics or migration logs.
- New graph-era overlay writes should not add new retained-keyed rows.

## Recommended Migration Order

### 1. Message Overlay Bridge

Target:

- `message_annotations`
- `message_user_flags`
- `message_user_tags`

Reason:

Search, saved messages, tags, and evidence review all select message evidence.
Keeping message overlays retained/GUID-keyed is the highest split-brain risk
once Search becomes graph-native.

Done means:

- graph evidence rows can report saved/tagged/annotated state by `message_ss_id`.
- existing GUID/message-id rows are still honored through a named bridge.
- new writes have a graph-keyed target or a documented temporary exception.

Implementation note:

- The graph-era write target is `message_intent_overlays` and
  `message_intent_tags`, keyed by `message_ss_id`.
- `message_annotations`, `message_user_flags`, and `message_user_tags` are
  compatibility fallbacks.
- GUID fallback must only apply when the GUID maps to exactly one graph message.
  Ambiguous GUIDs must not cross-apply user intent.

### 2. Contact and Handle Overlay Bridge

Target:

- `participant_overrides`
- `favorite_contacts`
- `handle_to_participant_overrides`
- `virtual_participants`

Reason:

Display identity and manual linking depend on these overlays. They block
retirement of retained participant and handle identity.

Done means:

- user override display names resolve through graph contact/person identity.
- contact favourites are graph-keyed or bridged with explicit removal criteria.
- manual handle links attach graph handle identity to graph contact/person
  identity.
- virtual participants have only one user-facing name field.

### 3. Handle Visibility and Dismissal Semantics

Target:

- `handle_visibility_overrides`
- `dismissed_handles`

Reason:

These may legitimately be keyed by normalized handle string if the user's intent
is address-scoped rather than source-occurrence-scoped.

Done means:

- each table explicitly declares whether its key is address-semantic or
  source-occurrence identity.
- duplicate-source behavior is tested.

### 4. Attachment Archive Bridge

Target:

- `archived_attachments`

Reason:

Archive integrity is data-recovery infrastructure. It should follow ordinary
graph migration, not lead it.

Done means:

- existing `(message_guid, import_attachment_id)` archive records remain
  resolvable.
- graph attachment evidence can resolve through `message_ss_id` and
  `attachment_ss_id`.
- unresolved historical archive rows are reportable.

## Immediate Implementation Guidance

Do not migrate overlay schemas opportunistically.

Message overlay bridge boundaries now exist. New implementation work should
continue retiring compatibility rows deliberately, with explicit diagnostics and
tests for unresolved user intent. Do not add new retained-keyed overlay writes.

## Tests Needed

- Existing message tags by GUID resolve to graph `message_ss_id`.
- Duplicate GUIDs across sources do not cross-apply tags.
- New graph-era message annotation writes target graph identity.
- Contact display override wins through graph contact identity.
- Manual handle link uses graph handle identity and does not mutate graph
  projection.
- Conversation favourites remain graph `ss_id` keyed.
- Archived attachment resolver preserves existing archive records while exposing
  graph evidence identity.

## Open Questions

1. What is the final graph contact/person identity key?
2. Should virtual participants remain overlay-local ids or become first-class
   graph contact identities?
3. Are handle visibility and dismissed-handle overlays address-semantic or
   source-occurrence-semantic?
4. Should message annotations and message tags share one graph-keyed message
   user-intent table, or remain separate tables with shared identity rules?
