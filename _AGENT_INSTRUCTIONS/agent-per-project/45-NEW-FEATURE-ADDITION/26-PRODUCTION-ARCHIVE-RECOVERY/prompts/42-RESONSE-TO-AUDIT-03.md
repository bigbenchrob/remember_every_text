Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation.

This is the third remediation pass following the Historical Archives architecture-conformance audit.

D1 — contradictory workflow-state combinations — is resolved.

D2 — state-dependent center Track boundaries — is resolved.

The next deferred finding is D3:

> Historical archive source identity can currently be reconstructed through two authority paths, especially when the source folder is offline/unavailable.

The goal of this task is to establish one canonical, offline-capable source-identity contract used consistently by inspection, duplicate detection, registration, imported membership, removal, reimport, and presentation targeting.

Do not begin MessageLens-folder ingestion in this task.

## Read first

Read:

- the canonical source identity / historical archive documentation;
- current source registration and source-key implementation;
- folder inspection/preflight code;
- duplicate detection;
- imported-source read model;
- removal/reimport lookup;
- persisted historical source metadata;
- architecture audit:
  `responses/40-HISTORICAL-ARCHIVES-ARCHITECTURE-CONFORMANCE-AUDIT.md`;
- D1 implementation:
  `responses/41-HISTORICAL-ARCHIVES-TYPED-PRESENTATION-STATE-IMPLEMENTATION.md`;
- D2 implementation:
  `responses/42-HISTORICAL-ARCHIVES-STABLE-CENTER-TRACK-SKELETON-IMPLEMENTATION.md`.

Before editing, identify and document the two current identity authorities and every call site that uses each.

## Problem

Historical Archives needs to answer:

> Is this the same historical source I have seen before?

That question must have one authoritative answer.

Today, identity is apparently derived through two compatible but separate routes:

1. an inspection/filesystem-oriented path when the source folder is available;

2. a persisted/offline reconstruction path when only stored metadata remains.

Even if both currently produce the same source key, two implementations of the same semantic rule are an architectural risk.

They may diverge under:

- path normalization;
- symlink resolution;
- case normalization;
- moved/remounted volumes;
- unavailable drives;
- renamed wrappers;
- historical persisted metadata;
- future MessageLens-folder sources.

This should be corrected before adding another archive-source arm.

## Governing principle

Apply:

> One semantic fact has one authority.

Historical archive identity should be produced by one canonical component/contract capable of operating from the evidence available in both:

- live source inspection;
- persisted/offline source metadata.

Do not maintain one “online identity algorithm” and a second “offline reconstruction algorithm.”

## First: map current identity semantics

Document exactly what currently constitutes historical source identity.

Determine whether the canonical source key is based on:

- normalized absolute `chat.db` path;
- enclosing folder path;
- source type;
- hash;
- archive/source registration metadata;
- another composite.

Do not infer from display labels.

Trace:

- where normalization occurs;
- whether filesystem existence is required;
- whether `realpath` / symlink resolution is used;
- whether volume identity matters;
- whether case sensitivity is normalized;
- how persisted keys are reconstructed;
- how source type is encoded or assumed.

## Enumerate all identity consumers

At minimum audit:

- folder inspection;
- duplicate already-added detection;
- source registration;
- source metadata persistence;
- Folders Already Added membership;
- selected-source lookup;
- orange correspondence targeting;
- removal;
- reimport;
- final source verification;
- success cartouche creation;
- offline startup/read model;
- source history/details.

Search repository-wide for direct source-key construction or path normalization.

## Desired canonical contract

Introduce or consolidate around one clear authority.

A likely conceptual shape is something like:

`HistoricalArchiveSourceIdentity`

or:

`HistoricalArchiveSourceKeyFactory`

that can derive/validate identity from typed evidence.

The exact API should follow repository conventions.

The important property is that all callers use the same semantic rule.

Conceptually it may support:

- `fromInspectedSource(...)`
- `fromPersistedMetadata(...)`

but those should both delegate to one canonical normalization/key-construction rule, not duplicate it.

Do not create a generic global identity framework.

This belongs to Historical Archives / archive-source domain ownership.

## Offline capability

The canonical authority must support the important case:

- source was imported previously;
- external drive is currently disconnected;
- MessageLens starts;
- Folders Already Added must still identify the persisted archive consistently;
- removal/details/read models should still refer to the same canonical source record where current semantics permit.

