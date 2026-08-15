Yes. This is now a direct implementation slice; Audit 33 already established that the transport paragraph is redundant while the support action itself remains useful. 33\-FAILURE\-DIAGNOSTIC\-INFORMATION\-HIERARCHY\-AUDIT.md

Implement the next bounded presentation correction following:

- `33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md`
- `34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md`
- `35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md`

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

The goal is:

> Remove the email/Finder transport-explanation caption from the ordinary stable setup-failure surfaces while preserving **Send Report To Developer** and all post-action feedback.

Do not change support-report generation.

Do not change retry, recovery, reset, failure persistence, or Presence.

---

## 1. Scope

Apply this only to the stable:

```text
importFailed
graphProjectionFailed
```

failure presentations.

Do not remove transport/help text from other parts of the application unless the same shared component is proven to be used exclusively by these two branches.

Search before changing shared presentation code.

---

## 2. Remove the pre-action transport explanation

Remove the ordinary explanatory text that tells the user, before they act, that MessageLens will:

- try to prepare/open an email;
- attach the support bundle when possible;
- otherwise reveal the bundle in Finder.

That transport mechanism does not change the human decision:

```text
Do I want to send diagnostic information to the developer?
```

The button label already expresses that action.

---

## 3. Preserve Send Report To Developer

Keep:

```text
Send Report To Developer
```

visible and functional.

Do not change:

- support-bundle contents;
- report generation;
- privacy bounds;
- email-draft behavior;
- Finder fallback;
- support email address;
- exporter APIs.

The capability remains intact.

---

## 4. Preserve post-action feedback

Keep the existing result-specific feedback after the user presses the support action.

Examples include current outcomes equivalent to:

```text
Email draft prepared with the support bundle attached.

Support bundle prepared and shown in Finder.

MessageLens could not prepare a diagnostic report right now.
```

These messages are useful because they tell the human what actually happened.

The distinction is:

```text
before action
    transport mechanics are unnecessary

after action
    transport result is useful
```

---

## 5. Preserve primary failure hierarchy

Keep unchanged:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.
```

Do not change primary copy.

---

## 6. Preserve retry actions

Keep current branch-specific retry labels/actions unchanged:

```text
importFailed
    -> Try Import Again

graphProjectionFailed
    -> Retry Import and Graph Build
```

Do not unify or rename them in this slice.

Do not change dispatch.

---

## 7. Preserve earlier removals

Do not restore:

```text
Environment Summary
What to check
raw error
timestamp
previous-launch narrative
phase-inference notes
```

The stable failure surface should continue composing all prior simplifications.

---

## 8. Preserve diagnostics

Do not alter:

- `OnboardingFailureStore`;
- environment probes;
- raw failure evidence;
- support-report headers;
- logs;
- pipeline audit logs;
- database-health reporting.

Removing explanatory transport copy from the UI must not remove any diagnostic data.

---

## 9. Automatic recovery remains out of scope

Do not change:

```text
Cleaning Up A Previous Setup Attempt
resetAppDatabasesReason
recoveringFailedAttempt
```

Recovery presentation is the next separate area to review after the stable failure screen is complete.

---

## 10. Focused tests

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

- email transport explanation;
- Finder fallback explanation;
- Environment Summary;
- What to check.

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

- email transport explanation;
- Finder fallback explanation.

### Support action still works

Invoke **Send Report To Developer** and prove:

- support generation still executes;
- the existing success/fallback/failure snackbar feedback still appears.

### Diagnostics preserved

Existing support-report tests continue passing unchanged.

---

## 11. Layout verification

Render both stable failure branches at default typography.

Do not add:

- scrolling;
- larger card geometry;
- smaller typography;
- tighter spacing.

Report whether the final minimal surface fits naturally.

---

## 12. Documentation

Create:

`36-REMOVE-SUPPORT-TRANSPORT-CAPTION-STABLE-FAILURE-IMPLEMENTATION.md`

Record:

1. caption removed;
2. why transport mechanics do not belong before the action;
3. support action preserved;
4. post-action feedback preserved;
5. diagnostic evidence preserved;
6. retry behavior unchanged;
7. final stable-failure reading order;
8. layout result;
9. tests;
10. deviations from Audit 33.

If document 36 is occupied, use the next free number and proceed without asking for confirmation.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- changelog/version if current convention requires it.

---

## 13. Verification

Run:

- focused stable-failure widget tests;
- support-report/action tests;
- Environment Readiness failure tests;
- OnboardingGate retry/failure tests;
- complete Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the production archive.

# Hard constraints

Do not:

- change support-report behavior;
- change report contents;
- change failure persistence;
- change retry labels/actions;
- change automatic recovery;
- change reset;
- change attachment handling;
- modify Presence;
- add Technical Details;
- alter snackbar feedback;
- add layout machinery.

If any of those appears necessary, stop and explain why.

# Success criterion

The ordinary stable setup-failure surface should now be:

```text
[failure icon]

MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

[Try Import Again / Retry Import and Graph Build]

[Send Report To Developer]
```

Nothing else should compete for ordinary reading order.

All technical evidence remains preserved behind support/developer infrastructure.

Stop after this bounded removal and report before beginning automatic-recovery presentation work.
