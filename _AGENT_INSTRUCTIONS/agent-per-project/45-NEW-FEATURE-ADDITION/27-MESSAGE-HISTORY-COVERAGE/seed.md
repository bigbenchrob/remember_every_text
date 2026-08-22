Absolutely. I’d open **27** with a read-only audit prompt, not implementation. We want Codex to prove what “Message History Coverage” actually means before we polish the UI or trust its numbers.



Work on branch `Ftr.archive-recovery` unless Feature 27 has already been split to a new branch according to repository conventions.

Create/use the new Feature 27 working folder for **Message History Coverage**.

This is a READ-ONLY architecture, semantics, and performance audit.

Do NOT redesign the UI yet.

Do NOT optimize blindly.

Do NOT change database schemas or production behavior.

The purpose is to answer:

> What does Message History Coverage actually claim to measure, how is that claim computed, and is the current implementation architecturally and mathematically trustworthy?

## Current manual observation

Settings → **Message history coverage report** currently presents explanatory sidebar copy and a center panel that can sit at:

**Loading Message History Coverage…**

The completed report has not yet been treated as trustworthy product evidence.

Before polishing presentation, establish the underlying semantics and execution path.

## Product question

The current sidebar appears to claim that MessageLens compares:

- messages stored in the current Mac’s `chat.db`;
- messages MessageLens has imported and organized;

and groups current-Mac messages into categories roughly like:

- messages visible in chat timelines;
- messages recovered but not linked to a conversation;
- messages that could not be accounted for.

Audit whether that is actually what the implementation does.

Do not preserve wording merely because it exists.

## Read first

Read:

- current Message History Coverage feature code;
- canonical database architecture docs;
- source-scoped import docs;
- current working/import database ownership;
- Unknown Sources / Recovered Messages docs if they participate;
- Message evidence / conversation graph docs;
- DateConverter guidance;
- maintenance/readiness rules;
- Feature 26 Historical Archives lineage/source-scoping documentation where relevant;
- Track / Settings layout guidance;
- architecture tripwires.

Create the new Feature 27 audit record under the appropriate `responses/` location.

## Phase 1 — define the authoritative denominator

Identify exactly what set of messages the report treats as:

> messages on this Mac.

Questions:

- Is the denominator `chat.db.message` row count?
- Distinct GUIDs?
- Only rows with non-null GUID?
- Only rows MessageLens considers message-like?
- Are reactions/tapbacks/service rows included?
- Are deleted/unsent rows included?
- Are messages without conversations included?
- Are malformed/unreadable rows included?
- Are duplicate GUIDs deduplicated?
- Are source-scoped historical messages excluded because this report is about the current Mac only?

Document the exact SQL/domain predicate.

The denominator must have one canonical definition.

## Phase 2 — define each coverage category

For every category currently shown or computed, identify:

- exact semantic meaning;
- source of truth;
- query;
- mutual exclusivity;
- whether categories sum to denominator.

At minimum audit:

### Visible / organized messages

What exactly qualifies a current-Mac message as visible in MessageLens conversation timelines?

Is this based on:

- working graph membership;
- message-to-conversation edge;
- conversation browser visibility;
- source membership;
- another projection?

### Recovered but not linked to a conversation

What does “recovered” mean here?

Does this refer to:

- Unknown Sources;
- Recovered Messages;
- orphaned imported facts;
- messages present in working data but lacking conversation linkage?

Trace ownership.

### Unaccounted-for messages

This is the most important category.

Define mechanically:

> denominator − known covered categories

or identify the direct query if different.

Do not allow negative arithmetic or double counting.

## Phase 3 — prove category arithmetic

Establish invariants such as:

- every denominator message belongs to at most one terminal category;
- every denominator message belongs to at least one category if the report claims complete accounting;
- category counts cannot exceed denominator;
- no count can be negative;
- sum of terminal categories equals denominator, or document why not.

If current logic clamps or massages impossible arithmetic, flag it.

Add no fixes yet unless necessary to complete the audit.

## Phase 4 — identity semantics

Determine what identity joins current `chat.db` messages to MessageLens data.

