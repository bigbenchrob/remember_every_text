Work on branch `Ftr.archive-recovery`.

This is a READ-ONLY architecture and product-design audit.

Do NOT implement the MessageLens Historical Archives arm yet.

Do NOT enable the currently disabled `MessageLens` segment.

Do NOT modify databases, source folders, staging data, production data, schemas, or application code.

Documentation/audit files may be created or updated according to repository conventions.

## Context

The **Mac Messages** arm of Settings → Historical Archives has now undergone extensive implementation, manual validation, UX refinement, and architecture hardening.

The architecture-conformance audit identified four deferred findings.

Three have now been resolved:

- D1 — Historical Archives presentation state is now a sealed typed model rather than a combinatorial set of independently nullable fields.
- D2 — Historical Archives now has one stable center-column Track A–I skeleton across presentation states.
- D3 — `HistoricalArchiveSourceIdentity` is now the sole historical-source identity authority, including offline reconstruction.

D4 — writable generated APIs for frozen legacy Drift tables — remains deliberately deferred and is not part of this task.

Codex concluded after D3:

> The Mac Messages arm is now a sound structural basis for the future MessageLens arm, provided that arm defines its own source-kind identity evidence rather than reusing the Mac Messages path rule.

We are now ready to investigate that second arm.

## Product concept

Historical Archives is the umbrella feature.

The sidebar already presents:

`Mac Messages | MessageLens`

The MessageLens segment is currently disabled.

The intended conceptual distinction is:

### Mac Messages

Historical material originating from a macOS Messages folder containing `chat.db`.

### MessageLens

Historical material originating from a preserved/recovered **MessageLens data folder**.

The expectation is that both arms will share much of the same human interaction grammar:

- folders already added;
- choose/add a folder;
- qualify it;
- inspect it;
- explain what was found;
- request authorization for consequential ingestion;
- Narrator + Directed Instrumentation during real work;
- terminal acknowledgement;
- durable cartouche;
- select/manage/remove an existing source.

But we must NOT assume the underlying source semantics are identical.

## Governing rule

Do not copy the Mac Messages implementation mechanically.

First determine:

> What is genuinely Historical-Archives-wide behavior?

versus:

> What exists only because a Mac Messages source is a `chat.db` plus optional attachment material?

Reuse should be earned from evidence.

## First: audit the MessageLens data-folder format

Trace the canonical MessageLens archive/data-folder architecture.

Determine exactly what constitutes a preserved MessageLens data folder.

Document:

- required archive marker(s);
- archive instance identity;
- environment marker semantics;
- database files;
- source-scoped import ledger;
- working/graph database;
- overlay database;
- search/support databases;
- attachment archive/storage;
- any Presence database;
- schema/version information;
- optional versus required components;
- retained backups/sidecars;
- environment-specific files.

Use canonical project/database documentation and current implementation.

Do not infer from the one staging clone alone.

## Qualification question

Define:

> What evidence proves that a selected folder is a MessageLens data folder that this build can inspect safely?

This should become the future equivalent of the Mac Messages `chat.db` qualification boundary.

Identify deterministic pre-context failures such as, where applicable:

- no MessageLens archive marker;
- missing required databases;
- invalid marker;
- incompatible environment;
- unsupported archive version;
- structurally incomplete archive;
- corrupt SQLite database;
- another condition.

Do NOT implement these yet.

Classify them conceptually into:

### A. Does not qualify as a MessageLens data folder

Likely future behavior:

modal
→ hub

### B. Recognized MessageLens archive but cannot currently be safely ingested

Likely future behavior may require a richer inspection/failure presentation.

Do not collapse these categories prematurely.

## Source identity

D3 deliberately established:

`HistoricalArchiveSourceIdentity`

as the sole historical-source identity authority.

Mac Messages identity evidence remains:

source kind + normalized absolute `chat.db` path.

Do NOT reuse that evidence blindly for MessageLens sources.

