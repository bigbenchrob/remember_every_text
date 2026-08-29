---
tier: project
scope: completed-installation-validation-responsiveness
owner: agent-per-project
last_reviewed: 2026-08-28
source_of_truth: implementation-record
---

# Complete Erase Validation Responsiveness Correction

## Root Cause

The production-shaped external-drive validation exposed two independent kinds
of work.

Startup installation classification performs strict schema, topology, count,
and `PRAGMA quick_check(1)` inspection of the canonical MessageLens stores. A
runtime process sample proved that this work runs on a worker isolate rather
than Flutter's presentation isolate. A controlled attempt to inspect the four
stores concurrently was rejected: on the external hard drive it exceeded one
minute and was slower than the prior 37-second sequential cold run because the
integrity scans competed for one physical disk. The canonical checks therefore
remain strict, sequential, and off the presentation isolate.

The Contacts delay occurred while one live message catch-up continued from an
8.7-second graph build into approximately 41 seconds of attachment archival.
The source-range attachment query admitted opaque NULL-MIME payloads, and the
file store could hash a payload before discovering that its extension was not
eligible for preservation. Hashing also executed through the calling isolate's
stream callbacks. This unnecessary work coincided with ordinary graph reads on
the same external archive.

The runtime log also captured a transient navigation assertion: a sidebar rack
described shared Track participation during a frame in which no resolved page
matrix was mounted.

## Correction

- Live graph mutation now completes and releases its coordinator scope before
  attachment preservation acquires its own `attachmentReconciliation` scope.
- If another mutation acquires authority between those operations, attachment
  work is deferred to the existing rolling sweep rather than extending or
  bypassing graph authority.
- Live source-range attachment selection now follows the established
  conventional-file policy and excludes NULL/blank-MIME opaque payloads.
- Unsafe attachment extensions are rejected before content hashing.
- Valid attachment SHA-256 computation runs through `Isolate.run`, keeping
  crypto work off the presentation isolate.
- The sidebar consumes shared Tracks only while its mounted tree can see the
  page's resolved matrix. During a transient rack/composition mismatch it
  renders the existing native cassette flow and creates no substitute geometry.

## Preserved Invariants

- No installation evidence or integrity check was removed.
- No database schema or persisted representation changed.
- Graph and attachment mutations still require their canonical coordinator
  operations.
- Attachment preservation remains idempotent and converges through the rolling
  sweep if immediate source-range preservation is deferred.
- Opaque payload records remain in the imported/projected graph; only their
  unapproved preservation work is excluded.
- `attachment_archive/`, Apple Messages, Contacts, Historical Archive sources,
  recovery donors, overlays, Presence history, and preferences were not
  modified by diagnosis or implementation.

## Regression Coverage

Focused tests prove:

- source-range selection excludes NULL and blank MIME payloads;
- graph mutation finishes before attachment preservation begins;
- graph failure cannot start attachment preservation;
- canonical file installation and hashing behavior remains correct;
- a Track-enabled rack without a mounted resolved matrix renders native flow
  without a `TrackCellView` assertion;
- existing shared-Track pages retain their established behavior.

The controlled external-drive classifier benchmark was read-only and was
stopped after it proved concurrent scans were counterproductive. Complete Erase
was not invoked and the disposable archive was not reset.
