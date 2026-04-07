# Temporary Exceptions

This file is the single tracking point for any temporary migration exception
introduced during the authorship refactor.

Rules:

- A temporary exception must be explicit, narrow, and phase-scoped.
- A temporary exception must not become an alternate semantic writer.
- A temporary exception must not retain hidden UI state or executable behavior.
- If removing the exception changes user-visible behavior, the exception was
  carrying meaning and is invalid.
- Untracked exceptions are not allowed.

## Current Status

### Exception: Contact chooser render-edge snapshot adapter

- Location: `lib/features/contacts/application/sidebar_cassette_spec/widget_builders/contact_chooser_widget.dart`
- Reason: moving chooser readiness into the shared cassette coordinator caused relaunch-time sidebar flicker and a sidebar spinner because chooser async state invalidated the app-level async coordinator.
- Scope: the chooser widget may upgrade a loading inert payload from the feature-owned `contactChooserSnapshotProvider`, but it does not author sidebar meaning, mutate panels, or transport runtime UI types across the cassette boundary.
- Removal phase: Phase 1 - Eliminate Widget Transport
- Why it is not a semantic writer: canonical chooser meaning still originates from `ContactChooserResolver` and `ContactChooserCassettePayload`; the widget only fills in already-feature-owned chooser snapshot data for render-time loading-to-ready transition.
- Why it does not retain hidden state: the adapter watches a provider snapshot and rebuilds directly from current data; it does not cache prior widget trees or preserve alternate chooser state.
- What test/assertion/check will fail if it survives too long: the Phase 1 checklist item `Any temporary adapter can be removed without behavior change` remains open, while `cassette_widget_coordinator_provider_test.dart` now freezes the no-flicker shared-coordinator behavior and the chooser snapshot upgrade separately.

## Required Entry Format

When an exception is introduced, add one entry using this structure:

### Exception: <short conspicuous name>

- Location:
- Reason:
- Scope:
- Removal phase:
- Why it is not a semantic writer:
- Why it does not retain hidden state:
- What test/assertion/check will fail if it survives too long:
