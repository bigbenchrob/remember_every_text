# App Breakdown Refactor

This folder is the working control center for the architectural refactor of the
MessageLens sidebar, panel, and message-surface system.

The attached text documents are authoritative on verdict, target shape, and
execution constraints:

- `agent-seed.txt`
- `before-after-diagram.txt`
- `plan-revisions.txt`
- `foundational-constraints.txt`
- `pr-review-rubric.txt`

The markdown files in this folder translate that verdict into an execution
program that can be carried out step by step.

## File Guide

- `agent-seed.txt`
  Architectural verdict and non-negotiable laws
- `before-after-diagram.txt`
  Current vs target architecture diagram
- `plan-revisions.txt`
  Mandatory clarifications and enforcement constraints for the implementation
  plan
- `foundational-constraints.txt`
  Mandatory anti-drift enforcement rules that must be installed before and
  during the refactor
- `pr-review-rubric.txt`
  Mandatory architecture review checklist for every refactor PR
- `IMPLEMENTATION_PLAN.md`
  Formal refactor program, ordered phases, risks, and phase gates
- `CHECKLIST.md`
  Granular execution checklist for each phase
- `TESTS.md`
  Metrics, automated tests, runtime scenarios, and acceptance gates
- `TEMPORARY_EXCEPTIONS.md`
  Central tracking file for any temporary migration exceptions
- `PR_ARCHITECTURE_REVIEW_TEMPLATE.md`
  Required review section template for refactor PRs
- `PHASE0_ENFORCEMENT_CONTRACTS.md`
  Concrete contract draft for resolver returns, inert payload transport, and
  render-edge action reconstruction
- `CONTACT_TIMELINE_INERTIAL_SCROLL_FREEZE_NOTE.md`
  Active runtime handoff note for the contact-timeline inertial-scroll freeze
  investigation and its relevance to the refactor
- `INERTIAL_SCROLL_FREEZE_2ND_OPINION.TXT`
  Active second-opinion directive for the inertial-scroll freeze investigation,
  including instrumentation expectations and hot-path design guidance

## Refactor Posture

This refactor is high risk.

The objective is not to preserve broken pathways while layering repair logic on
top. The objective is to remove alternate sources of truth until the system
becomes deterministic again.

The intended end state is:

`one semantic state -> one projection path -> one rendered outcome`

The constraints in `plan-revisions.txt`, `foundational-constraints.txt`, and
`pr-review-rubric.txt` are mandatory. If a markdown file drifts from those text
files, the text files are authoritative until the markdown is corrected.

The anti-drift enforcement plan is part of the implementation program, not
optional polish.

The PR review rubric is mandatory process, not advisory review guidance.

## Execution Rule

Only one problem area should be refactored at a time, in the strict order laid
out by `agent-seed.txt` and `IMPLEMENTATION_PLAN.md`.

No later phase begins until the current phase has:

- satisfied its structural exit criteria
- satisfied its test gate
- passed its manual runtime checks

A phase is still incomplete if it only appears correct because hidden state,
repair logic, or preserved broken pathways are masking architectural failure.

If any phase breaches a declared invariant, treat that as an engine failure,
not a soft warning.