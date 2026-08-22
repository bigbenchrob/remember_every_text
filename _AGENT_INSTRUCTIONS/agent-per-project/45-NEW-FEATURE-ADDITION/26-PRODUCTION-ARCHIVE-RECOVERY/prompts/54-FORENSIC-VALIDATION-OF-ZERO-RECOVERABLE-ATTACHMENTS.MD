Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for a **forensic, evidence-first investigation** and bounded correction if the zero-result classification is demonstrably wrong.

Do NOT enable actual attachment recovery yet.

Do NOT assume that the current result is either correct or incorrect.

The purpose is to prove it.

Suggested prompt name:

`prompts/54-FORENSIC-VALIDATION-OF-ZERO-RECOVERABLE-ATTACHMENTS.MD`

# Manual finding

Prompt 53 dramatically improved MessageLens attachment preflight.

Manual testing of the real legacy donor now behaves well:

- folder chooser closes;
- center panel appears immediately;
- Narrator explains the operation;
- Directed Instrumentation advances crisply;
- total preflight takes approximately 5–8 seconds rather than several minutes;
- terminal acknowledgement appears.

The final result for the real donor was:

> **No missing attachments were found.**
>
> There are no missing attachments in this folder that MessageLens can safely recover.

This may be correct.

However, recovering missing attachments from older MessageLens data folders is the entire reason this arm exists.

Before enabling mutation, we must prove that `recoverable = 0` reflects actual attachment/payload truth rather than a defect in:

- current payload-presence detection;
- donor payload discovery;
- message/attachment matching;
- canonical destination resolution;
- attachment archive metadata;
- historical path interpretation;
- classification ordering.

# Governing rule

Do not change code merely because zero is surprising.

Instead:

> Select representative donor attachment evidence and trace it end-to-end until we can explain exactly why each representative payload is or is not recoverable.

The desired output is an auditable chain such as:

donor message  
→ original message identity  
→ current message  
→ donor attachment relationship  
→ current attachment relationship  
→ donor payload location/presence  
→ current canonical payload location/presence  
→ final classification.

# Safety

This investigation may inspect the user's real donor/current archive only through established read-only mechanisms and only if repository/project rules permit it.

Do NOT mutate:

- donor MessageLens folder;
- production/current MessageLens data;
- live `chat.db`;
- attachment payloads;
- archive markers;
- databases.

Do not run actual recovery.

If macOS permissions prevent direct forensic access, build/run an in-app read-only diagnostic through the existing authorized application access path rather than bypassing TCC.

Do not request Full Disk Access for arbitrary tooling merely to make investigation convenient.

# Part 1 — define exactly what “missing” currently means

Trace the current preflight implementation.

Document the exact predicate that causes a current attachment to be classified as:

- payload present;
- payload missing;
- conflict;
- donor missing;
- mismatch;
- ambiguous;
- unsafe.

Identify which evidence is consulted.

In particular, determine whether “current payload present” means:

A. database metadata says a payload path exists;

B. canonical destination path can be derived;

C. a regular file actually exists at the canonical current path;

D. file exists and expected size agrees;

E. another definition.

This distinction is critical.

# Part 2 — prove the current-side payload-presence adapter

The manual instrumentation examined approximately:

`32,067`

current attachment files/claims.

Audit the current-side evidence adapter.

For representative records, trace:

current attachment database row  
→ attachment identity  
→ stored/current location metadata  
→ canonical current attachment archive path  
→ filesystem probe  
→ actual regular-file presence  
→ size if relevant.

Ensure the adapter is not confusing:

- attachment metadata exists

with:

- attachment payload exists.

Also ensure it is not looking at:

- original Apple Messages attachment path;
- stale historical path;
- donor path;
- derived-media path;

when it should be checking MessageLens-managed attachment storage.

# Part 3 — prove donor payload discovery

For representative donor attachments:

donor attachment row  
→ donor attachment relationship  
→ donor MessageLens archive-relative payload evidence  
→ safe contained path  
→ actual donor regular file exists  
→ file size.

Confirm the optimized Prompt 53 preflight did not accidentally move a necessary **presence** check to execution time.

Prompt 53 intentionally moved full SHA-256 verification out of preflight.

That is fine.

But preflight must still know whether the donor payload actually exists.

# Part 4 — exact aggregate classification counts

Expose/derive the full classification distribution for the real preflight.

We currently know:

`recoverable = 0`

That alone is insufficient diagnostically.

Determine exact counts for all existing typed classifications, such as:

- already present;
- donor missing;
- message mismatch;
- attachment mismatch;
- conflict;
- ambiguous;
- unsafe donor path;
- recoverable.

Use the actual enum names.

Also report:

- total donor attachment claims;
- total current attachment claims;
- total successfully message-matched claims;
- total successfully attachment-matched claims;
- total donor payloads physically present;
- total current payloads physically present;
- any claims excluded before final classification.

The counts must reconcile.

Add an invariant where appropriate:

