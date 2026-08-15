---
tier: project
scope: production-data-protection
owner: attachments
last_reviewed: 2026-07-28
source_of_truth: implementation-record
status: implemented-pending-production-verification
links:
  - ./README.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
tests:
  - test/features/attachments/infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader_test.dart
  - test/features/attachments/application/attachment_archive_service_provider_test.dart
---

# Delayed Attachment Retry

## Problem

The periodic retry sweep inherited an image-specific candidate predicate:

```sql
AND a.mime_type LIKE 'image/%'
```

The downstream source lookup and archive writer were already type-agnostic,
but video, audio, PDF, and document rows never reached them. NULL-MIME plugin
payloads were excluded by the same predicate without having an explicit
preservation policy.

## Solution

Delayed retry now selects unarchived live attachments whose source metadata
contains a nonblank MIME type:

```sql
AND NULLIF(TRIM(a.mime_type), '') IS NOT NULL
```

This admits conventional user-visible attachments while continuing to exclude
opaque NULL/blank-MIME payloads pending a separate policy decision. Existing
archive-key, source-scope, path, availability, and cursor behavior is
unchanged.

Focused tests cover image, QuickTime video, audio, PDF, and document selection,
complete PDF archiving, and explicit NULL/blank-MIME exclusion.

## Production Follow-Up

The three bounded QuickTime residuals should become eligible after a production
build containing this change is installed. Their recovery must still be
verified. The nine plugin payload residuals remain inventoried but unresolved.
