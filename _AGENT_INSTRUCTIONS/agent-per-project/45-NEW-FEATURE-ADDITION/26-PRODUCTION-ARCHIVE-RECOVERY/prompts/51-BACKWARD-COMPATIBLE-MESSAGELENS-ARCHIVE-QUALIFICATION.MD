Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation after a read-first compatibility audit.

The first manual test of the newly enabled MessageLens Historical Archives arm rejected a real archived MessageLens data folder with:

> “This doesn’t appear to be a MessageLens data folder.”

The selected folder visibly contains historical MessageLens data such as:

- `attachment_archive`
- `derived_media`
- `macos_import_ss.db`
- `working_ss.db`
- overlay/user databases
- other MessageLens-owned files

The selected folder level appears correct.

Therefore the next task is to determine **which qualification requirement rejected a genuine older MessageLens archive**, then add the narrowest safe backward-compatible qualification path supported by historical evidence.

Do NOT weaken qualification into filename-based guessing.

Do NOT implement attachment recovery mutation yet.

Do NOT bypass archive identity or same-lineage admission.

Suggested prompt name:

`prompts/51-BACKWARD-COMPATIBLE-MESSAGELENS-ARCHIVE-QUALIFICATION.MD`

## Context

Prompt 50 enabled the MessageLens Historical Archives arm through read-only ready state.

Its qualification pipeline is:

1. structural MessageLens archive qualification;
2. archive marker and compatibility validation;
3. canonical identity from `archiveInstanceId`;
4. shared Messages-lineage admission;
5. attachment evidence matching/preflight.

The first real archived folder was rejected at or before that pipeline completed.

We need to know exactly why.

## First: reproduce the decision path in code

Trace the qualification path for a selected MessageLens folder.

Identify:

- every required marker;
- every required file;
- every required database;
- archive-environment requirements;
- schema/version requirements;
- `archiveInstanceId` expectations;
- any assumptions introduced after the archived folder was created.

Document the exact typed result that produced the current “doesn’t appear to be a MessageLens data folder” modal.

Do not infer from screenshots alone.

## Audit the historical archive generation

Determine what generation/version of MessageLens produced the archived folder used in manual testing.

Use:

- canonical changelog/version history;
- archive marker history;
- database schema history;
- historical Feature/database documentation;
- persisted metadata available in the archived format.

Do not require access to the user’s real folder if fixtures/docs are sufficient.

If read-only inspection of the actual selected archive is needed and repository rules permit it, use only established immutable/read-only mechanisms. Never mutate it.

## Key questions

Answer explicitly:

1. Did this archive generation have the current archive marker?
2. Did it have an `archiveInstanceId`?
3. Where was archive identity stored at that time?
4. Did the canonical app data folder itself serve as identity evidence before explicit archive-instance IDs existed?
5. Which current qualification checks are newer than this archive?
6. Is the archive structurally compatible enough for attachment recovery despite lacking newer metadata?

## Do not conflate three cases

Preserve distinct typed outcomes:

### A. Not a MessageLens data folder

Arbitrary/unrelated folder.

### B. Recognizable historical MessageLens archive, but unsupported/incompatible

The folder is clearly MessageLens-owned but cannot safely be inspected/recovered by the current build.

### C. Recognizable and safely compatible historical MessageLens archive

May proceed to identity reconstruction, lineage admission, and attachment preflight.

The manual folder likely belongs to B or C, not A.

## Backward-compatible qualification principle

A historical MessageLens archive should not be rejected merely because it predates a metadata convention introduced later, provided its identity and compatibility can be established through canonical older evidence.

But:

> backward compatibility must be evidence-based, not heuristic.

Do NOT admit folders merely because they happen to contain:

- `working_ss.db`;
- `macos_import_ss.db`;
- `attachment_archive`;
- familiar filenames.

Those are useful supporting evidence but not sufficient identity authority on their own unless canonical historical docs establish that combination as a format signature.

## Archive identity for legacy folders

Current MessageLens source identity uses:

source kind + `archiveInstanceId`.

If older archives predate `archiveInstanceId`, determine whether a safe legacy identity can be reconstructed.

Possible canonical historical evidence might include:

- earlier environment/archive marker;
- installation/archive UUID stored elsewhere;
- immutable database metadata;
- app-owned archive metadata table;
- another durable identifier.

Do not invent a random hash of path/files as a replacement unless architecture explicitly supports that as legacy compatibility evidence.

If there is no authoritative legacy identity, STOP and report the product limitation rather than weakening D3.

## Identity migration rule

If a legacy archive can be deterministically assigned a stable identity without mutating the donor:

- derive it read-only;
- feed it through the canonical `HistoricalArchiveSourceIdentity` authority;
- store canonical current metadata only in the receiving MessageLens environment if/when needed;
- do not write new markers into the donor.

The donor must remain untouched.

## Same-lineage gate remains mandatory

Backward-compatible MessageLens archive recognition is NOT enough to authorize recovery.

The candidate must still pass the shared:

`MessagesLineageAdmissionService`

before attachment matching.

Do not bypass or weaken:

- ROWID↔GUID proof;
- contradictory lineage rejection;
- insufficient evidence rejection.

A legacy archive may be a valid MessageLens archive and still belong to a different Messages history.

## Donor schema compatibility

Determine whether the archived donor databases can be safely read using current read-only adapters.

