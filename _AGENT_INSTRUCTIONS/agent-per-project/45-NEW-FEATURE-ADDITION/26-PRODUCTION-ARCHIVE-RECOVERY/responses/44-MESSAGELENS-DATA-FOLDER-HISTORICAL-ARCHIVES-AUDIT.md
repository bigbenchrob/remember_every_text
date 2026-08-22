---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: architecture-audit
links:
  - ../prompts/43-RESPONSE-TO-AUDIT-04.md
  - ./40-HISTORICAL-ARCHIVES-ARCHITECTURE-CONFORMANCE-AUDIT.md
  - ./41-HISTORICAL-ARCHIVES-TYPED-PRESENTATION-STATE-IMPLEMENTATION.md
  - ./42-HISTORICAL-ARCHIVES-STABLE-CENTER-TRACK-SKELETON-IMPLEMENTATION.md
  - ./43-HISTORICAL-ARCHIVE-CANONICAL-SOURCE-IDENTITY-IMPLEMENTATION.md
  - ../../../10-DATABASES/00-all-databases-accessed.md
  - ../../../10-DATABASES/07-overlay-database-independence.md
  - ../../../10-DATABASES/14-historical-archive-source-identity.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md
  - ../../../50-ENVIRONMENT-SAFETY/00-overview.md
---

# MessageLens Data-Folder Historical Archives Audit

## Supersession Note

The general archive-ingestion, donor-provenance, source-fact, overlay, and
multi-store merge possibilities below remain historical design evidence, not
the current product contract.

Feature 26 has deliberately narrowed the supported MessageLens-folder use case
to attachment payload recovery from an earlier snapshot of the same continuing
local Mac Messages `chat.db` lineage. Donor messages, graph facts, overlays,
source registries, and B/B1/B2/B3 ancestry will not be imported. See
[MessageLens Attachment-Recovery Lineage Proof](45-MESSAGELENS-ATTACHMENT-RECOVERY-LINEAGE-PROOF.md).

Sections below that describe general source-fact ingestion are superseded for
the current product direction; they have not been erased because they document
why the narrower boundary was chosen.

The narrower read-only arm is now implemented through ready state. It performs
structural archive qualification, archive-instance identity, shared
same-Messages-lineage admission, and exact attachment recovery preflight. It
does not import or merge donor facts. See
[MessageLens Historical Archives Ready-State Implementation](50-ENABLE-MESSAGELENS-HISTORICAL-ARCHIVES-THROUGH-READY-STATE.md).

## Decision

The future MessageLens arm is a legitimate second Historical Archives source
type, but it is not a larger version of the Mac Messages `chat.db` importer.

The shared interaction grammar, typed presentation lifecycle, A-I Track
skeleton, modal boundaries, Narrator, Directed Instrumentation, and stale-work
guards are sound foundations. The source semantics are materially different.
A MessageLens donor is a versioned archive containing multiple stores, multiple
original sources, user overlays, and preservation payloads.

The implemented MessageLens segment remains strictly attachment-recovery-only.
That scope makes donor-qualified fact provenance, arbitrary overlay merge, and
donor graph ingestion inapplicable rather than deferred blockers. Recovery
mutation remains deferred for the narrower reason that the preservation-safe
per-candidate installer does not yet have an aggregate batch executor owning
iteration, interruption, and truthful terminal outcomes.

This audit changes no application behavior, schema, archive, donor, or data.

## 1. MessageLens Data-Folder Anatomy

The archive root is the directory admitted by `ArchiveAccessAuthority`. The
canonical current layout is:

