# Production Candidate And Adoption Rehearsal

Date: 2026-07-27

Result: Preparation passed; real production cutover not authorized

Revision at preparation start:
`4e1d407e427003984285d42fad7188e827d5cb7d`

No production application was installed or launched. The real production
archive was not marked, adopted, restored, or mutated.

Later preparation supersedes this record's requirement for a second full
offline checkpoint. The verified existing recovery backup and read-only
in-place adoption inventory are recorded in
[`final-cutover-preparation-2026-07-28.md`](final-cutover-preparation-2026-07-28.md).
The disposable checkpoint rehearsal below remains valid recovery evidence.

## Current Operational State

- Debug/Run uses the development bundle identity and external development
  archive.
- No MessageLens process currently preserves newly arriving production data.
- Production preservation remains interrupted until authorized adoption.
- The months-old installed application is not treated as authority or fallback.

## Signed Candidate

Path:

```text
build/production-candidate/MessageLens.app
```

Built with:

```text
./tool/build_and_notarize.sh --candidate-only
```

Verified facts:

- bundle identifier: `com.bigbenchsoftware.MessageLens`;
- archive environment: `production`;
- build identity: `productionRelease`;
- product/display identity: `MessageLens`;
- signing team: `FQHT2QP3NE`;
- expected Developer ID identity:
  `Developer ID Application: Robert Campbell (FQHT2QP3NE)`;
- CDHash: `fcb56d3213c0d523b7892a7cc16e9a92a129abc1`;
- executable SHA-256:
  `26b25b0be3ac652e455a2472298e74f19c904572b02c922d07218d43676883b0`;
- canonical production-root contract:
  `~/Library/Application Support/com.bigbenchsoftware.MessageLens`;
- development-root metadata absent;
- production entitlements accepted by the verifier;
- stable bundle identifier and signing team preserve the expected macOS Full
  Disk Access identity.

Candidate-only mode intentionally performed no DMG creation, notarization,
stapling, tester-portal publication, installation, or launch. The final cutover
artifact must still use the normal notarized distribution path.

## Disposable Adoption Lifecycle

Representative source:

```text
build/production-adoption-rehearsal/20260727T232059Z/source
```

Retained work/evidence:

```text
build/production-adoption-rehearsal/20260727T232059Z/work
```

Checkpoint ID:

```text
7ccea480-0df7-42bd-a8eb-4dae07eb56f0-1785194628719825
```

The rehearsal proved:

1. checkpoint preparation for an offline unmarked archive;
2. verified restore into a separate root;
3. atomic marker adoption from the checkpoint plan;
4. production admission of the adopted disposable root;
5. unchanged-payload marker rollback;
6. source archive remained unmarked.

Source and restored payload hashes matched:

```text
working_ss.db
92f6bd176508830db52ba0515144fe4173860602d566738472a77eff78841aea

attachment_archive/rehearsal.bin
172cd7ff87a51e215fa9ecab5289ea4f21596e7e281f17aaf78aa23f276973ef
```

## Preservation-Path Integration Rehearsal

The focused integration rehearsal used file-backed disposable archive
databases and the production archive authority model to prove:

- initial import through the real `MessageImporter`;
- source advance and catch-up import;
- graph attachment discovery for the catch-up message;
- attachment preservation through the real `AttachmentArchiveService`;
- retention of the pre-existing attachment payload;
- refusal to roll back marker adoption after production-like payload mutation.

This validates the handoff mechanics without claiming runtime behavior against
the real Apple source or production archive.

## Regression Verification

Focused production-protection, importer, monitor, attachment, and artifact
verification:

```text
68 tests passed
```

Architecture tripwires:

```text
352 tests passed
```

Full Flutter regression suite:

```text
1,442 tests passed
```

Static analysis:

```text
flutter analyze
No issues found
```

The first focused run exposed one stale synthetic Info.plist fixture: the
hardened artifact verifier now requires the expected signing-identity contract.
The fixture was updated, and the complete focused command then passed.

## Remaining Limits

- the candidate has not been notarized or stapled;
- the candidate has not been launched;
- real Full Disk Access behavior has not been exercised by this candidate;
- at this stage, final backup and adoption evidence had not yet been verified;
- real startup catch-up and attachment preservation remain unverified;
- production preservation remains interrupted;
- cutover requires explicit authorization.