Do not require filesystem access merely to reconstruct identity for an already-known persisted source.

## Online inspection

When a folder is freshly selected:

- inspect/qualify it as currently designed;
- derive canonical identity through the same authority;
- use that identity for duplicate lookup and registration.

Do not let the file-picker/inspection path invent a special identity representation.

## Path normalization

Centralize the normalization rule.

Search for all local code involving:

- `absolute`;
- `normalize`;
- separator cleanup;
- `chat.db`;
- parent-folder extraction;
- case handling;
- URI/file conversion;
- volume prefixes.

Remove duplicated source-key normalization when safe.

Do not change semantics merely for style.

If canonical behavior intentionally uses normalized absolute `chat.db` path, preserve that unless the audit proves a defect.

## Display name is never identity

Lock this invariant:

- folder display name;
- cartouche title;
- basename;
- user-facing path abbreviation;

must never determine source identity.

Two sources with the same display name must remain distinct when canonical identity differs.

A renamed display label must not create a new identity by itself unless the underlying canonical identity rule says so.

## Persisted metadata

Audit what is stored today.

Prefer using the already persisted canonical source key directly where available rather than “reconstructing” it unnecessarily.

If persisted records already contain the authoritative key:

- use that key;
- validate it if appropriate;
- do not recompute from display/path fields merely because those fields also exist.

If older records lack a canonical key and require reconstruction, isolate that compatibility logic behind the same authority and document it.

Do not add a schema migration unless genuinely required.

If resolving D3 correctly requires schema change, STOP and report instead.

## Registration

Source registration must accept/consume canonical identity, not construct it independently.

Search for registrar code that derives a source key from path again.

Eliminate duplicate construction.

The registrar owns persistence of identity, not identity semantics.

## Duplicate detection

Duplicate detection must compare canonical identity only.

Preserve:

freshly chosen folder
→ derive canonical identity
→ lookup current imported source truth
→ duplicate modal if already added.

Do not compare:

- labels;
- raw selected path strings;
- display path;
- last-seen path.

## Removal

Removal should operate against the persisted canonical identity of the selected source.

It should not require the original source folder to be mounted merely to identify which source-scoped facts to remove.

Confirm current behavior and preserve it.

Do not change donor/source file safety.

## Reimport

A previously removed source may later be selected again.

The fresh inspection path should derive the same canonical identity as persisted history when the underlying canonical source is the same.

This preserves deterministic reuse.

Test this explicitly.

## Moved/renamed copies

Be careful here.

Current identity may intentionally be path-based.

Do not silently redefine identity to be content/hash-based in this task.

If moving/copying the same historical `chat.db` to another path currently produces a new canonical source identity, preserve that unless canonical docs say otherwise.

The goal is one authority, not a product-level identity redesign.

Document the existing semantics clearly.

## Source type future-proofing

Historical Archives now anticipates:

- Mac Messages;
- MessageLens.

Do not implement MessageLens-folder identity yet.

However, avoid hard-coding the canonical identity API in a way that makes a second source type impossible.

Prefer a typed source-kind input where appropriate if that is already consistent with architecture.

Do not prematurely generalize storage format.

## Equality / value semantics

If introducing a typed identity object, ensure:

- value equality;
- stable serialization representation;
- safe use as provider/map key where needed;
- clear distinction between identity and display metadata.

Do not expose raw strings broadly if a typed value can enforce correctness without large churn.

Use repository style.

## Presentation targeting

Blue selection and orange correspondence should consume canonical typed identity.

Do not let presentation widgets reconstruct keys from paths.

The sidebar cartouche should receive identity from its read model.

## Source membership

Preserve current semantics:

canonical identity

- successful/current imported source truth
  → Folders Already Added.

Do not let identity unification alter membership rules.

## State model integration

Use the D1 typed presentation states.

Candidate/source variants should carry canonical identity in the appropriate typed form rather than raw/path-derived substitutes where possible.

Do not reopen the combinatorial state problem.

## Track architecture

D2 is resolved.

Do not change Tracks A–I.

Identity remediation must not affect layout.

## Error handling

If persisted metadata is malformed and canonical identity cannot be reconstructed/validated:

- do not invent an identity;
- surface/report the problem through existing diagnostics;
- do not silently merge with another source;
- do not use display label as fallback identity.

Prefer explicit unavailable/invalid evidence.

## Architecture tripwires

Add strong protections.

At minimum prove:

1. one canonical source identity authority exists;

