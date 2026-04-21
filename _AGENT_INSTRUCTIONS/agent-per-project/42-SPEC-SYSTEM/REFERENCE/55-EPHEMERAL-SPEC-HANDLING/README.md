

README.md

55 — Ephemeral Spec Handling

How the sidebar supports temporary action flows alongside durable, flow-state-driven cassette stacks.

Key Idea

The sidebar is composed from two projection layers:

1. Stable projection — derived from durable flow state
2. Ephemeral projection — temporary cassette specs for one-off actions

The visible sidebar is always:

stable projection + ephemeral projection

Stable projection is reconstructible.
Ephemeral projection is not.

⸻

Why This Exists

The sidebar cassette system already distinguishes between:

* durable meaning (owned by flow state)
* rendered structure (the cassette rack)

However, some sidebar interactions do not represent durable meaning at all.

Examples:

* Send logs
* Reset message data
* Future confirmation flows or contextual prompts

These must:

* render as proper cassette specs
* participate in the normal coordinator → payload → render pipeline
* but not become durable state
* and not be reconstructed when the sidebar is rebuilt

This document defines how that is achieved.

⸻

Relationship to 54 — Sidebar Cassette Spec System

This folder extends, but does not replace, the core cassette system described in:

* 54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md  
* 54-SIDEBAR-CASSETTE-SPEC-SYSTEM/10-layout-and-optical-composition.md  
* 54-SIDEBAR-CASSETTE-SPEC-SYSTEM/INVIOLATE_RULES.md  

The existing system already defines:

* cassette specs
* rack state
* cascade topology
* coordinator dispatch
* payload boundary
* render routing
* essentials-owned layout

Ephemeral spec handling introduces a second projection layer, not a new rendering system.

⸻

Documents in This Folder


File                                          Purpose

00-ephemeral-spec-handling-architecture.md    Full architecture: projection layers, rules, intent taxonomy, provider model, topology constraints

INVIOLATE_RULES.md                            Non-negotiable rules specific to ephemeral spec handling
⸻

Mental Model

Think of the sidebar as two stacked layers:

[ Stable cassette stack ]
[ Ephemeral cassette stack ]

* Stable stack answers: what does the app mean right now?
* Ephemeral stack answers: what temporary action is the user performing right now?

Only the stable layer survives reconstruction.

⸻

Key Rules (Summary)

* Durable meaning lives only in flow state
* Stable projection is derived from flow state
* Ephemeral actions never write to flow state
* Stable and ephemeral specs are stored separately
* Ephemeral projection is always terminal
* New ephemeral actions replace existing ephemeral projection
* Mode switches clear ephemeral projection
* Coordinator renders: stable first, ephemeral second

⸻

Intent Model

Durability is a property of semantic intent, not of specs or UI.

Use a typed intent hierarchy:

* SidebarPersistentIntent
* SidebarEphemeralIntent

UI layers (menus, buttons) must emit the correct intent type directly.

Do not emit generic intents that require downstream inspection to determine durability.

⸻

What This Enables

* Clean separation between state and UI projection
* Correct restoration of sidebar on mode switch
* Safe addition of temporary sidebar flows
* No special-casing of Settings vs Messages
* Future extensibility for contextual prompts, confirmations, and assistant-like suggestions

⸻

Design Philosophy

Do not special-case modes.

Do not special-case features.

Special-case projection type.

That is the only distinction that matters.