Audit use of:

- original `ROWID`;
- GUID;
- source-scoped IDs;
- source ID 1/current source conventions;
- canonical `SourceScopedRowKey`.

Make sure the report is not comparing raw working IDs against raw `chat.db` ROWIDs incorrectly.

Given Feature 26’s lineage/source-scoping work, this deserves explicit scrutiny.

## Phase 5 — current-Mac source semantics

Prove how the report distinguishes:

- current Mac Messages source;
- imported historical Mac Messages sources;
- MessageLens attachment-recovery donors;
- recovered/orphaned messages.

The report appears to be about the current Mac only.

Imported Historical Archives messages should not accidentally enlarge the denominator.

Document the exact source filter.

## Phase 6 — graph/projection semantics

Determine whether coverage relies on `working_ss.db` / conversation graph truth.

If so:

- which tables?
- which graph version?
- what happens during maintenance/rebuild?
- can the report observe partially rebuilt graph state?
- does readiness/maintenance suppress the report?

Do not allow the report to infer “missing messages” merely because graph maintenance is temporarily in progress.

## Phase 7 — maintenance/readiness safety

Audit all database reads during report generation.

Confirm the report does not:

- open protected working/import databases during admitted maintenance;
- trigger Onboarding because a protected database is unavailable;
- race migration/rebuild;
- create stale cached counts.

Reuse the architecture hardened in Feature 26.

## Phase 8 — DateConverter audit

If the report displays date ranges, oldest/newest missing messages, or samples:

- verify all Apple timestamps use canonical `DateConverter`;
- no local epoch arithmetic;
- no magnitude heuristics.

## Phase 9 — performance trace

Profile the current loading path.

Measure separately:

- opening/reading current `chat.db`;
- loading MessageLens working/import evidence;
- joins/set construction;
- category classification;
- optional examples/detail generation.

Determine why the center may remain at:

**Loading Message History Coverage…**

If total runtime is perceptible, identify real countable work.

Do not add progress UI yet.

First determine whether the implementation is inefficient.

Look for:

- repeated full scans;
- N×M comparison;
- per-message queries;
- duplicate database opens;
- provider rebuild/re-execution;
- main-isolate CPU blocking.

## Phase 10 — provider/execution lifecycle

Trace:

Settings selection
→ provider construction
→ report execution
→ UI projection.

Determine:

- whether the report recomputes on widget rebuild;
- whether navigation away cancels/invalidates stale results;
- whether returning uses stale evidence;
- whether loading can hang due to provider dependency cycles.

## Phase 11 — completed report audit

Inspect the actual completed center-panel composition and every displayed field.

For each element ask:

- does the user need this?
- is it primary evidence or diagnostic detail?
- does wording accurately match the underlying category?
- is there an implied action?
- are any green checks/reassuring labels stronger than the evidence?

Do NOT redesign yet.

Record findings.

## Phase 12 — sidebar copy audit

Compare the existing sidebar explanation with actual semantics.

Current wording appears to say:

> MessageLens compares the messages stored in your Mac’s Messages database (`chat.db`) with the messages it has imported and organized.

and:

> This report shows whether everything on this Mac has been accounted for.

Determine whether those claims are literally true.

Flag copy that overstates certainty.

## Phase 13 — relationship to other features

Map how coverage relates to:

- Recovered Messages;
- Unknown Sources;
- Conversations;
- Historical Archives;
- current-source import/migration;
- Message evidence spine.

Do not duplicate canonical queries that another feature already owns.

If the report has local copies of identity/category logic, flag them.

## Phase 14 — architecture ownership

Identify the correct ownership boundary for:

- coverage domain model;
- current-Mac denominator query;
- graph/working classification;
- recovered/unlinked classification;
- presentation provider.

Determine whether current Settings code reaches too far into databases.

No edits yet.

## Phase 15 — output a concrete semantic model

Propose a typed conceptual model based on current truth.

For example only if supported:

`MessageHistoryCoverageReport`
- totalCurrentMessages
- visibleInConversations
- recoveredUnlinked
- unaccounted
- coverageStatus
- evidenceGeneratedAt
- optional diagnostics

