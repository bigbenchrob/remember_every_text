Implement the next bounded onboarding slice identified by:

`19-POST-READINESS-ONBOARDING-HANDOFF-AUDIT.md`

The defect to repair is:

> A completed required-sources Presence Schedule is the durable authority that the user has accepted source readiness, including the `import_anyway` path, but the production Environment Readiness panel still derives its action solely from `OnboardingEnvironmentReport`.

As a result, a sparse source can be durably accepted in Presence and still reveal only **Re-check** instead of **Import My Messages** after the Presence surface disappears.

This slice must repair **that handoff only**.

Do not redesign import.

Do not move import into Presence.

Do not add a new Step type.

Do not add a new acceptance flag.

Do not change `OnboardingEnvironmentReport` factual meaning.

---

## 1. Governing truth model

Preserve these as distinct truths:

```text
OnboardingEnvironmentReport
    = current machine/environment facts

completed required-sources Presence Schedule
    = durable evidence that required source readiness has been accepted

Onboarding import-readiness handoff
    = combines those truths to decide whether import may be offered
```

Do not make the environment report claim that sparse history is sufficient when it is not.

A source may remain:

```text
sourceSparseOrUnsynced
```

while the completed Presence Schedule truthfully means:

```text
the user knowingly accepted continuing with that source
```

---

## 2. Read the current production action-selection path first

Before editing, trace exactly how the Environment Readiness panel currently decides between:

```text
Confirm Local Messages History
Ready To Import
Retry Setup
```

and where **Import My Messages** becomes available.

Identify the smallest place where completed required-source Presence state can influence that presentation/action decision without contaminating environmental fact production.

Do not immediately alter `OnboardingEnvironmentReport`.

Prefer composition at the application/presentation decision boundary.

---

## 3. Add a read-only accepted-readiness query

Provide the smallest read-only application-facing way to answer:

> Has the required-sources Presence Schedule durably completed?

Use the existing Schedule run in `presence.db`.

Do not inspect trace.

Do not infer completion from the last Trip name.

Do not add another persisted Boolean.

The source of truth is the existing Presence run checkpoint:

```text
currentTripOccurrenceId == null
```

for the canonical required-sources Schedule run.

Follow existing repository/provider architecture.

The query should be semantically narrow: accepted required-source readiness, not generic “Presence complete” UI state if that would leak abstraction upward unnecessarily.

---

## 4. Derive import eligibility from both authorities

At the existing Onboarding handoff boundary, derive the user-facing import opportunity from:

```text
current environment facts
+
durable required-source acceptance
```

The required cases are:

### Ordinary sufficient path

```text
environment = readyToImport
Presence accepted = true
```

Result:

```text
existing Ready To Import surface
Import My Messages available
```

No behavioral change.

### Sparse but explicitly accepted

```text
environment = sourceSparseOrUnsynced
Presence accepted = true
```

Result:

```text
existing Ready To Import / import action becomes available
```

Do not show the old “only Re-check” dead end.

Do not erase or falsify the sparse fact.

If useful, the existing import-readiness copy may continue to describe what will happen next; do not invent a second acceptance screen.

### Sparse and not accepted

```text
environment = sourceSparseOrUnsynced
Presence accepted = false
```

Result:

```text
existing Confirm Local Messages History behavior
Re-check only
Presence flow remains responsible for acceptance
```

### Derived stores already ready

Preserve existing behavior.

Do not force an import surface merely because Presence is complete.

### Active recovery / caught failure

Preserve existing truthful recovery/retry behavior.

Presence acceptance must not override operational facts that legitimately block or alter import.

---

## 5. Do not change Presence completion semantics

Do not alter:

```text
required_sources_confirmation
ScheduleRun completion
currentTripOccurrenceId == null
```

The completed run already contains the durable truth we need.

This slice consumes that truth.

It does not change how Presence produces it.

---

## 6. No new acceptance persistence

Explicitly do not add:

```text
acceptedSparseHistory
sourceReadinessAccepted
importAnywayAccepted
readyToImportOverride
```

to:

- `presence.db`;
- overlays;
- preferences;
- Onboarding state;
- environment report;
- provider-local durable storage.

The whole point of this slice is to use the durable workflow result that already exists.

---

## 7. Do not inspect ChoiceValue history

The handoff should not need to know whether completion came from:

```text
history sufficient
```

or:

```text
import_anyway
```

If the required-sources Schedule is complete, that Schedule has already established the accepted outcome.

Do not read trace to look for `import_anyway`.

Do not persist or recover the selected ChoiceValue.

Completion is the contract.

This keeps the handoff independent of how the Schedule arrived there.

---

