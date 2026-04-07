---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-04-05
source_of_truth: doc
links:
  - ../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
  - ../../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../../10-DATABASES/05-db-overlay.md
  - ../../10-DATABASES/INVIOLATE_RULES.md
  - ../app-breakdown-refactor/live-vs-archive-message-src-redefinition.txt
  - ./CHECKLIST.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
feature: archive-canonical-attachments
status: proposed
created: 2026-04-05
---

# Feature Proposal - Archive-Canonical Attachments

**Proposed Branch**: `Ftr.img-archive`
**Status**: Proposed
**Created**: 2026-04-05

---

## Overview

Redefine attachment sourcing so MessageLens has two explicit modes instead of the current mixed live-first behavior.

- Archive disabled: render attachment files directly from `~/Library/Messages/Attachments`
- Archive enabled: render attachment files from the MessageLens archive only

In archive-enabled mode, Apple's attachment cache remains an ingestion source, but it is no longer a peer display source.

This feature is a separate planning track because it changes product semantics, import timing expectations, attachment availability states, and the contract between the archive subsystem and message hydration.

## User Value

### Problem

The current system mixes two different ideas:

- the archive is described as the durable authoritative local copy
- runtime rendering still prefers the live Messages path first and falls back to the archive later

That split-brain behavior creates three problems:

1. scroll-time rendering can depend on Apple's volatile cache instead of app-controlled storage
2. attachment source-selection logic is duplicated across resolver and hydration layers
3. product behavior is hard to explain when a file is present live but not yet archived

### Proposed User-Facing Outcome

When archive mode is enabled, the user should experience MessageLens as a durable attachment system:

- message rows can appear immediately when new messages arrive
- attachments may temporarily show a pending state such as "attachment being added..."
- attachments that are currently unavailable can later become available if the underlying file is restored from iCloud and MessageLens later detects and archives it in background
- once archived, the attachment renders from the MessageLens archive and stays available regardless of Apple cache eviction

### Benefits

- stable display semantics in archive-enabled mode
- simpler product story: MessageLens keeps its own durable copy
- no scroll-time fallback ambiguity between live cache and archive
- attachment unavailability becomes explicit instead of implicit

---

## Existing Architecture Summary

- `chat.db` changes are auto-imported on a polling cycle by `ChatDbChangeMonitor`
- import and migration rebuild working data before the UI surfaces newly available messages
- attachment archive metadata lives in the overlay DB, which is correct because archiving is app-owned state rather than source-db truth
- the current archive document frames the archive as authoritative, but the current resolver/hydration flow still checks the live Messages path first
- attachment resolution responsibility is currently split across:
  - attachment resolver providers
  - message hydration loaders
  - attachment helper models that pick the "best available" file

## Assumptions

1. Users do not require zero-latency attachment availability for newly arrived messages.
2. A temporary pending state for newly seen attachments is acceptable and may even be positively perceived.
3. The app must continue rendering the message record even when its attachment is pending or unavailable.
4. Archive-enabled mode should favor semantic clarity over immediate use of any live file discovered at render time.
5. A file that is unavailable now may become available later if Apple re-downloads it into the Messages Attachments folder.
6. Eventual archival matters more than immediate recovery latency for restored attachments.

## Hard Invariants

1. Do not suppress message rows because an attachment is pending, missing, or failed.
2. Do not write archive metadata into working DB tables.
3. Do not bypass centralized DB providers.
4. Do not let archive-enabled mode silently fall back to live-file rendering after the new contract is adopted.
5. Do not remove live-only behavior when archive mode is disabled.

---

## Scope

### In Scope

1. Define a single source-policy boundary for attachment display.
2. Replace live-first rendering in archive-enabled mode with explicit archive-only display states.
3. Introduce a pending archive state for newly arrived attachments.
4. Align background archive ingestion with the auto-sync pipeline.
5. Remove duplicated attachment source-selection rules from hydration helpers.
6. Add a recovery mechanism for attachments that reappear later in the live Messages folder.
7. Apply the same source-policy flow to all attachment types.
8. Update docs and tests to reflect the new contract.

### Out Of Scope

- Full redesign of attachment UI chrome
- Real-time filesystem watching
- Large import/migration architecture changes unrelated to attachment sourcing

---

## Proposed Direction

### Product Contract

#### Mode 1 - Archive Disabled

- Render directly from the live Messages attachment path
- If no live file exists, show cloud-only or unavailable state
- Do not consult archive for display

#### Mode 2 - Archive Enabled

- Render from archive only
- If archive file is not yet available, show a pending archive state
- Use the live Messages path only to ingest missing archive entries
- Once archive ingestion completes, update the attachment state to archived/displayable
- If a currently unavailable attachment later reappears in the live Messages folder, detect that reappearance during background recovery work and archive it so the UI can transition to available

