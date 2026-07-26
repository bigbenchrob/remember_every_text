**Audit Result**

The intended ownership chain is mostly intact. Messages owns the complete `MessagesSpec.handleLens` presentation while consuming Handles through its public feature seam. No ViewSpec rendering should move.

Three boundary issues remain.

### 1. Dismiss Semantics: Ownership Leak

The Messages action named `dismissHandle` calls `handleReviewActionsProvider.markReviewed()` in [handle_lens_actions_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/application/handle_lens/handle_lens_actions_provider.dart:38).

These are different Handles concepts:

- `markReviewed` records review state but leaves the handle in active stray-handle results.
- `dismissUnfamiliarHandle` removes it from active review and supports restoration.

The Handles sidebar correctly dispatches the latter. Messages has independently chosen the wrong Handles operation for its **Dismiss** button.

**Recommendation:** expose one Handles-owned source-review dismissal action keyed by canonical handle identity. Messages should invoke it without choosing normalization or persistence semantics.

### 2. Create/Link Workflow: Ownership Leak

Messages directly calls Contacts’ `manualHandleLinkServiceProvider` to:

- link a handle to an existing participant;
- create a virtual participant;
- then link the handle to it.

Contacts correctly owns the primitive contact creation and linking operations. The leak is that Messages now understands and sequences the **handle-review workflow** around those primitives.

**Recommendation:** introduce a small Handles-owned source-review action facade for:

- create contact and associate source;
- associate source with existing contact;
- dismiss source.

That facade may delegate Contact operations to Contacts. Messages continues to own the buttons, forms, busy state, errors, and complete ViewSpec presentation.

Using the public `ContactPickerDialog` remains appropriate. It is a Contacts-owned presentation helper consumed by a Messages-owned view.

### 3. Source Identity Preparation: Small Ownership Leak

Messages currently watches:

- `handleDisplayNameProvider`;
- the complete `strayHandlesProvider` list.

It then scans the list by ID and independently prepares:

```text
resolved display name
→ raw handle
→ "Handle #<id>"
```

This appears twice, in [handle_lens_view.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/presentation/view/handle_lens_view.dart:65) and [unfamiliar_sources_message_track_occupants.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/presentation/layout/unfamiliar_sources_message_track_occupants.dart:54).

Messages also hardcodes `Unfamiliar source` in both presentation paths.

The existing display-name provider is an **appropriate dependency**. The duplicated source identity projection is not: Handles owns source identity and source-review presentation payloads.

**Recommendation:** provide a Handles-owned per-handle read model containing the prepared source identity facts required by presentation. Messages should consume that payload without scanning an investigation list or recreating fallback rules.

**Dependencies That Are Correct**

| Concern                                           | Classification         | Reason                                                                              |
| ------------------------------------------------- | ---------------------- | ----------------------------------------------------------------------------------- |
| `MessagesSpec.handleLens` and its renderer        | Appropriate dependency | Messages owns the ViewSpec and complete evidence presentation.                      |
| Track occupants prepared by Messages              | Appropriate dependency | Navigation places them; Messages defines its presentation.                          |
| Display-name resolution                           | Appropriate dependency | Handles resolves identity using graph, overlay, and Contacts.                       |
| Endpoint-kind classification                      | Appropriate dependency | Entirely Handles-owned; Messages does not inspect `shortCode` or infer source type. |
| Identify/Numeric investigation filtering          | Appropriate dependency | Handles returns compatible read models.                                             |
| Review persistence                                | Appropriate dependency | Overlay writes and invalidation remain Handles-owned.                               |
| Handle facts and message totals                   | Appropriate dependency | Messages consumes the Handles read model without redefining those facts.            |
| Message timeline, search, and metrics             | Appropriate dependency | These are Message-evidence concerns.                                                |
| Handle-lens query/busy/form state                 | Appropriate dependency | This is transient Messages presentation state, not durable Handles state.           |
| Navigation compatibility and selected-handle flow | Appropriate dependency | Essentials owns flow; Handles supplies opaque investigation meaning.                |

**Minimal Direction**

Keep the ViewSpec and every widget in Messages. Add two Handles-owned public seams:

1. A per-handle source presentation/read model.
2. A source-review action facade that delegates Contact operations where necessary.

The resulting direction becomes:

```text
Messages ViewSpec presentation
    → Handles source presentation model
    → Handles source-review actions
    → Contacts linking primitives / overlay review persistence
```

No broad restructuring is warranted. The significant issue to correct first is the current **Dismiss → markReviewed** mismatch. No files were changed during this audit.
