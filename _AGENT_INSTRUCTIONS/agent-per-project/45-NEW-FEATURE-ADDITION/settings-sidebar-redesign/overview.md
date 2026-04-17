overview.md

Settings Sidebar Redesign — Overview

Purpose

Simplify the Settings sidebar by removing redundant structure, clarifying user intent, and aligning both UX and system behavior around a single, deterministic data reset and import flow.

This redesign addresses both:
	•	Surface-level UX issues (clutter, redundancy)
	•	Deeper architectural issues (multiple inconsistent import paths)

⸻

Problems in Current Design

1. Redundant Menu Structure

Current structure:
	•	Top menu: “Actions”
	•	Submenu: “Choose an action”

This creates:
	•	No additional meaning
	•	Extra interaction cost
	•	Visual clutter

This is a false hierarchy and should be removed.

⸻

2. Ambiguous “Reimport Data” Behavior

The current “Reimport Data…” action:
	•	Has unclear scope (what is deleted?)
	•	Has unclear lifecycle (in-place mutation vs restart)
	•	Is inconsistent with first-launch import
	•	Is not trusted (doesn’t work reliably)

This creates:
	•	User confusion
	•	Debugging complexity
	•	Multiple competing system states

⸻

Design Goals
	1.	Single, flat menu structure
	2.	Clear grouping by intent
	3.	Explicit and predictable system behavior
	4.	Single import pipeline (first-launch flow only)
	5.	MacOS-native UX patterns

⸻

New Sidebar Structure

All actions are moved into a single top-level menu, grouped by subheadings.

Troubleshooting
	•	Send Logs…
	•	Reset Message Data…

Notes
	•	“Send Logs…” is placed first because it is non-destructive
	•	“Reset Message Data…” is destructive and therefore secondary

⸻

Action: Reset Message Data

Conceptual Model

This replaces “Reimport Data…” entirely.

Instead of:
	•	Performing an unclear in-place reimport

We move to:
	•	Delete derived data
	•	Quit app
	•	Rebuild deterministically on next launch

⸻

User-Facing Behavior

When to Use

The user should choose this action if:

The messages or contacts shown in MessageLens do not match what they see in Messages or Contacts on macOS.

⸻

What Happens
	1.	MessageLens deletes:
	•	Imported messages data
	•	Imported contacts data
	2.	MessageLens preserves:
	•	User preferences
	•	Favorites
	•	Tags
	•	Any overlay data
	3.	MessageLens quits automatically
	4.	On next launch:
	•	The app runs the standard first-launch import flow
	•	Data is re-imported from macOS sources

⸻

Confirmation Dialog

Title

Reset MessageLens Data?

⸻

Body

Use this if the messages or contacts shown in MessageLens don’t match what you see in Messages or Contacts on your Mac.

This will:
	•	Delete all imported messages and contacts data in MessageLens
	•	Keep your preferences (favorites, tags, etc.)

Your data will be re-imported from your Mac the next time you open the app.

After resetting, MessageLens will quit automatically.

⸻

Buttons
	•	Cancel
	•	Reset and Quit

Notes:
	•	“Reset and Quit” is destructive and right-aligned
	•	No ambiguity about outcome

⸻

Naming Decision

Preferred label:

Reset Message Data…

Rationale:
	•	Short and macOS-native
	•	Dialog provides full explanation
	•	Avoids overloading menu text

Alternative (acceptable):
Reset and Reimport Data…

⸻

Architectural Impact

Before
	•	Multiple import flows:
	•	First launch
	•	Reimport action
	•	Possibly partial refresh logic

This leads to:
	•	Inconsistent state
	•	Edge cases
	•	Hard-to-debug issues

⸻

After
	•	Single import flow
	•	Only runs on app launch
	•	Reset becomes:
	•	A controlled destruction of derived state

Benefits:
	•	Deterministic behavior
	•	Easier debugging
	•	Reduced code complexity
	•	Stronger mental model

⸻

UX Principles Applied
	•	Clarity over flexibility
	•	One obvious path instead of multiple partial ones
	•	Destructive actions are explicit and contained
	•	System resets follow restart-based patterns (macOS standard)

⸻

Final Outcome

This redesign provides:
	•	Cleaner UI
	•	Clear user intent
	•	Predictable system behavior
	•	Simplified architecture
	•	Improved reliability