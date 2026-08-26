Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for a bounded Journey-semantics audit and implementation.

Prompt 13 introduced the live Onboarding Journey path:

`Messages → History → Contacts → Ready → Import → Verify → Start`

Manual production-shaped testing showed that the Journey path works extremely well through Import.

However, the human perceived:

> **Import → Start**

with no perceptible Verify Episode.

Do NOT automatically solve this by adding an artificial dwell.

First determine whether `Verify` belongs on the human Journey path at all.

Suggested prompt name:

`14-AUDIT-ONBOARDING-JOURNEY-NODES-AND-VERIFICATION-GATE-SEMANTICS.MD`

# Governing distinction

Feature 28 must distinguish:

## Human Episode

A distinct part of the Journey whose meaning is useful to the human.

from:

## Mechanical gate

An internal predicate that must succeed before another Episode becomes constructible.

A gate can be architecturally essential without deserving a node on the human Journey path.

# Central question

For every current Journey node ask:

> Does this represent a distinct human-meaningful Episode, or merely implementation machinery / a completion predicate between Episodes?

Do not preserve a node merely because a typed internal state exists.

# Manual evidence

During a real production-shaped run:

- `Ready` was clearly perceptible;
- `Import` remained current while factual import/build substages advanced below;
- after import completed, the human perceived an immediate transition to `Start`;
- `Verify` was not perceptible.

The screenshots and human observation suggest durable verification may complete so quickly that it does not constitute a meaningful human Episode.

# Do not fake an Episode

Do NOT add:

- arbitrary 750 ms delay;
- artificial spinner;
- fake progress;
- minimum duration;

merely so the `Verify` ball can be seen.

A Journey path is not a demonstration of every internal state transition.

# Audit all seven nodes

Review:

- Messages
- History
- Contacts
- Ready
- Import
- Verify
- Start

For each document:

1. human meaning;
2. human action, if any;
3. authoritative entry predicate;
4. authoritative completion predicate;
5. typical duration;
6. whether distinct presentation exists;
7. whether the human benefits from knowing they are “in” this state;
8. whether it should remain a Journey node.

# Messages

Likely represents establishing access to local Messages data.

Confirm this is a real human Episode because the user may need to grant FDA or otherwise resolve source access.

# History

Confirm this represents a distinct human decision/understanding:

> the history MessageLens can import is the history currently stored on this Mac.

If the Episode merely performs an automatic check and immediately advances without human meaning, reconsider it.

If it presents count/date-range sanity evidence and allows the human to decide whether local history looks complete enough, it likely remains meaningful.

# Contacts

Reassess whether this is genuinely a distinct mandatory human Episode.

Prompt 12 noted Contacts remains required largely because the current pipeline imports it unconditionally.

Determine:

- whether Contacts access requires distinct human action;
- whether it is normally automatic;
- whether failure has its own blocker semantics;
- whether Contacts belongs as a node even if no intervention is normally required.

Do not make Contacts optional in this task unless architecture already supports that without redesign.

This audit may recommend a later Contacts-specific slice.

# Ready

Confirm `Ready` is a meaningful Episode.

It currently provides:

- Everything is ready;
- source message count;
- Import My Messages authorization.

This appears human-significant and should likely remain.

# Import

Confirm Import is a meaningful long-running Episode.

Existing Narrator + Directed Instrumentation live inside it.

Keep internal substages out of the Journey path.

# Verify

Audit exactly what occurs between:

last import/build work
→ durable installation completion
→ `readyToStart`.

Measure representative duration.

Identify:

- database checks;
- installation classification;
- graph/import reconciliation;
- integrity/readiness predicates.

Determine whether the human has:

- anything to do;
- anything meaningful to understand;
- enough duration to perceive it naturally.

# Preferred Verify outcome if evidence supports it

If Verify is an internal fast mandatory predicate:

REMOVE `Verify` from the human Journey topology.

Do NOT remove verification itself.

The architecture should become:

`Import`
→ mandatory internal durable verification gate
→ `Start` becomes constructible only on success.

Thus:

> The existence of `Start` is itself the human-visible receipt that verification succeeded.

This preserves Mechanical Impossibility while simplifying the Journey.

# Verification failure

If the hidden verification gate fails:

do NOT advance to Start.

Journey should remain owned by Onboarding and enter the appropriate typed failure/remediation Episode.

The path may remain on Import or project a failure state according to the Coordinator's semantics.

Do not create a fake completed Import→Start transition.

Determine the cleanest representation.

