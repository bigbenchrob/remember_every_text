# MessageLens UI/UX Walk

## Purpose

This directory contains a systematic review of every user-visible surface in MessageLens.

The objective is not simply to identify bugs, but to improve the overall experience of using the application.

Each document represents one UI surface (or one tightly related group of controls) and answers questions such as:

- What is this surface trying to accomplish?
- Does it accomplish that purpose?
- Is it obvious to a first-time user?
- Can the workflow be simplified?
- Is it visually consistent with the rest of the application?
- Does it support both novice and expert users?

These reviews intentionally separate **design** from **implementation**.

The review documents define _what should change_.

Codex implementation plans define _how those changes will be made._

This is the active product-improvement phase of the project. The graph
architecture should now be treated as supporting infrastructure. Do not expand
a UI review into unrelated architecture cleanup unless the review identifies a
clear release, data-integrity, ownership, or user-visible correctness blocker.

---

# Directory Structure

Each major application area has its own folder.

Within each folder, every significant UI surface has its own review document.

Reviews should remain focused. If a discussion grows beyond a single UI surface, split it into additional review documents.

Active review folders should stay numbered by application area, for example:

- `10-Messages-Sidebar/Conversations/`
- `10-Messages-Sidebar/Contacts/`

Historical cross-column layout review notes live in `15-X-COLUMN-LAYOUT/`.
The durable mechanical contract now lives in
`../09-CROSS-COLUMN-LAYOUT/`. Use the top-level folder when a UI issue concerns
page-level vertical rhythm across peer panels rather than the presentation of
one widget or one sidebar surface.

Cross-review registers live in `00-Registers/`. Use these registers for
deferred implementation decisions, future design concepts, and cleanup items
that should remain visible after the originating review is complete.

When a review identifies work that belongs to a later review area, record it in
`00-Registers/IMPLEMENTATION_DEBT.md` and add a short pending-implementation
note in the target review folder. This keeps the current review focused while
preserving the future work in the place that should own the design.

Completed and verified reviews move to `99-IMPLEMENTED/` so the active review
queue remains short. Preserve the same folder hierarchy inside
`99-IMPLEMENTED/`.

For example, when the Conversations sidebar reviews are complete:

```text
10-Messages-Sidebar/Conversations/
```

moves to:

```text
99-IMPLEMENTED/10-Messages-Sidebar/Conversations/
```

Leave the now-empty working parent folder in place when useful, because it
preserves context for other active review folders.

---

# Review Workflow

1. Walk through one UI surface.
2. Record observations.
3. Decide what should change.
4. Define acceptance criteria.
5. Hand the review to Codex.
6. Review the implementation.
7. Mark the review complete.
8. Move verified review documents to the matching path under
   `99-IMPLEMENTED/`.

---

# Guiding Principle

The goal is to make MessageLens feel obvious, consistent and enjoyable.

Every change should reduce friction.

Every screen should help users understand where they are, what they can do next, and how to accomplish their task with minimal effort.
