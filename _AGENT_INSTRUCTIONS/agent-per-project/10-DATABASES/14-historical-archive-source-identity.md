---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: architecture
links:
  - ../45-NEW-FEATURE-ADDITION/26-PRODUCTION-ARCHIVE-RECOVERY/responses/43-HISTORICAL-ARCHIVE-CANONICAL-SOURCE-IDENTITY-IMPLEMENTATION.md
---

# Historical Archive Source Identity

## Governing Rule

> **Historical archive source identity must always be obtained through
> `HistoricalArchiveSourceIdentity`. Do not construct source keys from paths,
> labels, or metadata ad hoc.**

One semantic fact has one authority. Inspection, source registration,
persisted metadata, imported membership, duplicate detection, selection,
correspondence, removal, and reimport all consume the same typed identity.

## Mac Messages Identity

A Mac Messages historical archive is currently identified by:

```text
historical_messages_archive source kind
    +
normalized absolute path to chat.db
```

Its stable serialized form is:

```text
historical-messages-archive:<normalized-absolute-chat.db-path>
```

`HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(...)` is the sole
construction rule. `fromPersistedValue(...)` validates and restores that same
representation.

The current rule:

- trims the supplied path;
- makes it absolute;
- normalizes `.` and `..` path components;
- does not require the file or enclosing folder to exist;
- does not call `realpath` or resolve symlinks;
- does not fold case;
- does not hash database contents; and
- does not use a display label, basename, or abbreviated path.

The path and volume location therefore remain part of identity. Moving or
copying the same bytes to a different canonical path produces a different
identity. This is intentional preservation of the existing policy, not a
content-identity decision.

## Online And Offline Use

Freshly inspected readable sources receive identity from the canonical
authority before duplicate lookup or registration. Registration persists the
supplied identity; it does not derive another one.

New Historical Archives overlay records persist the canonical serialized key.
Startup and other offline reads validate and consume that key without touching
the source filesystem. This allows an imported archive to remain identifiable
while its external volume is disconnected.

Older overlay records may lack the serialized key. The repository contains one
bounded compatibility path that supplies their stored `sourceChatDb` value to
the same canonical authority. It must not reproduce normalization or key
construction locally. Once rewritten, the record includes the canonical key.

Malformed persisted keys are not replaced with labels or guessed identities.
They fail through the existing repository/provider diagnostic path.

## Membership And Presentation

Identity alone does not establish **Folders Already Added** membership.
Membership still requires successful metadata plus current positive
source-scoped imported-message truth.

Blue selection and orange correspondence carry the typed identity supplied by
the read model. Widgets do not rebuild it from labels or paths. Presentation
occurrences remain separate process-local facts and are never source identity.

## Removal And Reimport

Removal consumes the selected source's persisted typed identity. Identifying
the source-scoped rows to remove does not require the donor folder to be
mounted.

Selecting the same canonical path again after removal deterministically
produces the same identity. A moved or copied archive at another path remains a
different identity under the current policy.

## Future Source Kinds

The identity type owns a source-kind discriminator, but only Mac Messages is
implemented. A future MessageLens-folder source must define its own evidence
and canonical rule before adding another identity kind. It must not reuse or
silently alter the Mac Messages path rule.
