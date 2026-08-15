The architectural evaluation is excellent and I would like to adopt it as the basis for implementation, with one refinement to the governing principles.

Please revise the proposal accordingly before implementation begins.

---

# Broad Principle

The evaluation correctly separates three concepts:

- panel identity;
- investigation orientation;
- selected subject.

I believe this is the right architecture.

However, I would like to phrase the resulting UI principle slightly more generally.

Rather than saying:

> the explanatory text belongs in the body

I think the principle is:

> **Persistent identity belongs in the header. Investigation orientation belongs in the first thing the user reads after the header.**

For Unknown Sources that will naturally be the idle evidence body, because no source has yet been selected.

For another feature it may naturally occupy a header track.

The architecture should describe _why_ the orientation is placed there rather than making "body" part of the rule.

---

# Idle Presentation

Please revise the documentation to express the idle state like this:

> The idle presentation uses the space normally occupied by evidence to orient the user to the current investigation.

The persistent page identity remains above it.

The explanation is replacing evidence.

It is not replacing the header.

---

# Panel Identity

One sentence from the evaluation deserves to become an explicit architectural rule:

> The center identity must be derived from the investigation every time.

Please strengthen this to something like:

> The center-panel identity is a projection of the active investigation.
> It is never cached or independently maintained as mutable UI state.

Just as Track geometry, investigation compatibility, and self identity are derived, the panel identity should also be derived.

No code should manually assign page titles based on transient UI events.

---

# Matrix Responsibility

I particularly like the statement:

> The Matrix should coordinate shared header geometry; it should not become a document-layout system for local explanatory prose.

Please retain this almost verbatim.

I think it captures an important architectural boundary.

The Matrix determines the shared semantic bands of the page.

Individual feature presentations determine how explanatory content is arranged within the evidence region.

---

# Scope

Do not broaden this into a universal investigation-page framework.

The Unknown Sources feature should become the first concrete implementation of this pattern.

If future investigations (Search, Contacts, Conversations, etc.) naturally converge on the same architecture, we can later promote it into a broader UI standard.

For now, document it as:

- a proven pattern within Unknown Sources;
- an architectural direction rather than a universal framework.

---

# Deliverable

Revise the proposal to reflect these refinements.

Do not change the implementation plan except where these wording changes improve the underlying architectural principles.

The goal is to document _why_ this structure exists rather than simply _where_ each piece of text happens to be rendered.
