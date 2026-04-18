---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-04-17
source_of_truth: doc
links:
  - ./overview.md
  - ./implementation-details.md
  - ../../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/00-universal-spec-handling-pattern.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/INVIOLATE_RULES.md
  - ../../25-ONBOARDING-AND-ARCHIVE/00-overview.md
  - ../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
tests: []
feature: settings-sidebar-redesign
status: proposed
created: 2026-04-17
---

# Feature Proposal — Settings Sidebar Redesign

**Proposed Branch**: `Ftr.settings-sdbr`
**Status**: Proposed
**Created**: 2026-04-17

---

## Overview

Redesign the Settings sidebar into a flatter, clearer troubleshooting surface that removes the current false hierarchy and replaces the ambiguous in-place reimport flow with a deterministic reset-and-quit flow.

The redesign is intentionally narrow.

It does not attempt to reinvent the broader settings system. It fixes the tester-facing settings path that currently exposes too much structure and too little clarity.

Approved tester-facing structure for this proposal:

- top settings menu cassette
- one troubleshooting cassette containing:
  - `Send Logs…`
  - `Reset Message Data…`

The current Attachment Archive choice is intentionally omitted from the visible menu for the current tester cohort, but its underlying logic should be preserved for later reintroduction.

## User Value

### Problem

The current Settings sidebar has two separate issues:

1. It uses a redundant hierarchy:
   - `SettingsMenuChoice.actions`
   - then `ContactsSettingsSpec.actionsMenu`
   - then a second action selection layer

2. It exposes `Reimport Data…` as a vague in-place action whose lifecycle is unclear:
   - unclear deletion scope
   - unclear relationship to first-launch onboarding
   - hard to trust when debugging import state

This creates a poor mental model for testers. The UI suggests there are multiple equivalent repair paths when the intended architecture really wants one deterministic bootstrap path.

### Proposed User-Facing Outcome

The visible Settings sidebar becomes a simple troubleshooting surface:

- `Send Logs…` remains the non-destructive first action
- `Reset Message Data…` becomes the only destructive recovery path

When the reset action is used, the app:

- deletes imported / derived message and contact data
- preserves user overlays and preferences
- quits automatically
- re-enters the standard first-launch import flow on next launch

### Benefits

- simpler sidebar structure
- clearer troubleshooting intent
- one obvious recovery path instead of multiple competing flows
- stronger alignment with the existing onboarding/import architecture
- lower support burden for the current tester cohort

---

## Existing Architecture Summary

- Settings mode already exists as `SidebarMode.settings`.
- The visible root settings cassette is currently `SidebarUtilityCassetteSpec.settingsMenu`.
- That top menu currently exposes two choices through `SettingsMenuChoice`:
  - `actions`
  - `attachmentArchive`
- Choosing `actions` currently cascades into `ContactsSettingsSpec.actionsMenu`, then into feature-owned info cassettes such as:
  - `ContactsSettingsSpec.sendLogsInfo`
  - `ContactsSettingsSpec.reimportDataInfo`
- Action execution is routed through `SidebarActionDispatcher`, which already handles:
  - `SendLogsRequested()`
  - `ReimportDataRequested()`
- `SendLogsRequested()` now exports a support bundle that may include `database_health.json`.
- `ReimportDataRequested()` currently starts an in-place onboarding reimport via `onboardingGateProvider.notifier.startReimport()`.
- Attachment Archive is not merely a stub. It already has feature-owned logic, providers, and UI backed by the app-owned archive system described in `25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md`.

### Architectural Mismatch This Proposal Fixes

The current settings path is split awkwardly across unrelated ownership boundaries:

- top-level settings choice lives under sidebar utilities
- the next level of settings content lives under the contacts feature
- attachment archive is a separate feature but is exposed as a peer settings choice

That makes the current settings stack work, but it obscures responsibility and makes the sidebar harder to reason about.

---

## Assumptions

1. The current tester cohort benefits more from a narrow troubleshooting surface than from a broader settings surface.
2. The launch-time onboarding gate is already the canonical import/rebuild path and should remain so.
3. A restart-based reset flow is easier to reason about than an in-place reimport flow.
4. Attachment Archive remains a valid long-term capability, even if it is temporarily removed from the visible Settings menu.
5. Preserving attachment archive logic means preserving its feature logic and data model, not necessarily preserving its current menu placement.

---

## Hard Invariants

1. Follow the existing cross-surface contract: spec -> coordinator -> resolver -> payload -> widget builder.
2. Feature cassette coordinators must keep returning `Future<SidebarCassettePayload>` and must not construct widgets directly.
3. Do not keep settings troubleshooting behavior coupled to the contacts feature longer than necessary.
4. Do not introduce a second import or reset path beside the standard onboarding/bootstrap flow.
5. Reset must preserve overlay-owned user intent such as favorites, tags, and archive metadata.
6. Reset must not violate overlay / working DB separation.
7. Attachment Archive logic must remain recoverable for later re-exposure; the visible menu may change, but the capability should not be conceptually discarded.
8. No widget leakage across feature / essentials boundaries.

