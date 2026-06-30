---
tier: project
scope: workflow
owner: agent-per-project
last_reviewed: 2026-06-06
source_of_truth: doc
links:
  - ../../agent-instructions-shared/INDEX.md
  - ../40-FEATURES/README.md
tests: []
---

# New Feature Addition Workflow

This folder tracks feature work that is still in planning or active development. Follow this workflow whenever the user asks for a new capability that is not yet represented in `40-FEATURES/`.

## Lifecycle Overview

1. **Kickoff** – Create a feature subfolder named `45-NEW-FEATURE-ADDITION/{feature-name}/`.
2. **Proposal** – Draft `PROPOSAL.md` summarizing goals, constraints, and open questions. Wait for user sign-off before planning.
3. **Planning** – Add `CHECKLIST.md`, `DESIGN_NOTES.md`, and `TESTS.md`. Flesh out the detailed checklist covering delivery, review, and verification steps.
4. **Execution** – Implement code while updating the checklist. Keep design notes in sync with any architectural decisions.
5. **Verification** – Ensure planned tests are written and passing. Capture any manual validation in `TESTS.md`.
6. **Completion** – Write `STATUS.md` and move the feature documentation into `40-FEATURES/{feature-name}/` once work ships, unless the folder is intentionally retained here as a historical planning record.

## Feature Folder Template

Each feature folder inside this directory should contain:
```
{feature-name}/
├── PROPOSAL.md
├── CHECKLIST.md
├── DESIGN_NOTES.md
├── TESTS.md
└── STATUS.md        # Added when feature is complete
```

Templates live under `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/`. Copy the feature brief template or create the proposal/checklist/test documents directly when creating a new feature so structure stays consistent.

## Working Agreement

- Do not start implementation until the proposal is approved.
- Keep `CHECKLIST.md` current; treat it as the single source of truth for progress.
- Move artifacts into `40-FEATURES/` once the feature is delivered when the feature has become stable, durable product guidance.
- Some older folders remain here as historical planning records. Do not treat a folder in this directory as active implementation guidance unless it is listed in the current-feature table below, linked from the current roadmap/checklist, or explicitly requested by the user.
- Archive or rename feature folders that the user cancels, documenting the reason in `STATUS.md`.

## Reference Material

- Workflow guide: `AGENTS.md`
- Feature brief template: `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/TEMPLATE-feature-brief.md`

## Current Feature Folders

The table below is the current active/planning set. Other folders in this directory may be useful history, but they are not active marching orders by default.

| Feature | Key Docs |
| --- | --- |
| `archive-canonical-attachments/` | [`PROPOSAL.md`](archive-canonical-attachments/PROPOSAL.md), [`CHECKLIST.md`](archive-canonical-attachments/CHECKLIST.md), [`DESIGN_NOTES.md`](archive-canonical-attachments/DESIGN_NOTES.md), [`TESTS.md`](archive-canonical-attachments/TESTS.md) |
| `ephemeral-sidebar-projection/` | [`PROPOSAL.md`](ephemeral-sidebar-projection/PROPOSAL.md), [`CHECKLIST.md`](ephemeral-sidebar-projection/CHECKLIST.md), [`DESIGN_NOTES.md`](ephemeral-sidebar-projection/DESIGN_NOTES.md), [`TESTS.md`](ephemeral-sidebar-projection/TESTS.md) |
