---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: doc
links:
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../50-ENVIRONMENT-SAFETY/00-overview.md
tests: []
---

# Production Archive Recovery

> **The March 2026 MessageLens archive is a read-only donor. The current
> MessageLens archive is production. The initial investigation is read-only and
> authorizes mutation of neither.**

> **Archived attachment payloads are preservation data and must be treated like
> gold.**

## Status

**Temporarily reopened for a separate historical-message recovery task.**

The direct relational bridge accounts for 33,011 of 33,018 checkpointed donor
relationships (99.9788%). A final private, local-only manifest reproduces the
354 apparently recoverable payloads and 445,063,249 total bytes from the first
audit. No recovery was performed.

See:

- [March 2026 Attachment Relational Bridge Audit](01-MARCH-2026-ATTACHMENT-RELATIONAL-BRIDGE-AUDIT.md)
- [March 2026 Recovery Manifest And Closure](02-MARCH-2026-RECOVERY-MANIFEST-AND-CLOSURE.md)

Further March attachment recovery requires new explicit authorization.

The March attachment-recovery investigation remains closed. Feature 26 is
reopened only to assess the separate `Messages_2012` historical donor. The
read-only feasibility result and staging recommendation are recorded in:

- [Historical Messages 2012-2016 Ingestion Audit](03-HISTORICAL-MESSAGES-2012-2016-INGESTION-AUDIT.md)
- [Historical Import Maintenance-Lock Correction](04-HISTORICAL-IMPORT-MAINTENANCE-LOCK-CORRECTION.md)
- [Historical Apple Timestamp Normalization Correction](05-HISTORICAL-APPLE-TIMESTAMP-NORMALIZATION-CORRECTION.md)
- [Historical Import Post-Correction Verification](06-HISTORICAL-IMPORT-POST-CORRECTION-VERIFICATION.md)

A disposable staging-clone rehearsal ultimately imported and projected all
8,882 donor messages. It exposed and corrected two independent defects: the
historical-import maintenance operation initially blocked its own graph access,
and old Apple-second timestamps were later interpreted as nanoseconds. The
timestamp correction is implemented and verified in code; the GUI import has
been rerun manually after that correction. Immutable post-import verification
confirms all 8,882 source-3 messages now span the correct 2012-2017 range and
project exactly into the graph. The next concern is the Historical Archives
UX/lifecycle behavior observed during maintenance; no redesign has begun.

## Original Emergency Objective

Safely make the current production MessageLens archive contain everything
valuable preserved in the March 2026 MessageLens Application Support archive,
especially historical Messages records and preserved archived image attachment
payloads.

The March 2026 saved folder contains both:

- historical Messages data reaching farther back than the current production
  archive, including records ultimately dating to approximately 2011; and
- archived image attachment payloads preserved before Apple later evicted some
  local originals to iCloud.

The package began by considering recovery of this known donor archive into this
known current production archive. It was never a generalized product feature.
The read-only evidence later justified stopping without performing recovery.

## Safety Boundary

The investigation was forensic inventory only. It authorized no write, copy,
rename, normalization, repair, migration, database opening in writable mode,
or other mutation of either archive.

No recovery operation may casually overwrite, delete, normalize, regenerate,
relocate, or otherwise mutate archived payloads. If two files eventually claim
the same logical destination but differ in bytes, that collision must be
surfaced explicitly. Silent overwrite is prohibited.

## Investigative Question

The audit answered, read-only:

> What exactly exists in the March 2026 donor archive, what exists in the
> current production archive, how do they overlap, and what is the safest
> one-way union seam?

That investigation identified:

- database files present in each archive;
- which stores contain the historical message facts needed for recovery;
- date ranges and approximate record counts;
- attachment archive structure, identity, and linkage;
- overlap between donor and production;
- authoritative and preservation stores;
- safely rebuildable derived stores; and
- existing ingestion code that may support a later bounded recovery.

The two audit records linked below preserve the result.

## Final Evidence

The read-only investigation is complete:

- [March 2026 Attachment Relational Bridge Audit](01-MARCH-2026-ATTACHMENT-RELATIONAL-BRIDGE-AUDIT.md)
- [March 2026 Recovery Manifest And Closure](02-MARCH-2026-RECOVERY-MANIFEST-AND-CLOSURE.md)

The direct relational bridge maps 33,011 of 33,018 checkpointed donor
message/attachment pairs (99.9788%). Matching is therefore considered proven.
The final manifest exactly reproduces the 354 mapped donor payloads that appear
absent from the current production attachment archive. The remaining payloads
are not important enough to justify recovery work at this time.

## Original Sequence

```text
FIRST
    determine whether the known March 2026 archive can be related safely to
    the current production archive

LATER
    only with new explicit authorization, consider recovery or use the
    evidence for a generalized archive-ingestion feature
```

## Explicit Non-Goals

Do not yet design or implement:

- public archive-import UI;
- generalized archive discovery;
- arbitrary historical-folder ingestion;
- multi-user workflows;
- migration wizards;
- recovery scripts;
- database merging; or
- attachment copying.

The March attachment investigation remains the historical record of an
explicit stop decision. The separately reopened historical-message task is
limited to the staging-clone rehearsal described in Audit 03.
