---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: implementation-record
links:
  - ../prompts/42-RESONSE-TO-AUDIT-03.md
  - ./40-HISTORICAL-ARCHIVES-ARCHITECTURE-CONFORMANCE-AUDIT.md
  - ./41-HISTORICAL-ARCHIVES-TYPED-PRESENTATION-STATE-IMPLEMENTATION.md
  - ./42-HISTORICAL-ARCHIVES-STABLE-CENTER-TRACK-SKELETON-IMPLEMENTATION.md
  - ../../../10-DATABASES/14-historical-archive-source-identity.md
---

# Historical Archive Canonical Source Identity Implementation

## Result

D3 is resolved. Historical Archives now has one typed, offline-capable answer
to “which source is this?” across inspection, registration, persistence,
membership, duplicate detection, selection, correspondence, removal, and
reimport.

No database schema, source provenance, source data, timestamp conversion,
Track geometry, archive mutation behavior, or user workflow changed.

## Previous Split

Two compatible authority paths previously reconstructed the same semantic
fact:

1. The online folder resolver normalized the selected folder, formed its
   `chat.db` path, and asked `HistoricalMessagesArchiveSourceRegistrar` to
   prefix that path into a source key.
2. The offline metadata repository independently normalized the persisted
   `sourceChatDb` path and called the registrar's static key builder.

Duplicate detection also offered folder-path and raw-key lookup methods, while
removal resolved the original folder again merely to recover the key. The two
algorithms happened to agree, but no type made that agreement necessary.

## Canonical Semantics

`HistoricalArchiveSourceIdentity` now owns the complete rule. Mac Messages
archive identity is:

```text
source kind: historical_messages_archive
canonical source path: normalized absolute path to chat.db
serialized value: historical-messages-archive:<canonical source path>
```

Normalization trims input, makes it absolute, and normalizes path components.
It does not require filesystem access, resolve symlinks, fold case, inspect
volume identity beyond the path, or hash contents. A moved copy at another path
therefore remains a different source under the existing policy.

Display labels, folder basenames, abbreviated paths, and cartouche text are not
identity.

## Final Authority And Flow

The authority exposes:

- `macMessagesFromChatDbPath(...)` for canonical construction from typed path
  evidence; and
- `fromPersistedValue(...)` for validation and offline restoration.

Fresh readable inspection attaches the typed identity to its evidence. The
preflight path requires that identity and cannot silently construct a second
one. The filesystem folder resolver uses the same authority for the import
boundary. The registrar receives the resolver's identity and only serializes
it into the import ledger.

Duplicate lookup, current imported membership, source verification, sidebar
selection, orange correspondence, and source management compare typed value
objects. Widgets receive identity from their payload and never derive it from
presentation text.

Removal now accepts persisted `HistoricalArchiveSourceIdentity` directly. It
does not resolve or require the historical folder before deleting that
source's derived facts. Re-selecting the same canonical path after removal
produces the same identity deterministically.

## Persisted And Offline Metadata

New overlay metadata records store the canonical serialized `sourceKey` beside
the existing source facts. Reading those records validates the key and requires
no mounted source folder.

No schema migration was needed because Historical Archives metadata is a
versioned overlay JSON value. Older records without `sourceKey` use one bounded
compatibility path: their stored `sourceChatDb` is passed to the canonical
authority. The repository does not duplicate normalization. Malformed stored
keys fail rather than falling back to labels or guessed identity.

## Consumer Audit

The following consumers now use the typed identity:

- source inspection and preflight;
- folder resolution and source registration;
- duplicate already-added detection;
- overlay metadata persistence and offline startup reads;
- import-ledger membership lookup;
- final import verification and success cartouche creation;
- selected-source lookup and source history/details;
- blue selection and orange correspondence targeting;
- removal and removal verification; and
- deterministic reimport of the same canonical path.

Membership semantics remain unchanged: identity plus successful persisted
metadata is insufficient by itself; Folders Already Added still requires a
positive current source-scoped imported-message count.

## Mechanical Protections

Focused tests prove normalized equality, distinct-path inequality, persisted
round trips without filesystem access, malformed-key rejection, same-path
reselection, online/persisted parity, legacy metadata reconstruction,
source-registration reuse, typed duplicate targeting, typed selection and
reference targeting, and removal without donor-folder resolution.

Architecture tripwires require the canonical identity class and both entry
points, prohibit revival of `buildSourceKey`, ensure registration does not
construct identity, ensure removal does not resolve a folder, and ensure the
sidebar does not construct identity from presentation data.

## Preserved Boundaries

- D1 sealed presentation variants remain unchanged.
- D2 Tracks A-I remain unchanged.
- Source-1 protection and source-scoped provenance remain unchanged.
- `DateConverter` remains the only Apple Messages timestamp authority.
- Maintenance and Onboarding behavior remain unchanged.
- D4 generated legacy Drift write APIs remain deferred.
- MessageLens-folder ingestion remains out of scope.

The Mac Messages arm is now structurally suitable as a reference for a future
MessageLens arm in identity ownership as well as mutation admission, typed
state, stable Tracks, source-scoped provenance, and DateConverter use. The
future arm still requires its own explicit source-kind identity rule.

## Verification

- Focused Historical Archives identity, persistence, workflow,
  import/removal, Track, sidebar, and panel suite: 119 passed.
- Complete Settings suite: 138 passed.
- Architecture tripwires and focused Historical Archives architecture tests:
  384 passed.
- Full Flutter suite: 1,848 passed.
- `flutter analyze`: no issues.
- macOS debug build: succeeded.
- `git diff --check`: clean before commit.
