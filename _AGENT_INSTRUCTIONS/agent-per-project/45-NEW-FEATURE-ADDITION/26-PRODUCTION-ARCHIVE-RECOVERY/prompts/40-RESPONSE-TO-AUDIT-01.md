Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation.

This is the first remediation pass following the Historical Archives architecture-conformance audit.

The audit identified a major deferred structural weakness:

> Historical Archives workflow state still permits contradictory field combinations.

The current implementation behaves correctly in ordinary tested flows, but that correctness is achieved largely by action methods constructing sensible combinations of independently nullable/orthogonal fields.

That does not satisfy the project’s Mechanical Impossibility Principle strongly enough.

The goal of this task is to make invalid Historical Archives presentation/workflow states materially harder or impossible to represent.

Do not begin D2 Track-boundary remediation or D3 source-identity unification in this task.

## Read first

Read:

- the canonical project architecture instructions;
- the Historical Archives workflow/application state implementation;
- the current Historical Archives presentation model;
- the current import/removal observation models;
- the current presentation-session/occurrence guards;
- the architecture audit:
  `responses/40-HISTORICAL-ARCHIVES-ARCHITECTURE-CONFORMANCE-AUDIT.md`;
- recent Feature 26 implementation records necessary to understand the current state model.

Pay special attention to the audit finding concerning contradictory combinations of:

- presentation context;
- selected source;
- candidate evidence;
- duplicate/invalid notices;
- import progress;
- removal progress;
- completion notice;
- orange reference;
- operation stage.

## Purpose

The current model conceptually has states such as:

- hub;
- existing source selected;
- inspecting candidate;
- ready to add;
- importing;
- import failed;
- removing;
- removal failed;
- duplicate notice;
- invalid-folder notice;
- success notice.

But those concepts are currently represented by multiple independently combinable fields.

That means the type system may permit states such as:

- `hub + selectedSource`;
- `existingSource + importProgress`;
- `readyToAdd + removalProgress`;
- `importing + duplicateNotice`;
- `hub + successNotice + selectedSource`;
- `removing + candidateEvidence`;
- stale orange correspondence attached to an unrelated state.

Ordinary actions may avoid creating these today, but architectural correctness should not depend on every future caller remembering all invalid combinations.

## Governing principle

Apply the Mechanical Impossibility Principle to workflow state:

> If two pieces of state cannot truthfully coexist, they should not be independently representable without an explicit typed variant that says what the combination means.

Prefer:

typed state variants with variant-specific data

over:

one large record containing many nullable fields plus procedural discipline.

Do not mechanically replace every field with an enum.

Use the smallest type structure that reflects real domain/presentation states.

## First: build the actual state machine

Before editing, derive the current state machine from code and tests.

Create a table covering every meaningful Historical Archives presentation/workflow state.

For each state document:

- semantic name;
- durable facts required;
- transient facts required;
- sidebar presentation;
- center presentation;
- permitted controls;
- permitted notices/modals;
- permitted progress model;
- permitted source identity;
- allowed next transitions;
- whether mutation authority may be active.

At minimum classify:

### Hub

- no active candidate;
- no selected existing source;
- no operation;
- center empty.

### Existing source

- explicit current-session cartouche selection;
- management center content;
- blue selection;
- no add/import progress.

### Inspecting candidate

- current add attempt;
- selected candidate path/source;
- inspection in progress;
- no imported-source management context.

### Ready to add

- valid current candidate;
- current typed inspection evidence;
- Add / Cancel / Details;
- no operation progress.

### Importing

- admitted import underway;
- import progress only;
- no candidate decision controls.

### Import failure

- failed admitted import;
- preserved truthful progress/failure evidence;
- only supported retry/recovery actions.

### Removing

- selected imported source being removed;
- removal progress only;
- no normal selected-source management controls.

### Removal failure

- failed removal;
- truthful durable/source state;
- supported recovery controls only.

### Duplicate-folder notice path

- no lasting add context;
- hub restored;
- modal occurrence;
- later temporary orange correspondence only.

### Invalid-folder notice path

- no lasting add context;
- hub restored;
- modal occurrence;
- no reference.

### Successful-import notice

- terminal import already finalized;
- hub restored;
- new cartouche exists ordinarily;
- modal acknowledgement only.

If additional real variants exist, include them.

Do not force current implementation names onto the conceptual model if they are misleading.

## Decide the appropriate typed structure

After deriving the state machine, determine the smallest architecture that makes invalid combinations difficult/impossible.

A likely shape may be a sealed/union presentation state such as conceptually:

`HistoricalArchivesPresentationState`

with variants such as:

- hub
- existingSource(...)
- inspectingCandidate(...)
- readyToAdd(...)
- importing(...)
- importFailed(...)
- removing(...)
- removalFailed(...)

plus separate narrowly scoped ephemeral notices if they genuinely cross those states.

This is illustrative, not mandatory.

Do not introduce a giant generic application state-machine framework.

Do not create framework abstraction for hypothetical future features.

