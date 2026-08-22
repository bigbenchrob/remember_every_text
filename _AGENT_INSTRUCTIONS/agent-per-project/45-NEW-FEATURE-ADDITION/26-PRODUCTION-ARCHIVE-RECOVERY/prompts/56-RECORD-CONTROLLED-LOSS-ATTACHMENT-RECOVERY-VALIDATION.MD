Absolutely. I would give Codex a short **validation-record prompt**, not another implementation prompt. This result deserves to be preserved because it is unusually strong end-to-end evidence.

Work on branch `Ftr.archive-recovery`.

This is a DOCUMENTATION-ONLY task.

No implementation changes are requested.

Record the successful human-controlled end-to-end validation of MessageLens attachment recovery performed after Prompt 55.

Suggested prompt name:

`prompts/56-RECORD-CONTROLLED-LOSS-ATTACHMENT-RECOVERY-VALIDATION.MD`

## Purpose

The MessageLens Historical Archives attachment-recovery path has now been validated against a deliberately damaged disposable development archive using a pre-generated controlled-loss manifest.

This is stronger evidence than an ordinary manual “it seemed to work” test.

The experiment established a known physical loss before MessageLens inspected the archive, then independently verified:

```text
known loss
→ exact preflight detection
→ exact recovery
→ byte-for-byte payload identity
→ zero recoverable on repeat.
```

This result should be recorded in the Feature 26 documentation and referenced from the appropriate canonical attachment-recovery documentation.

## Test environment

The receiving archive was the disposable development/staging MessageLens archive.

The donor was an intact same-lineage MessageLens archive.

Before any files were removed, Prompt 55 generated a controlled-loss manifest containing exactly:

- **7 attachment payload files**
- combined size: **918,067 bytes**
- JPEG/PNG payloads
- canonical attachment identity for each item
- receiving path
- donor path
- expected byte size
- expected SHA-256

Before deletion, all seven receiving payloads were independently confirmed to exist.

The manifest was preserved separately before the controlled loss was created.

No database rows, attachment metadata, donor files, or other archive content were manually modified.

## Controlled loss

With MessageLens fully quit, the human manually removed only the seven payload files named by the manifest from the receiving archive's managed `attachment_archive`.

A guarded shell command mechanically restricted deletion to:

`<receiving MessageLens archive>/attachment_archive/*`

After deletion, all seven paths were independently confirmed absent.

The donor remained untouched.

Thus the test condition was known exactly:

> current MessageLens metadata still described the attachments, but exactly seven physical managed payload files had been removed.

## Preflight result

MessageLens was launched against the disposable receiving archive.

The human opened:

```text
Settings
→ Historical Archives
→ MessageLens
```

and selected the intact donor.

The read-only attachment preflight reported exactly:

- **7 recoverable attachments**
- **918,067 bytes**, displayed in the UI as approximately **896.5 KB**

This exactly matched the controlled-loss manifest.

The existing unrelated diagnostic population remained distinct:

- six ambiguous claims;
- one conflict.

Those records were not incorrectly promoted to recoverable.

The human therefore authorized recovery.

## Recovery presentation

The actual recovery journey appeared through the established stable Historical Archives center Tracks.

Narrator:

**Recovering missing attachments from this MessageLens folder.**

Directed Instrumentation showed real recovery stages including:

- Verifying attachment files
- Recovering attachment files
- Checking that recovery finished

The operation used the real denominator:

`0 / 7`

and real byte denominator:

`0 B / 896.5 KB`

rather than fabricated progress.

## Recovery result

The terminal modal reported:

**Attachment recovery complete**

> MessageLens recovered 7 missing attachments from the folder you selected.

Thus the operation reported exactly the number deliberately removed.

## Independent filesystem verification

After recovery, the seven receiving files were checked outside MessageLens using the preserved manifest.

For every recovered file:

- physical file existed;
- actual byte size equaled `expectedSizeBytes`;
- independently calculated SHA-256 equaled `expectedSha256`.

All seven passed.

This proves that recovery did not merely recreate files at the expected paths.

The recovered payload bytes were byte-for-byte identical to the payload evidence recorded before controlled deletion.

## Idempotency verification

The same intact donor was then selected again through:

```text
Historical Archives
→ MessageLens.
```

MessageLens reported:

**No missing attachments were found.**

