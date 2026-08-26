Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for a read-first architecture audit followed by implementation.

Manual testing has exposed what is now the central architectural defect in Onboarding:

> **There is not one authoritative Onboarding Journey.**

Several systems appear able to react independently to changing conditions and choose what the human sees next.

The result is reactive presentation pinball.

This task must replace that with one mechanically gated, typed Onboarding Journey Coordinator.

Suggested prompt name:

`12-SINGLE-AUTHORITY-TYPED-ONBOARDING-JOURNEY-COORDINATOR.MD`

# Manual evidence

During a real Start Fresh → Onboarding test, the human observed approximately this sequence:

1. Presence guided Full Disk Access.
2. **Open System Settings** was pressed.
3. MessageLens immediately produced a **Welcome back** dialog merely because focus returned.
4. FDA was toggled on.
5. **Finish Step** was pressed.
6. MessageLens said it could read the database files it needed.
7. The center panel then again said MessageLens needed Full Disk Access.
8. Re-check with FDA enabled then shifted attention to Contacts.
9. Guidance said:

   **“Open Contacts and allow its local data to finish loading.”**

   The human reasonably asked what this actually meant.
10. After quit/restart, another path asked about starting fresh.
11. Eventually Environment Readiness showed:
    **Everything is ready**
    and **Import My Messages**.

The human described the experience accurately:

> “I think we have about five parallel processes competing for attention.”

and:

> “It seems as though the logic jumps directly from one screen to another according to changing circumstances as the whole messed up group of competing processes evolves.”

That is the defect to solve.

# Central architectural rule

There must be exactly **one authority** capable of selecting the active Onboarding Episode.

Call it according to project naming conventions, conceptually:

`OnboardingJourneyCoordinator`

All other systems publish facts/evidence.

They do NOT independently choose the next screen.

This includes:

- Environment Readiness;
- FDA detection;
- Contacts readiness;
- Presence;
- startup routing;
- Start Fresh;
- operation snapshot;
- import progress;
- durable readiness;
- modal completion callbacks;
- app-focus/lifecycle callbacks.

# Mechanical Impossibility

The central acceptance requirement is:

> **Episode N+1 must be unrepresentable until the authoritative completion predicate for Episode N is satisfied.**

Not merely unlikely.

Not enforced by widget convention.

Not “the provider usually updates first.”

Mechanically impossible through typed state/transitions.

# Forbidden transition evidence

The following must NEVER be sufficient to advance an Episode:

- user returned from System Settings;
- app regained focus;
- dialog was dismissed;
- user clicked Finish Step;
- a timer elapsed;
- a provider rebuilt;
- a spinner completed;
- one duplicate readiness observer turned green;
- navigation occurred.

These may trigger **re-evaluation**.

They are not completion evidence.

# Completion evidence

An Episode advances only when its typed authoritative predicate evaluates true.

For example:

FDA Episode
→ actual required database-access proof succeeds
→ transition permitted.

The user pressing Finish Step may request re-check.

It cannot itself mean FDA passed.

# Phase 1 — inventory competing authorities

Before editing, enumerate every current code path capable of:

- navigating Onboarding;
- presenting/dismissing an Onboarding modal;
- changing Presence Journey/Episode;
- selecting Environment Readiness content;
- advancing a step/trip;
- entering import;
- entering normal application;
- triggering Start Fresh;
- reacting to app focus/system-settings return.

For each document:

- owner;
- trigger;
- evidence consulted;
- presentation effect;
- whether it currently advances Journey state.

Produce a competing-authority table.

# Trips / steps audit

The human specifically asked:

> “Are we still in a series of trips and steps here?”

Answer this from code.

Audit the existing:

- trips;
- steps;
- Presence Journey/Episode/Moment model;
- readiness state;
- startup routing.

Determine which is currently authoritative and which are legacy/parallel concepts.

Do not preserve Trips/Steps merely because they exist.

If they are useful content descriptors but not Journey authority, demote them accordingly.

If obsolete, remove them once mechanically unreachable.

# Phase 2 — define the Journey

Derive the actual ordered human Journey from authoritative prerequisites and operations.

Do not blindly use the following names/order, but investigate a conceptual sequence such as:

## Episode: establishing Messages access

Prove MessageLens can access the required Apple Messages source.

## Episode: confirming local message history

Establish what history is present locally and provide truthful sync/iCloud guidance where appropriate.

## Episode: establishing Contacts access

Only if Contacts is truly required by the current pipeline.

## Episode: ready to import

All import prerequisites are proven.

## Episode: building local MessageLens data

Existing import/graph operation.

## Episode: verifying durable readiness

Canonical post-build verification.

## Episode: ready to start

Terminal human-controlled handoff.