Determine what canonical evidence should identify a MessageLens data-folder source.

Investigate candidates such as:

- archive instance ID;
- normalized archive root;
- marker identity;
- source kind + archive instance ID;
- another durable MessageLens-owned identifier.

Consider offline reconstruction.

The source may later be:

- disconnected;
- moved;
- renamed;
- unavailable.

We need to identify an already-added MessageLens historical source without requiring the original folder to remain mounted.

Do not change `HistoricalArchiveSourceIdentity` in this audit.

Return a recommendation for the source-kind-specific identity evidence that should eventually feed it.

## Critical identity question: copies

A preserved MessageLens data folder may be copied byte-for-byte to another disk/path.

Determine desired/current semantics:

> Is that the same historical source because its MessageLens archive instance identity is the same?

or:

> Is each physical/path copy treated as a distinct source?

Do not guess.

Use current archive-instance semantics and canonical documentation.

If this requires a product decision rather than an architectural deduction, flag it explicitly.

## What data would ingestion actually add?

This is the most important technical question.

A MessageLens data folder may already contain:

- imported source facts;
- conversation graph data;
- search/support structures;
- overlays;
- attachment archive;
- source metadata.

Determine what should be considered authoritative historical material for ingestion into the current MessageLens archive.

Do NOT assume we should copy the old working graph wholesale.

Identify:

- durable source facts worth preserving;
- derived data that should be regenerated;
- user-owned overlay facts that may require separate merge semantics;
- attachment payloads;
- source provenance;
- metadata/history that should or should not survive ingestion.

Apply existing database ownership rules.

## Derived versus authoritative data

Classify every major database/table/folder in a preserved MessageLens archive as:

### Authoritative/importable source material

Potentially merged into current archive.

### Derived/rebuildable

Should NOT be copied as truth; regenerate from imported facts.

### User overlay/personal metadata

Requires explicit merge semantics.

### Diagnostic/operational

Should not become imported historical content.

### Unknown / needs design decision

Be explicit.

## Source provenance

A preserved MessageLens archive may itself contain multiple source-scoped origins.

For example, it might contain:

- current-Mac source facts;
- previously imported historical Messages sources;
- recovered data.

Determine whether MessageLens-folder ingestion should preserve those original source identities/provenance or flatten the entire donor MessageLens archive into one new historical source.

This is a major architectural decision.

Use existing source-scoped import principles.

Do not implement until the correct semantics are explicit.

## Duplicate semantics

Determine how overlap should be measured between:

- current MessageLens archive;
- donor MessageLens archive.

Mac Messages currently uses GUID-compatible comparison for human-facing overlap while retaining source provenance.

For MessageLens-to-MessageLens ingestion, investigate whether:

- message GUID remains the appropriate human comparison identity;
- source occurrence identity matters;
- donor source provenance changes duplicate semantics;
- attachment identity requires separate handling;
- overlay facts have their own merge identities.

Return a concrete recommendation.

## Attachments

Unlike the first Mac Messages ingestion exercise, MessageLens data folders may already contain MessageLens-managed attachment payload archives.

Audit:

- where those payloads live;
- how they are addressed;
- whether imported messages refer to them by stable identity;
- whether payloads can be safely copied/merged;
- collision semantics;
- deduplication semantics;
- missing-payload behavior;
- whether current attachment archive ownership already provides a merge API.

Do not implement payload copying in this audit.

Determine what a truthful future ingestion journey would need to report.

## Overlays

Audit user overlay data such as, where applicable:

- nicknames;
- favourites;
- display-name overrides;
- tags;
- notes;
- suppression;
- other user-created metadata.

A recovered MessageLens archive may contain valuable user-authored overlay state.

Determine:

- whether Historical Archives should ingest it;
- whether it belongs in this same journey;
- conflict semantics;
- current-vs-donor precedence;
- whether some overlay types should be opt-in.

If this is unresolved product territory, identify it rather than inventing merge rules.

