Implement the next bounded presentation correction identified by:

`33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md`

and preserve the completed simplification in:

`34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md`

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

The goal is:

> Remove the **Environment Summary** diagnostic card from the ordinary stable `importFailed` and `graphProjectionFailed` failure surfaces.

Do not remove the underlying environment/probe data.

Do not change support reporting.

Do not change retry, recovery, reset, failure persistence, or Presence.

The stable primary failure experience should move closer to:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

[Try Again]

[Send Report To Developer]

[support transport caption — retained for later review]
```

---

## 1. Scope

Apply this only to the stable:

```text
importFailed
graphProjectionFailed
```

branches.

Do not remove Environment Summary from other Onboarding / Environment Readiness surfaces where it may still serve a different purpose.

Do not modify source-readiness blocker screens.

---

## 2. Remove the Environment Summary card

Stop rendering the ordinary diagnostic summary containing facts such as:

```text
Full Disk Access
Messages database
Contacts database
Imported message data
Conversation browsing data
```

from the two stable setup-failure branches.

Do not replace it with:

```text
Technical Details
System Status
Diagnostics
Environment Details
```

or another disclosure.

Audit 33 concluded that the current support-report path already preserves the relevant evidence and no supported user decision depends on seeing these rows.

---

## 3. Why removal is safe

On the stable failure branches:

- higher-priority FDA/source blockers already have their own dedicated surfaces;
- current source availability does not select a different retry operation here;
- import-store / graph-store facts expose internal architecture;
- the human's supported actions remain retry or support reporting.

The Environment Summary therefore explains implementation state without changing what the human should do.

Do not invent a new action merely to justify keeping the information visible.

---

## 4. Preserve diagnostic evidence

Do not change:

- `OnboardingEnvironmentReport`;
- FDA/source/database probes;
- derived-store probes;
- database-health reports;
- persisted failure records;
- support-report headers;
- logs;
- pipeline audit logs.

The boundary should remain:

```text
ordinary stable failure UI
    calm human orientation + actions

support/developer diagnostics
    detailed environment and database evidence
```

---

## 5. Preserve primary failure copy

Keep unchanged:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.
```

Do not revisit heading/body copy in this slice.

---

## 6. Preserve branch-specific retry actions

Keep unchanged:

```text
importFailed
    -> Try Import Again

graphProjectionFailed
    -> Retry Import and Graph Build
```

Do not rename or unify them in this slice.

Do not change dispatch.

Both continue through the existing full reset-and-rebuild operation.

---

## 7. Preserve Send Report To Developer

Keep:

```text
Send Report To Developer
```

visible and functional.

Do not change:

- support-bundle generation;
- report contents;
- email/Finder fallback;
- snackbar feedback.

The support action remains the place where detailed technical evidence is useful.

---

## 8. Preserve transport caption for now

Do not remove or rewrite the paragraph explaining email/Finder transport.

Audit 33 identified it as probably unnecessary in the final minimal hierarchy, but it is intentionally a later bounded decision.

This slice removes only:

```text
Environment Summary
```

---

## 9. Preserve What to check removal

Do not accidentally restore:

```text
What to check
raw error
timestamp
previous-launch claim
phase-inference notes
```

Those were intentionally removed in Slice 34.

The two simplifications should compose.

---

## 10. Automatic recovery remains untouched

Do not change:

```text
Cleaning Up A Previous Setup Attempt
resetAppDatabasesReason
recoveringFailedAttempt
```

Automatic recovery has its own information-hierarchy issues and remains a separate later slice.

---

## 11. Attachment-preservation boundary

Removing Environment Summary must not change any storage or reset behavior.

Continue to preserve the hard categories:

```text
AUTHORITATIVE EXTERNAL SOURCES
    Apple Messages
    Apple Contacts

REBUILDABLE MESSAGELENS DERIVED STORES
    source-scoped import database
    Conversation Graph / working stores

PRESERVATION DATA
    archived attachment payloads
```

No archive behavior changes are allowed.

---

## 12. Focused tests

Add/update stable failure presentation tests proving:

### importFailed

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
Environment summary
Full Disk Access
Messages database
Contacts database
Imported message data
Conversation browsing data
What to check
```

### graphProjectionFailed

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
Environment summary
Full Disk Access
Messages database
Contacts database
Imported message data
Conversation browsing data
What to check
```

### Diagnostics retained

Existing support-report tests must continue proving the environment/probe evidence is still included where currently expected.

Do not remove those facts merely to make widget tests pass.

### Other readiness surfaces unaffected

If there are tests for blocker/readiness surfaces that legitimately use Environment Summary, prove they remain unchanged.

---

## 13. Layout verification

Re-run the stable failure surfaces at default typography.

Do not:

- add scrolling;
- enlarge the card;
- shrink text;
- reduce spacing merely for fit.

Report whether the now-minimal surface fits naturally.

If it does not, document the remaining legitimate content causing the issue before changing geometry.

---

## 14. Architecture tripwires

Where practical, update existing presentation protections so the stable setup-failure branches do not directly render environment/probe summaries.

Do not create a new architecture-test framework.

Support/report code remains allowed to consume that evidence.

---

## 15. Documentation

Create:

`35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md`

Record:

1. component removed;
2. why it does not alter the human decision;
3. diagnostic evidence retained;
4. retry/support behavior preserved;
5. transport caption retained for later review;
6. other Environment Summary uses preserved;
7. layout result at default typography;
8. tests;
9. deviations from Audit 33.

If document 35 is occupied, use the next free number and proceed without asking for confirmation.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- changelog/version if current project convention requires it for user-visible changes.

---

## 16. Verification

Run:

- focused stable-failure widget tests;
- Environment Readiness failure/blocker tests;
- support-report tests;
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

- change environment-report semantics;
- delete probe evidence;
- change failure persistence;
- change retry labels/actions;
- change support-report behavior;
- change transport caption;
- change automatic recovery;
- change reset;
- change attachment handling;
- modify Presence;
- add Technical Details;
- add scrolling or other geometry changes merely to preserve removed diagnostics.

If any of those appears necessary, stop and explain why.

# Success criterion

The ordinary stable failure hierarchy should become:

```text
[failure icon]

MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

[Try Again]

[Send Report To Developer]

[support transport caption]
```

The user should no longer be asked to inspect environment/database state that does not change their next action.

All diagnostic evidence must remain available through support/developer systems.

Stop after this bounded removal and report before reviewing the support-transport caption or automatic-recovery presentation.

That should take us very close to the calm failure hierarchy Audit 33 recommended.
