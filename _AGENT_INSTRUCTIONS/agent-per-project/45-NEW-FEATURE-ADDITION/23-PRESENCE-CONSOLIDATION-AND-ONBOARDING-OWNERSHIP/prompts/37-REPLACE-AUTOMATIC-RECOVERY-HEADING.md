Assuming Slice 38 has now landed, the next bounded change is the **recovery-copy truthfulness pass**: remove unsupported “previous/earlier attempt” language and vague “clearing that data” language, while leaving the recovery mechanism completely alone.

### 39 — Calm, Truthful Automatic-Recovery Copy

Implement the next bounded presentation correction identified by:

- `37-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md`
- `38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md`

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

The goal is:

> Replace the current automatic-recovery heading and explanatory paragraph with calm, phase-neutral wording that describes only what MessageLens actually knows: incomplete rebuildable browsing data has been detected, MessageLens is preparing for another setup attempt, and the human should wait.

Do not change automatic-recovery mechanics.

Do not change reset semantics.

Do not change environment classification.

Do not change Presence.

---

## 1. Current problem

The existing production recovery surface says approximately:

```text
Cleaning Up A Previous Setup Attempt

MessageLens detected signs that an earlier setup attempt left incomplete local
data. It is clearing that data now so setup can restart cleanly.
```

Audit 37 established several problems with this wording.

### “Previous” / “earlier setup attempt”

This is not reliably known.

Recovery may be inferred from:

- current database disparities;
- a caught failure from the same process;
- persisted coarse failure evidence;
- partial durable stores after an interrupted process.

There is no durable launch identity proving that the incomplete state came from a previous application launch.

### “local data”

This is too broad.

The operation actually targets only allow-listed **rebuildable MessageLens derived browsing stores**.

The phrase could reasonably sound as though MessageLens is deleting:

- Apple Messages;
- Contacts;
- locally available source attachments;
- archived attachment payloads;
- user overlays/preferences.

It is not.

### “clearing that data”

This foregrounds deletion while failing to define the narrow deletion boundary.

### “so setup can restart cleanly”

Automatic recovery does not restart setup.

It removes incomplete derived stores, re-evaluates the environment, and normally makes another human-started setup attempt possible.

---

## 2. Replace the heading

Replace:

```text
Cleaning Up A Previous Setup Attempt
```

with:

```text
Preparing MessageLens to try again
```

This wording is deliberately:

- calm;
- human-facing;
- free of unsupported history;
- truthful even before mutation admission has completed;
- independent of the exact recovery heuristic.

Do not use:

```text
Cleaning Up Failed Data
Repairing Your Messages
Restarting Setup
Recovering Your Messages
Deleting Incomplete Data
```

Those either overstate what is known, foreground destructive mechanics, or imply an automatic restart.

---

## 3. Replace the explanatory paragraph

Use:

```text
MessageLens found incomplete browsing data and is preparing for another setup attempt. Please wait.
```

A tiny grammatical/style adjustment is acceptable if existing copy conventions strongly require one, but preserve these exact ideas:

1. **incomplete browsing data** — not generic “local data”;
2. MessageLens is **preparing**;
3. another setup attempt becomes possible afterward;
4. the human should **wait**;
5. recovery itself does not automatically rerun setup.

Do not add more explanation merely because the screen now has space.

---

## 4. Do not add preservation reassurance

Do not add copy such as:

```text
Your original Messages are safe.
Your attachment archive will not be touched.
Nothing important will be deleted.
```

The attachment-preservation invariant makes those architectural boundaries important, but Audit 37 concluded that naming deletion targets in ordinary recovery copy may introduce anxiety the user did not have.

Use precise nouns instead:

```text
incomplete browsing data
```

That is sufficient for this slice.

---

## 5. Preserve the attachment-preservation invariant

This copy change must remain consistent with:

`27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`

The actual reset boundary remains:

```text
AUTHORITATIVE EXTERNAL SOURCES
    Apple Messages
    Apple Contacts
    locally available source attachment payloads
    NEVER reset targets

REBUILDABLE MESSAGELENS DERIVED STORES
    source-scoped import database
    Conversation Graph / working stores
    resettable

PRESERVATION DATA
    archived attachment payloads
    NEVER ordinary reset targets
```

Do not change any implementation of this boundary.

---

## 6. Preserve diagnostic-reason removal

Do not restore:

```text
resetAppDatabasesReason
import ledger
Conversation Graph
graph projection
row-count disparity
```

to the production recovery surface.

Those remain diagnostic information only.

