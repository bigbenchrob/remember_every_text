---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-04-05
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
feature: archive-canonical-attachments
status: proposed
created: 2026-04-05
---

# Checklist - Archive-Canonical Attachments

## Phase 0 - Planning Alignment

- [ ] Confirm the product contract for archive-enabled mode: archive-only display, live-only ingestion
- [ ] Confirm the v1 attachment state vocabulary for pending, available, unavailable-awaiting-recovery, and high-confidence non-recoverable
- [ ] Confirm the user interaction model for unavailable placeholders: click-to-prioritize recovery, not click-to-load
- [ ] Confirm that rollout covers all attachment types in the same policy flow

## Phase 1 - Policy Boundary

- [ ] Introduce one attachment display-source policy boundary in the attachments application layer
- [ ] Ensure archive-disabled mode remains live-only for display
- [ ] Ensure archive-enabled mode no longer returns live-file display paths
- [ ] Decide whether the policy is represented by a boolean adapter or internal enum

## Phase 2 - Archive Ingestion Flow

- [ ] Audit the current auto-sync/import/migration cycle to identify where archive ingestion should be scheduled
- [ ] Ensure newly arrived live attachments can enter a pending state before archival completes
- [ ] Define retry and recovery behavior for attachments that are unavailable now but may reappear later in the live Messages folder
- [ ] Add a detection path for placeholder clicks to prioritize background recovery rather than trigger synchronous UI-path loading
- [ ] Define retry/backoff cadence for unresolved attachments, including slower recovery for older items
- [ ] Define internal recovery metadata fields such as last attempt time, next retry time, attempt count, priority, user-interest hint, and recent error summary
- [ ] Define the evidence threshold for classifying an attachment as non-recoverable
- [ ] Preserve overlay-only ownership for archive metadata

## Phase 3 - Hydration And View Models

- [ ] Remove direct live-first file selection from hydration helpers
- [ ] Remove or refactor `bestAvailableFile()` style helpers that bypass the resolver policy
- [ ] Carry explicit attachment availability state through message-row hydration
- [ ] Ensure anomalous rows still render visibly when attachment state is unresolved

## Phase 4 - Presentation

- [ ] Add a lightweight pending attachment UI state such as "attachment being added..."
- [ ] Ensure archive-enabled rows update when archival completes
- [ ] Render a single user-facing unavailable-awaiting-recovery state for unresolved archive-mode attachments in v1
- [ ] Reserve non-recoverable messaging for high-confidence cases only
- [ ] Add a recoverable unavailable placeholder flow that can prioritize background recovery when the source file later reappears
- [ ] Verify that archive-enabled mode never displays from the live Messages path

## Phase 5 - Verification

- [ ] Add resolver tests for both source-policy modes
- [ ] Add hydration tests proving pending state propagation
- [ ] Add UI tests for pending -> available transitions where practical
- [ ] Add regression coverage for "message visible, attachment pending" behavior
- [ ] Update canonical docs after implementation lands
