implementation.md

Settings Sidebar — Cassette System Implementation

Goal

Implement the redesigned Settings sidebar using the existing cassette architecture, ensuring:
	•	Strict adherence to spec → coordinator → resolver → payload → VM flow
	•	No widget leakage across boundaries
	•	Clean separation between essentials and feature logic

⸻

1. New Cassette Spec

SettingsCassetteSpec

Introduce a new spec variant for Settings:

SettingsCassetteSpec.troubleshootingMenu

This spec represents:
	•	A grouped list of troubleshooting actions

⸻

2. Cassette Composition

The Settings sidebar becomes a simple cassette stack:

CassetteRackState:
	1.	App-level top menu cassette (existing)
	2.	Settings → Troubleshooting cassette

No nested menus
No secondary “choose action” cassette

⸻

3. Coordinator

settings_cassette_coordinator.dart

Coordinator responsibility:
	•	Interpret SettingsCassetteSpec.troubleshootingMenu
	•	Return a SidebarCassetteCardViewModel

Important:
	•	Must return Future
	•	Must NOT return widgets

⸻

4. View Model

Single VM (no new types):

SidebarCassetteCardViewModel

Payload structure (example conceptual shape):
	•	title: “Troubleshooting”
	•	layoutStyle: listDense
	•	items:
	•	item 1:
	•	label: “Send Logs…”
	•	action: sendLogs
	•	role: standard
	•	item 2:
	•	label: “Reset Message Data…”
	•	action: resetMessageData
	•	role: destructive

⸻

5. Action Routing

Actions should not execute directly in the coordinator.

Instead:
	•	Coordinator emits action identifiers
	•	UI layer dispatches via existing action system

Example:

onTap → SettingsActionDispatcher.handle(action)

⸻

6. Actions

sendLogs

Already exists:
	•	Routes to LogExportService.exportAndPresent()

No changes required.

⸻

resetMessageData

New action:

SettingsAction.resetMessageData

⸻

7. Reset Flow Implementation

Step 1: Confirmation Dialog

Triggered by action dispatcher.

Dialog is:
	•	Modal
	•	Non-dismissible except via buttons
	•	Matches overview.md content

⸻

Step 2: On Confirm

Call:

ResetService.resetAndQuit()

⸻

8. ResetService

New service responsible for:

Responsibilities
	1.	Delete derived data:
	•	messages database
	•	contacts database
	•	any cached/import tables
	2.	Preserve:
	•	overlay database
	•	user preferences
	•	tags, favorites
	3.	Trigger app termination

⸻

Implementation Notes
	•	Use existing database services where possible
	•	Avoid partial deletion — must be atomic from user perspective
	•	Log reset event for diagnostics

⸻

9. App Restart Behavior

No special handling needed if architecture is clean.

On next launch:
	•	App detects missing working data
	•	Automatically enters first-launch import flow

This must already exist and be trusted.

⸻

10. Removal of Legacy Flow

Delete:
	•	Existing “Reimport Data…” action
	•	Any bespoke reimport dialog
	•	Any partial import triggers

Rationale:
	•	Enforce single import path
	•	Prevent regression into multi-flow state

⸻

11. Layout and Styling

Use:

SidebarCardLayoutStyle.listDense

Rationale:
	•	Matches list-style menu
	•	Minimizes padding
	•	Aligns with other menu-style cassettes

⸻

12. Role Semantics

Assign roles for visual consistency:
	•	Send Logs → standard action
	•	Reset Message Data → destructive action

Essentials layer should:
	•	Render destructive styling (e.g., red text)
	•	Maintain consistent alignment

⸻

13. Testing Requirements

Unit Tests
	•	Coordinator returns valid VM
	•	No widget leakage
	•	Correct action identifiers emitted

⸻

Integration Tests
	•	Selecting Reset shows dialog
	•	Confirming:
	•	deletes correct data
	•	preserves overlays
	•	triggers app quit

⸻

Invariants
	•	Only one import path exists
	•	Reset always leads to first-launch flow
	•	No in-place reimport remains

⸻

14. Future Extension

Additional sections can be added as new specs:

Examples:

SettingsCassetteSpec.privacy
SettingsCassetteSpec.storage
SettingsCassetteSpec.experimental

Each handled by:
	•	Same coordinator pattern
	•	Same VM structure

⸻

Final Implementation Principle

The sidebar remains:

Spec-driven
Deterministic
Stateless at the coordinator level

All system behavior is:
	•	Routed through actions
	•	Executed by services
	•	Reflected via restart and re-import