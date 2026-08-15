This one is earned by the production validation: it corrects an **observed P1 misdirection**, not a hypothetical edge case. The key constraint is that we must distinguish source failure from FDA failure using evidence the specialist can actually prove; if macOS/SQLite does not give us enough evidence for some subtype, Codex must not guess.

### 55 — Truthful Messages-Source vs FDA Readiness Correction

Implement the single bounded production-readiness correction identified by:

- `54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md`
- current canonical Onboarding Gate documentation
- current production Onboarding Schedule/composition
- current Messages source-readiness/FDA specialist code
- current FDA guidance presentation
- attachment-preservation invariant

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

Create:

`55-TRUTHFUL-MESSAGES-SOURCE-VS-FDA-READINESS-IMPLEMENTATION.md`

Continue using the `50-` document-number series.

## Purpose

End-to-end production validation found one remaining P1 truthfulness defect:

> A missing, invalid, or otherwise unreadable Messages source can currently collapse to the same Boolean result as an FDA/access denial and route the human into Full Disk Access remediation even when FDA is not the actual problem.

It also found one related P2 copy defect:

> Production-facing FDA guidance currently refers to **MessageLens Development** rather than the product **MessageLens**.

Correct these two related truthfulness problems and nothing broader.

---

# 1. Preserve the validated production wiring

The production route fixed during Validation 54 must remain:

```text id="8jgyza"
normal debug / production-shaped launch
    -> production router
    -> app shell
    -> OnboardingGate
    -> actual authored Onboarding Schedule
    -> real Onboarding Agents
    -> PresenceScheduler / PresenceRunner
```

The Presence laboratory harness remains explicitly opt-in through:

```bash id="bkr981"
flutter run -d macos \
  --dart-define=PRESENCE_DEVELOPMENT_HARNESS=true
```

Do not undo, bypass, or otherwise alter this distinction.

**The Gate must continue to point to the actual onboarding flow, not the Presence development harness.**

---

# 2. Start with the actual source probe

Before changing the workflow, inspect the current Messages source-read probe and establish exactly what evidence is available when it fails.

Trace at minimum:

```text id="l48a44"
production Messages readiness TestAgent
    -> source specialist / probe reader
    -> chat.db open
    -> query
    -> success / exception
    -> Boolean returned to Presence
```

Inventory the concrete failure evidence currently available for situations such as:

```text id="a5onjn"
source path absent
filesystem access denied
SQLite open denied
file is not a SQLite database
expected Messages schema/table absent
database unreadable for another I/O reason
query succeeds
```

Do not assume these are all reliably distinguishable.

Document which distinctions are **proved by current error signals** and which are not.

---

# 3. Hard truthfulness rule

The production flow may show FDA remediation only when the evidence reasonably supports:

```text id="h2gcgt"
Messages source access is being blocked by macOS privacy/access control
```

It must not say:

```text id="2z8wew"
Give MessageLens Full Disk Access
```

merely because:

```text id="gfj33d"
some attempt to inspect chat.db returned false
```

Likewise, do not claim:

```text id="xksnvl"
your Messages database is missing
your Messages database is corrupt
your Messages database is invalid
```

unless the specialist can actually establish that fact.

When evidence is less specific, use a less specific but truthful source-unavailable/readability outcome.

---

# 4. Keep source diagnosis in the specialist

Presence must not learn filesystem, SQLite, TCC, FDA, or Messages-domain semantics.

The ownership should remain conceptually:

```text id="nerdfq"
Messages / Onboarding specialist
    knows how to inspect the Messages source
    interprets concrete platform/database evidence

Onboarding authored workflow
    maps specialist facts to human journeys

Presence
    executes generic TestSteps / routes
    remains domain-blind
```

Do not add:

```text id="jd9ch8"
SourceReadinessStep
PermissionStep
DatabaseProblemStep
FDAResult
```

to Presence.

Do not change generic TestStep semantics.

---

# 5. A small specialist-owned classification is allowed if earned

If current source evidence supports it, introduce the smallest specialist-owned result needed to stop collapsing unlike facts.

A shape conceptually like:

```text id="gvictz"
MessagesSourceAccessResult
    readable
    accessDenied
    unavailable
```

may be sufficient.

If code-grounded evidence genuinely supports useful distinctions such as:

```text id="8gkwum"
missing
invalid
```

they may exist internally, but do **not** create a rich taxonomy simply because SQLite exposes many error codes.

The human contract is more important than diagnostic completeness.

The minimum product distinction is:

