# Enhanced Onboarding Flow Checklist

## Current Conformance Note (2026-06-06)

This checklist is historical. Current onboarding work should verify
source-scoped import, conversation graph build/readiness, overlay failure
persistence, and centralized reset/maintenance locks. Do not add new ordinary
setup steps that depend on retained `working.db` migration completion.

## Phase 0 — Planning

- [x] Write proposal
- [x] Write design notes
- [x] Write checklist
- [x] Write test matrix

## Phase 1 — State Model

- [ ] Define onboarding environment report types
- [ ] Define blocker categories and sync-plausibility categories
- [ ] Define recommended-action types for the UI
- [ ] Keep classification vocabulary small and user-facing

## Phase 2 — Evidence Gathering

- [ ] Reuse existing FDA check as one evidence source
- [ ] Add Messages source evidence beyond simple readability
- [ ] Add AddressBook readiness evidence via approved path resolution
- [ ] Add import database readiness evidence
- [ ] Add working database readiness evidence
- [ ] Add import failure summary evidence
- [ ] Add migration failure summary evidence

## Phase 3 — Classification

- [ ] Map raw evidence to environment report
- [ ] Map environment report to user-facing readiness state
- [ ] Distinguish permission blocked from source sparse and pipeline failed
- [ ] Mark inferred states explicitly rather than presenting them as facts

## Phase 4 — Presentation

- [ ] Upgrade onboarding UI to render the richer diagnosis
- [ ] Add clear next-step actions per blocker type
- [ ] Add an optional advanced-details disclosure
- [ ] Keep import and migration progress comprehensible and user-safe

## Phase 5 — Resilience

- [ ] Re-evaluate environment after permission changes or retries
- [ ] Preserve a concise last-failure summary for support use
- [ ] Ensure onboarding never strands the user in a blank state

## Phase 6 — Validation

- [ ] Add unit tests for classification logic
- [ ] Add focused provider tests for onboarding evaluator behavior
- [ ] Run analyzer
- [ ] Manually test key startup scenarios on macOS

## Nice-to-Have Follow-Ups

- [ ] Add a dedicated center-panel bootstrap surface if the overlay becomes too dense
- [ ] Add a rescan action when safe
- [ ] Add a debug-only reset/setup diagnostics action
- [ ] Persist a last-known environment report snapshot for support workflows