| Component | Current format | Role | Qualification status |
| --- | --- | --- | --- |
| `.messagelens-archive.json` | marker format 1 | Archive identity, environment, creation time | Required for this first source format |
| `macos_import_ss.db` | SQLite schema version 10 | Source-scoped import ledger and durable imported facts | Required for historical-content ingestion |
| `working_ss.db` | Drift schema version 2 | Conversation Graph projection | Optional for ingestion; diagnostic only |
| `user_overlays.db` | Drift schema version 8 | User intent, archive metadata, and attachment records | Optional unless its contents are offered for merge |
| `attachment_archive/` | content-addressed files plus compatibility fallback | Preserved attachment payloads | Optional, but preservation-significant when present |
| `presence.db` | Drift schema version 9 | Presence definitions and execution state | Optional; never historical content |
| `macos_import.db`, `working.db` | retired schemas | Legacy cleanup or diagnostic stores | Optional; not ordinary import authority |
| `MessageLens.instance.lock` | process lock | Single-instance/runtime coordination | Operational only |
| SQLite `-wal` and `-shm` files | SQLite sidecars | Potentially required for a coherent live snapshot | Optional by name, significant if nonempty |
| `.messagelens-checkpoint.json` | checkpoint manifest format 1 | Offline inventory and integrity evidence | Optional; strong qualification evidence when present |
| logs, health reports, and other evidence | version-specific | Diagnostics | Optional; not historical content |

The marker contains:

- `formatVersion`;
- `environment` (`production`, `development`, or `test`);
- `archiveInstanceId`, a validated UUID; and
- `createdAtUtc`, an ISO-8601 UTC timestamp.

There is no separate current search database. Search and support projections
live in the derived graph or overlay stores. A directory containing only
`working_ss.db` is therefore not an authoritative MessageLens historical
source. A donor intended to contribute message history must contain a valid
marker and a supported, coherent `macos_import_ss.db`.

At schema version 10, the source-scoped ledger contains `source_registry`,
`import_batches`, and source-scoped facts for `messages`, `handles`, `chats`,
`contacts`, `contact_channels`, and `attachments`, plus
`chat_to_message`, `chat_to_handle`, and `message_to_attachment` relationships.
These are the current authoritative relational domains; their recipient-local
numeric IDs are not portable identities.

## 2. Qualification Contract

Qualification must inspect the donor independently of active-archive
admission. It must not call normal archive admission, create a marker, open a
database through a migrating Drift class, or require donor reclassification.

The minimum positive evidence is:

1. a readable `.messagelens-archive.json`;
2. supported marker format;
3. valid archive instance UUID and UTC creation timestamp;
4. a donor root different from the active archive root and a donor archive
   instance different from the active archive instance;
5. readable `macos_import_ss.db` with a supported schema or an explicit
   read-only compatibility adapter;
6. required source-ledger tables and referential shape;
7. `PRAGMA quick_check` and `PRAGMA integrity_check` success on a coherent
   immutable representation; and
8. no evidence that a running process or unresolved WAL state makes the
   selected folder an incoherent snapshot.

### A. Does not qualify as a MessageLens data folder

These are deterministic pre-context failures suitable for modal then hub:

- marker absent;
- marker malformed;
- marker UUID or timestamp invalid;
- marker format unsupported as a MessageLens marker;
- `macos_import_ss.db` absent when message history is the requested material;
- the file is not SQLite or lacks the minimum source-ledger schema; or
- the selected folder is the active archive itself.

An unmarked legacy folder must not be silently marked or adopted. Supporting
pre-marker archives requires a separate, explicit compatibility design.

### B. Recognized archive but cannot currently be ingested safely

These require typed inspection/failure evidence rather than "not an archive":

- marker environment is disallowed by target-environment policy;
- archive or database schema is newer than the reader understands;
- an older schema has no read-only adapter;
- SQLite integrity fails;
- a nonempty WAL is required but the donor cannot be coherently inspected;
- the archive appears active or only partially copied;
- required provenance cannot be represented safely in the recipient;
- overlay or attachment metadata is internally inconsistent; or
- a preservation payload collision cannot be resolved without overwrite.

The exact cross-environment acceptance policy remains a product decision.
Conservatively, production should accept production-marked donors only until a
deliberate rule says otherwise. Development may inspect production or
development donors for rehearsal, but it still must never mutate them.

## 3. Source Identity Recommendation

The MessageLens source-kind evidence should be:

```text
MessageLens archive source kind + archiveInstanceId
```

The normalized path is locator evidence only. It must not participate in
identity. This lets persisted identity reconstruct while the disk is
disconnected, moved, or renamed.

A byte-for-byte copy that retains the marker is the same logical archive
source, regardless of path. A copied archive deliberately assigned a new
archive instance ID becomes a different logical archive. A later snapshot of
the same archive instance is an update/reimport candidate for the same source,
not another cartouche.