```text id="bychiv"
FDA / access remediation is warranted

versus

Messages source cannot currently be used for another reason
```

Use the smallest representation that establishes that distinction.

---

# 6. Do not guess at ambiguous failures

This is a hard stop condition.

If current macOS/filesystem/SQLite behavior cannot reliably distinguish:

```text id="s59ttq"
access denied
```

from:

```text id="7cjzs7"
other unreadability
```

for a relevant production case, **do not manufacture a heuristic merely to complete this slice**.

Instead:

1. document the exact ambiguous signals;
2. identify what distinction can still be made safely;
3. implement only the truthful bounded distinction if useful;
4. if FDA-specific remediation cannot be made reliable, stop and report the blocker before changing production routing.

False specificity is worse than generic truthful guidance.

---

# 7. Preserve the generic Presence Boolean boundary

If the authored onboarding topology requires more than one generic TestAgent to project the specialist classification into Boolean routing, that is acceptable.

For example, the architecture may become conceptually:

```text id="4r5u5y"
specialist source probe
        ↓
bounded source-access fact
        ↓
Onboarding-owned TestAgent(s)
        ↓
generic bool results
        ↓
generic Presence TestSteps
```

Presence should still see only:

```text id="6fwxu3"
opaque TestAgentId
Future<bool>
configured Trip destinations
```

Do not teach Presence about the richer specialist result.

Do not add multi-way TestStep routing.

---

# 8. Avoid repeated contradictory probing

If multiple Boolean TestAgents project from one richer specialist fact, inspect whether naïvely re-running the source probe for each Step could produce contradictory results or needless source access.

Use existing provider/repository conventions if a single current evaluation can safely underpin the authored decision.

However:

- do not add durable source-readiness state;
- do not cache readiness indefinitely;
- preserve the existing requirement that **Re-check** performs a fresh evaluation;
- do not create a new workflow-state store.

Freshness remains important.

---

# 9. Correct the production human journeys

The resulting authored production flow must distinguish at least these proven journeys.

## A. Healthy Messages source

```text id="ehs6oh"
source can perform the required protected read
-> continue ordinary onboarding
```

No FDA guidance.

No source-error guidance.

---

## B. FDA/access denial

When evidence supports a macOS privacy/access denial:

```text id="jmnf26"
source access blocked
-> existing FDA remediation journey
```

The human should understand that MessageLens needs permission to read Messages.

Preserve the existing settings-opening specialist exception and the existing re-check behavior unless a narrowly necessary routing adjustment is required.

---

## C. Missing/invalid/unusable Messages source

When the specialist proves—or can only truthfully conclude—that the source is unavailable for a reason other than FDA:

```text id="u0pp3o"
do NOT route into FDA remediation
```

Provide a calm source-specific human surface that communicates only what is known.

Conceptually:

```text id="m1n12z"
MessageLens can't use your Messages data

MessageLens couldn't read the Messages database it needs for setup.
```

The exact final copy should be derived from the evidence available.

Do not tell the person to change FDA settings when FDA is not the established problem.

Do not expose:

- SQLite error codes;
- `chat.db`;
- schema/table names;
- filesystem paths;
- stack traces.

---

# 10. Determine the supported human action for non-FDA source failure

Inspect the actual product mechanics before choosing an action.

Possible actions may include an existing:

```text id="91sfnn"
Re-check
```

if a later source/environment change can resolve the problem.

Do not invent:

- Choose Database;
- Repair Database;
- Reset Messages;
- Rebuild Source;
- Continue Anyway;

unless the product already genuinely supports such an operation.

If the only supported action is re-evaluation, keep it simple.

The human should never be offered an action MessageLens cannot perform.

---

# 11. Correct “MessageLens Development” leakage

Search production-facing FDA/onboarding copy for:

```text id="0a3i99"
MessageLens Development
```

Determine exactly where this is visible to ordinary production onboarding.

Replace production product language with:

```text id="zr410y"
MessageLens
```

where appropriate.

Do not blindly replace development-only identifiers in:

- bundle configuration;
- development harness labels;
- diagnostics;
- build products;
- test fixture names;
- instructions that are intentionally specific to developers.

The correction concerns **production human-facing copy**.

---

# 12. Development builds must remain testable

Be aware that the debug application may actually appear to macOS as:

```text id="ywwjgx"
MessageLens Development
```

while production product copy should say:

```text id="vaoqby"
MessageLens
```

Do not contort production wording around the development build name.