Use actual architecture to determine whether some should be combined or split.

The goal is a **small number of human-meaningful Episodes**, not implementation stages.

# Episode type

Introduce/refine a sealed typed Journey state.

Each variant should contain only evidence compatible with that Episode.

Conceptually:

`OnboardingJourneyState`

variants may include:

- checkingPrerequisites;
- needsMessagesAccess;
- needsMessagesHistoryConfirmation;
- needsContactsAccess;
- readyToImport;
- importing;
- verifying;
- readyToStart;
- blocked/failure variants where appropriate.

Do not create one nullable mega-object.

# Completion predicate per Episode

For every Episode document a function/authority:

`canAdvance(currentEvidence)`

or equivalent typed transition rule.

Examples:

## Messages access

Requires the exact source-access proof used by import.

## Contacts

Requires the exact Contacts access/readability proof if Contacts is truly mandatory.

## Ready to import

Requires all prerequisite predicates simultaneously true from one coherent evidence snapshot.

## Importing → verifying

Requires admitted operation completion evidence.

## Verifying → ready to start

Requires canonical durable installation completion/readiness truth.

No presentation callback can substitute.

# Coherent evidence snapshot

Avoid one provider observing FDA at T1 and another observing Contacts at T2 and constructing an impossible mixed state.

Determine whether prerequisite facts should be gathered into one typed Environment Readiness evidence snapshot with:

- occurrence/revision;
- observation time;
- source-access facts;
- Contacts facts;
- storage/import readiness;
- local-history evidence.

Journey Coordinator consumes one coherent snapshot.

Do not duplicate expensive database inspection.

# Single readiness authority

Prompt 11 introduced guided readiness presentation.

Now audit whether multiple readiness implementations still exist:

- Presence readiness;
- center-panel readiness;
- startup readiness;
- Environment Readiness provider.

Consolidate factual readiness into one canonical authority.

Presentation may project it differently.

# Full Disk Access truth

This deserves exact treatment.

Determine what FDA means operationally.

Do NOT treat:

“System Settings toggle appears on”

as necessarily authoritative if MessageLens actually needs:

“canonical source database opener successfully reads required databases.”

Prefer the proof closest to the actual capability required.

Define:

- unknown/checking;
- unavailable;
- available.

Returning from System Settings triggers re-inspection only.

# Remove “Welcome back” as progression

Audit the **Welcome back** dialog.

If it is merely triggered by app focus returning from System Settings, it must not imply the prerequisite is resolved.

Possible outcomes:

- remove it entirely;
- make it a Moment that says MessageLens is checking again;
- retain only if it has another legitimate meaning.

It may never advance the Episode by itself.

# Finish Step semantics

Audit every **Finish Step** action.

The action should mean:

> “I’ve done what you asked; check again.”

not:

> “Mark this step completed.”

Rename if necessary.

If **Check Again** / **I’ve done that** is clearer, use product voice.

The transition occurs only after authoritative proof.

# Duplicate FDA presentation

The manual run showed:

dialog says FDA succeeded
→ center panel says FDA still needed.

After consolidation this contradiction must be structurally impossible.

Both presentations must derive from the same Episode/evidence authority.

Prefer one presentation owner at a time.

# Modal vs center-panel ownership

Define when Onboarding uses:

- in-window Episode;
- modal Moment;
- system action.

Do not allow a modal and center panel to independently represent different Episodes.

Suggested principle:

> The center owns the current Episode. Modals are bounded Moments/authorizations within that Episode.

A modal dismissal never changes Episode unless the Coordinator receives authoritative new evidence.

# Contacts truth

Audit the current requirement:

> “Open Contacts and allow its local data to finish loading.”

Determine exactly what this means.

Questions:

- Why must Contacts.app be opened?
- Is AddressBook database population lazy?
- Is Contacts permission involved?
- What exact evidence proves the Contacts prerequisite?
- Can MessageLens trigger the required OS permission itself?
- Does merely opening Contacts guarantee anything?
- Is there a local database freshness/completeness condition?
- Can MessageLens distinguish unavailable from empty?

If the instruction is folklore or historical workaround, remove it.

If it is genuinely required, explain the causal mechanism and detect completion mechanically.

# Contacts required status

Prompt 11 retained Contacts as required because the current pipeline imports it unconditionally.

Re-evaluate architecture:

Does failure to import Contacts truly make message import unsafe?

or:

Could Contacts become optional enrichment, as Prompt 07's anomaly policy suggests?

Do NOT change this product contract casually.

But report whether unconditional pipeline sequencing is the only reason it is currently “required.”

If making Contacts optional requires a separate bounded architecture slice, defer it.

# Messages/iCloud Episode

Separate:

## Machine fact