---

## 7. Preserve the activity indicator

Keep the existing indeterminate recovery activity indicator.

Do not add:

- percentage;
- current stage;
- ETA;
- elapsed time;
- cancellation;
- Retry;
- Continue;
- Dismiss.

Recovery remains a non-interactive operation.

---

## 8. Preserve lifecycle semantics

Do not alter:

```text
environment inference
-> recoveringFailedAttempt
-> mutation admission
-> resetDerivedData()
-> clear recovery override
-> invalidate environment
-> awaitingUserAction
-> fresh environment classification
```

After successful recovery, setup does **not** start automatically.

Normally:

```text
recovery completes
-> environment becomes readyToImport
-> Import My Messages is offered
```

The new wording must remain truthful to that sequence.

---

## 9. Preserve recovery failure behavior

Do not change what happens if reset throws.

Current behavior remains:

```text
reset failure
-> logged
-> automatic retry suppressed for current Gate instance
-> recovery overlay cleared
-> awaitingUserAction
-> environment determines next surface
```

Do not add a recovery-failure screen in this slice.

That remains a separate operational concern.

---

## 10. Preserve mutation-admission behavior

Automatic recovery may briefly enter its presentation state before mutation admission succeeds.

Therefore:

```text
Preparing MessageLens to try again
```

must remain truthful even if admission is subsequently denied and no reset occurs.

Do not change admission ordering or coordination.

---

## 11. Preserve abrupt-restart semantics

Do not imply:

```text
recovery will continue after restart
MessageLens will pick up where it stopped
recovery has a durable checkpoint
```

None of those is true.

The new copy makes no such promise.

---

## 12. Focused tests

Add/update production recovery presentation tests proving:

### New heading

Visible:

```text
Preparing MessageLens to try again
```

Absent:

```text
Cleaning Up A Previous Setup Attempt
previous
earlier setup attempt
```

### New body

Visible wording equivalent to:

```text
MessageLens found incomplete browsing data
preparing for another setup attempt
Please wait
```

Absent:

```text
local data
clearing that data
restart cleanly
```

### Diagnostic reason stays absent

Even with a populated `resetAppDatabasesReason`, the production surface must not display:

```text
import ledger
Conversation Graph
graph projection
row disparity
```

### Activity remains

The existing indeterminate activity indicator remains.

### No controls appear

No:

```text
Cancel
Retry
Continue
Dismiss
```

during recovery.

### Gate mechanics unchanged

Existing recovery tests continue proving one admitted reset and return to `awaitingUserAction`.

---

## 13. Development diagnostics remain unchanged

If development tooling deliberately displays the recovery reason or internal classification, retain it.

This slice changes **production human-facing copy only**.

---

## 14. Documentation

Create:

`39-CALM-TRUTHFUL-AUTOMATIC-RECOVERY-COPY-IMPLEMENTATION.md`

Record:

1. previous heading/body;
2. unsupported claims removed;
3. final heading;
4. final body;
5. why “browsing data” is the correct bounded term;
6. why no explicit attachment-preservation reassurance was added;
7. recovery mechanics unchanged;
8. diagnostics unchanged;
9. tests;
10. deviations from Audit 37.

If document 39 is occupied, use the next free number and proceed without asking for confirmation.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- changelog/version if current convention requires it.

---

## 15. Verification

Run:

- focused automatic-recovery presentation tests;
- OnboardingGate recovery tests;
- Environment Readiness recovery-classification tests;
- reset-service preservation tests where relevant;
- complete Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the production archive.

# Hard constraints

Do not:

- change recovery heuristics;
- change reset behavior;
- change mutation coordination;
- add recovery persistence;
- add automatic retry;
- add controls;
- add telemetry;
- restore diagnostic reason UI;
- change attachment archival;
- modify Presence;
- redesign recovery-failure handling.

If any of those appears necessary, stop and explain why.

# Success criterion

While recovery runs, the ordinary production surface should now be approximately:

```text
[activity/recovery icon]

Preparing MessageLens to try again

MessageLens found incomplete browsing data and is preparing for another setup attempt. Please wait.

[indeterminate activity]
```

The user should understand:

```text
Something incomplete was found.
MessageLens is handling it.
I do not need to diagnose it.
I should wait.
I will get another opportunity to start setup afterward.
```

They should not be asked to think about prior launches, import ledgers, Conversation Graphs, deletion mechanics, or recovery stages.

Stop after this bounded copy correction and report before addressing automatic-recovery failure behavior or any other onboarding concern.
