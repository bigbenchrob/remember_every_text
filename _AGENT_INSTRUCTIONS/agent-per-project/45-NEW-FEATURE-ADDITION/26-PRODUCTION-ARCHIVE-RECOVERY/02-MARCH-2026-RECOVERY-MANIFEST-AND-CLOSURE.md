---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: closure-record
links:
  - 00-START-HERE.md
  - 01-MARCH-2026-ATTACHMENT-RELATIONAL-BRIDGE-AUDIT.md
tests: []
---

# March 2026 Recovery Manifest And Closure

## Manifest Result

The final read-only manifest reproduces Audit 01 exactly:

| Measure | Result |
|---|---:|
| apparently recoverable payloads | 354 |
| total payload bytes | 445,063,249 |
| approximate size | 0.414 GiB |

MIME distribution:

| MIME type | Payloads |
|---|---:|
| blank | 196 |
| `image/heic` | 104 |
| `image/jpeg` | 35 |
| `image/png` | 7 |
| `video/quicktime` | 7 |
| `image/gif` | 4 |
| `image/tiff` | 1 |

There were no discrepancies from the 354-candidate result recorded in
[Audit 01](01-MARCH-2026-ATTACHMENT-RELATIONAL-BRIDGE-AUDIT.md).

## Private Detailed Manifest

The detailed manifest contains private attachment paths and archive
identifiers, so it is deliberately outside Git at:

```text
/tmp/messagelens-production-archive-recovery/march-2026-recoverable-attachments.csv
```

It contains the donor message and attachment identities, donor-relative
payload path, actual and declared sizes, MIME type, mapped current MessageLens
message and attachment identities, decoded live-source attachment row
identity, and proposed `missing/recoverable` status. It does not contain or
query message text.

The local file is owner-readable and owner-writable only. Its SHA-256 digest
at generation was:

```text
2a8679a0ab618f8aeb4bc6d3fe7c52871330cc649922cd3f51f1471485036465
```

Because this is a temporary local-only artifact, its path is an audit pointer,
not a durable repository deliverable.

## Safety Boundary

The manifest was derived with immutable/read-only donor and production
database access. No archive writer was invoked. No attachment was copied. No
database, archive metadata, message history, or attachment payload was
mutated. **No recovery is being performed.**

The following were deliberately not investigated further:

- the seven-row relational residue;
- the 2,162 filesystem-residue files;
- heuristic matching;
- donor WAL-only records;
- the circa-2012 Messages archive;
- later MessageLens attachment lacunae; and
- generalized archive ingestion.

## Closure Decision

> The direct relational bridge recovered/accounted for approximately 99.98%
> of the relevant donor relationships. This exceeds the project's success
> threshold. The remaining missing payloads are not important enough to
> justify further recovery work at this time.

Feature 26 is suspended and complete for now by explicit user decision. Any
future recovery work requires a new, explicit authorization; this closure does
not authorize copying or recovery implementation.
