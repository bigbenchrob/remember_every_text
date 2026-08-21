Yes. This is a good moment for an **architecture-conformance audit**, especially after a long run of bug fixes where local expedience can creep in.

I would make this explicitly a **read-first, evidence-first refactoring audit**. Codex should not start “cleaning up” immediately. It should first identify deviations from the project's documented architecture, classify them by risk, and only then fix the bounded ones that can be proven safe.

Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for a long-running architecture audit and bounded remediation.

The goal is NOT to broadly refactor the repository.

The goal is to identify and correct places where recent bug fixing or feature implementation has violated, bypassed, duplicated, weakened, or locally reimplemented the project’s prescribed architecture.

This repository has extensive architectural documentation. Treat that documentation as authoritative unless current code and tests prove that the documented rule has intentionally evolved.

The recent Historical Archives work should receive especially close scrutiny because it involved many successive bug fixes, workflow-state corrections, database-maintenance fixes, Track additions, Narrator/Directed Instrumentation work, timing guards, modal/session handling, and source-scoped import/removal corrections.

The working hypothesis is:

> Some fixes may be operationally correct but architecturally expedient.

Your task is to find those.

# Governing approach

Proceed in this order:

1. READ the architectural rules.
2. BUILD an explicit audit checklist from them.
3. TRACE the current implementation against that checklist.
4. IDENTIFY violations or suspicious local workarounds.
5. CLASSIFY each finding.
6. FIX only those findings whose correct architectural remedy is clear and bounded.
7. STOP and report findings that require architectural redesign or product decisions.

Do not begin editing after finding the first problem.

This is an architecture audit first, implementation task second.

# Documentation-first requirement

Before inspecting implementation deeply, read the canonical project instructions relevant to at least:

- project architecture and ownership;
- database boundaries;
- persistent providers;
- mutation authority / maintenance locking;
- source-scoped historical archive import/removal;
- DateConverter / Apple timestamps;
- sidebar/center-panel responsibilities;
- Page Tracks / vertical column bands;
- Presence;
- Narrator + Directed Instrumentation;
- Settings feature ownership;
- asynchronous/provider/session lifecycles;
- feature-addition rules;
- architecture tripwires;
- testing conventions;
- version/changelog/documentation rules.

Also read the recent Feature 26 implementation/audit records necessary to understand why current code looks the way it does.

Do not assume the latest local implementation notes supersede canonical architecture documents unless they explicitly say so.

# Build an architecture checklist

Create a written checklist before editing.

At minimum include questions in these categories.

## 1. Ownership boundaries

For every recently touched Historical Archives component:

- Is this code located in the feature/module that owns the behavior?
- Is presentation code performing domain/database decisions?
- Is a provider making UI policy decisions it should not own?
- Is workflow state leaking into generic infrastructure?
- Is Settings code reaching directly into repositories/services that should be mediated through an application layer?
- Are shared abstractions genuinely shared, or were they made global merely to solve one screen?

Look especially for fixes that moved responsibilities because that was convenient.

## 2. Single source of truth

Audit for duplicated logic involving:

- source identity;
- archive membership;
- GUID comparison;
- date conversion;
- import readiness;
- maintenance state;
- selected-source state;
- progress stages;
- Track geometry;
- button styling;
- correspondence styling;
- modal/session state.

Find places where two code paths independently compute the same semantic fact.

The recent historical timestamp defect is the canonical warning example:

Apple timestamp conversion must always use:

`lib/core/util/date_converter.dart`

No local epoch arithmetic or magnitude heuristics may exist elsewhere.

Apply the same principle to other established authorities.

## 3. Mechanical impossibility

Audit whether recent fixes enforce impossible states structurally, or merely avoid them procedurally.

Examples:

- Can an unauthorized caller still open a protected database if call ordering happens to differ?
- Can a stale provider refresh temporarily project the wrong Historical Archives state?
- Can a duplicate/invalid source accidentally reach import controls?
- Can a successful cartouche appear before terminal import success?
- Can a removing source disappear before removal completion?
- Can Onboarding observe maintenance as failure?
- Can final success be presented from partial durable state?
- Can a stale Future/timer/modal callback mutate a newer presentation session?
- Can disabled MessageLens-folder UI reach an execution path?
- Can a center-panel context expose controls owned by the sidebar?
- Can a Narrator comment survive after its typed phase has ended?