### State Model

In archive-enabled mode, every attachment should resolve into one of a small number of explicit states:

- `pendingArchive`
- `available`
- `unavailableAwaitingRecovery`
- `nonRecoverable` only when the app has high-confidence evidence that recovery is not possible

The key shift is that "live file exists" stops being a display answer in archive-enabled mode. It becomes an ingestion opportunity.

For v1, archive-copy failures should not become a separate durable user-facing state. They should normally collapse into `unavailableAwaitingRecovery` while background retries continue.

### Pipeline Direction

The auto-sync/import pipeline should be treated as the primary place where newly available attachments get archived. However, archive-enabled mode may still opportunistically ingest a live file when a message row is hydrated and the archive entry is absent.

That gives the feature two compatible guarantees:

- background sync does most of the work before the user notices
- the UI still behaves honestly if an attachment arrives before the archive catches up

The same principle should also handle delayed iCloud restoration:

- an unavailable or cloud-only attachment may later become locally available again
- MessageLens should notice that transition during sync and on user-prioritized recovery flows
- once the file reappears, the app should archive it and move the attachment back to available

### Recommended Recovery Strategy

Recovery for restored iCloud files should be **background and eventual**, not synchronous in the UI path.

- normal unresolved attachments should be retried automatically on the normal sync cadence while they are recent
- older unresolved attachments should move to a slower backoff cadence
- clicking an unavailable placeholder should mark the attachment as user-interesting and raise its retry priority, but should not force immediate rendering-time recovery

This keeps the archive-enabled display contract clean while still ensuring the attachment eventually enters the archive.

### Internal Recovery Metadata

Even though the user-facing state model should stay small, the app should track richer internal recovery metadata for scheduling and diagnostics.

Candidate fields:

- `lastRecoveryAttemptAt`
- `nextRecoveryAttemptAt`
- `recoveryAttemptCount`
- `recoveryPriority`
- `userInterestRaisedAt` or equivalent flag/timestamp
- `lastRecoveryErrorSummary`
- `isNonRecoverable`

This keeps UX simple while still supporting good retry decisions and debugging.

---

## Architecture Impact

### Areas Likely To Change

| Area | Planned Change |
| --- | --- |
| Archive settings / policy | make the display policy explicit in code, even if the user-facing setting remains a boolean |
| Archive service | support deterministic pending -> archived transitions for newly discovered attachments and later recovery when a live file reappears |
| Attachment resolver | become the single display-source policy boundary |
| Message hydration | stop doing independent live-first file selection |
| Attachment view models | carry explicit pending/unavailable/recovery states |
| Presentation | render pending and unavailable recovery states without hiding the attachment record |
| Docs | replace the old live-first archive description in canonical docs after implementation |

### Candidate Files For Future Implementation

- `lib/features/attachments/application/attachment_archive_service_provider.dart`
- `lib/features/attachments/application/attachment_resolver_provider.dart`
- `lib/features/attachments/application/archive_settings_provider.dart`
- `lib/features/messages/presentation/view_model/shared/hydration/attachment_info_loader.dart`
- `lib/features/messages/presentation/view_model/shared/hydration/attachment_info.dart`
- `lib/features/messages/presentation/view_model/shared/message_row_mapper.dart`
- attachment presentation widgets that currently assume a file path exists immediately

---

## Risks

1. **State explosion**
   Pending, archived, cloud-only, and failure states can leak across layers if not normalized in one resolver boundary.

2. **Partial contract migration**
   If live-first logic remains in hydration helpers after resolver changes, the app will still behave inconsistently.

3. **Background timing assumptions**
   The auto-sync cycle may not always archive before the user scrolls to a new row, so the pending state must be first-class rather than treated as an edge case.

4. **Recovery ambiguity**
   Some attachments that appear unavailable may later be restored by Apple, so the plan must distinguish durable absence from retriable absence.

5. **Doc drift during transition**
   The current canonical archive doc still encodes the old live-first rule and must not remain the long-term source of truth once implementation starts.

---

## Proposed Delivery Shape

1. Planning docs in this folder define the product contract, phased checklist, and test strategy.
2. Implementation should begin only after the user signs off on the explicit state model and rollout order.
3. Canonical archive documentation under `25-ONBOARDING-AND-ARCHIVE/` should be updated only when the code has actually moved to the new policy.

## Open Questions

1. What exact evidence should promote an attachment from `unavailableAwaitingRecovery` to `nonRecoverable`?
2. What retry schedule should be used for unresolved attachments after they age out of the normal sync cadence?
3. Should the archive-enabled display policy remain driven by the current boolean setting, or should the code introduce an explicit internal enum for source policy even if the UI remains binary?
