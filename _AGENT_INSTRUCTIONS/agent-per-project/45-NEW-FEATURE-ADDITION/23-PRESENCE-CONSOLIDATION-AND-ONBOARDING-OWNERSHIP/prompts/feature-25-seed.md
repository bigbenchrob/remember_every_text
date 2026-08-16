

This first task should create the new feature home and establish the architecture **without implementing replacement, seeding, serialization, or database deletion yet**.

### Prompt for Codex — Create Feature 25 and Define the Presence Guidebook Lifecycle

Create the new Feature Addition package for the **Presence Guidebook Lifecycle** and perform the first architecture/design pass.

**This prompt is authorization to create and update documentation. Do not stop to ask for plan confirmation.**

Current branch must be:

```text
Ftr.gdbk-lifecycle
```

Before editing, verify that branch and confirm the worktree state.

The new feature folder is:

```text
_AGENT_INSTRUCTIONS/
  agent-per-project/
    45-NEW-FEATURE-ADDITION/
      25-PRESENCE-GUIDEBOOK-LIFECYCLE/
```

`24-HEATMAP-COLOR-REVISION` already exists. Do not use or modify that folder for this work.

---

# 1. Read the handoff first

Begin with:

```text
23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/
57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md
```

Then read the current permanent documentation and code needed to understand:

- `presence.db`;
- Presence database construction/lifecycle;
- Schedule/Trip/Step definition persistence;
- occurrence persistence;
- `schedule_runs`;
- execution trace;
- definition insertion/reconciliation;
- current production Onboarding Schedule installation/composition;
- production Presence runner/host;
- database inventory, backup, health, reset, and path authority;
- Overlay ownership;
- current application startup/database-opening sequence.

Use current code as source of truth.

Do **not** begin implementation.

---

# 2. Create the new feature folder

Create:

```text
25-PRESENCE-GUIDEBOOK-LIFECYCLE/
```

with at minimum:

```text
00-START-HERE.md
01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md
```

If this repository's Feature Addition convention requires an `INDEX.md` or equivalent package file, create/update it consistently.

Also update:

```text
45-NEW-FEATURE-ADDITION/INDEX.md
DOCUMENTATION_PASS_LOG.md
```

to register Feature 25.

---

# 3. Governing architectural conjecture

Treat the following as the design we are now testing against current code.

## Presence is a guidebook

`presence.db` contains the installed edition of MessageLens's Presence guidebook:

```text
Schedules
Trips
Steps
occurrences
Tell text
Agent IDs
Choice configuration
routes
```

It may also contain convenient execution state for that edition:

```text
schedule runs
current Trip checkpoint
completion state
execution trace
```

Within one installed guidebook generation, this state may behave as ordinary durable state.

---

# 4. Guidebook generation is the durability boundary

The core proposed rule is:

```text
SAME GUIDEBOOK GENERATION

keep presence.db
resume normally
retain runs/checkpoints/trace
```

but:

```text
NEW GUIDEBOOK GENERATION

discard old Presence database/state
create current Presence database
install current guidebook edition
start fresh
```

It is acceptable for replacement of the guidebook to discard:

```text
unfinished Schedule position
current Trip
completed Presence Schedule
Presence execution trace
old readiness position
other Presence-local workflow state
```

Those facts describe use of an obsolete edition of the guidebook.

The architecture does **not** need to map an old guidebook's page/bookmark onto the new edition.

Investigate this rule. Do not implement it yet.

---

# 5. Distinguish Presence durability from user-data durability

Do not generalize this disposable-generation rule to other MessageLens databases.

The contrast is essential:

```text
working/import/user-data stores
    may contain facts we must preserve or reconstruct
    -> normal schema/data lifecycle rules apply

presence.db
    application-supplied guidebook + edition-local state
    -> candidate for wholesale replacement
```

In particular, do not allow this feature to weaken the existing attachment-preservation invariant.

Archived attachment payloads remain preservation data and are completely unrelated to replacing Presence.

---

# 6. Durable human intent remains separate

Preserve the established Overlay principle:

> `overlay.db` is for durable user meaning or intent that should survive replacement of the guidebook.

Example:

```text
"I prefer detailed step-by-step guidance."

versus

"Take care of most of it for me."
```

That preference remains meaningful even if every Schedule, Trip and Step identity changes tomorrow.

By contrast:

```text
current Trip = 308
Schedule 6 completed
ChoiceStep 6903 was displayed
```

does not have independent user meaning and need not survive a guidebook-generation replacement.

Use this test:

> **Would this fact still mean something if every Presence Schedule, Trip and Step ID were replaced tomorrow?**

If yes, its owning domain may deserve durable storage.

If no, Presence-local durability is sufficient.

Do **not** add Overlay fields in this task.

---

# 7. Restore the blank-stare runtime boundary

The desired runtime ownership is:

```text
presence.db
    owns installed guidebook geometry/content

Presence
    loads and executes that guidebook

domain Agent resolvers
    supply opaque specialist capabilities
```

For Onboarding:

```text
Presence:
    "Evaluate Agent onboarding.messages-source-readable."

Onboarding:
    answers the domain question.
```

Onboarding runtime should not need to know:

```text
Schedule ID
Trip ID
Step ID
Step text
occurrence position
routing geometry
ChoiceStep placement
```

Ask Onboarding:

```text
"What does Step 6302 say?"
```

Desired answer:

```text
blank stare
```

Ask Onboarding:

```text
"Can the Messages source currently be read?"
```

That is Onboarding's business.

Assess current code against this boundary.

---

# 8. Separate three lifecycle phases

Investigate an architecture with three conceptually distinct phases:

```text
INSTALLATION
    create current Presence schema
    install current guidebook edition

REPLACEMENT
    determine installed guidebook is obsolete
    discard old Presence database
    create/install current edition

RUNTIME
    read presence.db
    execute what it says
```

The runtime phase should not need to construct a second full Schedule and compare it with the persisted Schedule.

This is the central issue exposed by the Step-6302 failure.

---

# 9. Fresh installation problem

A first-time user has no existing Application Support Presence database.

Drift can create the current schema, but something must populate:

```text
Schedules
Trips
Steps
occurrences
Tell text
TestAgentIds
Choice values/labels
destinations
```

Identify the exact current mechanism that supplies this content.

Then determine what a proper **guidebook installation boundary** needs to own.

Do not choose the serialized source format yet.

Possible formats remain open:

```text
JSON
Dart-authored static data
SQL
generated resource
other deterministic serialized representation
```

The first architecture pass should identify the requirements a format must satisfy, not choose one prematurely.

---

# 10. Upgrade/replacement problem

Investigate how MessageLens could answer one simple question:

> **Does this `presence.db` contain the guidebook edition expected by this build?**

Potential concepts include:

```text
guidebook generation integer
catalog generation
manifest identity
content hash
```

Do not implement one yet.

Determine the minimum properties required.

The target behavior is conceptually:

```text
presence.db absent
    -> create + install current guidebook

presence.db current
    -> use normally

presence.db obsolete
    -> replace wholesale
    -> install current guidebook
```

There should be no assumed chain such as:

```text
guidebook 4 -> 5 -> 6 -> 7
```

unless the audit finds a genuinely unavoidable requirement.

A user running guidebook generation 2 should be able to install generation 20 directly by replacement.

---

# 11. Schema version and guidebook generation are different concepts

Audit this distinction explicitly.

```text
DATABASE SCHEMA
    physical representation expected by current Dart/Drift code

GUIDEBOOK GENERATION
    edition of the application-supplied workflow content
```

Under the proposed replacement model, even schema migration of old `presence.db` may be unnecessary if an obsolete Presence database is simply replaceable.

Investigate whether the clean lifecycle is:

```text
database acceptable/current?
    -> open

otherwise
    -> close/remove Presence DB family
    -> create from current Drift schema
    -> seed current guidebook
```

Do not implement this.

Determine whether there are startup-order or Drift-opening constraints that affect it.

---

# 12. Audit the current runtime reconciliation mechanism

Trace precisely what currently happens when production Onboarding supplies its authored Schedule.

Identify:

- where the Dart-authored definition originates;
- which layer submits it;
- how Presence checks whether definitions already exist;
- how equality/redefinition is determined;
- why Step 6302 generated:

```text
Existing Step 6302 in Trip TripDefinitionId(303) cannot be redefined.
```

Then answer:

> Under the guidebook lifecycle model, which parts of this runtime reconciliation mechanism become unnecessary?

Do not remove them yet.

---

# 13. Reinterpret the Step-6302 incident

Do not treat Step 6302 as an isolated migration problem.

Use it as the worked example exposing the lifecycle issue.

Current shape:

```text
old presence.db
    Step 6302 = old text

current Dart authored workflow
    Step 6302 = changed text

startup reconciliation
    -> conflict
```

Desired future shape may instead be:

```text
new app contains new guidebook generation
        ↓
old presence.db generation differs
        ↓
old guidebook discarded
        ↓
new guidebook installed
        ↓
Step 6302 says whatever the new installed guidebook says
```

No runtime comparison between old and new Step text.

Document whether this model completely removes the observed blocker.

---

# 14. Audit what can safely disappear

Inventory all tables/data currently in `presence.db`.

For every category, classify:

```text
REPRODUCIBLE GUIDEBOOK CONTENT
EDITION-LOCAL EXECUTION STATE
POTENTIALLY USER-MEANINGFUL DURABLE STATE
UNKNOWN / NEEDS DECISION
```

Likely categories include:

- Schedule definitions;
- Trip definitions;
- Step definitions;
- subtype definitions;
- Schedule occurrences;
- Trip Step occurrences;
- Choice options;
- run checkpoints;
- execution trace.

Do not assume the answer merely from table names.

Conclude whether **anything currently in `presence.db` truly must survive a guidebook-generation replacement**.

If yes, explain exactly why.

If no, say so clearly.

---

# 15. Audit current backup/reset/database lifecycle policy

Presence was previously treated as durable shared application state.

Inspect how it participates in:

```text
database inventory
backup
health
checkpoint
reset
database reopening
archive mutation coordination
sidecar handling
```

Determine which policies would need reconsideration if Presence becomes **reproducible application content plus disposable edition-local state**.

Do not modify those systems yet.

Do not accidentally classify attachment preservation data as similarly disposable.

---

# 16. Atomic replacement requirements

Analyze what a future whole-database replacement must guarantee.

Consider:

```text
presence.db
presence.db-wal
presence.db-shm
```

and current database-provider lifecycle.

Questions include:

- must the database be closed first?
- how do we prevent code from reading it during replacement?
- should replacement be performed before Presence providers become available?
- what happens if replacement fails halfway?
- can creation + catalog install happen in a temporary DB and then be promoted?
- is ordinary startup reconstruction sufficient after an interrupted replacement?

This is analysis only.

Do not build a replacement engine.

Prefer the simplest lifecycle that is actually safe.

---

# 17. Failure philosophy for guidebook installation

A failed guidebook installation is different from an old workflow migration.

Determine the minimum truthful failure model.

For example:

```text
current guidebook cannot be installed
    -> Presence cannot run
```

Do not invent:

- resume checkpoints for catalog installation;
- catalog migration histories;
- rollback frameworks;
- background repair queues;

unless current architecture proves them necessary.

A fresh deterministic reinstall may be enough.

---

# 18. Authoring source versus runtime source of truth

Be precise about this distinction.

There must be some source shipped with MessageLens from which the guidebook is installed.

That source is **authoring/install input**.

After installation:

```text
presence.db
    = runtime authority
```

The architecture must avoid recreating the current problem where both:

```text
Dart-authored Schedule graph
```

and:

```text
presence.db Schedule graph
```

behave like competing runtime definitions.

Document the exact boundary you recommend.

---

# 19. Guidebook authoring ergonomics

Without choosing the serialization format, determine what the authoring system must support.

At minimum the guidebook source needs deterministic representation of:

