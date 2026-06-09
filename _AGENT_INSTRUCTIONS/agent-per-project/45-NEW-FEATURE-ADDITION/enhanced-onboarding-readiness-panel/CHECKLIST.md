# Environment Readiness Center Panel Checklist

## Current Conformance Note (2026-06-06)

This checklist is historical. Current readiness-panel execution should be
validated against graph build/readiness and overlay persisted failure state, not
retained `working.db` migration as the production gate.

## Phase 0 — Planning

- [x] Capture seed concept from developer notes
- [x] Capture alternate agent proposal
- [x] Write formal proposal
- [x] Write design notes
- [x] Write phased checklist
- [x] Write test plan

## Phase 1 — Routing Scaffold

- [x] Decide final spec boundary for readiness surface
- [x] Add a center-panel route for the readiness surface
- [x] Ensure sidebar suppression/clearing is owned by app-level navigation
- [x] Render a static readiness scaffold in the center panel

## Phase 2 — Domain Model

- [x] Define step keys for readiness checks
- [x] Define step status model
- [x] Define readiness snapshot type
- [x] Define action model for active-step controls
- [x] Define surface view model and step view model types

## Phase 3 — Resolver Layer

- [x] Introduce a readiness resolver for ordered step computation
- [x] Reuse current onboarding environment evidence where practical
- [x] Map evidence to step pass/fail state
- [x] Compute the first failing active step deterministically
- [ ] Keep inferred states clearly marked as inferred

## Phase 4 — Feature Coordinator And Builders

- [x] Add a readiness feature coordinator under the standard view-spec pattern
- [x] Add widget builder(s) for summary rail and active-step panel
- [x] Keep widget code free of environment inspection and sequencing logic
- [x] Define structured action rendering for Open System Settings and Re-check

## Phase 5 — UX Content

- [x] Write calm user-facing copy for each readiness step
- [x] Add privacy and read-only reassurance where relevant
- [x] Use explicit numbered repair steps for failure states
- [ ] Let success register before advancing to the next failing step

## Phase 6 — Startup Integration

- [x] Route startup and not-ready states to readiness surface instead of overlay dialogs
- [x] Keep readiness and import progress clearly separated
- [ ] Transition cleanly into import flow once all readiness steps pass
- [ ] Preserve restart-safe recomputation from machine state rather than wizard index

## Phase 7 — Validation

- [x] Add unit tests for step ordering and active-step selection
- [x] Add resolver/provider tests for mixed readiness states
- [ ] Add manual scenarios for FDA, sparse Messages history, Contacts issues, and import readiness
- [x] Run analyzer and focused readiness tests

## Nice-To-Have Follow-Ups

- [ ] Re-check automatically when the app regains focus
- [ ] Add subtle step-state transitions and success timing polish
- [ ] Add support-friendly details disclosure for advanced diagnostics
- [ ] Add resumable readiness state presentation for non-first-launch reentry
