# Contact Name Display Audit

## Invariant

Known contacts must be referred to by the user-assigned name in user-facing UI.

There is exactly one user-defined contact name override:

```text
participant_overrides.display_name_override
```

This is written only by the contact hero-card pencil rename action. Other name-like fields are imported or derived metadata, not user intent.

Precedence:

```text
user display-name override
→ imported AddressBook display name
→ raw handle only when no known contact identity exists
```

There is no separate app-facing short-name identity. Handles are metadata for known contacts, not person identity. They may appear only in explicitly handle-oriented contexts such as contact scope menus, handle filters, or developer diagnostics.

## Initial Trigger

Screenshots showed three different identity treatments for the same known contact:

- Contact message view: `Claire` — correct.
- Conversations sidebar: `Claire Merriman Campbell` — wrong when `Claire` is the user-assigned/preferred name.
- Conversation message header: `1 (778) 990-8506` — wrong for a known contact except in explicit handle-scope UI.

## Corrected Boundary

`DisplayIdentityResolver` is the graph-facing identity boundary used by:

- conversation signatures
- favourite conversation signatures
- contact-derived conversation lists
- conversation message headers
- recent graph chat summaries

The former `contactHandleLabelsProvider` adapter has been retired so new code cannot accidentally depend on a handle-label map as semantic authority.

The resolver applies the same preferred-name precedence as contact profile surfaces:

```text
displayNameOverride
→ participant display name
```

This prevents graph conversation surfaces from falling back to imported AddressBook display names when the user has assigned a preferred name.

## Current Audit Status

### Corrected

- `features/contacts/application/display_identity/`
  - owns app-facing identity resolution.

- `features/chats/application/conversation_browser/contact_handle_label_provider.dart`
  - retired; no production call sites remain.

- `features/messages/presentation/view/conversation_messages_preview_view.dart`
  - now uses `DisplayIdentityResolver` rather than raw-handle title reconstruction.

- `features/contacts/infrastructure/repositories/participant_merge_utils.dart`
  - now exposes a preferred participant-name helper for legacy working participant IDs using the same precedence.

- Message evidence hydration paths now receive preferred participant names instead of display-name overrides alone:
  - `features/messages/presentation/view_model/shared/message_row_mapper.dart`
  - `features/messages/presentation/view_model/shared/hydration/message_by_id_provider.dart`
  - `features/messages/presentation/view_model/shared/hydration/message_by_ordinal_provider.dart`
  - `features/messages/presentation/view_model/shared/hydration/messages_for_handle_provider.dart`
  - `features/messages/presentation/view_model/timeline/hydration/message_by_id_provider.dart`
  - `features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart`
  - `features/messages/presentation/view_model/timeline/hydration/message_grouping_metadata_by_ordinal_provider.dart`
  - `features/messages/application/view_spec/resolver_tools/search_result_context_provider.dart`
  - `features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart`

- Legacy chat summary paths now receive preferred participant names:
  - `features/chats/presentation/view_model/recent_chats_provider.dart`
  - `features/chats/application/chats_by_age_provider.dart`

- Handle-linking/readout paths now use preferred participant names for known contacts:
  - `features/handles/infrastructure/repositories/handle_display_name_provider.dart`
  - `features/handles/application/settings_cassette_spec/resolver_tools/manual_linking_provider.dart`

### Expected Downstream Fixes From That Boundary

- `features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart`
  - conversation sidebar titles receive preferred contact names.

- `features/messages/presentation/widgets/contact_graph_conversation_section.dart`
  - contact by-conversation list should continue using the same card data path with preferred names.

- `features/chats/presentation/view_model/recent_chats_provider.dart`
  - graph recent-chat summaries inherit preferred names through `DisplayIdentityResolver`.

## App-Wide Search Findings

Direct `displayNameOverridesMap(overlayDb)` usage has been removed from message evidence and chat summary paths identified in the first audit pass.

Remaining raw `participant.displayName` references in those paths are now fallback behavior after preferred-name lookup, not the primary known-contact label rule.

Second-band audit findings still needing separate review:

- `features/contacts/presentation/widgets/contact_picker_dialog.dart`
  - now renders the resolved display name only.

- `features/messages/infrastructure/repositories/messages_for_handle_provider.dart`
  - older handle-context message reader builds chat display names from handle display values. This should either be migrated onto the message evidence spine or updated through a named participant-label resolver before being treated as user-facing.

- `features/messages/presentation/view/handle_messages_evidence_view.dart`
  - now titles generic handle-scoped evidence with `handleDisplayNameProvider`, so known linked handles show contact identity and unknown handles remain raw-handle fallbacks.

### Still Requires Follow-Up Review

- Message row metadata may still show raw handles. This is acceptable only when:
  - developer mode is enabled, or
  - the active scope is explicitly handle-filtered, or
  - no known contact identity exists.

- Search result context and recovered-message context should be checked for any direct handle formatting when a known contact identity is available.

- Any future conversation/search/theme surface must consume preferred contact labels through a named application/read-model boundary, not by rendering raw participant handles directly.

## Risk Prevented

Without this invariant, graph-backed surfaces can regress into treating handles or imported AddressBook facts as user identity. That reintroduces:

- person/handle conflation
- inconsistent conversation titles
- user distrust of the graph UI
- duplicated local name-resolution logic
- hidden drift between Contacts and Conversations

## Test Coverage Added

Focused tests now verify that the graph handle-label boundary:

- prefers the hero-card display-name override over imported AddressBook names
- falls back to imported display name when no user override exists