```text
Schedule identity
Trip identity
Step identity
occurrence order
Tell text
opaque Agent IDs
Test destinations
FixedDestination routes
Choice values
Choice labels
Choice destinations
```

Consider also:

- validation before shipping;
- unique-ID validation;
- Schedule-local route validation;
- minimum Choice-option rules;
- readable diff/review in Git;
- testability;
- generation bump discipline.

Do not build the format.

---

# 20. Determine whether IDs remain valuable

If an entire old guidebook is discarded on generation change, ask what stable numeric IDs are still needed for.

They may still be useful **within an installed edition** for:

```text
foreign keys
routes
runs
trace
debugging
```

But perhaps they no longer need eternal cross-version semantic identity.

Audit this carefully.

Do not renumber anything yet.

Determine whether the new rule could become:

> IDs are stable and meaningful within a guidebook generation; cross-generation compatibility is not required unless explicitly designed.

Or whether some stronger identity rule remains valuable.

This is an important design question.

---

# 21. Same-generation durability

Do not accidentally turn Presence into an in-memory toy.

Within one guidebook generation, preserve the advantages already earned:

```text
quit/reopen
    -> resume current Trip

crash/relaunch
    -> Trip-granular restart

completed run
    -> remains completed during this installed edition

trace
    -> remains available during this installed edition
```

The new architecture changes the **cross-generation contract**, not necessarily ordinary runtime durability.

---

# 22. Cross-generation restart UX

Explicitly assess the human consequence:

```text
user halfway through guidebook generation 12
    -> upgrades MessageLens
    -> generation 13 installed
    -> starts guidebook fresh
```

Is that acceptable?

Our current conjecture is **yes**.

Likewise:

```text
user completed generation 12 onboarding
but browsing data has not yet been built
    -> upgrade
    -> may be asked readiness questions again
```

Current conjecture: acceptable.

Verify that no correctness/safety problem follows.

Separate mild repetition from genuine user-data loss.

---

# 23. Do not move things to Overlay merely to preserve them

Overlay is not the archive for discarded Presence state.

Do not propose copying:

```text
schedule_runs
execution_trace_events
Trip IDs
Step IDs
completion flags
```

to Overlay.

Only identify a durable semantic fact for Overlay if it independently passes the user-intent test.

The default should be:

```text
guidebook state dies with guidebook
```

---

# 24. Onboarding and other future clients

Presence may eventually guide features besides Onboarding.

The lifecycle model should therefore remain Presence-owned and generic.

The installed guidebook may contain multiple Schedules belonging semantically to different consumers.

Consumers provide specialist Agents/actions.

They should not own Presence persistence or catalog replacement.

Do not make the new lifecycle Onboarding-specific simply because Onboarding is today's production client.

---

# 25. Presence grammar remains out of scope

Do not redesign:

```text
Schedule
Trip
Step
Scheduler
TestStep
ChoiceStep
FixedDestinationStep
TellStep
```

The current execution grammar remains presumed valid.

This feature asks:

> How does the current edition of those definitions get installed and replaced?

not:

> How should execution work?

---

# 26. Production Gate/harness boundary remains fixed

Preserve:

```text
normal production-shaped debug
    -> actual Onboarding host

PRESENCE_DEVELOPMENT_HARNESS=true
    -> laboratory Presence harness
```

Do not reopen that architecture.

Do not route normal startup through the harness as an easier way to seed Presence.

---

# 27. Attachment preservation is an explicit non-analogy

Include a warning in the new package:

> The replaceability of `presence.db` must never be generalized to archived attachment payloads.

Presence is reproducible application-supplied content.

Archived attachments may be irreplaceable preservation data.

Any future database lifecycle implementation must keep those categories mechanically separate.

---

# 28. Recommend the minimum architecture

At the end of the audit, recommend the smallest architecture that satisfies:

```text
fresh install
    -> current guidebook exists

same generation restart
    -> Presence resumes normally

new generation
    -> obsolete guidebook/state is discarded
    -> current edition installed
    -> Presence begins fresh

runtime
    -> database is sole guidebook authority

domain consumers
    -> supply Agents, not sticks and balls
```