The donor marker is immutable evidence. Inspection and ingestion must not
rewrite its environment or archive instance ID.

`HistoricalArchiveSourceIdentity` remains the sole historical source identity
authority. It should eventually gain a MessageLens-specific construction and
persisted-value branch; this audit does not change it.

## 4. Authoritative Versus Derived Data

| Donor material | Classification | Future treatment |
| --- | --- | --- |
| Marker | Identity and qualification evidence | Read and retain as provenance; never copy over recipient marker |
| `source_registry` and source-scoped fact tables in `macos_import_ss.db` | Authoritative/importable historical facts | Import through a provenance-preserving adapter |
| `import_batches` | Import history/provenance evidence | Preserve only the history needed for lineage and audit; do not copy recipient-local IDs |
| `working_ss.db` | Derived/rebuildable | Never copy as truth; regenerate after fact import |
| Search/index/support projections | Derived/rebuildable | Regenerate |
| `user_overlays.db` user-authored rows | User overlay/personal metadata | Separate typed merge with explicit conflict rules |
| `user_overlays.db` Historical Archives settings and runtime metadata | Diagnostic/operational | Do not import as user content |
| `user_overlays.db` archived-attachment rows | Preservation metadata | Merge only with source-aware attachment semantics |
| `attachment_archive/` | MessageLens preservation data | Verify and merge without overwrite under a separate preservation phase |
| `presence.db` | Operational coordination state | Never import |
| retired databases | Legacy/diagnostic | Ignore unless an explicit read-only compatibility adapter is selected |
| lock files, logs, health reports, and trace files | Diagnostic/operational | Do not import |
| SQLite sidecars | Snapshot-coherence evidence | Consume only to form a coherent read-only snapshot; do not import |
| checkpoint manifest | Qualification evidence | Verify if present; do not import as historical content |

Although the current archive can rebuild `macos_import_ss.db` from reachable
external sources, a disconnected preserved archive may contain the only
remaining copy of those source facts. In the donor context, its source-scoped
facts are therefore the authoritative import material. The physical database
file is still not copied wholesale.

## 5. Provenance Strategy

The donor archive is a container of source histories, not one flattened source.
Each donor source must remain distinguishable after ingestion.

Raw donor source keys cannot be copied directly. The current reserved keys
`live-chat-db` and `live-address-book` mean "this recipient archive's current
Mac". Reusing those keys for another archive would falsely conflate two
origins.

The required provenance identity is conceptually:

```text
donor archive instance ID
    + donor source kind
    + donor source key
```

Recipient `source_id`, `batch_id`, and packed `ss_id` values are local storage
identities and must be allocated anew. The importer must map donor source rows
to recipient source registrations, recompute source-scoped IDs, and remap every
relationship. Journey membership must separately record which outer
MessageLens archive ingestion contributed each mapped fact so removal can be
precise.

Flattening all donor facts into one source would lose whether a message came
from the donor's live Mac, a previously added historical folder, or recovered
material. That conflicts with the source-scoped import architecture and is
rejected.

This donor-qualified provenance contract is a blocker for fact ingestion. It
is not a blocker for read-only qualification and inspection work.

## 6. Duplicate Semantics

Duplicate answers are domain-specific:

- Human-facing message overlap: distinct nonempty message GUID.
- Durable source occurrence: donor-qualified source provenance plus donor
  `source_rowid`.
- Recipient storage identity: newly allocated recipient source ID plus source
  row ID; donor packed `ss_id` values are never copied.
- Attachment payload overlap: verified content hash and byte length.
- Attachment relationship overlap: source-aware logical attachment identity,
  not content hash alone.
- Overlay overlap: the stable semantic key of each overlay type.

Two source occurrences with the same GUID may be legitimate provenance and
must not be silently collapsed in the ledger. The ready state may report GUID
overlap to the human, while the importer remains occurrence-aware and
idempotent.

## 7. Attachment Strategy

The current contract no longer merges arbitrary donor attachment metadata or
imports donor source occurrences. It recovers payload bytes only after the
donor passes same-Messages-lineage admission and each relationship proves the
same original Apple message and attachment ROWIDs, matching message GUID, and
noncontradictory attachment GUID.

