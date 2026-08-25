---
tier: project
scope: onboarding-start-fresh
owner: agent-per-project
last_reviewed: 2026-08-25
source_of_truth: implementation-record
---

# Installation State And Preservation-Safe Start Fresh

## Result

MessageLens now classifies an admitted installation from durable database,
schema, integrity, topology, source-registry, and operation-snapshot evidence
before deciding whether startup may proceed.

The typed states are:

| State | Meaning | Startup action |
| --- | --- | --- |
| `virgin` | No consequential derived installation exists | Begin ordinary Onboarding |
| `resumable` | Typed operation evidence permits idempotent continuation | Continue, or explicitly Start Fresh |
| `completed` | Import and graph stores are populated and reconcile with graph topology | Open normally |
| `abandoned` | Derived artifacts exist without a modern resumable operation | Offer Start Fresh |
| `remediationRequired` | Preservation evidence, schema, integrity, historical-source, or completion facts conflict | Fail closed; export logs and quit |

The operation snapshot is evidence, not the classifier. A healthy import and
graph reconciliation outranks a stale interrupted snapshot. Conversely, a
snapshot that says `completed` cannot override missing or contradictory
durable stores.

## Completion And Resumability

Completion requires both active derived databases to be readable, pass
`quick_check`, use a supported schema, contain the required tables, contain a
positive equal message count, and expose non-empty Conversation Graph chat and
chat-message topology.

Resumability is deliberately narrower than partial-file detection. The current
snapshot must be `running`, `interrupted`, or a typed failed operation whose
recovery disposition is `retryFromSafeBoundary`; every existing database must
also remain readable, structurally valid, and supported. Existing imported
Historical Archive sources prevent ordinary Start Fresh and require
remediation review.

## Artifact Ownership Inventory

| Artifact | Classification | Start Fresh policy |
| --- | --- | --- |
| `macos_import_ss.db` and sidecars | Rebuildable derived state | Discard |
| `working_ss.db` and sidecars | Rebuildable derived state | Discard |
| retired `macos_import.db` / `working.db` and sidecars | Rebuildable cleanup state | Discard |
| `user_overlays.db` and sidecars | User-authored intent and durable workflow metadata | Preserve; reset only Onboarding operation/failure keys |
| `presence.db` and sidecars | Durable interaction/operation history | Preserve; append a new latest Onboarding run |
| `attachment_archive/` | Preservation payload data | Preserve without traversal or mutation |
| `derived_media/` | App-owned derived media outside the proven reset allow-list | Preserve |
| `application_logs/` | Diagnostics | Preserve |
| archive marker | Archive identity/admission | Preserve |
| process instance lock | Archive identity/process coordination | Preserve |
| preferences stored through overlay-backed stores | User-authored configuration | Preserve |
| Apple Messages, Contacts, Historical Archive folders, recovery donors | External source | Never a target |

`AppDatabaseFile` is exhaustively mapped to this policy. Adding a canonical
database enum value therefore forces a new Start Fresh decision at compile
time. The filesystem reset accepts validated database base names only, ignores
symlinks, and performs no recursive deletion.

## Reset Instead Of Archive Rotation

Archive rotation was evaluated and rejected for this slice. Archive admission
establishes one canonical root for the process, and no atomic active-root
switching mechanism currently exists. Introducing one merely for Start Fresh
would materially broaden archive identity and crash-recovery architecture.

The safer current model is an in-place reset of only the four proven
rebuildable database base files. This retains attachment payloads, overlays,
Presence history, logs, identity, and user preferences in the admitted archive.

## Authorized Workflow

```text
typed abandoned/resumable state
  -> explicit Start Fresh choice
  -> explicit preservation and deletion explanation
  -> ArchiveMutationCoordinator(startFresh)
  -> reset typed Onboarding operation/failure evidence
  -> append a new latest Onboarding Presence run when the definition exists
  -> close import and graph database providers
  -> delete only canonical rebuildable database base files and sidecars
  -> invalidate derived providers
  -> reread durable installation evidence
  -> require typed virgin state
  -> enter ordinary Onboarding
```

`startFresh` blocks database reopen and cannot overlap an unrelated import,
graph build, Historical Archives mutation, attachment recovery, or other
archive mutation. It does not require a production checkpoint because it
cannot reach preservation or user-authored stores; its scope is mechanically
smaller than broad destructive maintenance.

## Interruption And Retry

The sequence clears replaceable operation intent before idempotent derived-file
deletion. Prior Presence runs remain append-only evidence. A retry may append a
new latest run, but it does not rewrite or erase earlier runs. Named file
deletion is idempotent, and startup classification resolves the resulting
durable state:

- intact completed stores still classify completed;
- coherent retryable operation evidence classifies resumable;
- partial derived state without resumable authority classifies abandoned;
- contradictory or unreadable preservation evidence classifies remediation.

Success is never inferred from navigation. The service rereads the admitted
archive and requires `virgin` before releasing the user into Onboarding.

## Startup Surface

The option-launch **Delete MessageLens App Data** no-op was removed. The same
classifier now drives both ordinary startup interception and option-launch:

- completed installations are not offered Start Fresh;
- abandoned installations are intercepted naturally;
- resumable installations can continue or Start Fresh;
- remediation-required installations cannot continue or Start Fresh
  automatically.

The confirmation explicitly states that Apple Messages and Contacts,
Historical Archive sources, recovery donors, archived attachments, MessageLens
customizations, diagnostics, and archive identity are preserved.

## Local Validation Boundary

Automated coverage uses only temporary test archives. No Start Fresh mutation
was run against production or the current development archive in this slice.
Local manual validation should use a disposable admitted development archive
representing virgin, resumable, abandoned, and completed states before this is
offered to external testers.

The completed production-shaped Onboarding run recorded in Response 08 remains
the completion baseline. It was not reset or used as a Start Fresh target.

## Tester Migration Flow

Once disposable-archive manual validation is authorized and complete, the
intended tester experience is:

```text
launch updated MessageLens
  -> classify admitted installation
  -> incomplete modern operation: offer Continue or Start Fresh
  -> abandoned legacy installation: explain and offer Start Fresh
  -> explicit preservation/deletion confirmation
  -> verified reset of rebuildable derived stores
  -> ordinary modern Onboarding
```

No external tester should use this path until that manual validation is
recorded. Healthy completed installations continue directly into MessageLens
and do not expose Start Fresh during ordinary launch.

## Verification

- 73 focused installation-state, Start Fresh, startup, Presence, lifecycle,
  and mutation-coordination tests passed before the final source-boundary
  strengthening.
- The artifact-policy and filesystem reset tests then passed with a new
  SHA-256 fingerprint proof covering external `chat.db`, AddressBook, and
  Historical Archive donor samples.
- All 382 architecture tripwires passed. The reviewed inventories now name the
  classifier's read-only archive evidence boundary, the Start Fresh mutation
  action boundary, and the exhaustive physical-artifact policy.
- The complete Flutter suite passed: 2,060 tests.
- `flutter analyze` reported no issues.
- `flutter build macos --debug` produced
  `build/macos/Build/Products/Debug/MessageLens Development.app`.
- `dart format` and `git diff --check` passed.

No production archive, current development archive, Apple source database,
Historical Archive folder, recovery donor, or attachment payload was mutated
by verification.