Do not implement it.

Use this summary structure:

```text
Guidebook source:
Installed-generation marker:
Fresh-install owner:
Replacement owner:
Replacement timing:
Database-close/reopen boundary:
Runtime authority:
Same-generation state:
Cross-generation state:
Overlay boundary:
Consumer/Agent boundary:
Current reconciliation code:
Step-6302 consequence:
Schema-migration consequence:
Backup/reset consequence:
Failure behavior:
```

---

# 29. Identify exactly one implementation starting point

Recommend **one** first implementation slice after the architecture is approved.

Do not create an entire multi-slice implementation plan unless needed to explain dependencies.

Likely candidates might be:

```text
introduce deterministic guidebook catalog representation + validator

or

introduce Presence generation metadata/lifecycle bootstrap

or

extract current authored production Schedule into an installable catalog
```

But derive this from code.

Do not assume the serialization format beforehand.

---

# 30. Create `00-START-HERE.md`

The package start page should explain in ordinary language:

> Presence is like a guidebook. While someone is using one edition, MessageLens may remember their bookmark and reading history. When MessageLens ships a new edition, it is acceptable to replace the old guidebook and start the new edition fresh.

Then introduce the architectural terminology.

Include:

- why Feature 25 exists;
- Step-6302 as triggering evidence;
- agreed generation boundary;
- runtime-authority principle;
- durable-user-intent distinction;
- blank-stare consumer principle;
- current status: architecture/design only;
- link to `01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md`.

Do not turn `00-START-HERE.md` into the full audit.

---

# 31. Documentation output

Create:

```text
25-PRESENCE-GUIDEBOOK-LIFECYCLE/
    00-START-HERE.md
    01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md
```

Plus any package index required by current repository convention.

Update:

```text
45-NEW-FEATURE-ADDITION/INDEX.md
DOCUMENTATION_PASS_LOG.md
```

Cross-link back to Feature 23's:

```text
57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md
```

Do not rewrite Feature 23 except for a narrowly necessary broken-link correction.

---

# 32. Verification

This is documentation/design work only.

Run:

- relevant architecture/documentation consistency checks;
- `git diff --check`;
- any existing documentation tripwires affected by the new package.

Do not run destructive Presence lifecycle experiments.

Do not delete or rewrite the current development `presence.db`.

Do not launch application behavior intended to trigger catalog replacement.

---

# Hard constraints

Do not:

- implement guidebook replacement;
- delete `presence.db`;
- change Drift schema;
- choose/implement JSON or another catalog format prematurely;
- add a guidebook-generation field yet;
- remove definition reconciliation yet;
- tactically fix Step 6302;
- allocate replacement Step IDs;
- create workflow-content migration chains;
- move Presence run/trace state to Overlay;
- add Overlay schema;
- redesign Presence grammar;
- change Onboarding Agents;
- change production Gate/harness routing;
- touch attachment archival;
- generalize Presence disposability to other databases.

If current code reveals a fact that materially contradicts the proposed replaceable-guidebook model, document that contradiction prominently instead of coding around it.

# Success criterion

At the end of this task we should understand whether this architecture is sound:

```text
MESSAGE LENS RELEASE
        |
        v
ships one current Presence guidebook
        |
        v
fresh install or generation mismatch?
        |
      yes
        |
        v
install a fresh current presence.db
        |
        v
Presence runs only what presence.db says
        |
        v
domain Agents answer domain questions
```

and:

```text
same edition
    bookmark survives

new edition
    old guidebook + bookmark may disappear

genuinely durable user meaning
    belongs to its owning durable domain
```

The most important question the audit must answer is:

> **Can we replace the entire Presence guidebook on a generation change, rather than maintaining a migration/reconciliation history of every Schedule, Trip, Step, and piece of prose MessageLens has ever shipped?**

If yes, explain the smallest safe lifecycle that makes that true.

If no, identify the **specific valuable fact** that prevents it from being true.