Prefer architectural exclusion over conditionals sprinkled through widgets.

## 4. Mutation authority

Audit all code paths involving:

- historical import;
- historical removal;
- message reset;
- graph rebuild;
- source registration;
- archive metadata mutation.

Confirm:

- `ArchiveMutationCoordinator` remains the sole process-local mutation authority where prescribed;
- owner identity remains private/controlled;
- operation scope is truthful;
- nested scopes preserve the strongest policy;
- checkpoint rules do not weaken under reentry;
- admitted operations can access only resources authorized for that operation;
- unrelated callers remain blocked;
- no pre-open/order workaround has reappeared;
- no broad bypass was added to “make it work.”

Search explicitly for code added after the maintenance-lock bug that circumvents admission rather than participating in it.

## 5. Database construction and provider boundaries

Audit all persistent database creation/opening.

Confirm:

- construction remains centralized;
- canonical connection configuration is reused;
- busy timeouts are applied at the correct canonical boundary rather than scattered;
- Environment Readiness does not create forbidden observational reads during maintenance;
- source read-only opening follows the established immutable/historical-source path;
- no provider silently opens a database merely because a read model rebuilt;
- reset code does not instantiate resources merely to close them;
- repository code is not directly constructing databases.

Look for any “temporary harness logic” that accidentally became production architecture.

## 6. Date/time correctness

Search the entire repository for Apple-epoch arithmetic or conversion.

Confirm:

- DateConverter is the sole authority;
- historical Apple seconds and modern Apple nanoseconds both flow through it;
- preflight and import use the same conversion path;
- no SQL or Dart code independently adds Apple epoch offsets;
- UTC/local presentation conversion is consistent with project rules.

Architecture tripwires should make regressions difficult.

## 7. Historical source identity

Confirm one canonical source identity mechanism is used for:

- inspection;
- duplicate detection;
- registration;
- imported membership;
- cartouche targeting;
- removal;
- reimport;
- transient correspondence.

Labels and display names must never substitute for canonical identity.

Audit for path-normalization duplication.

## 8. Imported membership semantics

Audit the distinction between:

- known/registered source;
- inspected/preflight source;
- currently added/imported source;
- currently importing source;
- currently removing source.

Confirm that:

`Folders Already Added`

cannot accidentally include:

- merely inspected folders;
- failed sources;
- partially imported sources;
- zero-row removed sources.

Also confirm that transient presentation overrides do not corrupt durable repository truth.

## 9. GUID comparison semantics

Audit all dry-run/comparison arithmetic.

Confirm:

- source and destination comparison use compatible GUID semantics;
- no `COUNT(*)` vs `COUNT(DISTINCT guid)` mismatch remains;
- counts cannot become negative;
- counts cannot exceed their denominator;
- `new + already represented` equals the comparable population when evidence is valid;
- UI never clamps impossible arithmetic to hide a semantic bug.

## 10. Import/removal symmetry versus false abstraction

The two journeys now share concepts:

- Narrator;
- Directed Instrumentation;
- staged observations;
- completion dwell;
- session guards.

Audit whether this produced:

A. useful shared presentation primitives;

or:

B. premature generic abstractions that erase meaningful differences.

Do not force import and removal through one generic engine merely because they look similar.

Conversely, flag duplicate local machinery that should clearly share an established primitive.

## 11. Narrator architecture

Audit that Narrator behavior is derived from typed operation state, not strings/timers.

Confirm:

- Narrator speaks on human meaning/scope transitions;
- Narrator comments are phase-scoped;
- silence is supported;
- stale commentary cannot survive phase completion;
- final verification can be Narrator-silent;
- success modal owns terminal acknowledgement;
- Narrator does not become a progress log.

Audit recent center-only Tracks F-I and ensure they conform to the established Track model rather than creating a parallel layout system.

