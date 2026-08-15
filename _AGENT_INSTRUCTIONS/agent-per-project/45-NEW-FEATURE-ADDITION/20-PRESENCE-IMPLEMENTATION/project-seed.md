Presence architecture is now complete.

From this point onward we are no longer designing Presence.

We are proving that the architecture can be implemented faithfully.

The first implementation must be a tracer bullet.

Its purpose is to validate the architecture from Journey through Rendering while deliberately avoiding MessageLens-specific complexity.

---

## Objective

Implement the smallest truthful Presence system.

This is NOT onboarding.

This is NOT archive ingestion.

This is NOT production UI.

It is simply proof that the Presence architecture is internally consistent.

---

## Rules

Read the complete Presence architecture before beginning.

Treat it as normative.

Do not redesign it.

Do not simplify it.

Do not add implementation shortcuts that bypass the architecture.

If implementation reveals an apparent contradiction, stop and report it rather than silently changing the architecture.

---

## Tracer Bullet Journey

Implement one simple Journey:

Journey created

↓

Inform / welcome

↓

Inform / explanation

↓

Ask<String>

Question:

"What should I call you?"

↓

Inform / completion

↓

Journey completed

Nothing else.

No Full Disk Access.

No database.

No Messages.

No Contacts.

No archive.

No filesystem.

No background work.

No Moments.

No concurrency.

---

## Implementation Goal

The implementation should exercise:

- Journey creation
- Journey identity
- Episode derivation
- Coordinator transitions
- Inform Episodes
- Ask<T>
- typed response
- Rendering
- Provenance
- Completion
- Restart-safe architecture (where practical)

while introducing as little application-specific code as possible.

---

## Project Structure

Begin implementing Presence as its own subsystem.

Use:

lib/essentials/presence/

Do not place implementation inside onboarding.

Presence should initially have no dependency on MessageLens features.

MessageLens features will later become Presence clients.

---

## Architecture First

Before writing implementation code:

Survey the existing Flutter project.

Propose:

- package structure
- folder layout
- ownership boundaries
- dependency direction

Demonstrate how the implementation maps onto the Presence architecture.

Explain:

Journey

Episode

Coordinator

Renderer

Moment

contracts

models

state

without yet discussing production onboarding.

---

## Implementation Strategy

Produce a staged implementation plan.

Each stage should leave the project compiling.

Prefer many small verifiable commits.

Avoid speculative abstraction.

The first rendered screen should simply prove that:

a Journey exists,

an Episode is derived,

the Renderer presents it,

the Coordinator advances,

and the next Episode appears.

---

## Important

Do not implement future architecture.

Do not anticipate archive ingestion.

Do not optimize for hypothetical future requirements.

Implement only what the tracer bullet requires while remaining completely faithful to the canonical Presence architecture.

---

## Deliverables

Produce:

1. Proposed package layout.
2. Implementation stages.
3. Suggested commit boundaries.
4. Risks where implementation may challenge the architecture.
5. Recommended first coding task.

Do not begin coding yet.

This is an implementation planning exercise.