> every inspected candidate belongs to exactly one terminal classification.

Do not hide unmatched records by dropping them from the denominator.

# Part 5 — identify where zero arises

The critical question is:

At which boundary does the potential recovery population disappear?

For example:

32,067 donor/current relationships  
→ 31,900 message matches  
→ 31,850 attachment matches  
→ 20,000 donor payloads present  
→ 20,000 current payloads present  
→ 0 recoverable

would strongly support the zero result.

Whereas:

32,067 relationships  
→ 31,850 attachment matches  
→ 12,000 donor payloads present  
→ **0 current payloads classified missing because metadata path exists**

would strongly suggest a bug.

Produce a funnel.

# Part 6 — representative forensic samples

Select deterministic representative samples from important classes.

At minimum inspect examples from:

## A. `alreadyPresent`

For several records prove:

- donor payload exists;
- current canonical payload exists;
- identities match;
- therefore recovery is unnecessary.

## B. `donorMissing`

If nonzero, prove donor metadata exists but donor file does not.

## C. mismatch/conflict

If nonzero, trace why.

## D. records suspected by the user to have lost attachments

If there is existing application evidence for missing attachments, compare those specifically.

Do not ask the user to identify individual attachments unless current evidence cannot locate any candidate missing payloads.

# Part 7 — compare physical archive populations

Perform a read-only inventory of attachment payload storage on both sides where safe.

Determine:

- donor managed attachment file count;
- current managed attachment file count;
- donor total payload bytes;
- current total payload bytes;
- intersection by canonical attachment identity where possible;
- donor-only payload identities;
- current-only payload identities.

Do NOT infer recovery merely from filename equality.

Identity remains authoritative.

But population-level comparison can tell us whether the donor actually contains files absent from current storage.

If:

donor-only valid matched payload identities = 0

then zero recoverable is strongly supported.

If donor-only matched identities are numerous but recoverable remains zero, investigate classification.

# Part 8 — original Apple path versus MessageLens archive path

Historical attachment systems often retain multiple location concepts.

Audit carefully whether donor/current records contain:

- original Messages attachment path;
- archived MessageLens path;
- relative managed path;
- overlay replacement path;
- derived-media path.

Ensure current payload presence is checking the path that represents **MessageLens's recoverable managed payload**, not merely evidence that the attachment once existed in Apple Messages.

# Part 9 — overlay metadata

Response 47 concluded recovery requires filesystem plus overlay metadata mutation.

Audit current overlay evidence.

Could current overlay metadata contain a location pointing to a file that has since been deleted?

If so:

overlay row exists

must not imply:

payload exists.

The filesystem must remain authoritative for physical presence.

Determine how stale overlay locations are handled.

# Part 10 — current archive may already contain the supposedly lost payloads

Do not discount the simplest possibility.

The user remembers attachments being lost during an earlier MessageLens data transition, but subsequent development/migration/reimport work may already have restored or preserved them.

If the current archive physically contains all matching donor payloads, document that clearly.

The feature can still be useful for other historical snapshots even if this donor currently has nothing to recover.

# Part 11 — donor may not contain the expected payloads

Likewise verify that the selected historical archive actually contains attachment payloads.

A historical `attachment_archive` directory may be:

- incomplete;
- metadata-only;
- created after/before some attachment archival feature;
- missing files because of earlier development behavior.

If donor payloads are absent, zero recoverable may also be correct.

# Part 12 — optimized preflight regression audit

Prompt 53 changed several important things:

- database work moved to worker isolates;
- O(N) indexed matching;
- repeated probes removed;
- SHA-256 moved to execution boundary;
- progress batching added.

Audit whether any optimization changed semantics.

Compare optimized preflight results against the pre-Prompt-53 matcher on a manageable fixture.

For the same fixture, classification counts must be identical except for intentionally deferred execution-time hash verification.

Add parity tests.

# Part 13 — query/path counting

Instrument enough to prove:

- each donor/current evidence set is loaded once;
- filesystem probes correspond to intended candidates;
- no candidate is silently skipped because of adapter batching;
- no integer/source-scope conversion overflow/truncation;
- no worker-isolate serialization loses attachment identity fields.

# Part 14 — source-scoped attachment IDs

Reconfirm on real/representative evidence:

scoped attachment ID  
→ original attachment ROWID

and:

scoped message ID  
→ original message ROWID.

Verify that matching uses the **original** ROWID relationship rather than comparing source-scoped IDs across different source scopes.

This is a particularly important potential zero-result cause.

# Part 15 — source provenance

The donor MessageLens archive may contain records from more than one internal source scope.

Our product deliberately treats the donor as unsplittable for recovery, but matching must still correctly unscope each donor record using its actual source scope.

Audit that:

- donor scoped message/attachment IDs are decoded correctly;
- original ROWIDs are recovered correctly;
- no assumption that all donor records share one source ID causes mismatch.

Do not reopen B/B1/B2/B3 durable provenance design.

