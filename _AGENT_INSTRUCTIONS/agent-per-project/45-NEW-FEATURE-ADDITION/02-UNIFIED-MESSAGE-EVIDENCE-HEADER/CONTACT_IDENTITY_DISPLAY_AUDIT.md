# Contact Identity Display Audit

## Purpose

Pause feature work and consolidate contact, participant, handle, sender, and conversation-title display semantics before more graph migration work.

The message evidence spine is now centralized enough that identity naming is the next weak boundary. The app must not drift into local widget fixes where one surface shows a user-assigned name, another shows an imported AddressBook name, and another shows a raw handle for the same known person.

## Core Invariant

User-assigned app display name wins everywhere.

Identity resolution is semantic, not relational.

The resolver answers:

```text
What should the user see?
```

It does not answer:

```text
Which database row owns this information?
```

Database rows, source-scoped IDs, handle IDs, participant IDs, and overlay rows
are inputs and provenance. The display identity read model is an app semantic
projection over those facts.

Precedence:

```text
user-assigned app display name / override
-> app-known contact identity
-> AddressBook / imported contact name
-> stable conversation participant label
-> raw phone/email/handle fallback
```

Handles remain important metadata and explicit scope controls. They must not become the primary label for a known person unless no better identity exists.

The only user-defined person-name override should be the name entered through the contact hero-card pencil action. Current storage candidate:

```text
overlay.participant_overrides.display_name_override
```

Other name-like fields are imported, derived, or diagnostic metadata.
`nickname`, `short_name`, and `name_mode` must not become competing app-facing identity paths. If physical legacy columns remain, they are schema-compatibility artifacts only.

## Current Canonical Boundary

The current canonical resolver boundary is:

```text
features/contacts/application/display_identity/
features/contacts/feature_level_providers.dart
```

Feature callers should import the contacts feature public API and consume `displayIdentityResolverProvider`.

Previous behavior:

```text
displayNameOverride
-> derived compact name
-> participant displayName
-> raw handle fallback at call site
```

That over-promoted derived compact names. The intended rule is now:

```text
displayNameOverride
-> participant displayName
-> raw handle fallback at call site
```

There is no app-facing short-name identity. Legacy database columns may remain temporarily for schema compatibility, but they should not be populated with meaningful values, searched as identity text, or rendered.

The former `features/chats/application/conversation_browser/contact_handle_label_provider.dart` compatibility adapter has been retired. New user-facing identity work must depend on `DisplayIdentityResolver` through the contacts feature public API.

Short-name audit status: current app-facing contact/conversation display helpers accept only `displayNameOverride` and imported/display contact name. Remaining `shortName` references are physical schema columns, generated Drift code, and test fixture constructor fields unless separately identified in a future audit.

Transition bridge:

Graph contact ids are source-scoped identities. Existing hero-card overrides may still be keyed by the older AddressBook/participant row id. During migration, the display identity repository may bridge:

```text
SourceScopedRowKey(live AddressBook source, source_rowid)
-> legacy participant override row keyed by source_rowid
```

This bridge belongs only in the identity resolver/infrastructure boundary. Widgets and message evidence views must not unpack source-scoped ids to recover display names.

## Current Display Paths