Preserved payloads live under `attachment_archive/`. Hash-addressed payloads
use a SHA-256-derived relative path; compatibility fallback payloads may live
under `_by_id`. Overlay rows relate payloads by
`(message_guid, import_attachment_id)`, where `import_attachment_id` is the
original Apple attachment ROWID.

The read-only matching and path/integrity contract is now documented in
[MessageLens Attachment Matching And Preservation-Safe Recovery](47-MESSAGELENS-ATTACHMENT-MATCHING-AND-PRESERVATION-SAFE-RECOVERY.md).
The Attachments-owned writer now provides atomic verified installation without
destructive overwrite. Actual copy remains disabled until that primitive is
composed behind an aggregate recovery executor with truthful batch outcomes.

Payload files are preservation data. Removing a MessageLens historical source
must not automatically delete them. A future preservation-aware garbage
collector may delete only payloads proven unreferenced under a separately
authorized policy; that policy does not exist now.

The ready journey should report safely recoverable payload count and exact
validated byte total. Mismatches and unavailable donor payloads remain typed
diagnostics, not guesses.

## 8. Overlay Strategy

The overlay store mixes several identity domains:

- GUID-keyed message flags and tags;
- normalized-handle dismissals;
- participant, chat, message, handle, and conversation IDs that are local to a
  graph projection;
- overlay-local virtual participant and tag IDs;
- attachment preservation metadata; and
- heterogeneous settings, including workflow metadata.

It cannot be merged wholesale. Historical Archives should first import source
facts without overlays. Overlay recovery should be a separately authorized,
per-category phase or later journey.

Recommended default conflict rule: current user intent wins. Donor data may add
only nonconflicting facts after stable identity remapping. Categories with
local numeric graph IDs require semantic remapping before they are eligible.
Runtime settings, Presence state, readiness state, and donor Historical
Archives metadata are excluded.

The following remain product decisions:

- which overlay categories are offered;
- whether each category is opt-in;
- how conflicting names, notes, tags, favorites, and visibility choices are
  presented; and
- whether imported overlay facts participate in source removal.

## 9. Compatibility And Read-Only Inspection

The donor must be opened through one-off immutable/read-only SQLite inspection,
not the normal persistent database providers and not current Drift database
classes. Normal Drift opening can run migrations, create tables or indexes,
and write sidecars.

Inspection must read `PRAGMA user_version`, table/column inventory, integrity,
source counts, ranges, and provenance using a version-specific adapter matrix.
Current known versions are import 10, graph 2, overlay 8, and Presence 9. These
numbers identify current code, not an entitlement to reject all older donors.

If a donor requires a nonempty WAL, the safe path is a SQLite backup into a
disposable staging representation after the donor is offline. Any migration or
normalization occurs only in that disposable copy. The donor remains unchanged.
A verified checkpoint manifest can provide stronger evidence that the folder is
an offline coherent snapshot but is not mandatory merely because the copy was
created by another safe mechanism.

D4 does not block this reader if it never opens legacy tables through writable
generated APIs. If a compatibility adapter relies on those APIs, D4 becomes a
specific blocker for that adapter and the adapter must instead use guarded
read-only SQL.

## 10. Mutation Authority

A future MessageLens archive ingestion merits its own
`ArchiveMutationOperation`; reusing `historicalArchiveImport` would hide the
larger protected resource set. The operation must protect:

- recipient source-scoped import ledger;
- recipient graph and graph connection lifecycle;
- recipient overlay when an authorized overlay phase exists;
- recipient attachment archive and attachment metadata during payload merge;
- durable Historical Archives source/lineage metadata; and
- ordinary observers that must not reopen protected stores.

Production requires a verified current-archive checkpoint before mutation.
The owner needs caller-specific graph access while unrelated readers remain
blocked. Busy timeout remains contention tolerance, never authority.

Cross-store work is not one SQLite transaction. It requires a durable,
idempotent operation journal with phase receipts, explicit commit boundaries,
and restart reconciliation. Failure must leave the current archive intact and
the operation retryable without manually deleting partial rows.

## 11. Truthful Execution Stages

