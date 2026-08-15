Implement the single bounded presentation correction recommended by:

`33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md`

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

The goal is:

> Remove the **What to check** diagnostic card from the ordinary stable-failure reading order for the two setup failure branches.

Do not replace it with a Technical Details disclosure.

Do not remove diagnostic evidence from persistence, logs, support reports, or developer tooling.

Do not change retry, recovery, reset, failure persistence, or Presence.

---

## 1. Scope

Apply this only to the stable:

```text
importFailed
graphProjectionFailed
```

failure presentations.

The settled primary layer remains:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.
```

Do not change it.

---

## 2. Remove the What to check card

Stop supplying/rendering the branch-specific **What to check** notes card on those two stable failure surfaces.

That removes ordinary display of material such as:

```text
raw persisted error
failure timestamp
"previous launch" claims
source/graph phase inference
clean import-pass explanation
duplicated Send Report To Developer guidance
```

Do not individually rewrite those notes.

The entire component is no longer justified in ordinary reading order.

---

## 3. Do not add Technical Details

Audit 33 concluded:

> A Technical Details disclosure is not yet earned.

The support-report path already preserves the useful diagnostic evidence.

Therefore do not replace the removed card with:

```text
Technical Details
Show Details
More Information
Error Details
```

or another disclosure mechanism.

Deletion is the intended simplification.

---

## 4. Preserve diagnostic evidence

Do not change:

- persisted raw failure strings;
- persisted timestamps;
- `OnboardingFailureStore`;
- environment probes;
- logs;
- pipeline audit logs;
- database-health reporting;
- support-bundle generation;
- report headers.

The rule is:

```text
ordinary UI
    does not show diagnostic stack

support/developer systems
    retain diagnostic evidence
```

---

## 5. Preserve Environment Summary for now

Do not remove or redesign the **Environment Summary** card in this slice.

Audit 33 concluded that it also belongs outside the long-term minimal hierarchy, but it is intentionally a later bounded decision.

This slice removes only:

```text
What to check
```

---

## 6. Preserve retry actions

Keep branch-specific retry actions unchanged:

```text
importFailed
    -> Try Import Again

graphProjectionFailed
    -> Retry Import and Graph Build
```

Do not rename them yet.

Do not change their dispatch.

Both must continue to invoke the existing full reset-and-rebuild operation.

---

## 7. Preserve Send Report To Developer

Keep:

```text
Send Report To Developer
```

visible and functional.

Do not change:

- export behavior;
- support-bundle contents;
- email/Finder fallback;
- snackbar feedback.

The support action remains the secondary diagnostic escape path.

---

## 8. Preserve support-transport caption

Do not remove the email/Finder explanatory paragraph in this slice.

Audit 33 recommends reviewing it later, but this implementation is one-component removal only.

---

## 9. Preserve automatic recovery

Do not change:

```text
Cleaning Up A Previous Setup Attempt
resetAppDatabasesReason
recoveringFailedAttempt
```

or any automatic-recovery presentation.

Recovery information hierarchy is a separate later slice.

---

## 10. Preserve attachment safety

Removing the card must not change any reset or archival behavior.

Continue to preserve the hard categories:

```text
REBUILDABLE
    MessageLens derived import / graph stores

PRESERVATION DATA
    archived attachment payloads

EXTERNAL SOURCES
    Apple Messages and Contacts
```

No archive behavior changes are permitted.

---

## 11. Focused tests

Add/update stable failure widget tests proving:

### Import failure

Visible:

```text
MessageLens couldn't finish setup
MessageLens couldn't finish preparing your browsing data.
You can try again.
Try Import Again
Send Report To Developer
```

Not visible:

```text
What to check
raw persisted error
previous launch
clean import pass
```

### Graph-projection bucket

Visible:

```text
MessageLens couldn't finish setup
MessageLens couldn't finish preparing your browsing data.
You can try again.
Retry Import and Graph Build
Send Report To Developer
```

Not visible:

```text
What to check
raw persisted error
previous launch
failure happened while preparing it for browsing
```

### Diagnostics remain preserved

Prove the same raw failure and timestamp still appear in the generated support report/header where current tests already cover them.

Do not weaken diagnostic-report tests.

### Environment Summary remains

Prove it is still present where currently expected.

### Support action remains

Prove report export still dispatches normally.

---

## 12. Overflow verification

Re-run the failure widget tests at the normal/default test typography.

Determine whether removal of **What to check** eliminates the previously observed overflow.

Do not:

- shrink text;
- increase the fixed card height;
- add scrolling;
- reduce spacing merely to force a pass.

Report the result.

If the reduced ordinary surface still overflows, document the remaining truthful content causing it and stop rather than introducing geometry changes.

---

## 13. Architecture tripwires

If practical, add or update protection ensuring that stable failure presentation does not directly expose:

```text
raw persisted failure strings
previous-launch narrative
phase-inference notes
```

Do not create a new architecture-test framework.

Diagnostic/report code must remain allowed to use those values.

---

## 14. Documentation

Create:

`34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md`

Record:

1. component removed;
2. categories of information removed from ordinary reading order;
3. confirmation that persistence/diagnostics retain the evidence;
4. Environment Summary retained for later review;
5. retry/support actions unchanged;
6. overflow result at default typography;
7. tests;
8. deviations from Audit 33.

If document 34 is occupied, use the next free number and proceed without asking for confirmation.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- changelog/version if current project convention requires it for user-visible changes.

---

## 15. Verification

Run:

- focused stable-failure widget tests;
- support-report tests;
- Environment Readiness failure tests;
- OnboardingGate retry/failure tests;
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
- delete raw diagnostic evidence;
- remove Environment Summary;
- add Technical Details;
- change retry labels/actions;
- change support-report behavior;
- change transport caption;
- change automatic recovery;
- change reset;
- change attachment handling;
- modify Presence;
- add scrolling or geometry changes merely to fit content.

If any of those appears necessary, stop and explain why.

---

# Success criterion

The ordinary stable failure hierarchy should become:

```text
[failure icon]

MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

[Environment Summary — retained temporarily]

[Try Again]

[Send Report To Developer]

[support transport caption — retained temporarily]
```

The **What to check** card and its raw/unsupported diagnostic material must no longer appear in ordinary reading order.

All diagnostic evidence must remain available through support/developer systems.

The previous overflow should be re-tested at normal typography rather than patched geometrically.