Therefore the recovery converged correctly.

The seven restored payloads were recognized as present and were not offered for recovery again.

## What this experiment proves

Record explicitly that this controlled-loss experiment validates the complete product chain:

1. donor qualifies as a supported MessageLens recovery donor;

2. donor passes same-Messages-lineage admission;

3. donor/current message identity correspondence is sufficient;

4. attachment identity matching selects the intended attachments;

5. physical payload absence, rather than metadata existence alone, drives missing-payload classification;

6. preflight identifies the exact deliberately missing set;

7. preflight byte totals are exact;

8. unrelated ambiguous/conflicting evidence is not incorrectly admitted;

9. user authorization invokes the recovery journey;

10. execution-time payload verification succeeds;

11. preservation-safe installation restores the missing payloads;

12. recovery restores exactly the intended files;

13. independently calculated post-recovery sizes and SHA-256 hashes match the pre-loss manifest;

14. donor remains unchanged;

15. rerunning preflight is idempotent and reports zero recoverable.

## Important scope of the evidence

Do not overstate the result.

This test validates the supported product case:

> attachment recovery from an intact, same-lineage MessageLens donor into a deliberately damaged disposable receiving archive.

It does not by itself prove every possible:

- interruption;
- disk failure;
- foreign donor;
- unsupported historical schema;
- metadata corruption;
- ambiguous attachment relationship;
- concurrent filesystem race.

Those remain protected primarily by automated tests and fail-closed architecture.

The manual validation demonstrates that the complete intended happy path works against realistic archive data.

## Relationship to automated verification

Note that Prompt 55 had already passed:

- 101 focused tests;
- 553 broader relevant tests;
- full Flutter suite: 1,949 tests;
- analyzer;
- macOS debug build;
- formatting/diff checks.

The controlled-loss experiment supplements those automated tests with real-format end-to-end evidence.

It does not replace them.

## Architectural significance

Record that the experiment validates the intended layered safety model:

```text
same Messages lineage
→ exact message identity
→ exact attachment relationship
→ physical missing-payload evidence
→ explicit user authorization
→ execution-time donor verification
→ preservation-safe atomic/no-overwrite installation
→ final verification
→ idempotent rescan.
```

No donor message import or graph reconstruction is involved.

The MessageLens donor remains an ephemeral recovery donor rather than a durable historical content source.

## Documentation work

Create the next Feature 26 response/validation record under `responses/`.

Suggested title:

`CONTROLLED-LOSS-MESSAGELENS-ATTACHMENT-RECOVERY-VALIDATION`

Use the next repository-appropriate response number.

Update:

- Feature 26 index;
- documentation pass log;
- canonical MessageLens attachment-recovery documentation;

with a concise reference to this successful controlled-loss validation.

Do not rewrite historical implementation records.

Do not change application version/changelog unless repository rules explicitly require a version bump for documentation-only work.

## Controlled-loss manifest

The original temporary manifest was generated under `/tmp` and a copy was preserved on the human's Desktop during testing.

Do NOT commit the manifest.

It contains machine-specific filesystem paths and was only a manual-test artifact.

Do not add those paths to canonical documentation.

Record only the non-sensitive test facts:

- 7 files;
- 918,067 bytes;
- JPEG/PNG;
- all seven size/hash checks passed.

## No code changes

Do not modify application code.

Do not add tests.

Do not rerun recovery.

Do not modify any archive or attachment.

This task records evidence already obtained.

## Verification

Run documentation/index checks required by repository conventions and:

- `git diff --check`;
- documentation architecture/tripwires if applicable.

Commit and push the documentation changes if clean.

## Report back

Report:

- documentation record created;
- canonical docs updated;
- index/log updated;
- confirmation that the manifest itself was not committed;
- commit hash.

The central validation statement to preserve is:

> In a controlled-loss test, seven known attachment payloads totaling 918,067 bytes were removed from a disposable receiving MessageLens archive. Historical Archives independently identified exactly those seven payloads as recoverable, restored all seven, and each restored file independently matched its pre-loss size and SHA-256. A subsequent scan of the same donor reported zero recoverable attachments.

That gives future Codex agents something very valuable: not merely “the feature has tests,” but **we deliberately broke a realistic archive in a precisely known way and proved that MessageLens put it back exactly.**
