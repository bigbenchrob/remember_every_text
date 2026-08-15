---
tier: project
scope: production-readiness-workstream-organization
owner: agent-per-project
last_reviewed: 2026-07-27
source_of_truth: doc
status: current
links:
  - ../00-PRODUCTION-READINESS-MASTER-PLAN.md
  - ./README.md
tests: []
---

# Workstream Organization Convention

## Purpose

This document establishes the organizational conventions used throughout the Production Readiness review.

These conventions are intended to make every workstream self-contained, auditable and historically valuable, while ensuring that canonical architecture continues to live in its appropriate permanent location elsewhere in the documentation.

---

# Workstreams Are Architectural Investigations

Each workstream should be viewed as a focused architectural investigation.

A workstream is **not** simply a collection of implementation notes.

Instead, it records the complete lifecycle of an architectural question:

- what question was asked;
- what was discovered;
- what was proposed;
- what was implemented;
- what evidence was gathered;
- what conclusions were reached.

The workstream becomes the permanent engineering notebook for that investigation.

---

# Numbering

Workstreams are numbered according to **architectural dependency**, not the order in which they happened to be conceived.

For example:

```
01-PRODUCTION-DATA-PROTECTION
02-ONBOARDING-REVIEW
03-HISTORICAL-MESSAGES-IMPORT
04-ARCHIVED-MESSAGELENS-IMPORT
05-ATTACHMENT-INTEGRITY
06-IMPORT-VALIDATION
07-PRODUCTION-HEALTH
```

This numbering communicates implementation order and project dependencies.

The authoritative numbering appears in:

- the Production Readiness Master Plan;
- `WORKSTREAMS/README.md`;
- the active workstream folder names.

Historical seeds may retain earlier conception-order numbering. They remain
source evidence and do not override the active dependency order.

---

# Folder Creation

Create workstream folders only when work begins.

Avoid creating empty placeholder directories simply to complete the numbering sequence.

The active workstreams should accurately reflect the current state of the project.

---

# Standard Workstream Structure

A workstream will typically evolve through documents such as:

```
README.md
00-task.md
CURRENT-STATE-AUDIT.md
QUESTIONS.md            (optional)
PROPOSAL.md
IMPLEMENTATION-PLAN.md
VALIDATION.md           (optional)
COMPLETION-REPORT.md
```

Not every workstream requires every document.

Documents should be created only when they become necessary.

---

# Purpose Of Each Document

## README.md

Acts as the cover page.

It should briefly describe:

- purpose;
- current status;
- reading order;
- important links.

It should remain concise.

---

## 00-task.md

This is the permanent mission statement.

It records the original assignment exactly as given.

It is intentionally **not** rewritten as understanding improves.

Subsequent documents represent the response to that assignment.

Numbering, path, date, or scope contradictions should be corrected before the
investigation begins. Once investigation evidence is recorded, the task is
frozen; later changes belong in a superseding decision or subsequent document.

---

## CURRENT-STATE-AUDIT.md

Records verified observations of the existing implementation.

This document should distinguish carefully between:

- verified code behaviour;
- documented intentions;
- assumptions;
- unresolved questions.

---

## PROPOSAL.md

Describes the preferred architectural direction after the current system has been understood.

---

## IMPLEMENTATION-PLAN.md

Defines the agreed implementation strategy.

This document should remain focused on execution rather than architectural debate.

---

## COMPLETION-REPORT.md

Summarizes:

- what was implemented;
- what remains outstanding;
- validation results;
- remaining risks;
- follow-up work.

---

# Workstream Philosophy

Think of every workstream as an engineering laboratory notebook.

```
Question

↓

Investigation

↓

Observations

↓

Proposal

↓

Implementation

↓

Validation

↓

Conclusion
```

The notebook records the complete reasoning process.

---

# Historical Preservation

Nothing should be deleted from a completed workstream.

If an architectural proposal is abandoned:

do not remove it.

If a conclusion changes:

record the superseding decision.

If an audit later proves incomplete:

document the correction.

The workstream records the evolution of understanding.

---

# Relationship To Canonical Documentation

Workstreams are **not** the permanent home of architecture.

Instead they exist to investigate, validate and mature architectural decisions.

Once a workstream has completed successfully:

- update the canonical documentation in its owning sequence;
- ensure implementation matches the promoted documentation;
- leave the workstream intact as the historical record explaining how the decision was reached.

The canonical documentation explains:

> **What is true today.**

The workstream explains:

> **How we discovered it.**

Both are valuable.

They serve different purposes.
