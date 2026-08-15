### 56 — Fix Observed Production Onboarding Step-Redefinition Blocker

Investigate and correct the **observed production onboarding blocker** encountered during the manual production-shaped onboarding validation.

**This prompt is authorization to investigate and implement the smallest correct fix. Do not stop to ask for plan confirmation.**

Create:

`56-OBSERVED-ONBOARDING-STEP-REDEFINITION-BLOCKER-IMPLEMENTATION.md`

Continue using the `50-` document-number series.

## Observed production failure

During a normal production-shaped debug launch, after Environment Readiness had passed, MessageLens displayed:

```text
Unable to continue setup: Bad state: Existing Step 6302 in Trip
TripDefinitionId(303) cannot be redefined.
```

This was observed in the real onboarding journey, not the Presence development harness.

Treat this as a **P1 onboarding blocker**.

Do not dismiss it as test-state contamination.

Do not delete/reset `presence.db` to make the symptom disappear.

The requirement is that an existing MessageLens installation survive legitimate authored-onboarding evolution.

---

# 1. Preserve the production wiring

Validation 54 corrected normal debug launches so they use:

```text
production-shaped router
-> app shell
-> OnboardingGate
-> actual production Onboarding host
-> authored Schedule
-> real Agents
-> PresenceScheduler / PresenceRunner
```

The Presence development harness remains explicitly opt-in:

```bash
flutter run -d macos \
  --dart-define=PRESENCE_DEVELOPMENT_HARNESS=true
```

Do not regress this.

The observed error is valuable precisely because the Gate is now reaching the real authored onboarding flow.

---

# 2. Read before changing

Read at minimum:

- `54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md`
- `55-TRUTHFUL-MESSAGES-SOURCE-VS-FDA-READINESS-IMPLEMENTATION.md`
- canonical Presence persistence/schema documentation
- canonical Onboarding Schedule documentation
- current required-sources authored Schedule builder
- Schedule-definition extension/reconciliation code
- Presence repositories that persist/reconstruct:
  - Schedule definitions
  - Trip definitions
  - Step definitions
  - occurrences
- schema migrations relevant to Step/Trip definitions
- tests covering additive Schedule evolution
- tests covering existing runs/checkpoints surviving definition extension

Use code as source of truth.

---

# 3. Trace the exact identities first

Before editing anything, identify exactly:

```text
TripDefinitionId(303)
StepDefinitionId / Step identity 6302
```

Determine:

- what Trip 303 means in the current authored onboarding Schedule;
- what Step 6302 means today;
- what Step 6302 meant in the previously persisted definition;
- which slice/version originally introduced Step 6302;
- whether Slice 55 changed:
  - Step 6302 itself;
  - its type;
  - its payload;
  - its Agent ID;
  - its destination;
  - its Trip membership;
  - its position;
  - or only surrounding topology.

Do not infer this from numbering.

Trace it.

---

# 4. Establish the stored-versus-authored mismatch

The central question is:

> **What exact persisted definition is Presence protecting, and what exact current definition is trying to replace it?**

Produce a concrete comparison such as:

```text
Persisted Step 6302
    type:
    payload:
    Trip:
    position/occurrence:
    Agent/value/destination:

Current authored Step 6302
    type:
    payload:
    Trip:
    position/occurrence:
    Agent/value/destination:
```

Identify the first semantic difference that makes the repository say:

```text
cannot be redefined
```

Do not change the invariant until this comparison is understood.

---

# 5. Treat the redefinition guard as presumptively correct

The existing invariant:

```text
existing canonical Step identity
must not silently acquire different meaning
```

is valuable.

Do **not** solve this by weakening equality checks or allowing arbitrary overwrite of existing Step definitions.

In particular, do not implement:

```text
if definition exists:
    UPDATE it to whatever current code says
```

That could rewrite the meaning of:

- existing Schedule runs;
- historical trace;
- checkpoints;
- active Trip reconstruction.

The preferred fix should preserve immutable semantic identity.

---

# 6. Determine which class of defect this is

Classify the root cause into one of these shapes, or another code-proven shape.

## A. Authored identity reuse

A new semantic Step was accidentally assigned an existing Step ID.

Correct response likely:

```text
new semantic definition
-> new canonical StepDefinitionId
```