This should remain a Historical Archives-owned typed state model.

## Separate durable facts from presentation state

Do not move durable archive truth into the new state union.

Durable facts remain in their established repositories/read models:

- source registry identity;
- imported row counts;
- persisted source metadata;
- import/removal results;
- graph state.

The new typed model owns current presentation/workflow context.

Do not persist:

- selected cartouche;
- Narrator phase;
- transient orange reference;
- modal occurrence;
- current candidate decision surface.

## Notices and modal occurrences

Audit whether duplicate, invalid, and success notices should be:

A. state variants themselves;

or:

B. separate process-only ephemeral events layered over a stable hub state.

Preserve the semantics already established:

duplicate:
hub + modal
→ dismissal
→ temporary orange reference

invalid:
hub + modal
→ dismissal
→ hub

success:
hub + finalized cartouche
→ modal acknowledgement

Do not force these into a state union if doing so would incorrectly imply that the center panel owns the notice.

The goal is coherent modeling, not ideological purity.

## Selected source and reference identity

Separate clearly:

- blue selected-source identity;
- orange referenced-source identity.

These must not share one ambiguous field.

Blue belongs to `existingSource`.

Orange remains an external transient correspondence event.

A duplicate-folder occurrence must never create `existingSource`.

A cartouche click must never generate duplicate-folder orange correspondence.

## Candidate evidence ownership

Inspection/preflight evidence should exist only in variants that can truthfully own it:

- inspectingCandidate;
- readyToAdd;
- possibly import failure if genuinely needed for recovery.

Hub and existing-source states must not carry stale candidate evidence merely because the workflow object once inspected a folder.

If durable source/preflight metadata exists separately for diagnostics, leave it there.

## Progress ownership

Import progress must only exist in:

- importing;
- importFailed where preserved failure evidence is required;
- possibly bounded terminal dwell if that is represented as a substate of importing.

Removal progress must only exist in:

- removing;
- removalFailed;
- bounded removal completion dwell if applicable.

A generic state containing both importProgress and removalProgress fields is suspicious.

Make simultaneous import/removal progress mechanically impossible.

## Narrator ownership

Do not store free-form Narrator strings as workflow truth.

Narrator projection should derive from typed state/progress phase.

Preserve current rules:

- source import phase → source Narrator;
- combined history phase → combined-history Narrator;
- final verification → silence;
- equivalent removal phase mapping;
- success modal owns terminal acknowledgement.

The typed state should make stale Narrator projection difficult.

## Session identity

Preserve the current presentation-session/occurrence safety.

Audit whether session identity belongs:

- once at workflow/session level;
- inside each state variant;
- in operation/notices only.

Prefer one coherent authority.

Do not duplicate session tokens across unrelated fields unless necessary.

Every delayed callback must still prove it belongs to the current session.

## Transition methods

Replace scattered field mutation with explicit typed transitions where practical.

Examples conceptually:

`beginAddAttempt()`
`candidateInspectionStarted(...)`
`candidateReady(...)`
`candidateCancelled()`
`importAuthorized(...)`
`importFailed(...)`
`importSucceeded(...)`
`existingSourceSelected(...)`
`removalStarted(...)`
`removalFailed(...)`
`removalSucceeded()`

Do not require exactly these names.

The important property is:

each transition constructs one complete valid state rather than mutating several independent fields in sequence.

Avoid intermediate impossible states becoming visible during provider rebuilds.

## Atomic presentation transitions

This is especially important.

The earlier UI bug where Add/Details disappeared temporarily demonstrated the danger of independently changing fields and relying on rebuild ordering.

A transition such as:

readyToAdd
→ importing

should publish one coherent new variant.

There should not be a visible intermediate state equivalent to:

candidate evidence cleared
but import state not yet published.

The model should favor atomic semantic transitions.

## Durable revalidation

Do not make the union state authoritative for durable facts.

Where a transition depends on durable truth, verify through the existing authoritative source.

Examples:

- imported membership;
- source removal completion;
- source canonical identity;
- final import success.

Presentation state follows durable truth; it does not replace it.

## Navigation reset

Preserve:

leaving Historical Archives
→ presentation session resets
→ hub on return.

The new typed state model should make this simpler:

session end
→ presentation state becomes hub
→ ephemeral notices/references invalidated.

Do not clear durable source metadata.

## Mutation authority

Do not alter `ArchiveMutationCoordinator`.

Do not change:

- owner identity;
- admitted operation scope;
- checkpoint semantics;
- database admission.

This task is state/presentation architecture only.

If the new state model exposes a mutation-authority flaw, STOP and report rather than folding mutation redesign into this task.

## D2 and D3 are explicitly out of scope

Do not solve these audit findings here:

### D2

Historical Archives has a state-dependent center-column shared Track boundary.

Leave Track architecture unchanged.

### D3

Offline source identity reconstruction has two authority paths.

Leave source identity unchanged.

The new state model should not make either harder to fix later.

## Preserve current validated UX

Do not change human-facing behavior unless necessary to eliminate an impossible state.

