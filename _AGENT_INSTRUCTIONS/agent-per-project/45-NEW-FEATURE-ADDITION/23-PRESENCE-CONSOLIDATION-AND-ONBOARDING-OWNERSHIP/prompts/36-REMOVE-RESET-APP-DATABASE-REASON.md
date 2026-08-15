Implement the single bounded presentation correction recommended by:

`37-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md`

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

The goal is:

> Remove `resetAppDatabasesReason` from the ordinary production automatic-recovery surface while preserving the reason everywhere it currently serves diagnostic and classification purposes.

Do not change recovery mechanics.

Do not change reset behavior.

Do not change environment classification.

Do not change Presence.

---

## 1. Scope

Apply this only to the production automatic-recovery presentation associated with:

```text
recoveringFailedAttempt
```

Do not remove the reason from:

- environment reports;
- logs;
- development diagnostics;
- support evidence;
- tests that intentionally inspect classification.

---

## 2. Remove the bordered reset-reason card

Stop rendering the ordinary bordered card containing:

```text
resetAppDatabasesReason
```

from the production recovery widget.

Do not replace it with:

```text
Technical Details
Why this happened
More information
Recovery details
```

or another disclosure.

The audit concluded that no user action depends on the diagnostic reason.

---

## 3. Preserve current heading/body for now

Do not change the current recovery heading or explanatory paragraph in this slice.

Keep the existing:

```text
Cleaning Up A Previous Setup Attempt
```

and current body copy temporarily.

Audit 37 found those strings need a later truthfulness correction, but reason-card removal is mechanically separate and should remain one bounded change.

---

## 4. Preserve the activity indicator

Keep the existing indeterminate recovery activity indicator.

Do not add:

- percentage;
- stage;
- ETA;
- elapsed time;
- controls;
- cancellation.

The operation remains non-interactive.

---

## 5. Preserve resetAppDatabasesReason as diagnostic evidence

Do not remove or stop computing the field.

Preserve:

- `OnboardingEnvironmentReport.resetAppDatabasesReason`;
- environment classification logic;
- Gate logs;
- automatic-recovery logs;
- reset-service logs;
- development-panel display;
- support/diagnostic evidence.

The boundary should be:

```text
production ordinary recovery UI
    does not show heuristic reasoning

diagnostics
    retain heuristic reasoning
```

---

## 6. Preserve recovery lifecycle

Do not change:

```text
environment inference
-> recoveringFailedAttempt
-> mutation admission
-> resetDerivedData()
-> clear recovery override
-> invalidate report
-> awaitingUserAction
-> fresh environment classification
```

No automatic retry is added.

No resume behavior is added.

---

## 7. Preserve attachment-payload safety

Do not change the reset allow-list or any archive behavior.

The hard categories remain:

```text
AUTHORITATIVE EXTERNAL SOURCES
    Apple Messages
    Apple Contacts

REBUILDABLE MESSAGELENS DERIVED STORES
    import / graph stores

PRESERVATION DATA
    archived attachment payloads
```

Removing the reason card is presentation-only.

---

## 8. Preserve development diagnostics

If the development Onboarding panel deliberately shows the reset reason, keep it.

This slice is specifically about the production ordinary-user recovery surface.

Do not make production simplicity reduce development observability.

---

## 9. Focused tests

Add/update production recovery widget tests proving:

### Reason absent

Given an environment report with a non-null:

```text
resetAppDatabasesReason
```

the production recovery surface still shows:

- recovery heading;
- recovery body;
- activity indicator;

but does **not** show the reason text or its bordered card.

### Recovery still runs

Existing Gate tests continue proving:

```text
recoveringFailedAttempt
-> one reset operation
-> return to awaitingUserAction
```

### Diagnostics retained

Existing classification/log/development tests continue proving the reason still exists outside production ordinary UI.

### No new controls

Prove recovery remains non-interactive.

---

## 10. Layout verification

Render the recovery surface at default typography.

Do not:

- add scrolling;
- enlarge the card;
- reduce type size;
- tighten spacing.

Report whether the simplified surface fits naturally.

---

## 11. Documentation

Create:

`38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md`

Record:

1. reason card removed;
2. reason/classification evidence preserved;
3. production/development presentation distinction;
4. recovery mechanics unchanged;
5. attachment-preservation boundary unchanged;
6. layout result;
7. tests;
8. deviations from Audit 37.

If document 38 is occupied, use the next free number and proceed without asking for confirmation.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- changelog/version if current convention requires it.

---

## 12. Verification

Run:

- focused automatic-recovery presentation tests;
- OnboardingGate recovery tests;
- Environment Readiness classification tests;
- reset-service tests where relevant;
- complete Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the production archive.

# Hard constraints

Do not:

- change recovery heading/body;
- change environment heuristics;
- change reset semantics;
- remove resetAppDatabasesReason from data models;
- change mutation admission;
- add recovery controls;
- add telemetry;
- change support evidence;
- change development diagnostics;
- modify Presence;
- change attachment archival.

If any of those appears necessary, stop and explain why.

# Success criterion

During automatic recovery, the production user should no longer see implementation reasoning such as:

```text
import ledger
Conversation Graph
graph projection
row disparity
```

They should see only the existing human-facing recovery message and indeterminate activity.

All technical reasoning must remain available where it belongs: diagnostics, logs, and development tooling.

Stop after this bounded removal and report before correcting the recovery heading/body wording.