These stages correspond to real work boundaries:

| Stage | Truthful evidence/progress |
| --- | --- |
| Inspecting archive | files/databases inventoried; marker and schema checks completed |
| Comparing histories | donor sources and distinct GUIDs compared against recipient |
| Importing source facts | source registrations, batches, and source table rows committed per original source |
| Preparing combined history | existing graph projector unit progress and row counts |
| Preserving attachments | payload files verified/copied and bytes completed, when authorized |
| Merging personal metadata | per overlay category considered/applied/conflicted, when authorized |
| Verifying result | source counts, date ranges, references, graph coverage, payload hashes, and SQLite integrity |

Inspection and comparison are pre-authorization reads. Fact import and later
phases require mutation admission. Attachments and overlays may be separate
authorized operations rather than mandatory parts of the first message-fact
slice. Narrator explains scope changes; Directed Instrumentation reports these
real counters and terminal evidence.

## 12. Ready-State Evidence

Primary evidence should answer whether this archive adds meaningful history:

- message date range;
- total distinct messages and messages not currently represented by GUID;
- number of original source histories represented;
- attachment payload count and total size available for preservation; and
- whether recoverable personal metadata is present.

Details may contain:

- archive creation date, environment, marker format, and archive version;
- archive instance ID;
- database schema versions and integrity results;
- per-source counts;
- duplicate counts;
- missing/unverified attachment counts; and
- overlay category counts.

The archive instance UUID is diagnostic identity, not human-facing title copy.

## 13. Cartouche, Selected Source, And Removal

### Cartouche

Use a human label derived from the chosen folder or retained source metadata,
then date range, message count, and trustworthy added date. Source kind is
communicated by the selected MessageLens arm, not by repeating a UUID.

### Selected source

The center panel should explain meaning and management, for example that this
archive contributed a date range, message count, and number of original source
histories, plus the status of attachments and personal metadata. It should not
repeat the cartouche name as a synthetic header.

### Removal

Removal means removing only recipient facts and metadata whose lineage belongs
to that outer MessageLens archive ingestion. Facts shared with another donor or
independently imported source remain. The graph is rebuilt from remaining
facts. Copied preservation payloads remain by default.

Imported overlay removal cannot be defined until each overlay category has
lineage and conflict semantics. Recipient source-registry entries may be
deleted only when no remaining ingestion references them. Durable outer-source
history should retain enough identity and terminal operation evidence for
deterministic reimport and offline cartouche reconstruction.

## 14. Shared Versus Source-Specific Architecture

| Concern | Historical Archives shared | Mac Messages specific | MessageLens specific |
| --- | --- | --- | --- |
| Sidebar arm | Segmented source-type shell and cartouche grammar | Mac Messages arm | MessageLens arm and its scoped cartouches |
| Typed presentation state | Hub, notices, candidate, ready, existing, operation, failure | Mac payloads inside variants | MessageLens typed evidence inside variants |
| Tracks | Stable A-I skeleton and post-I center seam | Current occupants/copy | Different occupants/copy, same geometry |
| Modal grammar | Pre-context invalid/duplicate notices | Missing `chat.db`, path duplicate | Missing/invalid marker, self archive, recognized incompatibility |
| Narrator | Human scope transitions | One `chat.db` history | Multi-store, multi-origin archive |
| Directed Instrumentation | Typed real-stage reporting | Apple source import/project/remove | Fact remap, payload and optional overlay stages |
| Session guards | Presentation session plus occurrence/operation | Existing implementation | Reuse unchanged |
| Source identity authority | `HistoricalArchiveSourceIdentity` | Kind plus normalized `chat.db` path | Kind plus archive instance ID |
| Qualification | Shared inspection lifecycle | `chat.db` and Apple schema | Marker, multi-database coherence, compatibility |
| Inspection evidence | Source-specific typed evidence behind shared state | Message/chat/handle/GUID evidence | Store/source/payload/overlay inventory |
| Duplicate comparison | Human-facing GUID comparison separated from durable identity | Apple source path occurrence | Donor-qualified source occurrence |
| Import service | Mutation-coordinated operation boundary | Apple database importer | Provenance-remapping archive importer |
| Attachment handling | Preservation invariants and truthful reporting | Optional Messages folder payload lookup | Existing MessageLens payload archive merge |
| Overlay handling | Current intent wins | Not part of Mac source | Separate typed merge domain |
| Removal | Confirmed, instrumented, lineage-bounded operation | Remove one historical path source | Remove one outer ingestion without deleting shared origins/payloads |
| Success semantics | Durable verification, terminal dwell, acknowledgement | Source registered and projected | Sources mapped, graph verified, authorized preservation phases verified |

