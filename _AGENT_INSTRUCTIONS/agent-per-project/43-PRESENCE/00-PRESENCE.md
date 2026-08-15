00-PRESENCE

Presence

Purpose

Presence is the interaction model through which MessageLens accompanies the user during work that unfolds over time.

Rather than presenting a succession of dialogs, progress bars, and transient notifications, Presence provides a calm, continuous conversation between MessageLens and the user.

Whether MessageLens is welcoming a new user, requesting permission to access macOS databases, importing an archive, repairing data, or performing long-running analysis, the interaction should feel consistent.

The user should never feel abandoned.

The user should never feel hurried.

The user should never wonder whether MessageLens is still there.

Presence exists to make the software feel quietly attentive throughout these experiences.

⸻

The Promise

Presence is built around a simple promise:
“I’ve got you. I’ll be here when you come back.”

That promise is more important than any animation, widget, or screen layout.

Every Presence experience should reinforce it.

⸻

Design Principles

Presence is calm.

MessageLens presents one meaningful thing at a time.

It avoids unnecessary movement, interruptions, competing controls, and information overload.

⸻

Presence is truthful.

MessageLens never pretends to know more than it actually knows.

Progress indicators represent real progress.

Estimates are used only when they are meaningful.

Uncertainty is communicated honestly.

⸻

Presence is patient.

The user is never pressured to complete a task immediately.

Interruptions are expected.

Closing the application, leaving for lunch, restarting the Mac, or returning tomorrow are all considered normal parts of the experience.

⸻

Presence is attentive.

MessageLens quietly observes the state of the work.

If user input is required, it asks clearly.

When no input is required, it gets on with the job.

⸻

Presence is respectful.

The user is interrupted only when necessary.

Information is presented because it helps the user, not because the software happens to know it.

⸻

Presence remembers why the work matters.

Some operations involve the user’s own history.

Where appropriate, Presence may gently surface meaningful moments discovered during that work.

These moments are never decorative.

They remind the user that MessageLens is working with memories, conversations, and relationships—not merely records in a database.

⸻

Core Vocabulary

Presence uses a small shared vocabulary throughout the application.

Journey

A complete interaction extending over time.

Examples include onboarding, archive ingestion, database maintenance, and future long-running operations.

⸻

Foreground Journey

The one Journey currently owning Presence.

Several Journeys may remain ongoing, but only the Foreground Journey may have an Active Episode.

⸻

Episode

A single step within a Journey.

Episodes are the primary unit of user interaction.

⸻

Active Episode

The one truthful Episode currently presented for the Foreground Journey.

Only one Episode is active at a time.

⸻

Moment

Transient content that may appear during an Episode.

Moments provide gentle insight into the work being performed without changing the current Episode.

⸻

Coordinator

The component responsible for advancing a Journey.

The Coordinator derives the Active Episode from Journey truth and current feature facts.

It never performs rendering.

⸻

Renderer

The presentation layer.

The Renderer displays Episodes and Moments.

It never decides what should happen next.

⸻

Completion Authority

The source capable of truthfully establishing that an Episode's interaction is complete.

Completion Authority determines the Episode family.

⸻

Presentation Policy

The project-wide rules governing how an already-derived Active Episode is presented calmly and accessibly.

Presentation Policy cannot change Episode semantics or Completion Authority.

⸻

Presentation Observation

A Renderer report that a declared presentation condition occurred.

“Readable opportunity provided” is the canonical example.

A Presentation Observation never establishes acknowledgement, understanding, or completion and is never Journey evidence by itself.

⸻

Provenance

The identity chain accompanying every Coordinator-bound interaction.

A declared Presentation Observation carries the same Provenance when it crosses the Renderer/Coordinator boundary.

It consists of Journey identity, Journey revision, Episode identity, activation occurrence, and interaction occurrence.

Provenance allows obsolete and duplicate interactions to be rejected mechanically.

Episode identity may survive restart. Activation authority does not.

Restart reconciliation issues a new activation occurrence before rendering resumes.

⸻

Responsibilities

Presence is responsible for:

- presenting long-running interactions
- coordinating user participation
- maintaining continuity across interruptions
- providing a consistent interaction vocabulary
- supporting calm communication during work

Presence is not responsible for:

- performing the work itself
- database operations
- import logic
- business rules
- feature-specific decisions

Those responsibilities remain with the feature or operation that is using Presence.

⸻

Relationship to Features

Presence is a project-wide architectural system.

Features supply work.

Presence supplies interaction.

Features describe:
“What needs to happen.”

Presence determines:
“How the user experiences it.”

Onboarding, archive ingestion, database maintenance, and future workflows are consumers of Presence.

They do not own or redefine it.

⸻

A Measure of Success

Presence succeeds when users feel that MessageLens is quietly attentive throughout an interaction.

The goal is not to entertain or impress.

The goal is confidence.

The user should feel:
MessageLens knows where we are.

MessageLens knows what comes next.

I don’t need to supervise it.

If it needs me, it will ask.

⸻

A Design Test

Every proposed Presence experience should be evaluated against one question:
Does this interaction make the user feel that MessageLens is present, attentive, and quietly in control?

If the answer is no, the design should be reconsidered, regardless of how elegant the implementation may be.