while preserving the old definition for existing persisted workflows.

## B. Occurrence movement incorrectly treated as definition mutation

The Step definition is semantically unchanged, but moving/reordering its occurrence caused the extension code to compare placement as though it were definition identity.

Correct response may belong in occurrence reconciliation rather than definition identity.

## C. Existing definition was legitimately extended in a supported additive manner

The extension mechanism may be failing to distinguish:

```text
new surrounding topology
```

from:

```text
redefinition of existing canonical object
```

## D. Slice 55 authored topology accidentally mutates an old Step

Slice 55 added source-classification topology and two Trips. It also retained existing canonical identities where possible.

Inspect this carefully, but **do not assume Slice 55 is the culprit merely because it was recent**.

## E. Earlier persisted development definition is incompatible with current canonical production topology

If so, determine whether this is:

- a legitimate migration problem that real installations can encounter; or
- an obsolete pre-release development-only definition that requires an explicit bounded migration.

Do not simply erase it.

---

# 7. Preserve the definitions / occurrences distinction

Keep the settled conceptual model:

```text
definition
    WHAT something is

occurrence
    WHERE that reusable definition is placed
```

A Step changing position in a Trip/Schedule must not require redefining what the Step _is_ if the current model supports occurrence identity separately.

Conversely, if the Step's semantic meaning changed, moving an occurrence must not be used to disguise a redefinition.

Use the correct layer.

---

# 8. Preserve existing runs and checkpoints

This is a hard requirement.

Any fix must account for existing:

```text
schedule_runs
current Trip occurrence
execution trace
persisted Schedule definitions
Trip occurrences
Step occurrences
```

Existing runs must not suddenly mean something different.

If a currently active run refers to the old Step/Trip topology, determine how current restart semantics handle it.

Remember:

```text
restart is Trip-granular
no current Step is persisted
current Trip occurrence is durable
```

Do not introduce Step-level resume state.

---

# 9. Inspect Schedule extension semantics

Trace the code path used when the production authored Schedule encounters an existing canonical definition.

Document what it currently permits:

```text
existing identical definition
    -> reuse

new definition
    -> insert

existing definition with changed semantics
    -> reject
```

Then inspect what happens to:

- newly added Trips;
- newly added Steps;
- reordered Trip occurrences;
- moved canonical confirmation occurrence;
- new destinations to existing Trips;
- added Choice/Test routing.

Determine whether the extension code already expresses the correct model and the authored IDs are wrong, or whether a bounded reconciliation capability is actually missing.

Prefer fixing authored identity misuse over expanding persistence machinery if that is sufficient.

---

# 10. Do not renumber casually

If Step 6302 needs a new identity, choose the new canonical ID according to the project's existing allocation convention.

Before assigning anything:

- search all Step IDs;
- search docs/tests/fixtures;
- ensure the new ID is unused;
- preserve the old definition rather than repurposing its ID.

Likewise for Trip IDs or occurrence IDs if the root cause lies elsewhere.

Document every identity change explicitly.

---

# 11. Inspect the Slice 55 topology carefully

Slice 55 currently states that the production Schedule became:

```text
readable?
    yes -> ordinary Contacts and history checks
    no  -> access denied?
               yes -> existing FDA remediation and verification
               no  -> Messages-source-unavailable guidance
                         -> continue
                         -> fresh readable check
```

and that two new Trips were added while existing occurrence identity was intended to remain compatible.

Verify that implementation against persisted identity rules.

Check especially whether:

- an old FDA TestStep was repurposed to mean `readable?`;
- an existing Step was changed from one Agent ID to another;
- a destination was changed in a way that belongs to a new definition;
- a Tell/Test Step's payload changed under the same ID;
- a Trip definition changed under a stable ID rather than adding/replacing occurrences appropriately.

Again: verify, do not assume.

---

# 12. Determine whether current user state is reproducible from fixtures

Create a focused test fixture representing the **pre-change persisted Schedule definition** that leads to:

```text
Existing Step 6302 in Trip 303 cannot be redefined
```

Then load the current authored topology over it.

The test should fail before the fix for the same reason observed manually.

Do not depend solely on the user's live `presence.db`.

If inspecting the live development `presence.db` is necessary to establish the exact old definition:

