Yes. I’d make this **analysis/design only** again. The overflow is evidence that we need to decide what deserves primary reading order before touching layout.

The implementation record explicitly says that raw errors, timestamps, environment summaries, **What to check**, and report-export guidance are all still present as secondary material, and that simplifying that hierarchy was intentionally deferred. 32\-PHASE\-NEUTRAL\-STABLE\-SETUP\-FAILURE\-COPY\-IMPLEMENTATION.md

Perform an **analysis/design audit only** of the secondary diagnostic information shown on the stable initial-setup failure surface.

**This prompt is authorization to perform the audit. Do not stop to ask for plan confirmation.**

Read first:

- `30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md`
- `31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md`
- `32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md`
- `27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`
- current stable failure widgets
- current Environment Readiness failure-surface model
- current support-report/export implementation
- current `OnboardingFailureStore`
- current environment-summary / `What to check` generation
- relevant widget tests, including the test-envelope overflow that surfaced during Slice 32

Use current code as source of truth.

Do not implement code.

Do not change failure persistence.

Do not change retry or recovery mechanics.

Do not change layout merely to make all existing content fit.

Do not change Presence.

The purpose of this audit is to answer:

> **After the calm primary failure message, what information does the human actually need to see immediately, what belongs behind secondary diagnostic access, and what should not appear in ordinary reading order at all?**

---

## 1. Start from the now-approved primary layer

Treat this as settled:

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.
```

Do not reconsider that wording in this audit.

The primary orientation layer is complete.

This audit begins **below it**.

---

## 2. Inventory every secondary element currently shown

For both stable failure branches, record every secondary element after the primary heading/body.

At minimum inspect:

- Environment summary;
- `What to check`;
- raw persisted error;
- failure timestamp;
- source-readiness information;
- imported/graph database facts;
- cleanup/reset reasoning;
- retry explanation;
- report-export explanation;
- **Send Report To Developer**;
- any technical labels or bordered diagnostic panels.

Record exact current wording where useful.

Distinguish:

```text
importFailed
graphProjectionFailed
shared content
branch-specific content
```

Do not simplify yet.

---

## 3. Classify each item by purpose

For every secondary item, classify it as one or more of:

```text
ACTION-CRITICAL
    changes what the human should do next

REASSURANCE
    helps the human understand what is safe / what will happen

SUPPORT
    helps them seek assistance

DIAGNOSTIC
    useful to development/support investigation

IMPLEMENTATION DETAIL
    true but exposes internal architecture

REDUNDANT
    repeats something already established more simply
```

Then answer:

> Does this item deserve to be visible without the human asking for more detail?

---

## 4. Use a strict primary/secondary rule

Evaluate this principle:

> **Ordinary reading order should contain only information that changes the human's understanding or next action.**

Everything else should be considered for:

```text
secondary disclosure
support report
developer diagnostics
removal from ordinary UI
```

Test every current note against this rule.

Do not retain something merely because it is technically accurate.

---

## 5. Audit the raw persisted error

The transient raw-error headline is already fixed, but the stable failure surface still exposes raw persisted error text in secondary content.

Determine:

- exactly where it appears;
- how visually prominent it is;
- whether it can contain paths, SQL, provider names, or arbitrary exception text;
- whether the human needs to read it to decide whether to retry;
- whether **Send Report To Developer** already preserves the useful diagnostic value.

Conclude one of:

```text
raw error belongs in ordinary secondary UI

raw error belongs behind explicit Technical Details