2. fresh inspection uses it;

3. persisted/offline read models use it;

4. registration does not independently reconstruct identity;

5. duplicate detection uses canonical identity;

6. removal uses persisted canonical identity;

7. reimport derives deterministic same identity for same canonical path/evidence;

8. presentation targeting does not compare display labels;

9. no second path-normalization/source-key algorithm exists outside the authority;

10. offline source reconstruction requires no mounted source folder when canonical persisted identity exists.

Consider repository-search tripwires if appropriate.

## Repository-wide search

Search for:

- `sourceKey`;
- historical archive path normalization;
- `chat.db` parent/path identity;
- `.absolute`;
- path canonicalization;
- duplicate source-key helpers;
- raw string equality in archive widgets/providers;
- reconstruction from labels.

Classify every hit.

Remove obsolete duplicate helpers.

## Tests

Add/update focused tests covering:

### Canonical construction

- same canonical inspected source produces same identity deterministically;
- equivalent normalized path forms behave according to current documented semantics;
- different canonical sources remain distinct;
- display names do not affect equality.

### Online/offline parity

- inspected source identity equals persisted-source identity for same source;
- offline read model returns same identity with source drive unavailable;
- no filesystem existence check is required when consuming persisted canonical identity.

### Duplicate detection

- freshly selecting already-imported source finds persisted source by canonical identity;
- same display label with different identity does not false-match;
- preflight-only/removed source behavior remains correct.

### Removal/reimport

- removal lookup works from persisted identity;
- donor/source folder need not be mounted merely for identity lookup where current architecture allows;
- reselecting same canonical source after removal reuses identity deterministically.

### Presentation

- blue selection targets canonical identity;
- orange duplicate correspondence targets canonical identity;
- no widget reconstructs identity from label/path.

### Regression

- D1 typed states remain intact;
- D2 Tracks remain intact;
- import/removal behavior unchanged;
- source-1 protection unchanged;
- DateConverter unchanged;
- maintenance/Onboarding behavior unchanged.

## Preserve current UX

No user-facing redesign is expected.

Do not change:

- sidebar copy;
- cartouche copy;
- folder chooser;
- duplicate modal;
- invalid modal;
- import/removal journeys;
- Narrator;
- Directed Instrumentation;
- success modal;
- button behavior;
- spacing.

If a visible path/details value changes because duplicate normalization was removed, document it and verify it remains semantically equivalent.

## D4 remains out of scope

Do not address generated writable APIs for frozen legacy Drift tables.

That remains a schema/codegen concern outside this task.

## Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- two old identity authority paths;
- exact canonical identity semantics;
- final authority/API;
- online derivation;
- offline/persisted consumption;
- path-normalization rule;
- display-name non-identity rule;
- registration ownership;
- duplicate/removal/reimport behavior;
- future source-kind considerations;
- tripwires.

Update the architecture-conformance audit/follow-up to mark D3 resolved if successful.

Update canonical database/archive identity documentation so future agents cannot invent another identity algorithm.

Use strong language analogous to DateConverter guidance:

> Historical archive source identity must always be obtained through the canonical source-identity authority. Do not construct source keys from paths, labels, or metadata ad hoc.

Update version/changelog according to repository rules.

## Verification

Run:

- focused source-identity tests;
- Historical Archives workflow tests;
- import/removal tests;
- Settings suite;
- offline/startup/read-model tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

## Stop conditions

STOP if:

- one canonical identity cannot be established without schema migration;
- current online/offline semantics materially conflict;
- resolving identity requires changing path-based/product identity policy;
- source provenance semantics must change;
- MessageLens-folder ingestion must be designed first;
- production/staging data repair is required.

Do not hide such a conflict with compatibility heuristics.

## Final report

Report:

- the two old authority paths;
- final canonical identity semantics;
- canonical API/type introduced or reused;
- persisted/offline behavior;
- path-normalization rule;
- duplicate detection behavior;
- removal/reimport behavior;
- duplicate helpers removed;
- tripwires added;
- full verification results;
- documentation updated;
- commit hash;
- confirmation that D3 is resolved;
- any remaining architecture findings;
- recommendation on whether the Mac Messages arm is now structurally safe to use as the basis for implementing the MessageLens arm.

Acceptance standard:

> Historical Archives should have one answer to “which source is this?” regardless of whether the source is currently mounted, being freshly inspected, already persisted, selected in the sidebar, removed, or reimported.