## 12. Directed Instrumentation

Confirm all displayed progress is real.

For every row/count:

- identify the execution boundary it represents;
- identify the numerator source;
- identify the denominator source;
- confirm monotonicity where claimed;
- confirm no timer drives progress;
- confirm no elapsed-time estimate is presented as work completed;
- confirm database algorithms were not made less efficient solely to animate progress.

Check both import and removal.

## 13. Track architecture

Audit Historical Archives Tracks A-I.

Confirm:

- they use the shared Page Track / vertical-band architecture correctly;
- no magic top offsets or duplicated geometry exist;
- center-only Tracks are an intentional supported use of the system;
- track occupancy does not accidentally control variable-list height;
- fixed Narrator allocation is implemented through structural geometry rather than a local `SizedBox`;
- sidebar and center responsibilities remain mechanically aligned.

Search for local padding values introduced before/after Track integration that may now be obsolete.

## 14. Sidebar / center-panel responsibility

Audit all Historical Archives states.

Required ownership:

Sidebar:

- source arm;
- folders already added;
- start new folder-selection attempt;
- selected existing object identity.

Center:

- valid candidate inspection;
- import decision;
- active import/removal journey;
- selected-source meaning/management;
- failure presentation where appropriate.

Modal:

- invalid folder;
- duplicate folder;
- destructive confirmation;
- terminal success acknowledgement where specified.

Find duplicate controls or content that violate these boundaries.

## 15. Presentation session / async safety

Audit:

- occurrence counters;
- session tokens;
- delayed futures;
- completion dwell;
- modal dismissal callbacks;
- orange correspondence timers;
- async folder inspection;
- import/removal observations.

For every delayed callback ask:

> Can this callback fire after the user leaves Historical Archives or begins a newer attempt?

If yes, prove it is guarded.

Look for inconsistent local implementations of the same session-safety principle.

## 16. Provider invalidation stability

Recent work fixed disappearing Add/Details controls.

Audit provider relationships for other transient impossible UI states.

Check whether:

- maintenance/readiness refreshes can revoke stable candidate presentation;
- source metadata refresh can overwrite active operation state;
- completion callbacks race source-list refresh;
- selectedSource / addArchive / importing / removing contexts can coexist incorrectly.

Find cases where UI correctness depends on provider rebuild ordering.

## 17. Readiness / Onboarding boundary

Audit the complete Environment Readiness interaction with maintenance.

Confirm:

- admitted maintenance cannot become `graphProjectionFailed`;
- no import-ledger or graph observational count is attempted when maintenance forbids it;
- maintenance is represented truthfully as `maintenanceInProgress`;
- restart reevaluates durable truth rather than replaying stale transient failure;
- Historical Archives work cannot accidentally redirect into Onboarding.

## 18. Busy timeout

Audit the newly added import-ledger 3-second busy timeout.

Confirm:

- it is configured at canonical connection creation;
- it is not duplicated elsewhere;
- it does not hide authority violations;
- it is bounded contention tolerance only;
- prohibited readiness reads remain suppressed rather than relying on the timeout.

## 19. Error handling

Search for catches introduced during recent work.

Flag:

- broad `catch (_)`;
- swallowed exceptions;
- conversion of architecture violations into generic user errors;
- retries that hide deterministic bugs;
- fallback values that make impossible evidence look valid;
- UI state restoration that ignores durable truth.

A failure should remain observable and attributable.

## 20. Expedient ordering dependencies

Search specifically for comments/code equivalent to:

- “must resolve before lock”;
- “open early”;
- “invalidate after”;
- “delay one frame”;
- “wait before calling”;
- “preload provider”;
- “keep alive so maintenance does not block.”

Not every ordering requirement is wrong.

Classify each as:

- legitimate presentation/event-loop sequencing;
- legitimate transaction ordering;
- architectural smell;
- known workaround that should now be removed.

The `endOfFrame` render barrier for immediate import acknowledgement is likely legitimate presentation sequencing; distinguish it from database-authority workarounds.

## 21. Local duplicated styling

