---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: validation-record
---

# Controlled-Loss MessageLens Attachment Recovery Validation

## Result

The Historical Archives MessageLens attachment-recovery path completed a
human-controlled end-to-end validation against realistic archive data.

The experiment deliberately removed an exactly known set of payloads from a
disposable development receiving archive, then independently proved:

```text
known physical loss
    -> exact read-only preflight detection
    -> explicit human authorization
    -> exact recovery
    -> byte-for-byte payload identity
    -> zero recoverable on repeat
```

This is validation evidence for the implemented product path. It does not
replace the automated verification recorded under Prompt 55.

## Controlled Test Condition

Before any loss was created, the read-only Prompt 55 helper generated a
separate controlled-loss manifest containing:

- 7 attachment payload files;
- 918,067 combined bytes;
- JPEG and PNG payloads;
- canonical attachment identity for every item;
- corresponding donor and receiving paths;
- exact expected byte size; and
- exact expected SHA-256.

All seven receiving payloads existed before deletion. MessageLens was fully
quit, and the human removed only those seven receiving payload files from the
disposable archive's managed `attachment_archive`. The deletion command was
mechanically restricted to that directory. Database rows, attachment metadata,
donor payloads, and all other archive content were untouched.

After deletion, all seven receiving paths were independently confirmed absent.
The test condition was therefore exact: current metadata still described the
attachments, while precisely seven managed payload files were missing.

The temporary manifest itself is not repository evidence. It contained
machine-specific paths, was preserved separately for the manual test, and was
not committed.

## Preflight Evidence

Historical Archives -> MessageLens admitted the intact donor and reported:

- **7 recoverable attachments**; and
- **918,067 bytes**, presented as approximately **896.5 KB**.

Those values exactly matched the controlled-loss manifest.

The existing unrelated diagnostic population remained separate: six ambiguous
claims and one conflict were not promoted to recoverable. Physical payload
absence, exact identity correspondence, and the supported same-lineage donor
proof therefore selected only the deliberately removed set.

## Recovery Presentation And Result

The stable Historical Archives center Tracks presented the real recovery
journey.

Narrator stated:

> **Recovering missing attachments from this MessageLens folder.**

Directed Instrumentation showed the real stages:

- Verifying attachment files;
- Recovering attachment files; and
- Checking that recovery finished.

It used the real denominators `0 / 7` and `0 B / 896.5 KB`, not timer-driven or
estimated progress.

The terminal acknowledgement reported:

> **Attachment recovery complete**
>
> MessageLens recovered 7 missing attachments from the folder you selected.

The reported result therefore matched the deliberately created loss exactly.

## Independent Physical Verification

After recovery, every receiving payload was checked outside MessageLens
against the preserved manifest. For all seven files:

- the expected physical file existed;
- actual size equaled `expectedSizeBytes`; and
- an independently calculated SHA-256 equaled `expectedSha256`.

All seven checks passed. Recovery restored the original payload bytes, not
merely files at expected paths. The donor remained unchanged.

## Idempotency Verification

The same donor was selected again through Historical Archives -> MessageLens.
MessageLens reported:

> **No missing attachments were found.**

The restored payloads were recognized as present and were not offered for
recovery again. The end-to-end operation therefore converged from known loss to
zero recoverable without duplicate files or repeated recovery.

## What The Experiment Proves

For the supported product case, this validation proves the complete chain:

1. the donor qualifies as a supported MessageLens recovery donor;
2. same-Messages-lineage admission succeeds;
3. donor/current message identity correspondence is sufficient;
4. exact attachment relationships select the intended attachments;
5. physical absence drives missing-payload classification;
6. preflight identifies the exact deliberately missing set and byte total;
7. ambiguous and conflicting evidence remains fail-closed;
8. explicit user authorization starts recovery;
9. execution-time donor verification succeeds;
10. the preservation-safe atomic no-overwrite writer restores the payloads;
11. final verification proves the intended files and bytes were restored;
12. independent size and SHA-256 checks match the pre-loss evidence;
13. the donor remains read-only and unchanged; and
14. repeat preflight reports zero recoverable.

No donor message import, graph reconstruction, overlay import, source
registration, or donor cartouche was involved. The MessageLens folder remained
an ephemeral recovery donor rather than a durable historical content source.

## Evidence Boundary

This manual experiment validates attachment recovery from an intact,
same-lineage MessageLens donor into a deliberately damaged disposable receiving
archive. It does not alone prove every possible interruption, disk failure,
foreign donor, unsupported schema, metadata corruption, ambiguous relationship,
or concurrent filesystem race.

Those conditions remain protected primarily by the fail-closed architecture
and automated tests. Prompt 55 had already passed 101 focused tests, 553 broader
relevant tests, the complete 1,949-test Flutter suite, analyzer, formatting,
diff checks, and a macOS debug build. The controlled-loss experiment adds
real-format end-to-end evidence to that automated foundation.

## Validated Safety Model

The combined evidence validates the intended layered model:

```text
same Messages lineage
    -> exact message identity
    -> exact attachment relationship
    -> physical missing-payload evidence
    -> explicit user authorization
    -> execution-time donor verification
    -> preservation-safe atomic no-overwrite installation
    -> authoritative final verification
    -> idempotent rescan
```