## Archive marker/environment

Audit the archive marker semantics carefully.

A preserved MessageLens folder may be marked:

- production;
- development;
- another environment.

Determine:

- what marker facts prove identity;
- what marker facts govern whether it may be used as an ingestion source;
- whether source ingestion should require reclassification;
- whether the donor marker must remain untouched;
- whether archive-instance IDs must remain immutable.

Historical ingestion should never require mutating the donor merely to inspect it.

## Database compatibility

Determine how a current build should inspect an older MessageLens archive.

Audit:

- schema versions;
- migration assumptions;
- whether opening an old database through current Drift code would mutate/migrate it;
- immutable/read-only inspection options;
- compatibility adapters;
- whether a donor must first be copied into a disposable staging representation.

The donor must not be silently migrated merely because the current application opened it.

## Source safety

Define hard future invariants.

At minimum consider:

- donor MessageLens folder remains unchanged;
- donor databases are never migrated in place;
- donor archive marker remains unchanged;
- donor attachments remain unchanged;
- current production archive is modified only under admitted mutation authority;
- partial ingestion cannot destroy current source data.

## Mutation authority

Map the likely future MessageLens-folder ingestion operation onto `ArchiveMutationCoordinator`.

Determine:

- operation type needed;
- protected resources;
- graph access;
- attachment archive access;
- overlay access;
- checkpoint requirements;
- rollback/recovery concerns.

Do not add a new operation enum in this audit.

## Narrator + Directed Instrumentation

Identify likely **real execution boundaries**, not invented UX stages.

For example, investigate whether a future operation would naturally contain real phases such as:

- inspecting donor archive;
- comparing histories;
- importing source facts;
- copying attachment payloads;
- merging overlays;
- rebuilding combined MessageLens history;
- final verification.

These are examples only.

Return the actual likely boundaries from architecture.

For each, identify whether real progress telemetry exists or could exist truthfully.

## Ready-state evidence

Design what the human should know before authorizing ingestion.

Do not overload the user.

Potentially useful facts may include:

- archive date range;
- total messages;
- messages not currently represented;
- attachment payload count/size;
- number of original source archives represented;
- overlay/user metadata present;
- archive version;
- import date/history.

Determine which are genuinely useful primary facts versus Details diagnostics.

## Existing-source cartouche

Recommend what a MessageLens-folder cartouche under:

Folders Already Added

should show.

Aim for parity of information hierarchy with Mac Messages, not forced identical fields.

For example:

- human source label;
- date range;
- message count;
- added date when trustworthy.

Determine what identity/display label is appropriate.

Do not use archive-instance UUID as primary human copy.

## Selected existing source

Recommend what center-panel story should appear when the user selects an already-added MessageLens archive.

Apply the established rule:

Sidebar owns identity.

Center owns meaning and management.

Do not repeat the cartouche name merely to satisfy a header contract.

## Removal semantics

Determine what:

`Remove this folder…`

would mean for a MessageLens historical source.

If donor provenance includes multiple original sources, removal must be well defined.

Determine:

- which imported facts are removed;
- whether copied attachments are removed when unreferenced;
- whether imported overlay data is removed;
- whether graph is rebuilt;
- whether source registry identity remains for deterministic reimport.

Do not implement.

## Shared versus source-specific architecture

Produce a clear table:

| Concern | Historical Archives shared | Mac Messages specific | MessageLens specific |
| ------- | -------------------------- | --------------------- | -------------------- |

At minimum include:

- sidebar arm;
- typed presentation state;
- Tracks;
- modal grammar;
- Narrator;
- Directed Instrumentation;
- session guards;
- source identity authority;
- qualification;
- inspection evidence;
- duplicate comparison;
- import service;
- attachment handling;
- overlay handling;
- removal;
- success semantics.

This table should drive future implementation boundaries.

## Reuse audit

Identify which current Mac Messages classes/components should be:

### Reused unchanged