| Surface / path | Primary files | Data source | Override considered? | Raw handle risk | Notes |
|---|---|---:|---:|---:|---|
| Contact hero card | `features/contacts/application/sidebar_cassette_spec/widget_builders/contact_hero_summary_widget.dart`, `features/contacts/infrastructure/repositories/contacts_list_repository.dart` | legacy `working.db` participants + overlay | yes | low | Correct user-facing behavior today. This is the rename authority. |
| Contact picker | `features/contacts/application/sidebar_cassette_spec/resolver_tools/participants_for_picker_provider.dart`, `contacts_list_repository.dart` | legacy `working.db` participants + overlay | yes via contact summary | low | Uses contact summaries, so it should inherit override behavior. |
| Contact all-messages header | `features/messages/presentation/view/contact_messages_evidence_view.dart`, `contact_profile_provider.dart` | legacy contact profile + overlay | yes | medium | Uses display name after override resolution. Profile resolver should still converge with the graph-wide resolver. |
| Conversation sidebar signatures | `features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart` | graph conversation handles + `DisplayIdentityResolver` | yes | low | Uses canonical identity resolver output. Unknown or unmapped handles fall back through the resolver. |
| Contact by-conversation list | same conversation signature display path plus `ConversationSignatureCard` | graph conversation handles + `DisplayIdentityResolver` | yes | low | Uses the same display model as the Conversations sidebar. |
| Conversation message header | `features/messages/presentation/view/conversation_messages_preview_view.dart` | graph conversation overview + `DisplayIdentityResolver` | yes | low | Uses the canonical identity resolver for conversation title composition. |
| Message sender line, graph evidence | `features/messages/presentation/widgets/message_evidence/message_evidence_row.dart`, graph repositories | graph message rows | no direct contact overlay at row level | high | Repositories emit `sender_display_handle` as `COALESCE(canonical_handles.display_handle, handles.id)`. Application hydration should resolve that into `MessageEvidenceRowData` before widgets render it. Known contacts can still appear as handles if that evidence-boundary resolution is bypassed. |
| Unfamiliar source / handle lens | `features/messages/presentation/view/handle_lens_view.dart`, `features/handles/infrastructure/repositories/handle_display_name_provider.dart` | overlay handle links + legacy working handles | yes | intended fallback | Correct conceptually: handle is primary only while the source is unfamiliar or explicitly handle-scoped. Once linked, display should become known contact identity. |
| Generic handle messages view | `features/messages/presentation/view/handle_messages_evidence_view.dart`, `features/handles/infrastructure/repositories/handle_display_name_provider.dart` | graph handle scope + resolved handle identity | yes | intended fallback | Header now receives resolved handle identity. Known linked handles show contact identity; unknown handles fall back to raw handle. |
| Recovered messages | `features/messages/presentation/view/recovered_messages_evidence_view.dart`, `recovered_unlinked_messages_provider.dart` | legacy recovered tables | partially | medium | Earlier audit noted recovered/search context should be checked for direct handle formatting when known identity exists. |
| Legacy timeline / older message paths | `features/messages/presentation/view/messages_timeline_view.dart` and timeline hydration providers | legacy working/recovered providers | mixed | medium | Some older paths still format sender labels locally. These should be retired or routed through the evidence spine identity resolver before being treated as production UI. |

## Problematic Patterns

### Local title reconstruction

`conversation_messages_preview_view.dart` and `conversation_signature_display_provider.dart` now derive titles through `DisplayIdentityResolver.resolveConversationFromHandles(...)`.

Remaining risk: future surfaces could still reconstruct titles locally instead of consuming the resolver.

### Sender display is still handle-shaped

Graph message repositories currently return sender display as:

```sql
COALESCE(canonical_handles.display_handle, handles.id)
```

That is handle identity, not person identity. It is useful metadata, but it should not be the primary sender label when the canonical handle is linked to a known contact.

Risk: known contacts appear as raw phone/email handles inside the message stream while headers and sidebars show contact names.

### Retired handle-label adapter

`contactHandleLabelsProvider` has been removed. It was useful during migration but semantically underspecified because it exposed handle-label maps rather than typed identity semantics.

Risk prevented: future features adding source-specific naming helpers instead of using one identity boundary.

### Contact profile resolver duplicates precedence

`contactProfileProvider` applies overlay override, then imported display name. It is close, but it is separate from `DisplayIdentityResolver` and `contactsListRepository`.

Risk: precedence changes in one path do not update the others.

## Proposed Resolver Contract

Introduce one application/read-model boundary for display identity. Suggested location:

```text
features/contacts/application/display_identity/
```

Suggested public model names:

```text
ContactDisplayIdentity
ParticipantDisplayIdentity
HandleDisplayIdentity
ConversationDisplayIdentity
MessageSenderDisplayIdentity
```

Suggested provider/repository contract:

```text
ContactDisplayIdentityResolver

resolveContact(contactId)
resolveParticipantForHandle(handleValue or handleSsId)
resolveConversation(conversationId)
resolveSender(senderCanonicalHandleSsId, senderHandleSsId)
resolveHandleFallback(handleId or handleValue)
```

The resolver should return typed display data, not raw strings:

```text
primaryLabel
secondaryLabel / metadataLabel
rawHandleLabel
isKnownContact
sourceKind: userOverride | overlayVirtual | graphContact | importedContact | handleFallback
contactId / participantId when known
```

Rendering widgets should receive these typed labels from application/read-model providers. Widgets should not query databases, inspect overlay state, or decide whether a handle is a known person.

## Proposed Precedence Details

### Contact display name

```text
overlay.participant_overrides.display_name_override
-> overlay virtual participant display name
-> graph/working contact display identity
-> imported AddressBook display name
-> raw handle fallback only if no contact exists
```

### Participant display label

Same as contact display name, but it may include lightweight metadata separately:

```text
primaryLabel: Claire
metadataLabel: 1 (778) 990-8506
```

The metadata label may be shown in explicit handle-scope controls or developer detail, not as the primary person label.

### Conversation title

Build from resolved participant identities:

```text
1 participant: Claire
2 participants: Claire and Cathie
3+ participants: Claire, Cathie + N more
```

The title composer should not receive raw handles except as already-resolved fallback identities.

### Sender line display label

For non-me messages:

```text
known contact primaryLabel
-> stable participant label
-> raw handle fallback
-> unknown sender
```

The raw sender handle remains available as metadata/debug detail and for explicit handle scopes.

### Unfamiliar-source label

For truly unfamiliar sources, the handle may be primary:

```text
title: 1 (604) 307-8325
identity/context: Unfamiliar source
```

Once linked to a contact, the same handle should resolve through the known-contact path everywhere except explicit handle-scope metadata.

## Migration Sequence

1. Name the identity resolver boundary. Completed.
   - `features/contacts/application/display_identity/`
   - exported through `features/contacts/feature_level_providers.dart`

2. Replace conversation title composition. Completed for graph conversation sidebar, contact-by-conversation rows, recent graph chats, and conversation message headers.

3. Replace graph sender labels.
   - Graph repositories may continue returning raw/canonical handle metadata.
   - Application hydration should resolve sender display identity before `MessageEvidenceRow` receives the row.
   - Keep raw handle as metadata.

4. Normalize contact profile consumers.
   - Contact hero, contact picker, and contact message headers should consume `ContactDisplayIdentity` or a compatible `ContactSummary` built from the resolver.

5. Recheck recovered/search/legacy bridge paths.
   - Any remaining legacy path still used in production should either use the resolver or be explicitly marked diagnostic/temporary.

6. Deprecate extra user-name concepts.
   - Keep one user override: hero-card display-name override.
   - Remove app-facing short-name concepts. Treat imported display name and raw handle as derived/imported metadata, not user intent.

## Tests Needed

- User display-name override wins over imported AddressBook display name in:
  - contact hero
  - conversation sidebar signature
  - contact by-conversation list
  - conversation message header
  - non-me sender line

- Known contact sender line does not show raw handle as primary label.

- Raw handle remains primary for an unfamiliar source with no contact link.

- Explicit handle-scope controls still show the handle metadata.

- Multiple handles for the same contact collapse to one participant label in conversation titles.

- Group conversation titles are stable and de-duplicated after identity resolution.

- Recovered/search contexts do not regress to raw handles when a known identity exists.

## Files Likely Requiring Modification Later

Resolver / read-model:

- new `features/contacts/application/display_identity/...`

Conversation titles:

- `features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart`
- `features/messages/presentation/view/conversation_messages_preview_view.dart`

Sender labels:

- `features/messages/application/message_evidence/message_evidence_spine_provider.dart`
- `features/messages/presentation/widgets/message_evidence/message_evidence_row.dart`
- `essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart`
- `essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart`
- `essentials/conversation_graph/infrastructure/repositories/message_graph_repository.dart`

Contact profile/picker:

- `features/contacts/infrastructure/repositories/contact_profile_provider.dart`
- `features/contacts/infrastructure/repositories/contacts_list_repository.dart`
- `features/contacts/application/sidebar_cassette_spec/resolver_tools/participants_for_picker_provider.dart`

Unfamiliar/handle surfaces:

- `features/handles/infrastructure/repositories/handle_display_name_provider.dart`
- `features/messages/presentation/view/handle_lens_view.dart`
- `features/messages/presentation/view/handle_messages_evidence_view.dart`

Legacy/recovered audit targets:

- `features/messages/presentation/view/messages_timeline_view.dart`
- `features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart`
- older timeline hydration providers under `features/messages/presentation/view_model/`

## Non-Goals For First Implementation Slice

- No schema changes.
- No message evidence renderer changes.
- No source-specific widget fixes.
- No broad contact model redesign.
- No AddressBook reimport changes.
- No removal of raw handles as metadata.

## Completed Slices

- Created the display identity resolver/read model.
- Moved conversation title resolution onto it.
- Retired `contactHandleLabelsProvider`.
- Moved graph recent chats and generic handle-message headers to resolver-backed identity.

These slices:

- does not alter persistence
- removes duplicated conversation-title logic
- improves Conversations sidebar and conversation message headers together
- establishes the authority boundary before sender-row identity is corrected

Next: migrate any remaining sender display labels in hydrated message evidence rows so known senders render by contact identity while preserving raw handles as metadata.