Do not implement it in this audit unless it already exists.

The key is to define mutually exclusive categories and invariants.

## Phase 16 — identify product states

Recommend the honest product states, such as:

### Complete coverage

Every current-Mac message belongs to a known MessageLens category.

### Partial coverage

Some current-Mac messages are unaccounted for.

### Temporarily unavailable

Report cannot be computed because maintenance/rebuild is in progress.

### Failed

Evidence could not be read safely.

Do not conflate these.

## Phase 17 — progress/Narrator recommendation

Only after profiling, recommend whether this feature earns:

- immediate first paint;
- Narrator;
- Directed Instrumentation;
- no progress presentation because it should be nearly instant.

If work is perceptibly long, identify truthful stages and denominators.

Do not implement presentation yet.

## Phase 18 — Tracks/layout recommendation

Audit whether Message History Coverage currently uses the shared Settings Track architecture.

The screenshot suggests the center `Loading...` is simply centered in empty space.

Recommend how the final page should align with sidebar structure and other polished Settings features.

Do not implement Tracks in this audit.

## Phase 19 — failure and action semantics

If unaccounted messages exist, determine what the user can actually do.

Possibilities may include:

- open Recovered Messages;
- inspect Unknown Sources;
- rerun/rebuild;
- no direct action.

Do not invent an action that architecture does not support.

The report should not diagnose a problem without knowing whether the user can act on it.

## Phase 20 — architecture smells

Search for:

- raw SQL duplicated from canonical repositories;
- GUID counting inconsistencies;
- source-scoping arithmetic outside canonical utility;
- direct SQLite constructors;
- broad catches;
- string-based category logic;
- arbitrary delays;
- stale `FutureProvider` patterns;
- mutable global report state;
- UI-owned classification.

Classify findings by severity.

## Deliverable

Create the first Feature 27 audit record.

Suggested title:

`01-MESSAGE-HISTORY-COVERAGE-SEMANTICS-AND-ARCHITECTURE-AUDIT.md`

Include:

1. current feature architecture;
2. authoritative denominator;
3. category definitions;
4. identity/join semantics;
5. arithmetic invariants;
6. source filtering;
7. graph dependency;
8. maintenance behavior;
9. performance trace;
10. provider lifecycle;
11. completed report critique;
12. sidebar copy accuracy;
13. relationship to adjacent features;
14. architecture violations;
15. proposed typed semantic model;
16. honest product states;
17. progress/Narrator recommendation;
18. Track/layout recommendation;
19. actionable next steps;
20. recommended implementation slices in order.

## Implementation authority

This is primarily read-only.

You MAY make only tiny diagnostic/test additions necessary to prove semantics or performance, if repository conventions allow and they do not change product behavior.

Do NOT:

- redesign the report;
- change user-facing copy;
- add Tracks;
- add Narrator;
- optimize production algorithms;
- change schemas;
- change category semantics;
- alter source identity;
- mutate real data.

If a clear correctness defect makes the report mathematically false, document it and STOP before fixing unless the correction is trivial and architecture-prescribed.

## Verification

Run the smallest relevant checks needed for the audit:

- focused Message History Coverage tests;
- related source/graph/recovered-message tests;
- architecture tripwires;
- `flutter analyze` if code/test changes occur;
- `git diff --check`.

Do not run destructive GUI operations.

## Final report

Report back with:

- exact denominator definition;
- exact category definitions;
- whether categories reconcile mathematically;
- how current `chat.db` identity maps into MessageLens;
- whether Historical Archives data contaminates the report;
- maintenance/readiness behavior;
- why loading takes as long as it does;
- current architecture violations;
- whether existing sidebar copy is accurate;
- recommended final product model;
- recommended implementation slices;
- whether the feature is safe to begin polishing.

Acceptance standard:

> Before Message History Coverage tells the user that MessageLens has “accounted for everything,” we must be able to state precisely what “everything” means, prove that every category is mutually coherent, and show that the report is derived from canonical current-source truth rather than duplicated or accidental arithmetic.

That’s the right opening move for **27**.