## 15. Reuse Recommendations

### Reuse unchanged

- A-I `PageTrackLayoutMatrix` geometry and column boundaries;
- shared Track rendering primitives;
- sealed-state transition grammar at the level of meaning;
- modal, orange-reference, and blue-selection presentation grammar;
- presentation-session and occurrence guards;
- Narrator and Directed Instrumentation visual components;
- mutation-coordinator ownership pattern; and
- terminal evidence, dwell, and acknowledgement semantics.

### Generalize narrowly after the second concrete source exists

- `HistoricalArchiveSourceIdentity` source-kind dispatch;
- known-source summary/read model;
- source-specific inspection evidence union/interface;
- source-specific operation progress behind shared presentation variants; and
- sidebar filtering by source kind.

### Leave Mac-Messages-specific

- Messages folder resolver;
- `chat.db` qualification and normalized-path identity evidence;
- Apple message count/range/GUID dry run;
- Apple source registrar/importer;
- optional Messages attachment-folder discovery;
- Mac Messages copy and exact instrumentation labels; and
- one-source removal assumptions.

### Never reuse for MessageLens ingestion

- direct `sourceChatDb`/`chatDbStatus` payload fields as generic evidence;
- Mac path-based source identity;
- private Apple timestamp conversion or any Apple timestamp conversion outside
  `DateConverter`;
- donor packed `ss_id`, recipient-local `source_id`, or `batch_id` values;
- direct copy of `working_ss.db`; or
- ordinary migrating database providers for donor inspection.

## 16. State-Model Compatibility

All 13 sealed presentation variants remain semantically sufficient:

- hub;
- duplicate notice;
- invalid notice;
- import-success notice;
- known-source reference;
- inspecting candidate;
- inspection failed;
- ready to add;
- existing source;
- importing;
- import failed;
- removing; and
- removal failed.

No new top-level variant is justified. The leakage is in payloads such as
`HistoricalArchivesInspectionEvidence` and
`HistoricalArchivesPresentationData`, which currently expose `chat.db`,
Messages-folder status, and Mac-specific counts. MessageLens-specific typed
evidence should sit behind the shared variants rather than widening every
variant with nullable fields.

## 17. Track Compatibility

The A-I skeleton works unchanged:

- A-E coordinate the fixed sidebar hierarchy and cartouche-list start;
- F-I coordinate center page identity, transition, Narrator, and its stable
  handoff to native Directed Instrumentation flow; and
- the variable cartouche list and center operation body remain independent
  after their shared boundaries.

Source type changes content, not geometry. No state-dependent Track boundary,
dynamic selected-row alignment, hidden padding, or new Track is required.

## 18. Segmented-Control Behavior

Each arm should own an independent coordinator/presentation session and a
source-kind-scoped cartouche list. Only the active arm's state is effective.

Recommended switching rule:

- hub or existing-source state: switch is allowed and the destination arm
  opens at its hub; durable sources remain available;
- read-only candidate/notice/reference: switching abandons transient context,
  increments the arm session, and prevents late results from reviving it;
- admitted import or removal: segment switching is disabled until terminal
  mutation evidence and authority release; and
- returning to an arm does not replay stale pulses, modals, or candidate work.

Selecting an existing cartouche remains an explicit action in the active arm.
Durable metadata alone never creates selected context.

## 19. Unresolved Product Decisions

1. Which donor environments may each target environment ingest?
2. Are unmarked pre-marker MessageLens folders supported through an explicit
   legacy adoption/compatibility path?
3. Which overlay categories are offered, opt-in, and removable?
4. What precedence and human review apply to overlay conflicts?
5. Are attachment preservation and overlay recovery part of one authorization
   or separate journeys?