## 8. Preserve restart behavior

Prove:

### Sparse accepted, then quit

After:

```text
sparse
-> Import Anyway
-> required_sources_confirmation
-> Schedule complete
```

quit before starting import.

Relaunch.

Expected:

```text
Presence remains complete
environment still sparse
handoff still exposes Import My Messages
```

No user re-acceptance required.

### Sparse not yet accepted, then quit

Expected:

```text
Presence resumes current Trip
handoff does not prematurely expose import
```

### Sufficient accepted, then quit

Expected existing import-ready behavior.

---

## 9. Preserve operational authority

`OnboardingGate` still owns:

- pre-mutation FDA re-check;
- archive mutation admission;
- derived-data reset coordination;
- graph-build coordination;
- recovery;
- failure persistence.

Do not bypass `OnboardingGate.startImportAndGraphBuild()`.

The existing **Import My Messages** action should still call the existing operational path.

The handoff determines only whether that existing action is truthfully available.

---

## 10. Avoid parallel workflow state

Do not introduce a new enum case merely to represent:

```text
Presence accepted but environment sparse
```

unless the existing presentation decision model absolutely requires one.

Prefer a derived application/presentation model.

If a small value object is helpful, keep it non-durable and narrowly scoped to the handoff.

Do not create another lifecycle authority.

---

## 11. Focused tests

Add tests proving at least:

### Sparse accepted

Drive the real required-sources Schedule through:

```text
history false
-> guidance
-> import_anyway
-> confirmation
-> complete
```

with environment report still:

```text
sourceSparseOrUnsynced
```

Prove production exposes:

```text
Import My Messages
```

### Restart after sparse acceptance

Recreate repository/providers from the same persisted `presence.db`.

Prove import remains available.

### Sparse unaccepted

With incomplete Presence Schedule and same sparse report:

```text
Import My Messages
```

must not be available.

### Sufficient path

Preserve existing ready-to-import behavior.

### Already-ready derived databases

Preserve `notNeeded` / ordinary app behavior.

### Recovery

If current environment truth says recovery/retry is required, Presence completion must not incorrectly force normal import readiness.

### Failure state

Preserve existing retry semantics.

### No trace dependency

Prove completion query works without using execution trace.

### No ChoiceValue dependency

The handoff should behave identically regardless of whether Schedule completion was reached through sufficient history or `import_anyway`.

---

## 12. Architecture tripwires

Protect these boundaries:

- environment fact production must not import Presence choice semantics;
- no `import_anyway` string parsing outside workflow definition/tests;
- no new durable acceptance flag;
- handoff may read Presence run completion but not trace;
- Presence must not depend on `OnboardingGate`;
- existing import action still delegates to `OnboardingGate`;
- operational code does not move into Presence.

Do not invent a new architecture-test framework.

---

## 13. Documentation

Create:

`20-DURABLE-ACCEPTED-READINESS-IMPORT-HANDOFF-IMPLEMENTATION.md`

Document:

1. exact defect repaired;
2. final source of accepted-readiness truth;
3. final handoff composition;
4. why environment facts remain unchanged;
5. sparse accepted behavior;
6. sparse unaccepted behavior;
7. restart behavior;
8. operational authority preserved;
9. confirmation that no acceptance flag or trace lookup was added;
10. tests;
11. deviations from Audit 19.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- any current onboarding-readiness document whose handoff description becomes stale.

Do not rewrite historical implementation records.

---

## 14. Verification

Run:

- focused accepted-readiness handoff tests;
- production Onboarding host tests;
- required-sources workflow tests;
- Presence runner tests;
- complete Presence/Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not perform a direct production launch if that risks the real production archive or identity.

---

# Hard constraints

Do not in this slice:

- change schema;
- add acceptance persistence;
- add a new Step type;
- add ActionStep;
- move import into Presence;
- modify graph-build lifecycle;
- redesign progress UI;
- alter environment fact semantics;
- inspect trace to recover acceptance;
- inspect selected ChoiceValue to recover acceptance;
- reset Schedule runs;
- change restart semantics;
- alter FDA behavior;
- add a second import screen.

If any of those appears necessary, stop and explain why.

---

# Success criterion

At the end of this slice:

```text
Environment says:
    source is sparse

Presence says:
    required-source workflow is durably complete

Production handoff says:
    the human has accepted this source
    therefore the existing Import My Messages action is available
```

while:

```text
environment fact remains sparse
Presence remains workflow authority
OnboardingGate remains operation authority
no new durable state exists
```

The disappearing Presence surface should no longer reveal a contradictory dead end.

Stop after this handoff repair and report before evaluating the import operation lifecycle itself.
