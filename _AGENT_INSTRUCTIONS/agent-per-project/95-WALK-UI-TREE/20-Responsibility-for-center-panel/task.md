The ownership audit is complete.

Please implement the narrow boundary corrections it identified.

Do not move the ViewSpec or any of its widgets out of Messages.

The governing rule remains:

- one feature owns one ViewSpec;
- Messages owns `MessagesSpec.handleLens` and its complete presentation;
- Handles owns source identity, source-review meaning, and source-review workflows;
- Contacts owns Contact creation/linking primitives;
- Navigation owns page composition and compatibility.

The objective is to let Messages ask Handles for help without teaching Messages Handles business rules.

---

# Priority 1: Correct Dismiss Semantics

The current Messages action named `dismissHandle` invokes:

    handleReviewActionsProvider.markReviewed()

This is wrong.

`markReviewed` and `dismissUnfamiliarHandle` are distinct Handles concepts.

The visible button says:

    Dismiss

Therefore it must perform the Handles-owned dismissal operation that:

- removes the source from active review;
- preserves recoverability;
- uses the existing overlay-owned dismissal semantics;
- invalidates the appropriate Handles read models.

Messages must not choose normalization, persistence, invalidation, or restoration semantics.

Introduce or expose one Handles-owned public source-review action keyed by canonical handle identity.

Conceptually:

    HandlesSourceReviewActions.dismissSource(handleId)

Messages invokes that public action and does not know how dismissal is implemented.

Add a regression test proving that the Messages-owned Dismiss button:

- removes the source from the active review list;
- does not merely mark it reviewed;
- leaves it recoverable through the existing dismissed-source path.

This is the first priority because the current implementation is behaviorally wrong.

---

# Priority 2: Handles-Owned Source-Review Action Facade

Messages currently sequences Contact primitives itself for:

- creating a Contact and associating the source;
- associating the source with an existing Contact;
- dismissing the source.

The individual Contact operations may remain Contacts-owned.

However, the source-review workflow belongs to Handles.

Add a small Handles-owned public facade for the workflows needed by the Messages ViewSpec.

Conceptually:

    HandlesSourceReviewActions
        createContactAndAssociateSource(...)
        associateSourceWithExistingContact(...)
        dismissSource(...)

Use repository naming conventions rather than these names literally.

The facade may delegate to Contacts-owned services and Handles-owned overlay persistence.

Messages should continue to own:

- buttons;
- dialogs/forms;
- transient form state;
- busy state;
- presentation errors;
- the complete ViewSpec rendering.

Messages should not own:

- source normalization;
- association workflow ordering;
- review-state persistence;
- source dismissal semantics;
- Handles-specific invalidation.

The existing Contacts-owned `ContactPickerDialog` may continue to be used directly by the Messages presentation.

That is an appropriate cross-feature presentation dependency.

---

# Priority 3: Handles-Owned Per-Source Presentation Model

Messages currently reconstructs source identity by:

- watching `handleDisplayNameProvider`;
- watching the full `strayHandlesProvider` list;
- scanning that list for one ID;
- applying its own fallback chain:

      resolved display name
      → raw handle
      → "Handle #<id>"

- hardcoding `Unfamiliar source`.

This logic appears in more than one Messages presentation path.

Introduce one Handles-owned per-handle presentation/read model that supplies the source identity facts needed by the ViewSpec.

Conceptually it may contain:

    canonicalHandleId
    primaryDisplayLabel
    rawEndpoint
    sourceKind
    relationship/status label
    messageCount
    firstActivity
    lastActivity
    review/disposition facts needed by presentation

Do not add fields merely because they might be useful later.

Include only what the existing Messages ViewSpec currently needs.

Handles owns:

- lookup;
- canonical identity;
- fallback rules;
- source-kind wording/facts;
- review-state facts.

Messages consumes the resulting payload and decides only visual presentation.

Remove the duplicated list scanning and fallback reconstruction from:

- `handle_lens_view.dart`;
- `unfamiliar_sources_message_track_occupants.dart`;

and any other duplicate path found during implementation.

---

# Dependency Direction

The intended direction after this slice is:

    Messages ViewSpec and presentation
        ↓
    Handles per-source presentation model
        ↓
    Handles source-review action facade
        ↓
    Contacts linking primitives / Handles overlay persistence

Messages orchestrates the user experience.

Handles defines what source-review actions mean.

Contacts performs Contact-specific primitives.

Do not create circular dependencies.

If the proposed facade placement would introduce a cycle, report the cycle and choose the smallest public seam that preserves dependency direction.

---

# Mechanical Impossibility Principle

Apply the Mechanical Impossibility Principle.

The goal is to make these mistakes difficult or impossible:

- a button labelled Dismiss invoking markReviewed;
- Messages independently choosing a Handles persistence operation;
- two Messages renderers inventing different fallback names for the same source;
- one workflow linking a source differently from another workflow.

There should be one Handles-owned meaning for each source-review action and one Handles-owned source identity projection.

---

# Tests

Add focused coverage for:

## Dismiss

    active source
    → invoke Messages Dismiss action
    → Handles dismissal executes
    → source disappears from active review
    → source remains available in dismissed/recovery view
    → reviewed-only state is not mistaken for dismissal

## Link to existing Contact

    source
    → select existing Contact
    → Handles facade associates source
    → Contacts primitive is delegated to
    → relevant Handles read models update

## Create Contact

    source
    → create Contact through existing Messages form
    → Handles facade coordinates Contact creation and source association
    → resulting source resolves through the new Contact
    → no duplicate workflow remains in Messages

## Source presentation payload

Test at least:

- resolved display name;
- raw-handle fallback;
- final ID fallback;
- source/status label;
- lookup by one canonical handle ID;
- no need to scan the full active investigation list.

## ViewSpec rendering

Confirm that:

- Messages still owns and renders the complete `MessagesSpec.handleLens`;
- title/identity presentation uses the Handles payload;
- buttons remain in Messages;
- no ViewSpec rendering moved to Handles.

---

# Documentation

Document the ownership rule near the public seams:

> Messages owns the complete handle-lens ViewSpec presentation. Handles owns the source identity projection and the meaning of source-review workflows. Contacts owns Contact primitives used by those workflows.

Also document:

> Cross-feature presentation ownership does not permit the rendering feature to reimplement the collaborating feature's business semantics.

Update the Unknown Sources feature documentation and any relevant feature charters or interaction documents.

---

# Scope Control

Do not:

- redesign the UI;
- rename the investigations;
- change the Track Matrix;
- move widgets into Handles;
- merge dismissal with blacklist;
- add new identity classifications;
- broaden Contact management;
- implement speculative future source-review actions.

This slice is solely about correcting dependency direction and the current Dismiss behavior.

---

# Completion Report

At completion, report:

- the final Handles-owned source-review facade API;
- the final per-source presentation/read-model API;
- how Dismiss semantics were corrected;
- which Contact primitives the facade delegates to;
- duplicated Messages logic removed;
- files changed;
- tests added or updated;
- architecture-tripwire results;
- analyzer result;
- manual verification of:
  - Create Contact;
  - Link to Existing;
  - Dismiss;
  - active/dismissed list transition;
  - source title fallback;
  - unchanged Messages-owned ViewSpec rendering.
