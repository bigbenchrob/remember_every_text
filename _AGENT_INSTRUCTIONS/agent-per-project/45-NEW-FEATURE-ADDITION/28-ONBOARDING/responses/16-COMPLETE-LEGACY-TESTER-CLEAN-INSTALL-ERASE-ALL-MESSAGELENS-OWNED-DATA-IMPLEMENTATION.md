---
tier: project
scope: feature-28-complete-installation-erase
owner: agent-per-project
last_reviewed: 2026-08-27
source_of_truth: code-and-tests
links:
  - ../prompts/16-COMPLETE-LEGACY-TESTER-CLEAN-INSTALL-ERASE-ALL-MESSAGELENS-OWNED-DATA.MD
  - ../../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../../50-ENVIRONMENT-SAFETY/00-overview.md
tests:
  - test/essentials/archive_environment/infrastructure/file_system_complete_installation_erase_store_test.dart
  - test/essentials/onboarding/application/complete_installation_erase_service_test.dart
  - test/essentials/onboarding/application/complete_installation_erase_virgin_verifier_test.dart
  - test/essentials/onboarding/presentation/complete_installation_erase_authorization_dialog_test.dart
  - test/essentials/onboarding/presentation/complete_installation_erase_operation_surface_test.dart
  - test/architecture/complete_installation_erase_boundary_test.dart
---

# Complete Legacy-Tester Installation Erasure

## Result

MessageLens now has a distinct destructive operation named **Erase MessageLens
Setup and Start Over**. It is intended for obsolete early-tester installations,
legacy incomplete installations, bounded support recovery, and a completed user
who deliberately chooses the advanced action.

It is not ordinary **Start Fresh**:

| Operation | Deletes | Preserves |
| --- | --- | --- |
| Start Fresh | Enumerated rebuildable import and graph stores | Archive identity, overlays, preferences, Presence/history, logs, and `attachment_archive/` |
| Erase MessageLens Setup and Start Over | Every artifact inside the admitted canonical MessageLens archive root | Every external Apple/source/donor artifact outside that root |

The implementations and exact mutation capabilities remain separate.

## MessageLens-Owned Inventory

The admitted archive root is exclusively MessageLens-owned. Complete erasure
therefore removes current and legacy contents without opening or migrating
them, including:

- source-scoped and retired import databases and SQLite sidecars;
- current and retired Conversation Graph databases and sidecars;
- overlay data, source registry, labels, favourites, notes, and customizations;
- Presence definitions, history, operation snapshots, and Onboarding state;
- the managed `attachment_archive/` and attachment metadata;
- derived media, indexes, projections, caches, and staging artifacts;
- application logs, diagnostics, incident evidence, and legacy log folders;
- current and obsolete archive markers and environment identity;
- unknown legacy files located inside the admitted MessageLens-owned root.

Current preferences are archive-backed. The audit found no active
`SharedPreferences` or `UserDefaults` store under `lib/`. Exported support
bundles outside the archive root and operating-system unified logs are not
owned erase targets.

Historical application identities such as `com.example.rememberEveryText` and
the earlier `rob_index` lineage were recorded during the audit. Their sibling
Application Support directories are not inferred to belong to the currently
admitted installation and are not deleted. A future cross-root cleanup would
require its own ownership admission.

## External Boundary

The operation cannot target a chosen folder. It accepts only the canonical root
carried by `ArchiveAccessAuthority`. It never enumerates or deletes:

- Apple Messages `chat.db`, sidecars, or attachment payloads;
- Apple Contacts databases or files;
- iCloud or other system data;
- Historical Archives source folders;
- MessageLens recovery donor folders;
- user-selected folders or files outside the admitted root.

The filesystem boundary rejects `/`, `/Volumes`, the home directory, a
non-canonical target, a symlinked root, descendant symlinks, nested `chat.db`,
and a nested archive marker. Recursive deletion never follows links.
Development-root overrides retain the same rule: only the exact canonical
`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is admitted, never its parent volume.

## Authority And Lifecycle

`ArchiveMutationOperation.completeInstallationErase` is the sole capability
for full installation erasure. An erase-only startup authority admits no
ordinary persistent database access and no other mutation. During the admitted
operation, unrelated and owner-scoped persistent store reopening is forbidden.

The operation:

1. takes visible presentation ownership and paints before filesystem work;
2. obtains the exact archive mutation capability;
3. stops the live Messages monitor;
4. closes only already-open archive resources in reverse registration order;
5. invalidates persistent database and logger providers;
6. writes a durable erase transaction token;
7. safely erases the admitted archive contents, including preservation data;
8. installs a fresh format-v1 marker with a new archive instance identity;
9. proves `virgin` through the canonical installation classifier;
10. clears the transaction token and relaunches the same application identity;
11. enters the six-node Onboarding Journey at Messages.

The resource registry deliberately does not resolve unopened legacy stores.
This avoids schema migration of data that the human has authorized for
destruction.

## Interruption And Recovery

The durable transaction token is created before destructive work. A crash
after partial erasure, after complete erasure, or after fresh marker creation
causes startup to resume the same exact operation. Recovery repeats safe
erasure, reinstalls the transaction's new identity, verifies canonical virgin
state, and clears the token only after proof succeeds.

No deleted MessageLens state is reconstructed. Failure remains a typed visible
outcome with safe retry semantics. External source safety does not depend on
successful completion because those paths are outside the admitted root.

## Product Boundary

Healthy completed installations expose the action only in the advanced Reset
Message Data surface and require the explicit **Erase and Start Over**
confirmation. Legacy/abandoned startup can offer it without first opening or
migrating obsolete databases. Ordinary Start Fresh remains the recommended
preservation-safe reset.

One clear confirmation is sufficient because it names both the permanently
deleted MessageLens data and the untouched Apple/source data. There is no
second confirmation step.

## Validation Status

Automated fixtures cover current and legacy database files, overlay and
Presence data, the attachment archive, logs, unknown root artifacts, marker
replacement, symlink and protected-root rejection, deterministic interruption
recovery, resource shutdown order, exact mutation admission, immediate
presentation ownership, typed failure, and ordinary Start Fresh separation.

Manual disposable-root validation remains required before early-tester rollout.
Do not send tester instructions until that local validation has completed.

## Future Tester Flow

After local staging validation, the intended no-Terminal flow is:

1. Install and launch the new MessageLens build.
2. On a detected legacy/incomplete installation, choose **Erase MessageLens
   Setup and Start Over**.
3. Read the destructive disclosure and choose **Erase and Start Over**.
4. MessageLens verifies a clean installation and relaunches automatically.
5. Continue through Messages, History, Contacts, Ready, Import, and Start.

The exact same action remains available to a healthy installation only through
advanced Settings; it is never an automatic recovery choice.