- inspect it read-only;
- preferably work from a copy;
- do not mutate or reset it during investigation;
- document what was learned.

Do not access or modify the production Messages/archive data.

---

# 13. Implement the smallest safe correction

Once root cause is proven, make the smallest fix.

Preferred characteristics:

```text
old semantic identities remain immutable
new semantic objects receive new identities
existing runs remain interpretable
new runs use current authored topology
no broad rewrite of Presence persistence
```

If an explicit migration/reconciliation step is required, scope it narrowly to the proven historical definition shape.

Do not create a general-purpose "rewrite Presence workflow definitions" mechanism.

---

# 14. If an explicit migration is necessary

If existing installations genuinely contain an old canonical definition that must coexist with a newer authored definition, design the migration around immutable history.

Possible safe shape:

```text
old Step definition remains
old occurrences/runs continue pointing to it

new authored Step definition gets new ID
new/current Schedule topology points to new definition
```

Do not mutate historical trace meaning.

If active Schedule runs require special reconciliation, derive it from Trip-granular restart semantics and document it.

No silent semantic rewrite.

---

# 15. Do not delete presence.db

This is a hard constraint.

Do not solve the observed blocker with:

```text
rm presence.db
reset Presence
clear app support
start onboarding from scratch
```

Those may make a development machine appear fixed while leaving the real upgrade defect intact.

The manual validation specifically exposed an **existing-installation evolution problem**.

Fix that problem.

---

# 16. No destructive workaround in onboarding

Do not make Onboarding react to:

```text
cannot be redefined
```

by deleting/rebuilding all Presence definitions.

Presence state is not disposable merely because authored workflow code changed.

Do not conflate:

```text
rebuildable browsing stores
```

with:

```text
workflow definition/run history
```

They have different ownership and durability semantics.

---

# 17. Preserve attachment safety

This defect is in Presence/Onboarding definition evolution.

There should be **no reason whatsoever** to touch:

- Message import databases;
- Conversation Graph reset;
- Apple Messages;
- Apple Contacts;
- source attachments;
- archived attachment payloads.

If the proposed fix requires any attachment/reset behavior, stop: the investigation has gone off course.

---

# 18. Preserve source-readiness correction

Do not regress Slice 55.

After the Step-definition blocker is fixed, the production onboarding flow must still distinguish:

```text
readable
accessDenied
unavailable
```

with:

```text
EPERM/EACCES -> FDA
other source failure -> non-FDA unavailable
```

Presence must still receive only generic Boolean TestAgent results.

Adjacent source classification Tests must still share one process-local observation, with retry performing a fresh probe.

---

# 19. Preserve Choice/history behavior

Do not change:

- Messages-history sufficiency thresholds;
- sparse-history topology;
- `Re-check`;
- `Import Anyway`;
- durable accepted-readiness;
- ChoiceStep semantics.

Unless the identity collision directly concerns one of those persisted definitions, leave them alone.

---

# 20. Preserve the Gate/harness boundary

Normal production-shaped debug launch must still use the real onboarding flow.

Do not "fix" the crash by routing debug builds back to the Presence harness.

Add/retain a regression test protecting:

```text
normal debug
    -> production-shaped onboarding

PRESENCE_DEVELOPMENT_HARNESS=true
    -> laboratory harness
```

---

# 21. Focused regression test for the exact blocker

Add a test reproducing the observed upgrade path.

Conceptually:

```text
persist old production Schedule topology
-> preserve existing run/checkpoint state if relevant
-> initialize current authored onboarding topology
-> extension succeeds
-> no "Step 6302 ... cannot be redefined"
```

Then prove:

- current authored topology is present;
- old semantic definition has not been silently rewritten;
- current/new occurrences point where intended;
- existing run/checkpoint remains valid.

This test is essential.

---

# 22. Definition immutability tests

Keep/add tests proving:

### Identical re-declaration

```text
same Step ID
same semantic definition
-> accepted/reused
```

### Genuine semantic redefinition

```text
same Step ID
different meaning
-> still rejected
```

The observed fix must not weaken this safety invariant.

### New semantic Step

```text
new Step ID
-> inserted safely
```

### Occurrence/topology evolution

Where supported:

```text
existing definition
new/repositioned occurrence
-> allowed without mutating definition
```

---

# 23. Active-run compatibility

