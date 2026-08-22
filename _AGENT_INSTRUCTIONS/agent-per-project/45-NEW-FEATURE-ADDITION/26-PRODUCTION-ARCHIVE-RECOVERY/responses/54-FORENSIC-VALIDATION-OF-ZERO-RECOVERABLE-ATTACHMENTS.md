---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: implementation-record
---

# Forensic Validation Of Zero Recoverable Attachments

## Conclusion

The real donor's zero-recoverable result is correct for the donor/current pair
examined on 2026-08-22. Matching semantics were not loosened and no recovery
candidate was manufactured.

The current MessageLens archive is a strict superset of the donor's archived
attachment claims and managed payload paths:

- every one of the donor's 33,399 archive metadata claims has the same logical
  key in the current archive;
- every donor managed payload path is represented in the current archive;
- 33,392 identity-admitted claims have a physically valid current payload;
- one identity-admitted claim has the same pre-existing metadata/size conflict
  on both sides;
- six donor claims lack exactly one donor relationship and therefore remain
  fail-closed and ambiguous;
- no donor claim can truthfully become recoverable.

All inspection was read-only. No donor, current database, attachment payload,
archive marker, live `chat.db`, or overlay record was modified.

## Payload-Presence Authority

Current payload presence means:

```text
canonical overlay archive metadata exists
    + archive-relative path resolves safely inside MessageLens attachment_archive
    + the resolved object is a regular file
    + actual size equals the recorded size
    = presentValid
```

Metadata alone is insufficient. A stale overlay row whose file is absent is
`missing`. A non-regular object, unsafe path, unreadable evidence, or size
disagreement is fail-closed as a conflict. The original Apple Messages path,
donor path, filename, transfer name, and derived-media paths do not prove
current payload presence.

Preflight deliberately does not hash all payloads. SHA-256 verification remains
mandatory at the future installation boundary, immediately before atomic
no-overwrite installation. This preserves Prompt 53's performance correction.

Donor payload presence uses the corresponding contained-path, regular-file,
and exact-size proof inside the selected donor's `attachment_archive/`.

## Read-Only Archives Examined

Representative donor:

```text
/Volumes/WD_ELEMENTS/2026-08_16-DATA_FOLDER/com.bigbenchsoftware.MessageLens
```

Current production-shaped archive:

```text
/Users/rob/Library/Application Support/com.bigbenchsoftware.MessageLens
```

The external development archive contained no comparable message/attachment
evidence and was not substituted for the current archive merely because it was
a configured development location.

## Evidence Funnel

### Database and claim populations

| Evidence | Donor | Current |
|---|---:|---:|
| Messages source relationships | 39,381 | 39,485 |
| Distinct relationship row pairs | 39,381 | 39,485 |
| Archive metadata claims | 33,399 | 33,503 |
| Unique archive metadata keys | 33,399 | 33,503 |
| Recorded claim bytes | 39,993,228,039 | 40,284,945,000 |

All message and attachment relationship evidence on both sides belongs to
source 1. The donor contains no actual multi-source attachment relationship
population in this comparison.

### Matching funnel

```text
33,399 donor archive claims
    -> 33,393 claims with exactly one donor relationship
    -> 33,393 exact message identity matches
    -> 33,393 exact attachment identity matches
    -> 33,392 current payloads physically valid
    ->      1 current payload conflict
    ->      6 ambiguous donor claims
    ->      0 recoverable
```

The six claims without one donor relationship are not dropped. They remain in
the denominator and are assigned the typed terminal classification
`ambiguous`.

### Terminal classifications

| Classification | Count |
|---|---:|
| `recoverable` | 0 |
| `alreadyPresent` | 33,392 |
| `donorMissing` | 0 |
| `messageMismatch` | 0 |
| `attachmentMismatch` | 0 |
| `conflict` | 1 |
| `ambiguous` | 6 |
| `unsafeDonorPath` | 0 |
| **Total** | **33,399** |

The terminal total exactly reconciles with donor claims.

## Physical Population Comparison

Filesystem inventory did not follow symlinks. Neither archive contained a
symlink under its managed attachment archive.

| Physical evidence | Donor | Current |
|---|---:|---:|
| Regular files, including `.DS_Store` | 26,130 | 26,223 |
| Regular-file bytes, including `.DS_Store` | 37,946,532,708 | 38,237,329,076 |
| Unique valid claimed payload files | 26,129 | 26,222 |
| Unique valid claimed payload bytes | 37,946,497,888 | 38,237,294,256 |
| Claims with exact physical size | 33,398 | 33,502 |
| Missing claimed files | 0 | 0 |
| Unsafe claimed paths | 0 | 0 |
| Size-conflicting claims | 1 | 1 |

Cross-archive comparison found:

- donor-only archive metadata identities: 0;
- current-only archive metadata identities: 104;
- donor managed paths absent from current: 0;
- current managed paths absent from donor: 93.

This population comparison independently supports the typed classification
result. The current archive contains all donor managed paths and additional
current payloads.

## Representative Traces

### `alreadyPresent`

One deterministic sample has:

```text
message GUID: 000B1168-64F6-45D5-9F9F-C1804FA9A0BA
original message ROWID: 108169
original attachment ROWID: 28670
attachment GUID: at_0_000B1168-64F6-45D5-9F9F-C1804FA9A0BA
source-scoped message ID: 8796093130377
source-scoped attachment ID: 8796093050878
managed payload size: 159286 bytes
```

The donor and current ledgers independently decode their scoped IDs to the same
original ROWIDs. Their message and attachment GUID evidence agrees. Both
overlays identify the same managed relative path and size, and both resolved
objects are regular 159,286-byte files. The typed result is therefore
`alreadyPresent`.

### `conflict`

The sole conflict is message GUID
`D0678B4A-5FE4-4C80-AD54-6FF737D52B6C`, attachment ROWID 40092. Both archives
record size 0 for a managed plugin payload whose actual regular-file size is
1,150 bytes. The path is shared by other claims whose recorded size is 1,150.
Identity agrees, but the claim's own preservation metadata conflicts with the
physical file. Current conflict precedence correctly prevents recovery.

### Ambiguous donor claims

Six donor overlay claims have physically present payloads and exact current
overlay counterparts but no corresponding donor `message_to_attachment`
relationship. Without that relationship, neither filename nor archive path may
substitute for attachment identity. They remain `ambiguous`.

### `donorMissing`

The real donor has no donor-missing claim. A focused fixture proves that donor
metadata whose contained regular file is absent becomes `donorMissing` rather
than recoverable.

## Source-Scoped Identity Audit

The evidence factory checks both packed IDs with canonical
`SourceScopedRowKey` decoding:

```text
packed message ID -> stored source ID + original message ROWID
packed attachment ID -> stored source ID + original attachment ROWID
```

Matching then compares original ROWID relationships across snapshots. It does
not compare packed IDs across source scopes. A focused test proves that a
coherent donor relationship in source 7 matches the corresponding coherent
current relationship in source 1 when original ROWIDs and GUID evidence agree.

Source scoping did not cause the real zero result. All real relationship
evidence in this donor/current comparison is source 1 and all packed IDs are
coherent.

## Prompt 53 Semantic Audit

The optimized preflight still:

- reads each donor/current relationship set once;
- reads donor claims once;
- reads current archive metadata once;
- matches through indexed original-row relationships;
- inventories physical paths in bounded O(N) passes;
- preserves every identity and classification predicate in the pure matcher;
- performs no preflight payload hashing or mutation.

The service now records the same evidence funnel used by the matcher. A focused
fixture compares indexed service matching with direct matcher expectations.
No semantic difference attributable to Prompt 53 was found.

## Diagnostic Correction

No matching correction was warranted. The bounded implementation adds:

- a typed read-only preflight funnel;
- explicit donor/current relationship and payload-presence counts;
- message- and attachment-identity match counts;
- explicit unmatched donor relationship and duplicate-collapse counts;
- a terminal-classification reconciliation invariant;
- development Details lines for ready candidates and persistent diagnostic
  logging for every completed preflight, including zero results, without
  changing the calm normal-user zero-result modal.

Donor presence now inventories every donor archive claim in the existing O(N)
pass, including claims that cannot enter identity matching. It still performs
no hashing.

## Tests And Safety

Focused coverage proves:

- overlay metadata alone cannot prove payload presence;
- a missing current managed file remains missing;
- current physically valid payloads become `alreadyPresent`;
- missing donor files become `donorMissing`;
- original source-scoped ROWIDs, not paths or filenames, govern matching;
- coherent IDs from different source scopes match through original ROWIDs;
- indexed service matching preserves direct matcher classifications;
- duplicate claims are accounted for explicitly;
- terminal classifications and exclusions reconcile with examined claims;
- all-present fixtures produce a truthful zero;
- preflight remains read-only and performs no recovery mutation.

## Product Consequence

The selected donor cannot recover anything into this current archive because
the current archive already physically contains every donor managed payload
identity that can pass exact proof. The recovery feature remains useful for
other historical snapshots whose valid, identity-matched payloads are absent
from current managed storage.

Actual attachment recovery remains disabled.

## Verification

The bounded correction was verified with:

- focused attachment matcher, current-evidence adapter, preflight-service, and
  Historical Archives presentation tests;
- the MessageLens attachment-recovery architecture tripwires;
- the source-scoped identity tests;
- the complete Flutter test suite: 1,938 tests passed;
- `flutter analyze`: no issues;
- a macOS debug build: succeeded;
- `git diff --check`: clean.

The implementation retains the Prompt 53 O(N) preflight shape. It adds no
payload hashing and no second relationship scan. Inspecting all donor payload
claims instead of only matched claims adds six physical-presence inspections
for this real donor. No post-change GUI timing was manufactured; the expected
manual result remains approximately the observed 5-8 second preflight.

## Manual Retest

For a final presentation check, choose the same MessageLens donor again. The
expected user-facing outcome remains the calm zero-result acknowledgement. The
application diagnostic log should record the complete evidence funnel,
terminal classification counts, and a positive reconciliation result even
though the zero-result path does not expose a ready-state Details panel.
