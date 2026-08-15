Implement the next bounded failure-presentation correction identified by:

`30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md`

and preserve the completed transient-headline correction in:

`31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md`

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

The goal is:

> Replace phase-specific or overcommitted **primary stable failure copy** with one calm, phase-neutral account of what MessageLens actually knows.

Do not redesign failure diagnostics.

Do not change retry mechanics.

Do not change persistence.

Do not change recovery.

Do not change Presence.

---

## 1. Governing truth

For a caught controller-lifecycle failure, MessageLens reliably knows:

```text
the attempt did not complete normally
browsing data preparation did not finish
the operation has stopped
another attempt may be offered
```

It does **not** reliably know:

```text
source import completed
graph projection was the failing phase
a particular orchestrator stage failed
the persisted record came from a previous launch
no partial derived data exists
```

Primary failure copy must stay inside the first set.

---

## 2. Replace the stable primary heading

For the current stable setup/build failure presentation, prefer one shared phase-neutral heading:

```text
MessageLens couldn't finish setup
```

If the existing component structure makes this wording awkward for the shared first-run/reimport surface, a tiny equivalent adjustment is acceptable, but it must remain:

- human-facing;
- phase-neutral;
- bounded;
- free of import/projection terminology.

Do not use:

```text
Import Attempt Failed
Graph Build Failed
Projection Failed
Import Failed
```

as the primary ordinary-user heading for the active caught-controller path.

---

## 3. Replace the primary explanatory paragraph

Use one short statement conveying the human result and next possibility.

Preferred shape:

```text
MessageLens couldn't finish preparing your browsing data. You can try again.
```

or a very small stylistic equivalent if project conventions strongly favor one.

Do not say:

```text
MessageLens imported source data, but...
The graph could not be completed...
Import finished, but...
The failure happened while preparing imported data...
```

because current persisted evidence does not prove those phase boundaries.

---

## 4. Apply phase-neutral copy across the stable caught-build surfaces

Inspect the current:

```text
importFailed
graphProjectionFailed
```

presentation branches.

Where they ultimately represent the same coarse human truth—

```text
a prior/current setup attempt did not complete
```

—use the same calm primary heading/body unless a currently proven factual distinction genuinely changes what the human must understand.

Do not preserve two different primary narratives merely because historical persistence has two bucket names.

Do not change the persistence buckets themselves.

---

## 5. Do not change diagnostic detail yet

Leave the existing secondary material untouched in this slice unless its compilation directly depends on the primary copy.

That includes, for now:

- raw persisted error notes;
- timestamps;
- environment summaries;
- reset reasons;
- `What to check`;
- report-export guidance;
- support bundle behavior.

Audit 30 found issues with several of these, but they belong to later bounded work.

This slice fixes the **primary orientation layer only**.

---

## 6. Preserve retry actions

Do not change current retry button labels or behavior in this slice.

Keep the existing actions wired to:

```text
OnboardingGate.startImportAndGraphBuild()
```

and preserve:

```text
reset rebuildable derived stores
-> run all build stages again
```

No resume behavior is added.

No new ChoiceStep or Presence interaction is introduced.

---

## 7. Preserve support-report action

Do not remove or redesign:

```text
Send Report To Developer
```

The audit concluded that the capability is useful diagnostic/support functionality even if its eventual visual hierarchy may change.

Leave it working exactly as today.

---

## 8. Preserve attachment-safety language

The new primary copy must not imply:

```text
everything was deleted
everything will be rebuilt
all attachments are preserved
all attachments can be recovered
all source material was copied
```

Remember:

```text
resettable
    rebuildable MessageLens derived stores

preserved
    archived attachment payloads

external sources
    Apple Messages / Contacts
```

Do not add new reassurance claims merely to make the failure screen sound friendlier.

---

## 9. Preserve abrupt-termination ambiguity

Do not introduce copy saying:

```text
during your previous launch
last time MessageLens ran
the previous import failed at...
```

Persistence does not prove launch identity.

If existing **primary** explanatory copy contains such a claim, remove or replace that primary claim with phase-neutral wording.

Do not redesign secondary timestamp/diagnostic presentation yet.

---

## 10. First-run and reimport

Use the same stable primary failure language wherever possible.

Current operation evidence supports a shared coarse truth:

```text
MessageLens couldn't finish preparing browsing data.
```

Do not create separate first-run/reimport failure architectures.

The later retry journey may lose reimport context; that is a separate lifecycle issue.

---

## 11. Focused tests

Add/update production presentation tests proving:

### Stable caught-build failure

Visible:

```text
MessageLens couldn't finish setup
```

and phase-neutral explanatory copy.

### No unsupported import-complete claim

Primary failure content must not contain wording equivalent to:

```text
imported source data, but
import completed
graph alone failed
projection failed
```

### No launch-history claim in primary copy

Primary content must not assert:

```text
previous launch
last launch
```

merely because a persisted record exists.

### Retry still present

Existing retry action remains available and invokes the same Gate operation.

### Support action still present

`Send Report To Developer` remains functional where currently applicable.

### Diagnostics preserved

Where existing tests inspect raw persisted error information or report generation, preserve those tests and behavior.

Do not remove diagnostic evidence to satisfy the new primary-copy tests.

---

## 12. Do not touch automatic recovery yet

Leave:

```text
Cleaning Up A Previous Setup Attempt
resetAppDatabasesReason
automatic recovery progress
```

unchanged in this slice.

Audit 30 identified technical-detail issues there, but stable recovery presentation is a separate concern.

---

## 13. Do not solve reset failure reporting

Reset/admission failures currently lack a stable human-facing failure state.

That is real debt, but it requires operational analysis rather than merely changing caught-controller copy.

Do not fold it into this slice.

---

## 14. Documentation

Create:

`32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md`

Record:

1. previous stable headings/body;
2. final primary heading;
3. final primary explanation;
4. why phase-neutral wording is required;
5. persistence buckets unchanged;
6. retry/support behavior unchanged;
7. diagnostics intentionally retained;
8. attachment-preservation boundary;
9. tests;
10. deviations from Audit 30.

If document 32 is occupied, use the next free number and report the adjustment without asking for confirmation.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- changelog/version only if current project convention requires it for this user-visible copy change.

---

## 15. Verification

Run:

- focused stable-failure presentation tests;
- onboarding overlay tests;
- Environment Readiness failure-surface tests;
- OnboardingGate failure/retry tests;
- support-report tests if touched;
- complete Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the production archive.

---

# Hard constraints

Do not:

- change failure persistence;
- create a new error taxonomy;
- change controller error capture;
- change retry mechanics;
- change automatic recovery;
- change reset;
- alter support-bundle contents;
- remove diagnostic evidence;
- add stage identity;
- add durable job state;
- modify Presence;
- change attachment archival;
- redesign the entire failure card.

If any of those appears necessary, stop and explain why.

---

# Success criterion

The stable ordinary-user failure surface should answer:

```text
Did setup finish?
    No.

Do we know exactly which internal phase failed?
    Not reliably, and the UI does not pretend otherwise.

Can I try again?
    Yes, using the existing retry action.
```

The human should no longer be asked to reason about whether import, enrichment, joins, or Conversation Graph projection failed.

Stop after this bounded primary-copy correction and report before simplifying diagnostic detail or automatic-recovery presentation.

That keeps us on the same discipline as the successful path: **fix the first layer the human sees, then decide separately what secondary diagnostics deserve to remain visible.**
