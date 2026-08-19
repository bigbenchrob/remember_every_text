---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-19
source_of_truth: implementation-record
links:
  - ../prompts/30-HISTORICAL-ARCHIVE-REMOVAL-JOURNEY.MD
  - 08-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-IMPLEMENTATION.md
  - 09-HISTORICAL-REMOVAL-ONBOARDING-REDIRECT-AUDIT.md
---

# Historical Archive Removal Journey Implementation

## Execution audit

The production path is:

```text
Remove this folder…
    -> destructive confirmation
    -> HistoricalArchivesWorkflowActions
    -> HistoricalArchivesWorkflow
    -> ArchiveMutationCoordinator(historicalArchiveRemoval)
    -> SourceScopedArchiveGraphRemovalService
    -> delete source-qualified import facts
    -> clear and reproject the graph from all remaining facts
    -> refresh message-data consumers
    -> recheck imported membership by canonical source key
```

`SourceScopedArchiveGraphRemovalService` returns only after its complete
deletion-and-reprojection operation succeeds or fails. It publishes no live
stage observations. The previous UI nevertheless marked deletion and graph
reprojection as simultaneously running. Those inferred stages have been
removed. No new observation seam was added.

The truthful live progress contract is therefore:

```text
removal started
    -> removal finished or failed
```

## Confirmation

The selected-source action opens a modal before any mutation:

```text
Remove this folder from MessageLens?

The messages added from this folder will be removed from MessageLens.
Your original Messages folder will not be changed.

Cancel | Remove Folder
```

Cancel closes the modal, preserves the blue-selected source story, and invokes
no removal action. `Remove Folder` is the canonical destructive action and
invokes the source-scoped removal seam once.

Removal eligibility now requires an explicitly selected imported source in the
current Historical Archives presentation. A merely inspected add-flow folder
cannot expose or invoke removal.

## Running presentation

After confirmation, the transient presentation context becomes
`removingSource`. The center panel retains the established A-E Track geometry
and begins at the cartouche-list seam. It shows:

```text
Removing this folder from MessageLens.

REMOVING MESSAGES FOLDER
Removing messages added from this folder    Working
```

The selected-source story, Remove action, import controls, chooser actions,
and fabricated sub-stages are mechanically absent while the operation runs.

## Durable success

After the service returns, the workflow bumps `messageDataVersion` and asks
the existing imported-source lookup whether the canonical source key still has
positive imported message membership.

When membership is absent:

- the known-folder provider omits the cartouche;
- the transient selection and removal context are reset;
- Historical Archives returns automatically to `hub`;
- the center panel becomes empty; and
- no completion, Next, Done, or Return action is required.

Canonical source metadata is not deleted. A later fresh folder choice may
therefore inspect and import the same source again.

## Failure

If the operation fails and positive imported membership remains, the original
selected-source context is restored and states that MessageLens could not
remove the folder. Technical detail remains under More Details. The source
cartouche remains because sidebar membership continues to derive from durable
positive import truth.

If failure leaves membership indeterminate or absent, a coarse failed-removal
surface remains instead of falsely claiming either a successful hub transition
or continued imported membership. No generic Retry action was introduced.

Completion and failure updates are guarded by presentation-session occurrence
and canonical source key. Late work cannot erase a newer selection or revive an
abandoned Historical Archives presentation.

## Safety invariants

The operation still runs under `historicalArchiveRemoval` mutation authority.
Owner-aware graph admission remains intact, and unrelated graph reopen remains
blocked during maintenance. Onboarding continues to classify this work as
`maintenanceInProgress`, not graph failure.

The removal service receives only the selected folder path as source identity.
It deletes source-qualified rows from MessageLens-owned derived storage and
does not perform source-folder filesystem writes. Focused tests byte-compare
the donor `chat.db` before and after removal, retain the source-registry row,
and prove that a source-1 message survives in both the import ledger and the
reprojected graph.

## Manual staging review

On the disposable development staging archive only:

1. Select an imported folder cartouche.
2. Click **Remove this folder…** and verify Cancel leaves the selection and
   cartouche unchanged.
3. Confirm removal and verify the modal closes before work begins.
4. Verify the center shows one compact **Working** row and no other actions.
5. Verify completion removes the cartouche and returns to the virgin hub with
   an empty center panel.
6. Verify current-Mac messages remain present and the original donor folder,
   `chat.db`, Attachments, and attachment archive remain unchanged.
7. Choose the same donor folder again and verify it is eligible for a fresh Add
   flow rather than remaining a selected existing source.

Do not conduct this review against production data.