---

## Scope

### Phase 1 — Flatten Settings Into A Troubleshooting Surface

1. Introduce a dedicated settings cassette surface rather than continuing to overload `ContactsSettingsSpec` for settings-only behavior.
2. Replace the current visible `Actions -> choose action` hierarchy with a single troubleshooting cassette.
3. Preserve `Send Logs…` as the first non-destructive troubleshooting action.
4. Replace `Reimport Data…` with `Reset Message Data…`.
5. Add a confirmation dialog with the copy approved in `overview.md`.
6. Implement a reset service that deletes derived app data, preserves overlays/preferences, and quits the app.
7. Remove legacy in-place reimport entry points from the settings sidebar flow.
8. Remove Attachment Archive from the visible tester-facing settings menu while preserving its underlying logic for future re-entry.

### Out Of Scope

- redesigning the broader settings system beyond troubleshooting
- removing or redesigning the underlying attachment archive architecture
- changing the attachment archive data model
- changing the onboarding import pipeline itself
- introducing a full storage/privacy/experimental settings taxonomy in the same pass

---

## Proposed Direction

### 1. Introduce A Dedicated Settings Feature Surface

This redesign should stop routing settings-only cassette content through `ContactsSettingsSpec`.

Instead, introduce a feature-owned `SettingsCassetteSpec` and a matching cassette coordinator/resolver path dedicated to settings-mode sidebar content.

Initial spec surface:

- `SettingsCassetteSpec.troubleshootingMenu`

Why:

- settings troubleshooting is not contacts-specific behavior
- the seed design already assumes a dedicated settings coordinator
- this keeps future additions like privacy/storage/experimental aligned with the repo's feature-spec architecture

### 2. Keep The Visible Cassette Stack Flat

Planned settings stack:

1. app-level settings top menu cassette
2. settings troubleshooting cassette

There should be no second chooser cassette for actions.

The troubleshooting cassette should use a dense list-style card payload and emit typed action intents rather than callback behavior.

### 3. Route Behavior Through Intents, Not Through The Coordinator

The troubleshooting cassette should emit typed action descriptors such as:

- `SendLogsRequested()`
- `ResetMessageDataRequested()`

The coordinator and resolver declare what actions exist.

The dispatcher owns what those actions do.

This preserves the existing cassette architecture rule that feature coordinators declare UI meaning but do not execute side effects.

### 4. Replace In-Place Reimport With Reset-And-Quit

`Reset Message Data…` replaces `Reimport Data…` in the visible settings surface.

The reset flow should:

- show a modal confirmation dialog
- on confirm, call a dedicated reset service
- delete derived import/working data
- preserve overlay DB and preferences
- quit the app

On next launch, the app should naturally fall back into the trusted onboarding/bootstrap flow because derived working state is missing.

### 5. Preserve Attachment Archive As A Deferred Settings Capability

For the current tester cohort, Attachment Archive should disappear from the visible settings menu.

However, the proposal explicitly does **not** recommend treating Attachment Archive as dead code.

Instead, preserve it in one of these two acceptable forms:

1. retain the current archive feature logic and content widget in place while removing only its visible menu entry
2. migrate its settings entry to a dormant future settings spec such as:
   - `SettingsCassetteSpec.attachmentArchive`
   - `SettingsCassetteSpec.storage`

Preferred direction for long-term cleanliness:

- keep archive feature logic where it already belongs
- move any future visible settings entry under the new dedicated settings cassette feature rather than leaving it coupled to `ContactsSettingsSpec`

This keeps the current tester UI simple without throwing away a real capability.

---

## Minimal Implementation Plan

### Step 1 — Add Dedicated Settings Cassette Ownership

Introduce a new settings cassette spec/coordinator/resolver path and add a corresponding top-level `CassetteSpec` variant.

Why this step is necessary:

- it removes settings behavior from the contacts feature boundary
- it gives the redesign a clean place to grow later

Primary risk:

- cassette dispatch and topology changes can accidentally break settings-mode rendering if the new spec is not wired through all app-level routing points

### Step 2 — Flatten The Settings Cascade

Change the settings-mode cascade so the top settings menu resolves directly to the troubleshooting cassette.

Why this step is necessary:

- it removes the false `choose action` hierarchy
- it makes the sidebar structure match the approved UX

Primary risk:

- stale cascade links may leave dead variants or unreachable cassettes behind if all old topology edges are not removed cleanly

### Step 3 — Replace Action Selection With Direct Typed Actions

Replace the old secondary action choice model with direct list items that emit typed intents.

Why this step is necessary:

