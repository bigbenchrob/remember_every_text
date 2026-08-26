---
tier: project
scope: onboarding
owner: essentials-onboarding
last_reviewed: 2026-08-26
source_of_truth: feature-implementation-record
---

# Onboarding Journey Node Semantics And Verification Gate

## Decision

The human Onboarding path is:

```text
Messages -> History -> Contacts -> Ready -> Import -> Start
```

`OnboardingVerifyingDurableReadiness` remains a typed internal Coordinator
state and a mandatory completion gate. It is not a distinct human Episode and
therefore has no ball, label, accessibility step, artificial dwell, spinner,
or progress claim.

This separates two truthful models:

```text
complete typed Coordinator state machine
        -> human-meaningful Journey topology
        -> Journey path renderer
```

The renderer does not hide an otherwise canonical node. The canonical
projection itself maps internal durable verification to the human Import node.

## Seven-Node Audit

| Original node | Human meaning | Human action | Entry authority | Completion authority | Typical duration | Distinct presentation | Decision |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Messages | Establish access to protected local Messages history | Grant FDA or re-check after changing access | Coherent evidence reports missing protected-source access | A fresh source-readability observation | Human-paced; indefinite while blocked | FDA guidance and remediation | Retain |
| History | Understand and accept that import can cover only history currently stored on this Mac | Accept observed local history when evidence is sparse | Coherent evidence reports sparse or potentially incomplete local history | Sufficient fresh evidence or explicit acceptance in this Episode | Human-paced when shown | Count/range explanation and acceptance | Retain |
| Contacts | Establish the currently mandatory local Contacts dependency | Resolve source access/availability when blocked | Coherent evidence reports the Contacts source unavailable | Fresh evidence proves the source readable | Usually automatic; indefinite when blocked | Contacts-specific blocker and guidance | Retain while the pipeline requires Contacts |
| Ready | Confirm prerequisites and authorize consequential import | Select **Import My Messages** | One evidence revision satisfies all prerequisites | Explicit import authorization accepted in this state | Human-paced | Source count, readiness receipt, and primary action | Retain |
| Import | Understand and follow the long-running local copy and graph build | Wait; use typed retry/recovery only after failure | Mutation admission and operation start | Source import, graph construction, and mandatory durable verification all succeed | About 49 seconds in the recorded production-shaped run | Narrator plus factual Directed Instrumentation | Retain |
| Verify | No additional human obligation or useful decision | None | Import/build work returns successfully | Two canonical derived-store probes produce a positive durable proof | 18 ms in the recorded production-shaped run; 6.8-29.0 ms across five current exact-verifier samples | No distinct useful presentation | Remove from human topology; retain internally |
| Start | Acknowledge that a usable local MessageLens installation now exists | Select terminal **OK** | Durable completion proof has been recorded | Human acknowledgement releases first-run ownership | Human-paced | Completion receipt and handoff action | Retain |

Contacts remains because it has a distinct blocker and completion predicate
under the current unconditional import dependency. Making Contacts optional is
not part of this slice.

## Verification Work And Timing

The canonical verifier:

1. resolves `macos_import_ss.db` and `working_ss.db` inside the admitted archive;
2. opens each through the canonical read-only probe reader;
3. reads `COUNT(*)` from each `messages` table;
4. proves both files exist, are readable, and have positive message counts;
5. returns `OnboardingInstallationReadyProof` with the two counts and UTC
   verification time;
6. allows the operation controller to record durable completion.

The existing production-shaped profile measured this gate at approximately
18 ms after a 137,360-message import. A direct five-run measurement through the
exact production verifier against the current 137,426-row development stores
measured 28.960 ms cold, then 7.090, 7.025, 8.206, and 6.844 ms. These are
observations, not timeout or performance policy.

The work is mandatory but naturally imperceptible. Adding presentation time
would make elapsed time, rather than proof, appear to authorize progression.

## Gate Semantics

During `OnboardingVerifyingDurableReadiness`:

- the internal state machine truthfully records verification;
- the human Journey path remains on Import;
- Start remains future and cannot be constructed;
- no presentation timer can satisfy the gate.

After successful proof:

- the operation snapshot records completion;
- the Coordinator publishes `OnboardingReadyToStart`;
- Import becomes completed;
- Start becomes current.

If verification throws or cannot prove positive durable stores:

- operation completion is not recorded;
- the Coordinator publishes `OnboardingOperationFailed`;
- the human path remains on Import;
- Start remains future;
- the existing typed retry/recovery presentation owns the failure.

The existence of Start is therefore the human-visible receipt that durable
verification succeeded.

## Accessibility And Motion

VoiceOver now receives six human nodes. During internal verification it
announces Import as current and does not announce a nonexistent Verify step.
Verification failure is communicated by the typed failure surface.

The existing 180 ms path transition remains presentation-only and honors
reduced motion. No delay, timer, fake progress, or minimum visible duration was
added.

## Protected Invariants

- The typed Coordinator state machine and human Journey topology are separate.
- The path derives only from `OnboardingJourneyState`.
- Durable verification remains mandatory before Start.
- A renderer cannot invent nodes from operation substages.
- Modal, focus, animation, and provider callbacks cannot advance the Journey.
- Backward prerequisite movement remains truthful.
- Terminal OK still removes the path before normal navigation is released.

## Verification Coverage

Focused coverage proves:

- all first-run typed states project onto the six-node human topology;
- internal verification maps to Import, with Start future;
- successful proof alone advances the path to Start;
- failed verification remains on Import and never makes Start current;
- accessibility omits Verify;
- no path dwell or timer was introduced;
- prerequisite regression, reduced motion, terminal disappearance, and
  coordinator-only projection remain intact.

Final verification on 2026-08-26:

- focused Onboarding, durable-readiness, Journey-path, and architecture
  coverage: 425 tests passed;
- complete Flutter test suite: 2,105 tests passed;
- `flutter analyze`: no issues found;
- debug macOS build: succeeded at
  `build/macos/Build/Products/Debug/MessageLens Development.app`;
- formatting and `git diff --check`: clean.

The manual acceptance path remains: run a healthy first-run or Start Fresh
flow and observe `Ready -> Import -> Start`, with no transient Verify node.
The mandatory verification-success and verification-failure transitions are
covered mechanically without manufacturing a visible dwell.