Audit recent UI changes for private copies of:

- primary/secondary button hover/pressed grammar;
- destructive button styling;
- blue selection;
- orange correspondence;
- Details disclosure;
- status rows;
- spinner/check/waiting visuals.

Use established shared presentation helpers where appropriate.

Do not over-generalize one-off composition.

## 22. Obsolete code from superseded UI

Historical Archives has gone through several designs.

Search for unreachable or obsolete remnants of:

- old giant control panel;
- Execution Gate card UI;
- old Preflight Summary;
- Activity Log;
- old Progress panel;
- Result Summary;
- `alreadyImported` center narration;
- Choose Another Folder;
- persistent orange success reference;
- old single Working presentation;
- abandoned layout helpers;
- dead enums/states.

Do not delete code merely because a string is no longer visible.

Prove it is obsolete.

Remove genuinely dead code when safe.

## 23. Tests versus architecture

Audit whether tests merely freeze implementation details instead of protecting architecture.

Identify missing tests for:

- impossible state combinations;
- owner-aware database admission;
- provider construction during maintenance;
- stale async callbacks;
- durable truth versus presentation overrides;
- canonical DateConverter usage;
- canonical source identity;
- track ownership;
- progress truthfulness.

Prefer tripwire-style tests for rules that must never regress.

## 24. Documentation drift

Compare current implementation with canonical docs.

Find:

- docs describing removed behavior;
- implementation records that accidentally became canonical despite being local history;
- canonical guidance missing newly established reusable principles;
- contradictory rules.

Update canonical docs only where implementation and product decisions are now settled.

Do not rewrite historical audit records.

# Repository-wide search for architectural smells

Perform a systematic search for patterns such as:

- duplicate epoch constants;
- direct database constructors;
- raw path normalization;
- direct source-key construction;
- unscoped provider reads during maintenance;
- local `Future.delayed` used to coordinate correctness;
- arbitrary UI `SizedBox` offsets used instead of Tracks;
- broad catches;
- string comparisons controlling workflow state;
- raw enum-name comparisons in widgets;
- manually copied color literals;
- duplicate count formulas;
- direct mutation-service access from presentation widgets;
- providers that both mutate and present;
- calls that rely on “resolve before lock” ordering;
- source lists based on display labels.

Use judgment; these are leads, not automatic violations.

# Audit result format

Before editing, create a written audit grouped into:

## A. Confirmed architectural violations

Code currently conflicts with a documented invariant.

For each:

- file/location;
- documented rule;
- current behavior;
- risk;
- proper remedy;
- remediation scope.

## B. Expedient but bounded implementations

Code is not necessarily wrong but is suspicious/local and should be normalized.

## C. Legitimate local decisions

Patterns that may look expedient but are justified.

Examples may include:

- `endOfFrame` presentation barrier;
- 1.5-second post-execution perceptual dwell;
- process-only occurrence counters.

Document why they are legitimate.

## D. Architectural gaps requiring future design

Do not fix these automatically.

Examples:

- a missing generalized capability;
- unclear canonical ownership;
- conflicting docs;
- changes requiring schema migration.

# Risk ranking

Rank confirmed findings:

P0 — data integrity / mutation-authority violation
P1 — can create incorrect durable state or impossible workflow state
P2 — architecture violation likely to cause future bugs
P3 — duplication / maintainability / presentation inconsistency

Fix in that order.

# Remediation authority

You are authorized to fix confirmed P0–P2 issues when:

- the canonical architecture clearly dictates the remedy;
- no schema migration is required;
- no production/staging data mutation is required;
- no product-design choice is required;
- scope remains bounded.

You may fix obvious P3 dead-code/duplication issues when low risk.

Do NOT perform broad aesthetic refactoring.

Do NOT rename large APIs for taste.

Do NOT rewrite working architecture merely to reduce line count.

# Important hard invariants

Do not change:

- source identity semantics;
- DateConverter semantics except to remove violations;
- database schemas;
- durable archive data;
- source-scoped provenance;
- mutation authority model;
- successful Mac Messages UX semantics;
- MessageLens segment disabled state;
- production/donor/staging data.