because they are genuinely Historical-Archives-wide.

### Generalized narrowly

because the abstraction has now been earned by two concrete source types.

### Left Mac-Messages-specific

because semantics differ.

### Never reused

because doing so would couple MessageLens ingestion to `chat.db` assumptions.

Do not generalize anything yet.

## State model

Determine whether the 13 sealed Historical Archives presentation variants can represent the MessageLens arm without source-specific leakage.

Do not change them.

Report:

- variants reusable unchanged;
- variant payloads currently Mac-Messages-specific;
- any new variants genuinely required;
- any places where source-specific typed evidence should sit behind a shared interface/union.

## Tracks

Determine whether the stable A–I skeleton works unchanged.

Expected answer is likely yes, but verify.

Do not change Tracks.

## Sidebar segmented control

Design the eventual enabled behavior of:

`Mac Messages | MessageLens`

Determine:

- whether each arm maintains independent transient presentation state;
- what happens when switching arms mid-candidate;
- whether switching is allowed during admitted mutation;
- how cartouche lists are scoped;
- navigation reset behavior.

Do not enable the control.

## D4

D4 remains explicitly out of scope:

> Frozen legacy Drift tables remain writable through generated APIs.

Do not solve it here.

If MessageLens-folder ingestion would be unsafe because of D4, explain precisely why.

## Post-D1/D2/D3 conformance check

As part of this audit, perform a short read-only confirmation that:

- no old combinatorial state compatibility path reappeared;
- no state-dependent Track boundary reappeared;
- no alternative historical source-key construction reappeared.

Do not launch another repository-wide remediation unless you find a clear regression.

## Deliverable

Create the next Feature 26 design/audit record under `responses/`.

The document should contain:

1. MessageLens data-folder anatomy;
2. qualification contract;
3. identity recommendation;
4. authoritative-versus-derived data classification;
5. provenance strategy;
6. duplicate semantics;
7. attachment strategy;
8. overlay strategy;
9. compatibility/read-only inspection strategy;
10. mutation-authority requirements;
11. likely truthful execution stages;
12. ready-state evidence;
13. cartouche/selected-source/removal semantics;
14. shared-vs-specific architecture table;
15. reuse recommendations;
16. state-model compatibility;
17. Track compatibility;
18. segmented-control behavior recommendation;
19. unresolved product decisions;
20. implementation slices in recommended order;
21. hard invariants;
22. risks/blockers.

Update Feature 26 indexes/documentation log as appropriate.

Do not bump application version for a documentation-only audit unless repository rules explicitly require it.

## No implementation

Do not:

- enable MessageLens segment;
- add chooser behavior;
- add new repositories;
- add schemas;
- add source kinds;
- alter `HistoricalArchiveSourceIdentity`;
- mutate archive markers;
- copy donor databases;
- copy attachments;
- merge overlays;
- run import/removal;
- alter production/staging data.

This task should leave application behavior unchanged.

## Verification

Run documentation checks required by repository conventions, including at minimum:

- `git diff --check`;
- any architecture/doc tripwires affected by documentation changes.

No GUI operation is required.

Commit and push documentation if repository rules call for it.

## Final report

Return:

- exact donor MessageLens folder anatomy;
- recommended qualification evidence;
- recommended source identity evidence;
- authoritative versus derived data;
- provenance strategy;
- attachment strategy;
- overlay strategy;
- compatibility/read-only strategy;
- likely real execution phases;
- shared versus source-specific reuse conclusions;
- unresolved decisions/blockers;
- recommended implementation slices;
- confirmation that D1/D2/D3 remain intact;
- whether you believe implementation of the MessageLens arm can now begin safely.

Acceptance standard:

> Before enabling the MessageLens segment, we should understand exactly what a MessageLens historical source is, what parts of it are authoritative, how its identity and provenance survive ingestion, and which parts of the Mac Messages experience are genuinely reusable rather than merely visually similar.