raw error belongs only in support/developer diagnostics
```

Do not implement the conclusion yet.

---

## 6. Audit the failure timestamp

Current persistence provides a timestamp but does not prove that the failure occurred during a previous launch.

Assess:

- whether timestamp changes the human action;
- whether it helps distinguish stale versus current failures;
- whether it mainly resembles an error log;
- whether it should remain visible only in diagnostics.

Also inspect any wording that says:

```text
previous launch
last launch
```

and identify whether it is still present below the primary layer.

Do not change it yet.

---

## 7. Audit Environment Summary

Inspect the current Environment Summary content.

Determine:

- what facts it shows;
- whether they are already represented elsewhere;
- whether they are understandable without MessageLens architecture knowledge;
- whether they change the retry decision;
- whether they are useful primarily for support.

Ask:

> If the user saw only the calm failure message and **Try Again**, what important decision would they be unable to make because the Environment Summary was absent?

If the answer is “none,” say so.

---

## 8. Audit “What to check”

Inspect how `What to check` is generated.

Classify every kind of note that can appear there.

Examples may include:

```text
source availability
persisted error text
timestamp
import/graph state
report-export advice
reset/recovery facts
```

For each, determine whether it is:

```text
genuine remediation guidance
diagnostic explanation
historical artifact
redundant support instruction
```

Pay particular attention to notes that sound actionable but do not actually change the next supported action.

---

## 9. Audit phase-specific diagnostic claims

Document 30 found secondary notes that still make unsupported claims, such as:

```text
imported data exists, therefore failure happened while preparing it for browsing
failure occurred during a previous launch
```

Verify whether those statements remain in current secondary content.

For each, classify:

```text
truthful
overcommitted
unsupported
```

Even if the eventual recommendation is simply to hide them behind diagnostics, record factual inaccuracies separately.

Do not silently preserve false copy merely because it is secondary.

---

## 10. Audit retry explanation

The actual retry truth is:

```text
retry
    -> reset allow-listed rebuildable derived stores
    -> run the whole build again from the beginning
```

It does not resume.

Determine whether the current stable surface explains this at all.

Ask:

- Does the human need to know it is a clean restart?
- Is that reassuring or unnecessarily technical?
- Would a short sentence help avoid a false expectation of resume?
- Does the retry button alone communicate enough?

Do not change the button or copy yet.

---

## 11. Audit Send Report To Developer hierarchy

Audit 30 concluded that report export is useful, but likely too prominent as a peer to retry.

Inspect current presentation:

```text
primary filled retry action
outlined Send Report To Developer
support-transport explanation
```

Assess whether:

- report export should remain visible immediately;
- it should be visually secondary;
- its explanatory transport details belong in ordinary reading order;
- support capability could survive even if ordinary failure UI were much simpler.

Do not redesign the report mechanism.

---

## 12. Audit automatic-recovery diagnostic detail separately

Do not redesign recovery in this audit, but compare its information hierarchy.

Current recovery may show:

```text
Cleaning Up A Previous Setup Attempt
resetAppDatabasesReason
```

with technical concepts such as import ledger, graph projection, and row-count disparity.

Determine whether the same hierarchy principle applies:

```text
human:
    MessageLens is cleaning up incomplete browsing data.

diagnostics:
    why probes decided cleanup was necessary
```

Do not implement recovery changes.

Record whether this should become a later separate slice.

---

## 13. Respect the attachment-preservation invariant

Secondary diagnostic wording must never muddy:

```text
rebuildable derived stores
archived attachment preservation data
Apple source data
```

Review any phrases such as:

```text
clearing data
resetting all data
starting from scratch
rebuilding everything
```

and identify whether an ordinary reader could interpret them as deleting:

- Apple Messages;
- Contacts;
- archived attachment payloads.

Do not add broad reassurance claims.

The goal is precise language, not “nothing can go wrong.”

---

## 14. Treat the layout overflow as evidence, not the problem

The Slice 32 implementation surfaced an existing issue:

> the complete secondary diagnostic stack can overflow the overlay's fixed test envelope at default test typography.

Do not solve that by:

```text
shrinking font
making the card arbitrarily taller
reducing spacing
making everything scroll
```

until the information hierarchy is decided.

Instead answer:

> If we remove/demote information that does not belong in ordinary reading order, does the overflow largely disappear naturally?

If yes, say so.

If substantial legitimate primary content still overflows, document the remaining layout need.

---

## 15. Compare three information hierarchies

Evaluate:

### A. Everything visible

```text
MessageLens couldn't finish setup

[human explanation]

Environment Summary
What to check
timestamp
raw error
reset reason
support guidance

Try Again
Send Report To Developer
```

### B. Calm primary + secondary support

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

Try Again

Send Report To Developer
```

with detailed diagnostics removed from ordinary reading order but retained in report/developer systems.