Audit:

- required donor tables/columns for attachment matching;
- schema version differences;
- whether current adapters already support this historical version;
- whether narrow compatibility SQL is needed.

Do not migrate the donor in place.

If compatibility requires a read-only version-specific adapter, implement the smallest bounded adapter.

Do not generalize to every historical schema ever produced unless evidence requires it.

## Attachment-recovery scope only

Remember the product scope:

The MessageLens arm is not a general archive importer.

Even if the legacy folder contains:

- messages;
- graph data;
- overlays;
- search data;

the current arm only needs enough donor evidence to:

- prove archive compatibility;
- prove same Messages lineage;
- match attachments;
- locate/validate donor payloads.

Do not expand this task.

## UX correction

Once typed qualification is corrected, ensure human modal copy matches the actual outcome.

### Truly invalid folder

Keep:

**This doesn’t appear to be a MessageLens data folder.**

### Recognizable but unsupported

Use distinct meaning, for example:

**This is a MessageLens data folder, but this version of MessageLens can’t safely read it for attachment recovery.**

### Missing modern marker but successfully recognized through supported legacy evidence

Proceed silently through qualification.

Do not warn the user merely because the archive is old if it is safely supported.

## Diagnostics

Details/logging may record:

- detected historical archive generation;
- legacy qualification route;
- identity evidence source;
- donor schema version;
- compatibility adapter used.

Do not expose raw implementation details in the primary modal.

## Structural qualification contract

After remediation, document the canonical qualification hierarchy.

Conceptually:

selected folder
→ current-format MessageLens archive?
yes → current identity/compatibility path
no →
→ recognized supported legacy MessageLens archive?
yes → canonical legacy identity/compatibility path
no →
→ recognizable but unsupported?
yes → incompatible result
no →
→ notMessageLensFolder

Do not implement this exact branching shape if current typed architecture has a cleaner equivalent.

## Architecture ownership

Keep qualification in the correct archive/domain layer.

Do not put legacy format detection in:

- sidebar widget;
- modal builder;
- attachment matcher;
- file chooser.

Historical Archives orchestrates typed qualification evidence.

## Tests

Add/update focused tests covering:

### Current format

1. current MessageLens archive continues to qualify;
2. current `archiveInstanceId` remains canonical identity evidence.

### Supported legacy format

3. representative older archive fixture is recognized;
4. legacy archive does not require modern marker if canonical old evidence proves identity;
5. stable canonical identity is derived deterministically;
6. donor is not modified;
7. lineage admission still runs afterward;
8. attachment preflight can consume the legacy adapter/evidence.

### Invalid folder

9. arbitrary folder remains rejected;
10. familiar filenames alone do not prove MessageLens identity;
11. a hand-crafted fake folder cannot pass qualification merely by copying names.

### Unsupported legacy archive

12. recognizable but unsupported archive gets distinct typed result;
13. UI uses incompatible-not-invalid modal copy.

### Safety

14. no donor migration;
15. no donor marker creation;
16. no MessageLens message import;
17. no graph import/rebuild;
18. no overlay merge;
19. D1/D2/D3 architecture remains intact;
20. same-lineage gate remains mandatory.

Do not create one test method mechanically per item.

## Real manual target

The archived folder shown in the user’s manual test should become classifiable correctly.

Do not hard-code its name/path.

The fix must derive from archive-format evidence.

Manual expected path after implementation:

MessageLens arm
→ Choose MessageLens Folder…
→ select archived MessageLens data folder
→ structural/legacy qualification succeeds
→ lineage admission runs
→ attachment preflight runs
→ ready/zero-result/lineage result shown truthfully.

## No recovery mutation

`Recover Attachments` remains omitted unless Prompt 50/47 infrastructure already intentionally exposes it later.

Do not enable actual copying in this task.

This is qualification/compatibility only.

## Documentation

Create the next Feature 26 implementation/audit record under `responses/`.

Document:

- exact qualification failure observed;
- historical format generation;
- current versus legacy marker/identity model;
- legacy identity evidence;
- compatibility support;
- donor schema handling;
- final typed qualification outcomes;
- UX modal distinctions;
- safety invariants;
- tests.

Update canonical MessageLens archive qualification documentation so future agents understand supported legacy formats.

Update version/changelog according to repository rules.

## Verification

Run:

- MessageLens qualification tests;
- legacy donor adapter tests;
- lineage tests;
- attachment preflight tests;
- Historical Archives Settings tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Do not mutate real archives.

## Stop conditions

STOP if:

- the archived generation has no trustworthy identity evidence;
- supporting it requires donor mutation;
- supporting it requires schema migration;
- compatibility would weaken lineage admission;
- the only possible recognition method is filename heuristics;
- current attachment adapters cannot safely read required historical evidence.

Report the exact incompatibility rather than punching through qualification.

## Final report

Report:

- exact check that rejected the real archive;
- historical archive generation/format discovered;
- whether `archiveInstanceId` existed;
- final supported legacy qualification evidence;
- identity reconstruction method;
- donor compatibility strategy;
- final invalid vs incompatible distinction;
- tests/tripwires;
- verification;
- commit hash;
- manual retest instructions.

Acceptance standard:

> A genuine older MessageLens archive should be recognized through documented historical evidence even if it predates newer metadata conventions, while arbitrary folders must remain mechanically unable to masquerade as MessageLens archives.