Preserve unrelated worktree changes.

# Historical Archives special attention

Trace the complete current state machine/presentation model and prove whether these states are mutually coherent:

- hub;
- existingSource;
- add/inspection candidate;
- readyToAdd;
- importing;
- import failure;
- removal;
- removal failure;
- duplicate notice;
- invalid notice;
- success notice;
- orange reference;
- completion dwell.

Build a state/transition table.

For every state document:

- durable facts required;
- transient facts required;
- sidebar presentation;
- center presentation;
- allowed controls;
- mutation authority;
- permitted next transitions.

Use this to discover states that are prevented only accidentally.

# Database lifecycle special attention

Trace the lifetime of:

- import ledger;
- working graph database;
- source `chat.db`;
- source registry/archive metadata database.

For each operation:

- preflight;
- import;
- graph preparation;
- removal;
- reset;
- readiness probe;
- startup;

document:

- who may open it;
- read/write mode;
- maintenance restrictions;
- connection reuse;
- close behavior;
- busy timeout;
- failure behavior.

Look for contradictory policies.

# Do not mutate real data

Do not run GUI import/removal.

Do not modify:

- production archive;
- staging clone;
- frozen snapshots;
- donor folders;
- source `chat.db`;
- source WAL/SHM;
- attachment payloads.

Use source inspection only when explicitly safe/read-only and genuinely required.

Prefer fixtures/temp databases.

# Documentation deliverables

Create an architecture audit record in the appropriate Feature 26 `responses/` location.

Also create/update a canonical architecture-conformance document if the project already has an appropriate home.

Do not turn Feature 26 historical notes into the sole source of truth.

Update:

- architecture tripwire documentation;
- database docs;
- Presence/Narrator docs;
- relevant indexes;

only where findings require it.

# Implementation records

For every nontrivial remediation, record:

- violation;
- governing rule;
- old implementation;
- corrected implementation;
- tests protecting the boundary.

If many small fixes belong to one architectural principle, group them coherently rather than generating dozens of tiny records.

# Verification

After remediation run:

- all focused tests for touched features;
- full Settings tests;
- database/import/removal tests;
- mutation-coordinator/admission tests;
- onboarding/readiness tests;
- DateConverter tests;
- Track/layout tests;
- Narrator/Directed Instrumentation tests;
- complete architecture tripwire suite;
- full Flutter test suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

If the full test suite is unusually expensive, run it unless there is a concrete resource reason not to; this is specifically an architecture-hardening pass.

# Commit discipline

Do not commit the initial audit before remediation unless repository policy requires it.

After fixes and verification:

- update version/changelog if repository rules require a release bump;
- commit with an architecture-focused message;
- push to `Ftr.archive-recovery`.

# Stop conditions

STOP and report rather than editing if:

- canonical documents conflict materially;
- correct fix requires schema migration;
- correct fix changes source provenance;
- correct fix requires production/staging data repair;
- a finding requires redesign of the mutation authority model;
- a finding requires enabling MessageLens-folder ingestion;
- a product decision is necessary.

# Final report

Return a detailed report containing:

1. canonical architecture documents read;

2. audit checklist used;

3. confirmed violations found;

4. expedient-but-legitimate patterns explicitly cleared;

5. fixes implemented;

6. dead/superseded code removed;

7. new architecture tripwires added;

8. remaining architectural gaps intentionally not fixed;

9. Historical Archives state/transition audit result;

10. database-lifecycle audit result;

11. DateConverter/source-identity audit result;

12. mutation-authority audit result;

13. Track/Narrator/Directed-Instrumentation audit result;

14. test/verification results;

15. documentation updated;

16. commit hash;

17. whether you consider the current Mac Messages Historical Archives arm architecturally conformant enough to use as the template for the future MessageLens-folder arm.

The central question is not:

> Does the code currently work?

It is:

> Is the code correct because the architecture makes the wrong behavior difficult or impossible, or does it merely work because a sequence of local fixes currently happens to line up?

Prefer the former.
