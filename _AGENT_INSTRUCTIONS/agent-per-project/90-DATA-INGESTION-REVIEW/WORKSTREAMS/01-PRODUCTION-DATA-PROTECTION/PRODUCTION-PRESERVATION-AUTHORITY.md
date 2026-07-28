PRODUCTION-PRESERVATION-AUTHORITY.md

Tier: Project
Scope: Production Data Protection
Status: Blocking architecture

⸻

Purpose

The Production Data Protection workstream establishes archive identity, admission, and mutation authority.

This document records an additional architectural requirement discovered during implementation:

Archive admission determines where a running process may write. It does not determine which archive is responsible for preserving newly arriving user data.

Those are separate responsibilities and must remain so.

This is not a deferred Production Health enhancement. Continuity of live
production preservation is a prerequisite for every Production Readiness
implementation slice.

⸻

Background

Archive admission guarantees:

- build identity is truthful;
- archive identity is validated;
- mutation occurs only within the admitted archive;
- development and production cannot silently share state.

However, archive admission does not guarantee that any admitted archive is currently preserving newly arriving Messages data.

If no MessageLens process is running, no attachment preservation occurs.

⸻

Current Behaviour

The current implementation provides:

- every admitted production or development GUI process in a supported runtime
  starts its own incremental monitor;
- startup performs a catch-up import from Apple’s Messages database;
- newly discovered messages trigger an attempt to archive every available
  attachment into that process’s admitted archive;
- current source code periodically retries conventional attachment
  preservation when source metadata declares a nonblank MIME type;
- attachment archiving may be enabled or disabled independently per archive.

Consequently:

- a running development process may preserve a redundant development copy;
- it does not preserve the production attachment archive;
- when no production archive is running, production attachment preservation is inactive.

The current signed production application now runs against the adopted
production archive and exercises production preservation authority. Startup
catch-up and later live arrivals have been observed. This current operational
fact is recorded in
[`VALIDATION-RESULTS/production-cutover-2026-07-28.md`](VALIDATION-RESULTS/production-cutover-2026-07-28.md).

⸻

Architectural Distinction

Two independent concepts now exist.

Archive Admission

Determines:

- which archive may be opened;
- where persistent state may be written;
- which archive identity a process represents.

Admission answers:

Where may this process operate?

⸻

Preservation Authority

Determines:

- which archive identity owns canonical live preservation;
- which admitted process may exercise that responsibility;
- which monitor is responsible for incremental ingestion while that process
  holds authority;
- which archive must preserve newly arriving attachments;
- how health and liveness are demonstrated.

Preservation authority answers:

Who is responsible for preserving newly arriving user data?

⸻

Required Invariant

The system must guarantee:

Exactly one production archive identity is designated as the Production
Preservation Authority. At most one admitted process may exercise that
authority at a time, and the application can objectively demonstrate when that
responsibility was last successfully fulfilled.

Development archives may preserve redundant copies. That redundancy does not
grant production authority and does not satisfy production continuity.

This is stronger than merely proving that a process was admitted.

⸻

Implementation Slice Admission

Under normal production operation, before any implementation slice begins, its
plan must identify:

- the production archive identity currently designated as the preservation
  authority;
- the admitted process currently exercising that authority;
- fresh evidence that monitoring and preservation are operating;
- how the slice preserves continuity while work is performed;
- any authority handoff required by the slice and how that handoff avoids an
  unowned interval.

If those facts cannot be demonstrated, the slice is blocked.

A slice must not stop, replace, migrate, or otherwise interfere with the
current preservation process until its successor has acquired authority and
the handoff can be verified.

The former transition with no production preservation process ended at the
authorized cutover on 2026-07-28. Normal slice admission now applies: fresh
evidence from the admitted production process is required before further
implementation begins.

Production Health may later present and explain preservation evidence. It does
not own this prerequisite and cannot defer it.

⸻

Required Evidence

The preservation authority should produce durable evidence that records at least:

- archive identity;
- latest monitor heartbeat and the freshness threshold used to interpret it;
- most recent successful Messages probe;
- latest source cursor observed by that probe;
- latest source cursor committed to the admitted archive;
- most recent incremental import;
- most recent attachment-preservation pass, including candidate, archived,
  skipped, and failed counts;
- failures preventing preservation.

A persisted running flag is insufficient because it may survive a crash.
Operational health must be inferred from fresh heartbeat and operation evidence,
not assumed from stale state. A successful preservation pass with zero
candidates is still valid health evidence.

⸻

Current Operational Procedure

After production adoption:

1. treat the installed current signed production application as the process
   exercising preservation authority for the adopted archive;
2. keep Debug/Profile mechanically confined to the development identity and
   external development archive;
3. require fresh startup, source-cursor, import, and attachment-preservation
   evidence before later implementation slices;
4. retain the verified recovery backup, adoption inventory, and cutover report;
5. do not rerun adoption or edit the production marker;
6. stop and investigate if preservation evidence becomes stale or reports
   failure;
7. deploy and validate generalized delayed retry for the three conventional
   QuickTime residuals through the normal production release process;
8. keep the nine NULL-MIME plugin payloads inventoried and excluded until an
   explicit preservation policy is approved.

The previous interrupted-preservation procedure remains historical audit
evidence and no longer governs current operations.

⸻

Known Limitation

The source implementation now retries conventional delayed attachments with a
declared MIME type, including image, video, audio, PDF, and ordinary document
files. The installed production application must still be upgraded and the
three bounded QuickTime residuals observed as recovered before production
parity is considered verified.

NULL or blank MIME rows remain excluded. The nine bounded production examples
are `.pluginPayloadAttachment` files whose durable value outside Apple
Messages has not been established. They require a preservation-policy decision,
not a type-agnostic copying change.

⸻

Future Architecture

A complete production architecture should resemble:

Archive Admission
│
▼
Preservation Role Assignment To One Production Archive Identity
│
▼
One Admitted Process Exercises Authority
│
▼
Fresh Monitor Heartbeat
│
▼
Successful Source Probe
│
▼
Successful Attachment Preservation
│
▼
Durable Health Evidence

Admission authorizes mutation.

Preservation authority establishes operational responsibility.

The two concepts intentionally remain separate.

⸻

Workstream Completion Criteria

This architectural work is complete when:

- preservation authority becomes an explicit architectural concept;
- one production archive identity is mechanically designated as the
  preservation authority;
- no more than one admitted process can exercise that authority at a time;
- fresh heartbeat and operation evidence demonstrate successful preservation;
- canonical operational documentation supersedes this workstream record.
