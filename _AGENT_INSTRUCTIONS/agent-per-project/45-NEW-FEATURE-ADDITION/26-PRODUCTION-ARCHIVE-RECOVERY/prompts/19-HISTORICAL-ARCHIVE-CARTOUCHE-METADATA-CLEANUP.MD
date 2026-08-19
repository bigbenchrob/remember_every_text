Work on branch Ftr.archive-recovery.

This is a very small Historical Archives sidebar metadata cleanup.

Suggested prompt name:

prompts/19-HISTORICAL-ARCHIVE-CARTOUCHE-METADATA-CLEANUP.MD

Read the current Feature 26 implementation records and the Historical Archives known-source/cartouche read model.

Do not proceed into the valid new-folder import journey yet.

MANUAL REVIEW FINDING

The Folders Already Added cartouche now has the right semantic role, but some of its persistent metadata is workflow archaeology rather than useful object information.

Current examples include:

Last dry run: new 0 | duplicates 8882

and:

Last imported: not yet imported

These are inappropriate for a cartouche under Folders Already Added.

The first is irrelevant to the ordinary user.

The second is actively confusing because the archive is visibly classified as already added/imported.

GOAL

Make each Folders Already Added cartouche present only durable, human-meaningful archive identity and history.

TARGET CONTENT

Representative cartouche:

Messages_2012-IMPORT_SOURCE

Date range: Jul 2012 – Jun 2017
Messages: 8,882
Imported on: Aug 16, 2026

Use the repository’s normal human-readable date formatting conventions.

Do not hard-code this source, date range, count, or import date.

REMOVE LAST DRY RUN FROM PRIMARY CARTOUCHE

Do not show:

Last dry run: ...

in the ordinary sidebar cartouche.

Dry-run comparison is temporary workflow evidence used when deciding whether to import a source.

It is not an enduring property of an already-added archive.

If that information remains useful for diagnostics, preserve it in the appropriate Details/diagnostic surface or persisted metadata. Do not delete useful durable evidence merely because it leaves the cartouche.

IMPORTED-ON DATE

Replace:

Last imported: not yet imported

with a truthful:

Imported on: [date]

First establish the authoritative existing durable source for successful import completion.

Trace the current Historical Archives persisted metadata/import records and identify which timestamp genuinely means:

“This archive was successfully added to MessageLens on this date.”

Do not infer this from:

- file modification time;
- last preflight time;
- dry-run time;
- source registration time;
- application-log time;
- current database modification time.

Use an existing successful-import completion timestamp only if its semantics are trustworthy.

If the current stored data does not contain a trustworthy successful-import date for some previously imported source:

- omit the Imported on line for that source;
- do NOT display “not yet imported”;
- do NOT fabricate a date.

The semantic contract is:

A cartouche appears under Folders Already Added only because current imported source-scoped data proves it is added.

Therefore the cartouche must never contradict that truth with “not yet imported.”

DATE FORMATTING

The sidebar should present a calm human date, not an exact operational timestamp.

Prefer the existing MessageLens date-formatting conventions.

For example:

Imported on: Aug 16, 2026

rather than:

2026-08-16T21:39:53.123456Z

Exact timestamps may remain in Details/diagnostics if already available and useful.

CARTOUCHE RESPONSIBILITY

The cartouche should answer:

What archive is this?
What historical period does it cover?
How large is it?
When was it added?

It should not become a miniature workflow/activity log.

Primary cartouche facts should therefore remain limited and stable.

Do not add:

- last preflight;
- last dry run;
- duplicate count;
- execution status;
- mutation owner;
- source registration status;
- graph projection counts;
- diagnostic timestamps.

TRUTHFUL FALLBACK

For every displayed field:

- show a value only when the underlying durable fact genuinely supports it;
- omission is preferable to misleading fallback prose.

In particular:

missing trustworthy imported-on date
-> omit Imported on

never:
-> Imported on: unknown
-> Last imported: not yet imported

unless product requirements elsewhere explicitly establish such wording.

TESTS

Add focused tests proving:

1. Folders Already Added cartouches do not show Last dry run;

2. imported sources do not show “Last imported: not yet imported”;

3. when a trustworthy successful-import timestamp exists, the cartouche shows Imported on with a human-readable date;

4. the displayed date comes from the authoritative successful-import completion fact;

5. preflight/dry-run/registration timestamps cannot masquerade as imported-on;

6. when no trustworthy imported-on timestamp exists, the line is omitted;

7. date range and message count remain visible;

8. existing cartouche selection, blue state, orange correspondence, and navigation behavior are unchanged;

9. sidebar membership semantics remain Folders Already Added = positive imported source-scoped data;

10. no persistence format, source identity, import/removal, mutation-authority, or database semantics change.

SCOPE / NON-GOALS

Do not:

- redesign cartouche layout broadly;
- redesign valid folder inspection;
- redesign import running/completion;
- redesign removal;
- change source registry semantics;
- add a new timestamp column/schema merely for this cleanup;
- change DateConverter;
- change mutation authority;
- perform any GUI archive mutation.

If a trustworthy successful-import timestamp does not currently exist, STOP before proposing a schema change. Omit the line and report that limitation.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- the cartouche’s human semantic responsibility;
- removal of dry-run workflow history from primary presentation;
- authoritative source used for Imported on;
- fallback behavior when that fact is unavailable.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives sidebar/read-model tests, Settings tests as appropriate, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this cleanup.

Report:

- exact durable timestamp chosen for Imported on;
- why its semantics are trustworthy;
- fallback behavior when unavailable;
- confirmation that Last dry run and contradictory not-yet-imported wording are gone;
- manual review instructions.