### C. Calm primary + explicit technical disclosure

```text
MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

Try Again

Technical details ▸
Send Report To Developer
```

with diagnostics available on demand.

For each assess:

- human comprehension;
- truthfulness;
- support value;
- cognitive load;
- implementation complexity;
- overflow risk;
- whether existing UI infrastructure already supports it.

Recommend one long-term hierarchy.

Do not implement a disclosure component merely because C may be architecturally attractive.

---

## 16. Determine whether Technical Details is earned

Conclude one of:

```text
A Technical Details disclosure is now earned.
```

or:

```text
A Technical Details disclosure is not yet earned; support reporting is sufficient.
```

If earned, identify the minimum content that belongs inside it.

Possible candidates:

```text
raw error
recorded timestamp
environment summary
reset/recovery reason
```

Do not design a generic disclosure framework.

This would be one local failure-details interaction only.

---

## 17. Determine what can disappear entirely from UI

Some diagnostic information may already exist in:

- logs;
- support bundle;
- developer diagnostics;
- database-health report.

For each current visible secondary item, ask:

> If we remove this from the ordinary UI, is any useful diagnostic evidence actually lost?

If no, it may not need a replacement disclosure at all.

This is important: do not assume every removed detail must move somewhere else.

---

## 18. Produce a proposed final reading order

Without implementing, show the recommended ordinary failure surface in order.

For example:

```text
[success/failure icon]

MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

Try Again

Send Report To Developer
```

or whatever the evidence supports.

Then separately list:

```text
not shown ordinarily
available diagnostically
```

Keep the proposal concrete.

---

## 19. Recommend exactly one next implementation slice

Choose the single highest-value bounded correction.

Potential examples:

```text
remove the Environment Summary / What to check diagnostic stack from ordinary failure UI

remove raw error/timestamp notes from ordinary UI

demote Send Report To Developer explanatory text

introduce one local Technical Details disclosure
```

Choose only one.

Use:

```text
Next concern:
Why it comes next:
Current defect:
Smallest implementation:
Owner:
Operation-layer changes:
Persistence impact:
Support-report impact:
Layout impact:
Test seam:
```

Do not bundle several hierarchy changes unless they are mechanically one presentation component whose removal is indivisible.

---

## 20. Explicitly assess whether layout work is still required

After applying the recommended information hierarchy conceptually, answer:

```text
Would the stable failure surface still require scrolling or other layout work?
```

If yes, explain why.

If no, state that the overflow was primarily an information-density problem rather than a geometry problem.

Do not implement scrolling.

---

## 21. Presence assessment

Confirm whether any Presence change is required.

Expected answer:

```text
No.
```

Failure diagnostics remain owned by Onboarding/support infrastructure.

---

## 22. Documentation output

Create:

`33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md`

If document 33 is already occupied, use the next free number and report the adjustment without asking for confirmation.

Include:

1. complete secondary-content inventory;
2. purpose classification;
3. raw-error audit;
4. timestamp audit;
5. Environment Summary audit;
6. What-to-check audit;
7. phase-specific secondary truth audit;
8. retry explanation;
9. support-report hierarchy;
10. recovery comparison;
11. attachment-preservation language check;
12. overflow assessment;
13. three hierarchy comparison;
14. Technical Details verdict;
15. removable-without-loss inventory;
16. proposed final reading order;
17. exactly one next slice;
18. remaining layout verdict.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not alter application code.

---

# Hard constraints

Do not:

- implement UI changes;
- add scrolling;
- reduce font sizes;
- change card dimensions merely to fit current content;
- change failure persistence;
- change retry;
- change recovery;
- change reset;
- change support bundle contents;
- delete diagnostic evidence from logs/reports;
- create a generic disclosure framework;
- modify Presence;
- change attachment archival.

This is analysis/design only.

---

# Success criterion

At the end of the audit, we should be able to answer:

> **Below the calm failure message, the human immediately needs to see **\_\_\_\_**. Everything else belongs **\_\_\_\_**.**

And we should know whether the current overflow problem is genuinely a layout problem—or simply the natural consequence of showing the user too much diagnostic material.

That should give us a principled answer to the overflow rather than “make the box bigger.”
