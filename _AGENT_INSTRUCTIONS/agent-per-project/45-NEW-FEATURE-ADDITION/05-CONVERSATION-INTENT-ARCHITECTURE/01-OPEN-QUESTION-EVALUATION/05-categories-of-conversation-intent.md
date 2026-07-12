I agree. This isn't really about Hidden/Suppressed at all anymore. It's become an architectural principle for the entire Conversation Intent model. I would make it a standalone document that the individual evaluation documents can reference.

# Architectural Principle: Categories of Conversation Intent

## Purpose

Conversation Intent is the architectural seam that captures user-authored or user-confirmed meaning attached to a canonical Conversation.

However, not all Conversation Intent expresses the same kind of user decision.

Recognizing these categories prevents unrelated concepts from being forced into the same product behavior simply because they share a common persistence model.

Shared architecture does **not** imply shared semantics or shared user experience.

---

# Categories of Conversation Intent

## Meaning

Meaning classifies what a Conversation represents.

Examples:

- Tags
- User-confirmed AI classifications

Question answered:

> **What does this Conversation mean?**

Meaning is durable. It supports retrieval, organization, and rediscovery.

---

## Importance

Importance expresses the significance of a Conversation to the user.

Examples:

- Core Favourite

Question answered:

> **How important is this Conversation to me?**

Importance affects prominence and accessibility rather than semantic classification.

Core Favourites should therefore remain a distinct user-facing concept while sharing the common Conversation Intent architecture.

---

## Visibility

Visibility expresses the user's preferred browsing policy.

Examples:

- Suppressed Conversations

Question answered:

> **Should this Conversation normally participate in browsing and discovery?**

Visibility policy affects default presentation.

It does **not** change:

- graph existence;
- message evidence;
- attachment evidence;
- search results;
- Conversation identity;
- source data.

Visibility is therefore a user preference about presentation, not about reality.

The governing principle is:

> **Visibility policy influences default presentation, not existence.**

---

## Context

Context represents what the user is actively working with.

Examples:

- Working Sets

Question answered:

> **What Conversations am I working with right now?**

Context is task-oriented rather than semantic.

Working Sets therefore represent current investigation rather than permanent meaning.

They may begin as temporary session intent and later become durable only through explicit user action.

---

## Annotation

Annotation preserves user-authored interpretation.

Examples:

- Conversation Notes

Question answered:

> **What do I want to remember about this Conversation?**

Annotations complement graph facts without modifying them.

---

# Why This Classification Matters

Without these categories, every new Conversation feature risks becoming either:

- another special-case sidebar mode;
- another persistence mechanism; or
- another interpretation of Tags.

Instead, every new feature should first answer:

> **What kind of Conversation Intent is this?**

Only after its category has been identified should implementation, persistence, retrieval behavior, and user interface be designed.

---

# Relationship to the Architecture

All Conversation Intent shares common architectural principles:

- attached to stable Conversation identity;
- owned by overlay/user-intent storage;
- merged into read models at read time;
- independent of graph projection;
- preserved across graph rebuilds.

Individual intent categories remain free to have different:

- product behavior;
- visual affordances;
- persistence lifetime;
- retrieval semantics;
- editing workflows.

Shared architecture therefore simplifies implementation without forcing unrelated user concepts into the same interface.

---

# Guiding Principle

The graph represents reality.

Conversation Intent represents the user's interpretation of that reality.

Different kinds of Conversation Intent express different kinds of interpretation.

The architecture should unify how those interpretations attach to Conversations while allowing the product to present each according to its own meaning.