If developers need an exact debug-specific FDA note, keep that in development diagnostics/instructions—not in ordinary onboarding.

Document this distinction.

---

# 13. Preserve the FDA factual test

Do not regress to inferring FDA merely from a preference toggle or static OS setting if current architecture deliberately tests ability to perform the real protected Messages read.

The useful principle remains:

```text id="oz823h"
Can MessageLens actually perform the protected operation?
```

rather than:

```text id="9yh1se"
Does some setting appear enabled?
```

The correction is about interpreting **why the protected operation failed** sufficiently to avoid false remediation.

Do not replace the real read probe with a weaker permission guess.

---

# 14. Preserve Messages-history sufficiency

Do not alter:

```text id="10o3qw"
onboarding.messages-source-history-sufficient
COUNT(*) FROM message
0–10 -> sparse
11+ -> sufficient
```

or its current production behavior.

That test runs only after the source-readiness prerequisite has been satisfied.

Do not conflate:

```text id="yhmnhm"
source readable?
```

with:

```text id="a5nyp7"
source contains sufficient history?
```

They remain different human questions.

---

# 15. Preserve sparse-history ChoiceStep

Do not change:

```text id="ivcpxf"
Re-check
Import Anyway
```

or ChoiceStep architecture.

The P1 source-readiness defect occurs earlier.

If source readiness is restored, the existing history-sufficiency journey should proceed unchanged.

---

# 16. Preserve accepted-readiness semantics

Do not modify the durable accepted-readiness handoff for:

```text id="bi1xt8"
Import Anyway
```

A non-FDA source failure must not be mistaken for sparse-history acceptance.

The human cannot “Import Anyway” when MessageLens cannot actually use the source.

---

# 17. Preserve Gate ownership

Do not make `OnboardingGate` diagnose Messages database failures.

The Gate remains responsible for:

```text id="hw303z"
operational admission
bootstrap/recovery coordination
environment gating
```

Source diagnosis belongs with the Messages/Onboarding specialist and authored onboarding flow.

The Gate must continue to point to the real production onboarding flow.

---

# 18. Preserve reset and attachment safety

This slice occurs before import/reset work should be admitted based on a valid source journey.

Do not change:

- `MessageDataResetService`;
- reset allow-lists;
- mutation coordination;
- automatic recovery;
- attachment archival;
- archived attachment payloads;
- source attachment handling.

In particular:

```text id="0yirji"
source unavailable
```

must not trigger destructive cleanup merely to discover whether the source becomes usable.

Attachment-preservation invariants remain unchanged.

---

# 19. Preserve stable failure/recovery work

Do not reopen:

- stable setup-failure presentation;
- `preparationFailed`;
- automatic-recovery presentation;
- mutation-busy deferral;
- Audit 53 user-command contention;
- proposed Slice 54 busy snackbar.

Those are unrelated to this observed source-readiness defect.

---

# 20. Required focused tests — source classification

Add deterministic specialist tests using the smallest available seams.

At minimum cover the error conditions the implementation claims to distinguish.

### Healthy source

```text id="52hly3"
required Messages query succeeds
-> readable/healthy result
```

### Access-denied source

Provide the concrete platform/database error used by production classification.

Prove:

```text id="qk4rrh"
-> FDA/access-remediation classification
```

### Missing source

If reliably distinguishable:

```text id="qupba1"
source absent
-> non-FDA source-unavailable classification
```

### Invalid source/schema

If reliably distinguishable:

```text id="46sz1j"
file present/readable but not usable as expected Messages source
-> non-FDA source-unavailable classification
```

### Other unreadable error

Prove it does not silently become FDA unless the evidence actually establishes access denial.

If the chosen production model intentionally merges several non-FDA cases into one bounded `unavailable`, test that explicitly.

---

# 21. Required authored-workflow tests

Prove the production onboarding Schedule/routes now yield:

```text id="tnu94g"
healthy source
-> continue

access denial
-> FDA guidance

non-FDA unavailable source
-> source-unavailable guidance
```

Do not test only the specialist result.

Prove the actual authored onboarding topology sends the human to the correct Trip.

Presence itself should remain mechanically ignorant of what the branches mean.

---

# 22. FDA guidance tests

Prove production-facing FDA guidance:

- says **MessageLens**;
- does not say **MessageLens Development**;
- still exposes the supported settings/re-check actions;
- still behaves correctly when access is subsequently restored.

If development-only material intentionally contains **MessageLens Development**, exclude it from the production-copy assertion.

---