If the relevant persisted topology can have an active run, add a fixture proving the supported behavior.

At minimum establish what happens when:

```text
existing schedule_run
-> current Trip occurrence belongs to pre-extension topology
-> app starts with current definitions
```

The result must be deterministic and consistent with Trip-granular restart.

Do not invent a Step-level migration.

If the current system deliberately completes old runs against old definitions and only new runs use new topology, document and test that.

If it deliberately extends the active Schedule compatibly, document and test that instead.

---

# 24. Improve the human error only if still useful

The root problem must be fixed.

Do not spend this slice redesigning generic definition-conflict UI.

If a truly incompatible future workflow definition can still be encountered, retaining a clear diagnostic error is acceptable.

Do not hide invariant violations behind a generic:

```text
Something went wrong
```

in developer diagnostics.

Ordinary onboarding should simply stop encountering this known legitimate evolution case.

---

# 25. Resume the manual validation only after automated proof

After the fix:

1. run the focused historical-definition upgrade fixture;
2. run Schedule/Presence persistence tests;
3. run Onboarding tests;
4. run full suite;
5. build normal debug app.

Then identify the manual step:

```text
launch the same existing development installation
without deleting presence.db
```

and confirm it now passes the point that previously produced:

```text
Existing Step 6302 in Trip 303 cannot be redefined
```

Do not claim this manual check succeeded unless it was actually performed.

---

# 26. Documentation

Create:

`56-OBSERVED-ONBOARDING-STEP-REDEFINITION-BLOCKER-IMPLEMENTATION.md`

Record:

1. exact observed exception;
2. production journey where it appeared;
3. persisted Step 6302 definition;
4. current authored Step 6302 definition;
5. exact semantic mismatch;
6. root cause classification;
7. why the immutability guard was correct or incorrect;
8. smallest implemented correction;
9. any new IDs allocated and why;
10. treatment of old definitions;
11. existing run/checkpoint compatibility;
12. authored Schedule after correction;
13. Slice 55 behavior preserved;
14. Gate/harness boundary preserved;
15. attachment/reset systems untouched;
16. regression fixture for the real upgrade path;
17. verification;
18. manual re-test still required/completed.

Update:

- package `00-START-HERE.md`
- Feature Addition `INDEX.md`
- `DOCUMENTATION_PASS_LOG.md`
- canonical Presence definition/persistence documentation if needed
- canonical Onboarding Schedule documentation if IDs/topology changed
- changelog/version according to project convention.

---

# 27. Verification

Run:

- exact historical-definition regression test;
- Presence definition repository tests;
- Presence persistence/migration tests;
- Schedule extension tests;
- active-run/checkpoint tests;
- required-sources authored Schedule tests;
- Slice 55 source-readiness tests;
- production router/composition tests;
- complete Onboarding suite;
- architecture tripwires;
- full test suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against or modify the production archive.

---

# Hard constraints

Do not:

- delete/reset `presence.db` as the fix;
- weaken canonical definition immutability generally;
- silently overwrite persisted Step meaning;
- renumber identities without tracing references;
- discard existing runs/checkpoints;
- add Step-level resume;
- change Presence grammar;
- change generic TestStep;
- regress Slice 55 FDA/source distinction;
- change ChoiceStep/history sufficiency;
- change reset;
- change mutation coordination;
- touch browsing databases merely to fix Presence definitions;
- touch archived attachments;
- route normal debug back to the Presence harness;
- chase unrelated edge cases discovered during investigation.

If the existing persisted definition cannot be safely reconciled without changing historical workflow meaning, stop and report the exact incompatibility before implementing a destructive migration.

# Success criterion

We should be able to explain the failure concretely:

```text
Step 6302 used to mean X.
Current code tried to make Step 6302 mean Y.
Presence correctly/incorrectly rejected that because Z.
The fix is ______.
```

And the actual upgrade path must become:

```text
existing installation
with existing presence.db
        ↓
launch current MessageLens
        ↓
current authored onboarding topology reconciles safely
        ↓
existing definitions/runs retain their historical meaning
        ↓
new onboarding flow continues
```

Most importantly:

> **Do not make a fresh install work. Make the existing installation that exposed this bug work without erasing its Presence history.**

After that, resume the manual visual onboarding pass from the exact point where this blocker appeared.