6. How should partially available archives present source facts when overlay
   or payload components are damaged?
7. Should repeated snapshots of one archive instance be treated as incremental
   refresh, replacement, or a selectable historical version?

## 20. Recommended Implementation Slices

1. **Read-only identity and qualification.** Add MessageLens source identity
   evidence, marker reader, immutable inventory, compatibility result, and
   focused tests. Keep the segment disabled.
2. **Typed inspection and dormant UI projection.** Add MessageLens evidence
   behind shared states and test hub/candidate/ready/invalid behavior without
   enabling the segment or mutation controls.
3. **Donor-qualified provenance and lineage contract.** Define source-key
   remapping, outer-ingestion lineage, recipient ID allocation, idempotency,
   and removal behavior. This is the gate for fact import.
4. **Source-fact import and graph rebuild.** Add a dedicated mutation operation,
   operation journal, import adapter, projection, and terminal verification.
5. **Enable the MessageLens arm for message-fact ingestion** only after staging
   rehearsals prove slices 1-4.
6. **Attachment preservation merge.** Add source-aware attachment identity,
   verified copy/dedup, collision reporting, and preservation tests.
7. **Overlay recovery by category.** Add only categories with settled identity,
   precedence, lineage, and removal semantics.
8. **Production checkpoint rehearsal and release hardening.** Prove restart,
   partial failure, duplicate reimport, removal, and no-donor-mutation behavior.

## 21. Hard Invariants

- The donor folder, marker, databases, sidecars, and attachments are never
  modified or migrated in place.
- The active archive is never accepted as its own donor.
- MessageLens donor identity is source kind plus archive instance ID, not path.
- A copied marker identifies the same logical source.
- Original donor source provenance is preserved; the donor is not flattened.
- Recipient-local source IDs, batch IDs, and packed source-scoped IDs are never
  copied.
- Reserved recipient live-source keys are never assigned to donor facts.
- `working_ss.db`, search projections, and Presence state are never copied as
  historical truth.
- Current user intent wins overlay conflicts unless a later explicit policy
  says otherwise.
- Archived payloads are never overwritten or deleted by import/removal.
- Apple Messages timestamps, wherever encountered, use only `DateConverter`.
- Production mutation requires admitted authority and a verified checkpoint.
- Unrelated readers remain blocked while the admitted owner uses protected
  resources.
- A fresh import requires a fresh explicit human command.
- Tracks and source arms retain semantic neutrality; content does not change
  the page's shared geometry.
- Late asynchronous work must prove source arm, session, occurrence, and
  operation identity before changing presentation.

## 22. Risks And Blockers

### Blocking fact ingestion

- no donor-qualified provenance key/lineage contract;
- no recipient ID remapping importer for all source relations;
- no durable cross-store operation journal/restart reconciliation;
- no source-aware attachment compatibility key or merge API; and
- no overlay category merge/removal policies.

### Blocking some older archives

- no versioned immutable compatibility adapter matrix;
- no policy for unmarked pre-marker archives; and
- no settled cross-environment acceptance policy.

### Not blockers for slices 1-2

- D4, provided donor readers use guarded immutable SQL;
- attachment and overlay merge, provided early slices report them without
  offering mutation; and
- the disabled segment, which should remain disabled during those slices.

## Post-D1/D2/D3 Confirmation

Read-only inspection confirms:

- D1 remains intact: the workflow uses one sealed presentation state; no old
  combinatorial compatibility path has reappeared.
- D2 remains intact: the page composes one stable A-I matrix independent of
  presentation variant.
- D3 remains intact: `HistoricalArchiveSourceIdentity` remains the sole
  historical source-key construction and reconstruction authority.
- D4 remains deferred. It is neither fixed nor broadened by this audit.

## Final Readiness Judgment

The MessageLens arm can begin safely only as bounded read-only foundation work:
identity, qualification, immutable compatibility inspection, and typed dormant
presentation evidence.

It is not safe to enable the segment or implement historical fact mutation yet.
The donor-qualified provenance and lineage contract is the first mandatory
design/implementation gate. Attachment and overlay recovery then require their
own explicit contracts rather than being implied by a successful message-fact
import.