This is only about correct reversible ID decoding.

# Part 16 — lineage gate versus attachment subset

Same-Messages-lineage admission proves the donor belongs to the same continuing `chat.db` lineage.

It does not prove every donor attachment is represented in current MessageLens.

That is fine.

Ensure preflight does not accidentally restrict matching only to the anchors used for lineage proof.

# Part 17 — Details diagnostic improvement

Regardless of whether zero is correct, the current terminal modal:

> No missing attachments were found.

is too opaque for development/debugging.

Do not necessarily expose diagnostics to normal users.

But ensure Details/logging/test diagnostics can report the classification funnel.

For a normal user, if zero is correct, the simple modal remains appropriate.

For development builds, existing diagnostic facilities may expose more.

Do not turn the user modal into a database report.

# Part 18 — if zero is correct

If forensic evidence proves zero recoverable:

do NOT change matching semantics to manufacture candidates.

Document:

- donor payload population;
- current payload population;
- matched intersection;
- why every donor payload is already present or otherwise unrecoverable.

Then leave product behavior unchanged except any diagnostic/test improvements.

# Part 19 — if zero is wrong

If a concrete bug is found, fix the narrowest authority.

Possible classes include:

- stale metadata mistaken for file presence;
- wrong current canonical path;
- donor path misresolution;
- source-scoped ID comparison error;
- adapter dropped fields;
- optimized matcher semantic regression;
- incorrect classification precedence.

Do not add heuristic fallback matching.

After correction, every new recoverable candidate must still satisfy the full established identity proof.

# Part 20 — ready-state consequence

If the real donor yields recoverable attachments after a justified fix:

the existing ready state should display:

- exact recoverable attachment count;
- exact recoverable bytes.

Do NOT wire actual recovery yet.

If zero remains correct, preserve the calm zero-result modal.

# Tests

Add/update the smallest clear focused set covering:

1. attachment metadata alone cannot prove payload presence;

2. current canonical file must physically exist for `alreadyPresent`;

3. stale overlay path with missing file becomes missing/recoverable if donor proof succeeds;

4. donor metadata without physical donor file becomes donorMissing;

5. donor/current path fields do not substitute for identity;

6. source-scoped IDs unscope before matching;

7. multiple donor source scopes decode correctly;

8. optimized and reference matcher classifications agree on fixtures;

9. every inspected candidate reaches exactly one terminal classification;

10. classification totals reconcile;

11. donor-only matched payload becomes recoverable;

12. physically present current matched payload becomes alreadyPresent;

13. conflict remains conflict;

14. zero recoverable is produced when all valid donor payloads are already present;

15. no recovery mutation occurs.

# Architecture tripwires

Protect:

- filesystem truth for payload presence;
- canonical attachment identity;
- canonical source-scoping decode;
- same-lineage requirement;
- no filename/path heuristic matching;
- no mutation during preflight;
- optimized/reference classification parity.

# Performance

Do not regress Prompt 53.

The forensic fix must not casually restore:

- exhaustive hashing;
- N² matching;
- repeated queries;
- multi-minute preflight.

Run representative performance checks after any correction.

The user has manually validated approximately five-second behavior.

Preserve that order of magnitude where possible.

# Safety

No attachment copying.

No database mutation.

No donor mutation.

No live chat.db mutation.

No overlay mutation.

Read-only forensic inspection only.

# Documentation

Create the next Feature 26 forensic record under `responses/`.

Document:

- zero-result question;
- exact classification funnel;
- representative traces;
- donor/current physical population comparison;
- payload-presence authority;
- source-scoping audit;
- optimized matcher parity;
- whether zero was correct;
- bug/fix if not;
- final performance.

Update canonical attachment recovery documentation only if an authority rule changes.

# Verification

Run:

- attachment matcher tests;
- evidence-adapter tests;
- source-scoping tests;
- lineage tests;
- MessageLens preflight tests;
- Settings regressions;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if code changes.

Commit and push if clean.

# Stop conditions

STOP if:

- proving the real zero result requires mutating data;
- matching identity is fundamentally ambiguous;
- the donor/current attachment schemas lack enough evidence;
- a fix would require heuristic filename matching;
- a fix would weaken lineage or per-attachment proof.

# Final report

Report:

- exact definition of current payload presence;
- complete classification funnel;
- donor/current physical payload counts and bytes where available;
- representative alreadyPresent/donorMissing/mismatch traces;
- whether source-scoping contributed to the result;
- whether Prompt 53 optimization changed semantics;
- whether zero was correct;
- if wrong, exact bug and correction;
- post-fix recoverable count/bytes if applicable;
- preflight performance;
- tests/tripwires;
- commit hash;
- manual retest instructions.

Acceptance standard:

> Before MessageLens is allowed to recover a single attachment, we must be able to explain exactly why the real historical donor produces zero recoverable payloads—or identify and correct the precise false-negative mechanism without weakening any identity or safety proof.