MessageLens can read the local Messages database.

from:

## Human expectation

The local Mac contains all history the user expects.

MessageLens cannot inspect the iPhone's configuration directly.

The Journey should not pretend otherwise.

Determine whether a human acknowledgement Episode is appropriate:

> “I found N messages from DATE to DATE on this Mac.”

Then:

> “MessageLens imports only what is stored here. If you expect older messages, make sure Messages in iCloud has finished syncing before continuing.”

Potential action:

**This looks right — Continue**

But only if this actually adds value and does not create ritual clicking.

Audit.

# Ready state construction

`readyToImport` must be constructible only from a coherent prerequisite evidence snapshot satisfying every required predicate.

Do not let widgets independently decide:

`if (allGreen) show Import`.

The Coordinator owns it.

# Import authorization

**Import My Messages** is an authorization within `readyToImport`.

On press:

- new operation occurrence;
- Journey transitions atomically to importing;
- first frame paints;
- mutation begins.

If mutation admission fails, Journey enters typed failure/recovery state.

# Import progress

Reuse the manually approved Presence/progress system.

Do not redesign.

The Journey Coordinator owns the Episode `importing`.

Operation snapshot owns factual operation truth.

Directed Instrumentation projects observations.

# Import completion

Operation callback alone does not advance to ready-to-start.

Sequence:

operation reports completed
→ Coordinator enters/verifies durable readiness
→ canonical installation classifier/readiness proves completed
→ readyToStart becomes constructible.

# Terminal handoff

Preserve Prompt 11:

**You’re ready to start**

**OK**

Sidebar remains closed.

OK releases Onboarding ownership only after durable truth already exists.

Normal app/sidebar reveal follows.

# Startup routing

Audit application startup.

Startup must ask the Journey Coordinator / installation classifier:

What Episode owns the application?

Do not let startup independently navigate to:

- readiness;
- Start Fresh;
- import;
- normal app;

based on partial conditions.

Define one startup resolution path.

# Start Fresh integration

Start Fresh completion must not directly navigate to an arbitrary Onboarding screen.

It establishes verified `virgin` installation state.

Then:

Journey Coordinator
→ derives first appropriate Episode from current prerequisite evidence.

This prevents Start Fresh from becoming another competing navigator.

# Resume/interrupted integration

Prompt 02 has interrupted/resumable operation truth.

On startup:

installation classifier + operation snapshot + prerequisite evidence
→ Coordinator selects the correct Episode.

Do not let Presence persistence choose independently.

# Presence ownership

Presence renders/interprets Journey state.

Presence does NOT select Journey state.

This should become an architecture tripwire.

Narrator copy may be projected from Episode.

Do not persist Narrator strings as state.

# Environment Readiness ownership

Environment Readiness publishes facts.

It does NOT navigate.

It does NOT present independent dialogs.

It does NOT decide import readiness in widgets.

# App lifecycle ownership

Focus/visibility callbacks may trigger:

- re-check;
- refresh;
- Moment.

They cannot advance the Journey.

Add mechanical protection.

# Occurrence/session ownership

Every asynchronous prerequisite inspection must belong to a Journey occurrence/revision.

Late results from:

- old FDA check;
- old Contacts check;
- old Start Fresh;
- old import;

must be rejected if Journey moved on.

# Backward transitions

Define whether a prerequisite can regress.

Example:

FDA was proven
→ permission later revoked before import.

If coherent readiness re-check shows it is no longer available:

readyToImport must not remain valid.

Journey may return to the appropriate blocker Episode.

This is a legitimate backward transition driven by authoritative evidence.

Document allowed transition graph.

# No impossible simultaneous Episodes

Tests must prove states such as these cannot exist:

- readyToImport + needsFDA;
- readyToStart + importing;
- Contacts blocker + FDA success modal from another owner;
- normal sidebar visible + active first-run blocker;
- completed installation + ordinary Start Fresh onboarding offer.

# Transition graph

Document the full allowed transition graph.

Prefer an explicit transition function/table.

Avoid scattered `state =` assignments.

# Mechanical transition API

Create one Coordinator API for events/evidence such as conceptually:

- refreshPrerequisites;
- prerequisiteEvidenceObserved;
- userRequestedSystemSettings;
- userRequestedRecheck;
- importAuthorized;
- operationObserved;
- durableReadinessObserved;
- terminalAcknowledged;
- startFreshCompleted.

Use project naming conventions.

Widgets call intents.

Coordinator decides transitions.

# Blocker priority

When multiple prerequisites fail, Coordinator selects one Episode deterministically.

Define priority from actual dependency order.

For example:

source access before history sanity before Contacts.

Do not let provider completion order determine which blocker appears.

# Human-action gating

For every Episode define allowed actions.

