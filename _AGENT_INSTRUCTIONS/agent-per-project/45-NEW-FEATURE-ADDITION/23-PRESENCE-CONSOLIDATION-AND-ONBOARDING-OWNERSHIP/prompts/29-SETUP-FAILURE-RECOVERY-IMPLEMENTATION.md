Implement the single bounded presentation correction recommended by:

`30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md`

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

The goal is:

> Prevent raw controller exception text from becoming the active setup/rebuild progress headline during failure handoff.

Do not redesign the stable failure screen.

Do not change error persistence.

Do not change retry/recovery.

Do not change controller semantics.

Do not change Presence.

## 1. Current defect

When:

```text id="hcn2ae"
ConversationGraphBuildController
    -> status = failed
```

while `OnboardingGate` still owns:

```text id="a1m1xt"
buildingGraph
or
reimportBuildingGraph
```

the progress presentation currently uses:

```text id="ux90dh"
ConversationGraphBuildState.lastError
```

verbatim as the headline.

That value comes from `error.toString()` and may contain:

- SQLite details;
- SQL;
- file paths;
- provider/service names;
- implementation terminology;
- long third-party exception messages.

It is diagnostic text, not human-facing orientation.

## 2. Replace only the active-progress failed headline

For controller status:

```text id="21uzmh"
failed
```

inside the existing active progress presentation, show one fixed, phase-neutral statement.

Preferred wording:

```text id="h0lf7j"
MessageLens couldn't finish preparing browsing data.
```

If current style conventions strongly favor a tiny wording adjustment, keep it equally phase-neutral and bounded.

Do not say:

```text id="2v0ivx"
Import failed
Graph build failed
Projection failed
Messages import failed
```

because the exact failed phase is not reliably known.

## 3. Preserve raw diagnostic evidence

Do not remove or sanitize `lastError` from:

- `ConversationGraphBuildState`;
- logs;
- persisted failure records;
- support-bundle generation;
- developer diagnostics;
- tests of diagnostic behavior.

This slice changes only where that value is shown in the **primary active-progress headline**.

The distinction is:

```text id="e14spr"
human headline
    bounded phase-neutral truth

diagnostics
    raw error preserved
```

## 4. Preserve Gate/controller handoff

Do not change:

- controller failed-state timing;
- Gate catch behavior;
- `saveGraphProjectionFailure()`;
- environment invalidation;
- stable failure surface;
- automatic recovery;
- retry;
- reset.

The transient failure window may still exist.

Its presentation just becomes safe and bounded.

## 5. First-run and direct reimport

Apply the same fixed headline to both:

```text id="hpxp5u"
buildingGraph
reimportBuildingGraph
```

when the controller is failed.

Do not create separate failure strings unless current presentation conventions make one shared string grammatically impossible.

The coarse truth is the same:

```text id="qlhsm5"
browsing-data preparation did not finish
```

## 6. Preserve preparation precedence

Do not disturb the recently implemented rule:

```text id="tnxkwf"
Gate = importing
    -> Preparing setup…
```

even if the keep-alive controller still contains an old failed state.

The ordering remains:

```text id="6wt1kh"
fresh preparation
    -> Gate preparation headline wins

active controller lifecycle
    -> controller state may drive running/succeeded/failed presentation
```

## 7. Focused tests

Add/update widget tests proving:

### Technical raw error is hidden from headline

Supply failed controller state with deliberately technical text such as:

```text id="jnqvwg"
SQLiteException(1): no such table...
/Users/example/Library/...
```

Prove the active progress surface shows:

```text id="t3d54r"
MessageLens couldn't finish preparing browsing data.
```

and does **not** show the raw error string.

### Raw error remains in controller state

Prove the diagnostic value is still available from the controller state.

Do not weaken diagnostic tests.

### First-run

Failed controller under first-run active build shows the bounded headline.

### Reimport

Failed controller under direct-reimport active build shows the same bounded headline.

### Preparation still wins

Seed stale failed controller state while Gate is:

```text id="ur6trj"
importing
```

Prove the headline remains:

```text id="wq84h8"
Preparing setup…
```

### Existing running/success states unchanged

Prove:

```text id="42apx1"
running
    -> Building browsing data…

succeeded
    -> existing success/progress behavior
```

remains unchanged.

## 8. Do not touch stable failure content yet

Leave current stable surfaces unchanged, including:

```text id="wi0aya"
Import Attempt Failed
Messages Could Not Be Prepared
raw diagnostic notes
timestamps
reset reasons
retry labels
Send Report To Developer
```

Audit 30 found real issues there, but they are explicitly later slices.

Do not bundle them into this correction.

## 9. Documentation

Create:

`31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md`

Record:

1. previous raw-headline behavior;
2. final fixed wording;
3. why phase-neutral wording is required;
4. confirmation that raw error evidence remains diagnostic;
5. first-run/reimport behavior;
6. preparation precedence;
7. tests;
8. deviations from Audit 30.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

If document 31 is already occupied, use the next free number and report the adjustment without asking for confirmation.

## 10. Verification

Run:

- focused progress failure widget tests;
- onboarding overlay tests;
- controller tests;
- Gate failure tests;
- complete Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the production archive.

# Hard constraints

Do not:

- change controller error capture;
- change persistence;
- change failure taxonomy;
- change stable failure surfaces;
- change retry;
- change recovery;
- change reset;
- add stage identity;
- add durable job state;
- modify Presence;
- change attachment handling;
- remove raw diagnostic evidence.

If implementation appears to require any of those, stop and explain why.

# Success criterion

During the controller-to-Gate failure handoff, the human may see:

```text id="4uymvp"
MessageLens couldn't finish preparing browsing data.
```

They must never see an arbitrary raw exception as the primary progress headline.

The raw error remains available to diagnostics and support, exactly where it belongs.

Stop after this bounded slice and report before stable failure-surface refinement begins.
