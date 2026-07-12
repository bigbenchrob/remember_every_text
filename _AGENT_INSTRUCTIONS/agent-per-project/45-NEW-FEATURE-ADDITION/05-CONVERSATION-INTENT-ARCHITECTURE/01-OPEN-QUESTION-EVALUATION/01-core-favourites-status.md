# Open Question Evaluation: Core Favourites and Shared Conversation Intent

## Question

Should existing Core Favourites migrate onto a generic Conversation Intent primitive, or remain separate until a second intent type proves the need?

## Recommendation

Core Favourites should migrate onto the shared Conversation Intent architecture when Conversation Tags are implemented.

However, they should remain a distinct, permanent, user-facing concept.

The architecture should be unified, while the user experience remains specialized.

## Rationale

Conversation Intent represents user-authored or user-confirmed meaning attached to a canonical Conversation.

Core Favourites clearly satisfy this definition:

- they are user intent;
- they are attached to a stable Conversation;
- they belong in overlay rather than graph projection;
- they should persist independently of graph rebuilds.

Creating a second persistence mechanism for Tags would duplicate architecture that already exists conceptually for Favourites.

Instead, both should share the same underlying Conversation Intent seam.

## Shared Architecture

Favourites and Tags should share:

- stable Conversation identity
- overlay persistence
- intent assignment mechanism
- read-model merge
- retrieval support
- export/import strategy
- future synchronization model

This creates a single architectural model for Conversation Intent while avoiding multiple special-case implementations.

## Distinct Product Meaning

Sharing architecture does **not** imply identical user experience.

Favourites and Tags represent different user concepts.

### Favourite

A Favourite means:

> "Keep this Conversation immediately accessible."

It is a permanent, built-in capability.

The user should not create, rename, or delete the Favourite intent type.

The existing star affordance and privileged location within the Conversations sidebar should remain.

### Tag

A Tag means:

> "This Conversation has this meaning."

Tags are user-defined semantic labels.

Users create them, rename them, delete them, and apply them to many Conversations.

Tags support organization, retrieval, and discovery.

They should not replace the role of Favourites.

## Architectural Principle

Shared persistence and identity do **not** require identical product behavior.

The architecture should unify how Conversation Intent is stored and attached to Conversation identity.

The product should preserve the distinct meaning of each intent type.

## Implications

This approach allows future Conversation Intent concepts—including Working Sets, Hidden state, Notes, and AI-confirmed classifications—to reuse the same architectural seam without requiring separate persistence models.

Each new concept becomes another kind of Conversation Intent rather than another special-case architecture.

I actually **wouldn't** make it a separate addendum.

I think it belongs naturally under the **Implementation Consequences** section, because it's not really a new architectural decision—it's a project-specific constraint that changes the implementation strategy.

I'd replace the implementation discussion with something like this:

---

### Implementation Considerations

The current state of the project simplifies this decision considerably.

MessageLens currently has a single user and only a handful of Core Favourites. Preserving those existing records is not a project requirement. They can be recreated manually in a few seconds.

Therefore the implementation should optimize for architectural correctness rather than compatibility with the existing Favourite storage.

Specifically:

- no compatibility migration is required;
- existing Favourite records may be discarded or ignored during implementation;
- the new Conversation Intent model should become the authoritative implementation immediately;
- the user can simply re-create the small number of Core Favourites after the transition.

The implementation should therefore preserve the **concept** of Core Favourites, not the existing stored data.

---

## Decision

**Approve.**

Core Favourites should become the first built-in Conversation Intent type, implemented using the same underlying primitives as future Conversation Tags while retaining their unique user-facing behavior and privileged role within the Conversations experience.
