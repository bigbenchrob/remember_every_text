The Episode Model analysis has converged on a small canonical protocol model.

Before writing 10-EPISODE-MODEL.md, I want to establish a normative specification for the concept of a Presence Episode itself.

Read:

- 43-PRESENCE/00-PRESENCE.md
- 43-PRESENCE/10-EPISODE-MODEL.md (placeholder)
- the Presence README
- the Episode Model Design Analysis
- any nearby architectural documents necessary to maintain project documentation conventions

This is a documentation task only.

Do not modify application code.
Do not design Flutter widgets.
Do not write Riverpod providers.
Do not propose database schemas.
Do not describe rendering implementation.

Instead, produce a formal architectural specification answering one question:

"What is a Presence Episode?"

The specification should read like a protocol or architectural contract rather than a design discussion.

Its purpose is to become the conceptual foundation for the later Episode Model document.

The specification should define:

# Definition

What an Episode is.

What it represents.

What it does not represent.

Its relationship to:

- Journey
- Moment
- Coordinator
- Renderer
- Feature operation

# Responsibilities

Precisely define what an Episode is responsible for.

Equally important, define what it is explicitly NOT responsible for.

# Lifecycle

Describe an Episode's lifecycle from creation through completion.

Include:

- creation
- activation
- presentation
- completion
- replacement by the next Episode
- re-derivation after application restart

Avoid implementation detail.

# Completion Authority

Define this concept formally.

Explain why Episode family is determined by the authority capable of truthfully completing it.

Provide several contrasting examples illustrating the principle.

# Interaction Contract

Describe the contract between:

Feature
↓

Journey Coordinator
↓

Episode
↓

Renderer
↓

User
↓

Journey Coordinator

State clearly that:

- operations publish facts
- Presence derives interaction
- rendering never advances Journeys
- user assertions never replace independently observable evidence

# Invariants

State the architectural invariants that every future Presence implementation must preserve.

Examples include:

- exactly one active Episode
- durable Journey state is authoritative
- Moments cannot alter Journey state
- Episode families cannot be invented by individual features
- rendering never owns operational logic

Expand this list where appropriate.

# Non-goals

List behaviours that Episodes must never acquire.

Examples:

- performing operational work
- storing business rules
- directly querying databases
- coordinating feature workflows
- deciding application behaviour
- becoming feature-specific screens

# Relationship to Episode Families

Explain that Episode is the abstract interaction contract.

Episode families (Inform, Ask<T>, Work, Await) are protocol specializations defined by the canonical Episode Model.

This specification must intentionally avoid describing those families in detail.

# Design Test

Conclude with a small number of review questions that future contributors can apply when designing new Presence behaviour.

Examples:

"Does this represent an interaction or an operation?"

"Who can truthfully complete this Episode?"

"Could this Episode be re-derived after restart?"

"Has the feature supplied facts while Presence supplied interaction?"

Important:

Do not yet write the canonical Episode Model.

Do not classify Episode families.

Do not discuss rendering technology.

Do not propose implementation classes.

This document should remain stable even if Flutter, Riverpod, rendering, or application architecture change completely.

Write it as an enduring architectural specification for Presence itself.

After completing the specification:

1. Briefly explain any refinements you made beyond the design analysis.
2. Identify any architectural questions that still remain before writing 10-EPISODE-MODEL.md.
