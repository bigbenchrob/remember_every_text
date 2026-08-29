---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-29
source_of_truth: implementation-record
---

# Legacy Tester Data Deletion Authorization And Onboarding Handoff

## Problem

Three early testers may still have the exact April-era, pre-source-scoped
MessageLens installation identified in Response 19. That obsolete
MessageLens-owned data is disposable, but an unmarked folder is not sufficient
proof that deletion is appropriate.

This slice adds one compatibility path for that proven cohort. It does not add
migration, general destructive data management, or a new Complete Erase product
surface.

## Recognized Cohort

The gate remains available only after read-only startup inspection proves all
of the existing fingerprint requirements:

- `macos_import.db` schema 4 with its complete expected table set;
- `working.db` schema 3 with its complete expected table set;
- `user_overlays.db` schema 3 with its complete expected table set;
- no current archive marker or current source-scoped, graph, or Presence store;
- canonical signed production application identity and root.

Every other unmarked, current, damaged, development, or unknown shape continues
to fail closed. Recognition does not open or migrate any database.

## User-Facing Copy

Title:

> This is data from an older MessageLens test version

Explanation:

> This version of MessageLens needs to start with a clean setup. I can remove
> the old MessageLens data on this Mac and start again.

Safety statement:

> Your Apple Messages and Contacts will not be changed.

Actions:

- **Cancel**
- **Delete Old Data and Continue**

Cancel changes only process-local presentation state. It creates, opens,
migrates, and deletes nothing; MessageLens remains blocked and offers Quit.

## Authorization And Mutation Authority

Deletion requires both facts:

1. startup admitted `ArchiveAccessMode.legacyTesterInstallDetected` from the
   exact positive fingerprint;
2. the human pressed **Delete Old Data and Continue** in that same current
   occurrence.

The action publishes its operation surface and waits for an end-of-frame
boundary before filesystem work. It then revalidates the immutable root,
environment, application identity, archive identity, and restricted access
mode. A stale occurrence or changed authority cannot execute or retry.

`ArchiveMutationOperation.legacyTesterInstallDeletion` is admitted only under
the restricted legacy authority. Full, erase-only, and unrelated operations
cannot request it. While active it blocks persistent database reopen, and the
service refuses to proceed if any archive-owned persistent resource has already
opened.

## Deletion Scope And External Boundary

The operation enumerates only descendants of the already admitted canonical
MessageLens root. It removes all obsolete MessageLens-owned contents there,
including the three legacy databases, old overlays, optional legacy attachment
archive, derived media, logs, and unknown legacy files.

The filesystem boundary rejects dangerous roots, root symlinks, descendant
symlinks, and any embedded `chat.db`. Apple Messages and Contacts data,
Historical Archive sources, recovery donors, and every sibling or external
path are unreachable by construction. The exact fixture test keeps
representative external source files byte-identical.

## Crash Convergence, Virgin Proof, And Handoff

The compatibility service reuses the existing low-level durable archive-root
replacement transaction. That is implementation infrastructure, not the
generalized Complete Erase product feature. A new archive identity is recorded
before erasure begins; startup detects an interrupted transaction before normal
admission and converges it to the same marker-only virgin state. Partial
deletion therefore cannot become a completed installation.

After installing the new marker, the canonical installation classifier must
report `virgin`. Only then is the transaction completed and MessageLens
automatically relaunched. A relaunch is necessary because archive authority is
immutable for one process. The fresh process receives normal current archive
admission, and `OnboardingJourneyCoordinator` becomes the sole owner of the
ordinary six-node Journey:

`Messages → History → Contacts → Ready → Import → Start`

No manual quit or database migration is part of the successful path.

## Failure And Retry

Deletion, mutation-admission, and virgin-verification failures remain on a
typed, visible compatibility surface. Retry is offered only while the original
legacy authority is still current. Failure never enters ordinary Onboarding and
never claims a clean installation.

## Generalized Complete Erase Rollout Decision

Settings no longer offers **Erase MessageLens setup and start over…**. It keeps
only the preservation-safe **Reset message data…** / Start Fresh workflow. The
low-level archive-replacement code remains internal for transaction convergence
and this exact compatibility operation.

## Verification Evidence

Focused coverage proves:

- exact fingerprint recognition and rejection of neighboring shapes;
- compatibility-gate copy and explicit authorization;
- Cancel performs zero mutation;
- operation presentation paints before deletion;
- stale authority and stale occurrences cannot execute;
- only the legacy authority admits the exact mutation capability;
- an exact fixture loses all owned legacy artifacts while external source
  fixtures remain byte-identical;
- a new production marker is installed and the canonical classifier reports
  `virgin`;
- interruption retains a durable transaction and no completed identity;
- typed failure remains visible and retry remains authority-bound;
- current database providers and migration code are absent from the deletion
  path;
- ordinary Start Fresh and the current Onboarding Journey remain unchanged.

## Tester Rollout

For each of the three testers:

1. install and launch the current MessageLens build;
2. read the older-test-version explanation;
3. choose **Delete Old Data and Continue**;
4. wait for MessageLens to relaunch automatically;
5. complete the normal Onboarding Journey.

No Finder navigation, Terminal command, Settings reset, or database upgrade is
required.