Example:

needsFDA:
- Open System Settings
- Check Again
- Details

It must be impossible for Import My Messages to be invoked from this state.

Enforce in application layer, not only hidden button.

# Diagnostics

Expose a bounded Journey diagnostic snapshot:

- current Episode;
- evidence revision;
- prerequisite statuses;
- operation state;
- installation classification;
- last transition reason.

No PII.

This will be invaluable for tester reports.

# Existing legacy code removal

Once the Coordinator owns Journey transitions, identify and remove/demote:

- independent navigation callbacks;
- old Trips/Steps advancement authority;
- focus-driven progression;
- duplicated readiness gates;
- modal-driven completion flags;
- legacy “Welcome back” progression.

Do not leave parallel authority “for fallback.”

# Tests — transition gating

Add comprehensive focused tests.

At minimum prove:

1. FDA unresolved → only FDA Episode constructible;

2. returning from System Settings does not advance;

3. Finish Step/recheck without proof does not advance;

4. FDA proof advances to exactly the next required Episode;

5. Contacts cannot appear before preceding predicates pass;

6. readyToImport impossible until all required predicates pass;

7. prerequisite regression removes readyToImport;

8. import action impossible outside readyToImport;

9. operation completion alone cannot produce readyToStart;

10. durable readiness proof required;

11. terminal OK required for normal-app ownership;

12. sidebar cannot open early.

# Tests — competing authorities

13. Presence cannot navigate;

14. Environment Readiness cannot navigate;

15. focus callback cannot navigate;

16. modal dismissal cannot navigate;

17. Start Fresh cannot select an Episode directly;

18. startup routing goes through Coordinator.

# Tests — stale async

19. stale FDA result rejected;

20. stale Contacts result rejected;

21. stale import completion rejected;

22. stale Start Fresh completion rejected.

# Tests — contradiction regression

Reproduce the manual sequence:

Open System Settings
→ focus returns
→ Welcome back / no proof
→ no advancement.

Then:

FDA becomes actually readable
→ recheck
→ one coherent transition.

Prove the UI cannot subsequently show FDA blocked from a different authority using stale evidence.

# Tests — Contacts instruction

If “Open Contacts...” remains:

prove the exact condition it resolves.

If no causal/mechanical basis exists:

remove the instruction and add regression coverage.

# Architecture tripwires

Protect:

1. exactly one Journey transition authority;

2. Presence cannot assign Episode;

3. Environment Readiness cannot assign Episode;

4. widgets cannot assign Episode;

5. focus/lifecycle cannot mark prerequisite complete;

6. dialog dismissal cannot mark prerequisite complete;

7. readyToImport requires coherent evidence snapshot;

8. durable readyToStart requires canonical completion;

9. sidebar reveal requires terminal acknowledgement;

10. no legacy Trips/Steps authority remains if superseded;

11. Start Fresh returns through Coordinator;

12. operation snapshot remains operation truth, not Journey navigator.

# Presentation scope

Do not broadly redesign the already improved Episode surfaces.

This task is primarily architecture/coordination.

Make copy changes only where needed to remove false/obsolete instructions such as Welcome back or Contacts folklore.

# Manual staging validation

After automated verification, provide a deliberate manual path reproducing the original problem:

1. Start Fresh in staging.
2. Reach FDA Episode.
3. Open System Settings.
4. Return without enabling FDA.
5. Confirm Journey stays on FDA Episode.
6. Enable FDA.
7. Check Again.
8. Confirm exactly one transition occurs.
9. Proceed through remaining prerequisite Episodes.
10. Reach Everything is ready.
11. Import.
12. Reach You’re ready to start.
13. OK.
14. Sidebar opens.

Do not run it yourself against production.

# Documentation

Create:

`12-SINGLE-AUTHORITY-TYPED-ONBOARDING-JOURNEY-COORDINATOR-IMPLEMENTATION.md`

Document:

- competing-authority audit;
- Trips/Steps disposition;
- final Episode model;
- evidence model;
- completion predicate for every Episode;
- transition graph;
- blocker priority;
- FDA semantics;
- Welcome back disposition;
- Contacts semantics;
- iCloud/history semantics;
- startup routing;
- Start Fresh integration;
- Presence ownership;
- Environment Readiness ownership;
- lifecycle ownership;
- stale occurrence protection;
- removed legacy authorities.

Update canonical Onboarding/Presence/Environment Readiness docs.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules.

# Verification

Run:

- Journey Coordinator tests;
- Environment Readiness tests;
- Presence tests;
- FDA tests;
- Contacts tests;
- startup routing tests;
- Start Fresh tests;
- import handoff tests;
- operation snapshot tests;
- sidebar/navigation tests;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
-