- the new UI is a list of actions, not a menu that leads to more menus
- destructive styling needs to live in payload semantics, not bespoke widget code

Primary risk:

- if the payload family is chosen poorly, action tone or dense-list behavior may be implemented ad hoc instead of through the shared sidebar render contract

### Step 4 — Add Reset Confirmation And Reset Service

Add `ResetMessageDataRequested()` handling in the dispatcher and route it into a modal confirmation flow backed by a dedicated reset service.

Why this step is necessary:

- reset behavior is the core product change in this redesign
- deletion scope must be owned by a named service, not scattered through UI code

Primary risk:

- deletion scope mistakes could remove overlay-owned user data or leave the app in a partial state

### Step 5 — Remove Legacy Reimport Entry Points From Settings

Remove the visible `Reimport Data…` settings action and any bespoke settings-path reimport UI that implies in-place repair remains supported.

Why this step is necessary:

- the redesign promises one recovery model
- leaving legacy reimport entry points behind would undermine that promise

Primary risk:

- hidden or duplicate reimport hooks may survive in the settings branch and reintroduce architectural ambiguity

### Step 6 — Defer Attachment Archive Cleanly

Remove Attachment Archive from the visible settings menu while preserving the feature logic and documenting the approved future re-entry point.

Why this step is necessary:

- it reduces tester-facing surface area now
- it avoids re-building archive settings from scratch later

Primary risk:

- if the menu entry is removed without an explicit re-entry plan, the archive feature may drift into unsupported dead code

### Step 7 — Verify With Focused Tests And Documentation

Add or update cassette, dispatcher, and reset-flow tests; update feature docs to reflect the new single-path recovery model.

Why this step is necessary:

- this change touches both navigation semantics and destructive behavior
- the removal of reimport needs regression protection

Primary risk:

- insufficient test coverage could leave a partially working settings surface that only fails during destructive recovery flows

---

## Likely Implementation Surface

The exact file list may vary, but this proposal is expected to touch areas like:

- `lib/essentials/sidebar/domain/entities/cassette_spec.dart`
- settings-mode cascade/topology files under `lib/essentials/sidebar/domain/entities/cascade/`
- `lib/essentials/sidebar/domain/sidebar_action_intent.dart`
- `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`
- a new settings feature surface such as `lib/features/settings/`
- existing settings top-menu resolvers/builders in `lib/features/sidebar_utilities/`
- onboarding/reset orchestration files
- tests for settings cassette payloads, dispatcher routing, and reset behavior

Expected non-goals for implementation:

- changing the core archive service implementation
- changing archive storage provenance rules
- changing the broader onboarding state machine beyond what reset invocation requires

---

## Attachment Archive Preservation Strategy

Because the visible menu is being simplified for testers, the proposal needs an explicit rule for how the Attachment Archive capability survives.

Approved preservation strategy:

1. Keep the archive domain, providers, services, and overlay-backed data model intact.
2. Remove only the visible tester-facing menu choice.
3. Preserve a future settings re-entry path in documentation and, if implementation reaches that point, in a dormant dedicated settings spec.
4. Do not keep archive exposure coupled to `ContactsSettingsSpec` as the long-term shape.

This gives the project a clean answer to both goals:

- a simpler tester-facing settings sidebar now
- no loss of archive capability later

---

## Risks

1. **Boundary churn**
   Extracting settings behavior out of `ContactsSettingsSpec` changes cassette routing and could cause temporary breakage in settings mode if done piecemeal.

2. **Destructive scope mistakes**
   The reset flow must preserve overlay-owned user data and preferences while removing derived import/working state only.

3. **Architectural backsliding**
   It will be tempting to implement the troubleshooting card quickly with ad hoc widgets or direct callbacks. That would violate the cassette system contract.

4. **Legacy path leakage**
   If `ReimportDataRequested()` or other partial import triggers survive in the settings UX, the redesign will fail its core goal.

5. **Archive drift**
   If Attachment Archive is merely hidden and never documented as a deferred capability, the feature may become difficult to reintroduce safely.

---

## Acceptance Criteria

- Settings mode renders a flat troubleshooting stack with no secondary action chooser.
- The visible troubleshooting cassette exposes only:
  - `Send Logs…`
  - `Reset Message Data…`
- `Send Logs…` still routes through the support-bundle export path.
- `Reset Message Data…` shows the approved confirmation dialog and routes to a dedicated reset service.
- The reset flow deletes derived message/contact state, preserves overlays/preferences, and quits the app.
- The next launch naturally re-enters the standard onboarding/bootstrap import flow.
- No visible in-place reimport action remains in the settings sidebar.
- Attachment Archive is removed from the visible tester-facing menu without discarding the underlying archive capability.
- The implementation respects the cassette architecture invariants and does not leak widgets across feature/essentials boundaries.