# Internal coordinator state

It is acceptable for the typed Coordinator to retain an internal `verifying` state even if the Journey path does not render it as a node.

Do not contort the domain model to match the number of balls.

Separate:

- complete typed state machine;
- human Journey topology projection.

# Path topology authority

Create/retain one canonical projection from typed Coordinator states to Journey nodes.

Do not make the widget hide Verify with a special case.

Conceptually:

typed states
→ human Journey topology
→ renderer.

This will allow future internal states without cluttering the Journey map.

# Completed-node semantics across hidden gates

If Verify is hidden:

during internal verification:
- Import may remain current or completed according to truthful semantics;
- Start remains future.

After verification succeeds:
- Import becomes completed;
- Start becomes current.

Choose the representation that avoids a misleading transient state.

Because verification may be extremely brief, this may never be perceptible, but it must remain semantically correct.

# Path labels after audit

If Verify is removed, likely topology becomes:

`Messages → History → Contacts → Ready → Import → Start`

Do not adopt this blindly.

Use audit evidence.

# Accessibility

Update Journey semantics accordingly.

VoiceOver should not announce a nonexistent human “Verify” step merely because an internal verification state exists.

If six human nodes remain, accessible Journey topology should say six.

Internal verification failure must still be announced through the actual failure presentation.

# Progress semantics

Do not treat Journey node count as a percentage.

Removing Verify must not alter operational progress.

Directed Instrumentation remains unchanged.

# Animation

A hidden gate should not cause a visual phantom transition.

Expected healthy behavior:

Import current
→ import completes
→ verification succeeds
→ Start current.

One meaningful visible transition.

# Audit whether other nodes are similarly mechanical

This is important.

Do not stop after Verify.

If another node fails the human-Episode test, report it.

However, avoid unnecessary churn.

A node may remain even if normally brief if it represents a meaningful blocker/decision under some scenario.

Example:

Contacts may normally pass instantly but still be a meaningful Episode when permission is missing.

That can justify a node.

# Tests

Add/update focused tests proving:

1. human Journey topology is a projection of Coordinator state, not identical to internal state count;

2. internal verification cannot construct Start until durable truth passes;

3. verification success advances human path from Import to Start;

4. verification failure never shows Start;

5. no artificial dwell added;

6. no fake progress added;

7. accessible node count matches human topology;

8. internal verifying state does not require a visible node if audit removes it;

9. backward prerequisite transitions remain correct;

10. modal/focus callbacks still cannot advance Journey;

11. path disappears after terminal OK as before.

# Architecture tripwires

Protect:

- internal state machine and human Journey topology are separate concepts;
- durable verification remains mandatory;
- no presentation timer can satisfy verification;
- Start requires canonical durable completion;
- Journey renderer cannot invent nodes from implementation substages.

# Manual validation

After implementation, repeat a healthy staging run.

Observe:

`Ready → Import → Start`

if Verify is removed.

Confirm this now matches both:

- actual human perception;
- architectural truth.

Also exercise/test verification failure through fixture injection and prove Start never appears.

# Documentation

Create:

`14-ONBOARDING-JOURNEY-NODE-SEMANTICS-AND-VERIFICATION-GATE-IMPLEMENTATION.md`

Document:

- seven-node audit;
- human Episode criteria;
- final topology;
- Verify decision;
- internal verification semantics;
- failure projection;
- accessibility topology;
- any other nodes retained despite normally brief duration and why.

Update canonical Onboarding/Journey/Presence docs.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules if code changes.

# Verification

Run:

- Journey Coordinator tests;
- Journey path tests;
- durable readiness tests;
- verification-failure tests;
- accessibility tests;
- Presence tests;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP if:

- `Verify` actually contains a human-significant long-running operation not observed in the manual run;
- hiding Verify would make failure presentation ambiguous;
- Start can currently become constructible before durable verification;
- human topology cannot be separated cleanly from internal Coordinator state without architectural redesign.

Do not paper over such findings with animation.

# Final report

Report:

- audit decision for each original node;
- final human Journey topology;
- exact Verify duration/work;
- whether Verify remains an internal Coordinator state;
- Start construction predicate;
- verification-failure behavior;
- accessibility changes;
- tests/verification;
- commit hash;
- manual review instructions.

Acceptance standard:

> The balls and sticks should represent the human Journey, not an implementation trace. Every visible node should mean something worth knowing. Internal gates may remain absolutely mandatory while staying invisible; the Journey should advance only when those gates prove that the next human Episode is true.