# 23. Non-FDA source-failure presentation tests

Prove the human is **not** shown:

```text id="0sodnx"
Full Disk Access
Privacy & Security remediation
Open FDA Settings
```

when the specialist says the source is unavailable for a non-FDA reason.

Prove the source-specific message/action is shown instead.

Keep the ordinary reading order minimal.

No raw error.

No Environment Summary unless current architecture genuinely requires it here and Validation 54 found it useful.

---

# 24. Re-check freshness

Where either FDA or source-unavailable UI offers an existing re-check operation, prove that re-check obtains **fresh source truth**.

Example:

```text id="ai40et"
first evaluation
    -> unavailable

underlying fixture changes

Re-check
    -> healthy
    -> onboarding proceeds
```

Do not allow a stale classification cache to trap the human in the wrong guidance.

---

# 25. End-to-end production composition test

Add/retain a focused production-composition test proving:

```text id="ydjm1p"
normal production-shaped launch
-> real Onboarding host
-> authored Schedule
-> real source agents
```

and not the Presence development harness.

Do not expand the harness work; simply protect Validation 54's corrected boundary.

---

# 26. Manual validation instructions

At the end of implementation, identify the smallest manual visual checks needed in the outstanding production-onboarding visual pass.

At minimum recommend observing:

1. FDA denied → correct FDA guidance;
2. FDA restored → successful continuation;
3. safely substituted missing/unusable Messages source → **not** FDA guidance;
4. production-facing text says **MessageLens**, not **MessageLens Development**.

Do not use the production archive to manufacture missing/corrupt source conditions.

Use development substitutions or disposable fixtures.

Do not claim these manual checks were performed unless they actually were.

---

# 27. Documentation

Create:

`55-TRUTHFUL-MESSAGES-SOURCE-VS-FDA-READINESS-IMPLEMENTATION.md`

Record:

1. observed Validation 54 defect;
2. previous Boolean collapse;
3. concrete source error evidence inspected;
4. distinctions that are reliably knowable;
5. distinctions deliberately **not** claimed;
6. final specialist result/API, if one was introduced;
7. projection into generic Presence TestAgents;
8. authored workflow topology change;
9. final FDA journey;
10. final non-FDA source-unavailable journey;
11. production **MessageLens** naming correction;
12. re-check freshness;
13. Gate/harness production boundary preserved;
14. reset/attachment behavior unchanged;
15. tests;
16. manual visual checks still outstanding;
17. deviations from Validation 54 recommendation.

Update:

- package `00-START-HERE.md`
- Feature Addition `INDEX.md`
- `DOCUMENTATION_PASS_LOG.md`
- canonical Onboarding/source-readiness documentation as appropriate
- changelog/version according to current project convention.

---

# 28. Verification

Run:

- focused Messages-source specialist tests;
- authored onboarding Schedule/Agent tests;
- FDA presentation tests;
- source-unavailable presentation tests;
- re-check tests;
- production composition/router tests;
- OnboardingGate tests;
- complete Onboarding suite;
- architecture tripwires;
- full test suite if practical;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against or mutate the production archive.

---

# Hard constraints

Do not:

- add new Presence grammar;
- teach Presence about FDA or Messages;
- reduce the real protected-read probe to a settings-toggle guess;
- route every source-read error to FDA;
- guess at error causes the platform does not prove;
- create a large source-error taxonomy;
- alter Messages-history thresholds;
- change ChoiceStep;
- change Import Anyway acceptance;
- change reset;
- change mutation coordination;
- change automatic recovery;
- implement Audit 53;
- alter attachment archival;
- use the production archive for destructive testing;
- route the Gate back to the Presence harness.

If reliable FDA-vs-other-source classification cannot be obtained from the current concrete platform/database evidence, stop and report that exact blocker rather than shipping another confidently wrong remediation path.

# Success criterion

The production prerequisite journey should become:

```text id="2lat5j"
Can MessageLens use the real Messages source?
             |
       +-----+-----+
       |           |
      yes          no
       |            |
       v            v
continue       what does the
onboarding     evidence support?
                    |
              +-----+------+
              |            |
        access/FDA       other source
          problem          problem
              |            |
              v            v
        truthful FDA   truthful source-
          guidance     unavailable guidance
```

The important human invariant is:

> **MessageLens should never send someone to Full Disk Access settings merely because “the Messages source test returned false.”**

And after this bounded correction, return to the outstanding **manual visual end-to-end onboarding pass** rather than searching for another theoretical state-machine edge case.