Preserve:

- hub layout;
- sidebar spacing;
- Mac Messages / disabled MessageLens segment;
- Folders Already Added semantics;
- cartouche selection;
- duplicate modal + orange reference;
- invalid-folder modal;
- ready-state evidence;
- Add / Cancel;
- import Directed Instrumentation;
- removal Directed Instrumentation;
- Narrator lifecycle;
- fixed Narrator Tracks;
- completion dwell;
- import success modal;
- removal success behavior;
- Tracks A–I;
- button interaction;
- Details behavior.

This should be primarily an architectural refactor with behavior-preserving presentation.

## Architecture tripwires

Add strong tests making impossible combinations difficult to reintroduce.

At minimum prove structurally or behaviorally:

1. hub cannot carry selected-source state;

2. hub cannot carry candidate evidence;

3. existingSource cannot carry import progress;

4. existingSource cannot carry removal progress unless explicitly represented as removal transition state;

5. readyToAdd cannot carry removal progress;

6. importing cannot expose ready controls;

7. importing cannot coexist with removal progress;

8. removing cannot expose import progress;

9. duplicate notice cannot implicitly select the referenced source;

10. invalid notice cannot carry source reference;

11. success notice occurs only after finalized hub state;

12. import and removal terminal states cannot both be active;

13. navigation reset atomically returns presentation to hub;

14. stale async callback cannot transition an obsolete session;

15. Narrator projection derives only from compatible typed variants/progress;

16. sidebar/center controls are impossible in the wrong variants.

Prefer compile-time/type-structure guarantees where reasonable, backed by focused behavioral tests.

## Migration strategy

This is likely a nontrivial refactor.

Do it in bounded steps:

1. define typed state model;
2. adapt projection/read model;
3. migrate workflow transitions;
4. migrate widgets to pattern-match/project typed state;
5. remove superseded nullable fields;
6. update tests;
7. search repository for remaining direct accesses to old fields;
8. remove compatibility shims once no longer needed.

Do not leave two competing state systems indefinitely.

If a temporary adapter is required during implementation, remove it before final commit unless repository conventions require a staged migration.

## Search for stale state assumptions

After migration search for:

- direct enum/context comparisons;
- nullable candidate checks;
- selectedSource + context condition chains;
- `if (progress != null)` state inference;
- string-derived state;
- duplicate combinations of context + stage;
- old helper booleans such as `isImporting`, `isReady`, etc. that can now contradict the typed variant.

Remove or simplify where safe.

## Tests

Run comprehensive focused coverage.

Add/update tests for:

### State construction

- each variant carries only valid data;
- required variant data cannot be omitted;
- mutually exclusive operation data cannot coexist.

### Transitions

- hub → existingSource;
- hub → inspecting;
- inspecting → ready;
- ready → hub via Cancel;
- ready → importing;
- importing → hub + success notice;
- importing → importFailure;
- existingSource → removing;
- removing → hub;
- removing → removalFailure;
- duplicate/invalid notice lifecycles;
- navigation reset.

### Race/session behavior

- stale inspection completion;
- stale modal dismissal;
- stale completion dwell;
- repeated add attempt;
- double import authorization;
- navigation away during async work.

### UI regression

- correct controls per variant;
- center/sidebar responsibility unchanged;
- Narrator/Directed Instrumentation unchanged;
- no previously validated screen regresses.

## Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- old combinatorial state model;
- concrete impossible combinations it permitted;
- new typed state architecture;
- state/transition table;
- separation of durable versus transient truth;
- notice/event strategy;
- session safety;
- progress ownership;
- Narrator projection;
- transition atomicity;
- architectural tripwires.

Update the architecture-conformance audit or follow-up record to mark D1 resolved.

Update canonical workflow/state architecture guidance if the resulting pattern is reusable elsewhere.

Do not rewrite historical records.

Update version/changelog according to repository rules.

## Verification

Run:

- focused Historical Archives workflow/state tests;
- import/removal tests;
- Settings suite;
- modal/session tests;
- Narrator/Directed Instrumentation tests;
- maintenance/Onboarding regressions;
- Track tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

## Stop conditions

STOP rather than broadening scope if:

- the correct typed model requires persistence/schema changes;
- mutation-authority semantics must change;
- D2 Track redesign becomes necessary;
- D3 source identity unification becomes necessary;
- product behavior must materially change;
- canonical architecture documents conflict.

## Final report

Report:

- exact old state fields/connections that created combinatorial risk;
- final typed state variants;
- exact notice/event strategy;
- exact transition API;
- examples of impossible combinations now unrepresentable;
- compatibility/dead fields removed;
- architecture tripwires added;
- full verification results;
- documentation updated;
- commit hash;
- confirmation that D1 is resolved;
- any newly discovered architectural gaps;
- recommendation for whether D2 Track-boundary remediation can now proceed safely.

Acceptance standard:

> Historical Archives should no longer be correct merely because every action remembers which unrelated fields to clear. The state model itself should express what combinations are valid.
